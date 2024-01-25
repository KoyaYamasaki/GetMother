{-# LANGUAGE OverloadedStrings #-}

import ResponseJson
import Network.Wai
import Network.Wai.Handler.Warp (run)

import Network.HTTP.Types.Header (Header)
import Network.HTTP.Client as HC
import Network.HTTP.Types ( status200 )
import Network.HTTP.Client.Conduit (responseOpen, responseBody)
import Network.HTTP.Simple (httpSource, parseRequest)
import Network.HTTP.Conduit
import Data.Aeson
import qualified Data.ByteString.Lazy.Char8 as LBS
import qualified Data.ByteString.Char8 as BS
import Data.Conduit (runConduit, (.|))
import Data.Conduit
import qualified Data.Conduit as C
import qualified Data.Conduit.List as CL
import Data.ByteString.Builder
import Data.ByteString.Builder (byteString)
import Control.Monad.IO.Class (liftIO)
import Control.Monad.Trans.Resource (runResourceT)
import qualified Data.Conduit.Combinators as CC
import qualified Data.ByteString.Lazy as BL
import qualified Data.Text as T
import qualified Network.HTTP.Client as HC
import Data.ByteString (toStrict)

type ContentType = String

streamBody :: Network.HTTP.Conduit.Request -> (Builder -> IO ()) -> IO () -> IO ()
streamBody req send flush = runResourceT $ do
    runConduit $ httpSource req responseBody
        -- .| CC.map BL.fromStrict
        -- .| CC.map createCompletion
        -- .| CC.map (decode :: BL.ByteString -> Maybe CompletionDict)
        -- .| CC.concatMap (map BS.pack . T.unpack . content . delta . head . choices)
        -- .| CC.mapM_ (liftIO . send . byteString)
        -- .| getMessage (decode :: BL.ByteString -> Maybe Completion)
        -- .| CC.concatMap (map content . delta)
        .| awaitForever (liftIO . send . byteString)

-- streamingAPIRequest :: Network.HTTP.Conduit.Request -> 
--     (Network.HTTP.Conduit.Response (C.ConduitM () byteString IO ()) -> IO ResponseReceived) -> IO ResponseReceived
-- streamingAPIRequest req respond = do
--     manager <- newManager tlsManagerSettings
--     withResponse req manager $ \res -> 
--         respond $ responseStream status200 [("Content-Type", "application/json")] $ \write flush -> do
--             responseBody res C.$$+- CL.mapM_ (liftIO . write . (<> "\n"))
--             liftIO flush

createCompletion :: BL.ByteString -> Maybe Completion
createCompletion x = decode x :: Maybe Completion

getMessage' :: Maybe Completion -> BS.ByteString
getMessage' comp = do
    case comp of
        Just jsonData -> BS.pack $ T.unpack $ content $ delta $ head $ choices jsonData
        Nothing -> BS.pack "Failure "

motherResponse request respond = do
-- リクエストの作成
    let authorization = BS.pack $ "Bearer " ++ myApiKey
    let request = "https://api.openai.com/v1/chat/completions"
        messages = [
            Data.Aeson.object [
                "role" .= ("system" :: String),
                "content" .= ("私のお母さんになりきって答えてください。年金の仕組みを教えて。" :: String)]
            ]
        requestBody = encode $ Data.Aeson.object [
            "model" .= ("gpt-3.5-turbo" :: String),
            "messages" .= messages,
            "stream" .= (True :: Bool),
            "max_tokens" .= (600 :: Int)]

        headers :: [Header]
        headers = [("Authorization", authorization), ("Content-Type", "application/json")]

    initialRequest <- liftIO $ parseRequest request
    let request' = initialRequest {
        method = "POST",
        HC.requestBody = RequestBodyLBS requestBody,
        HC.requestHeaders = headers }

    respond $ responseStream status200 [("Content-Type", "application/json;charset=UTF-8")] $ streamBody request'

main :: IO ()
main = do
    putStrLn "Starting server on http://localhost:8001"
    run 8001 app

app :: Application
app request respond = do
    case pathInfo request of
        [] -> serveResponse "index.html" "text/html" respond
        ["motherbot"] -> motherResponse request respond

serveResponse :: FilePath -> ContentType -> (Network.Wai.Response -> IO ResponseReceived) -> IO ResponseReceived
serveResponse filePath contentType respond = do
    content <- LBS.readFile filePath
    let response = responseLBS
            status200
            [("Content-Type", "text/html")]
            content
    respond response

-- APIキーの設定
myApiKey = "XXX"