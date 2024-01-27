{-# LANGUAGE OverloadedStrings #-}

import ResponseJson
import Network.Wai
import Network.Wai.Handler.Warp (run)

import Network.HTTP.Types.Header (Header)
import Network.HTTP.Types ( status200 )
import Network.HTTP.Client.Conduit (responseOpen, responseBody)
import Network.HTTP.Simple (httpSource, parseRequest)
import Network.HTTP.Conduit
    ( parseRequest,
      Request(method),
      Response(responseBody),
      RequestBody(RequestBodyLBS) )
import Data.Aeson ( encode, decode, object, KeyValue((.=)) )
import qualified Data.ByteString.Lazy.Char8 as LazyChar8
import qualified Data.ByteString.Char8 as Char8
import Data.Conduit (runConduit, (.|), awaitForever)
import qualified Data.Conduit.List as ConduitList
import Data.ByteString.Builder (byteString, Builder)
import Control.Monad.IO.Class (liftIO)
import Control.Monad.Trans.Resource (runResourceT)
import qualified Data.Conduit.Combinators as ConduitCombinators
import qualified Data.ByteString.Lazy as Lazy
import qualified Data.Text as Text
import qualified Network.HTTP.Client as HTTPClient
import Data.ByteString (toStrict)

type ContentType = String

streamBody :: Network.HTTP.Conduit.Request -> (Builder -> IO ()) -> IO () -> IO ()
streamBody req send flush = runResourceT $ do
    runConduit $ httpSource req responseBody
        -- .| ConduitCombinators.map BL.fromStrict
        -- .| ConduitCombinators.map createCompletion
        -- .| ConduitCombinators.map (decode :: BL.ByteString -> Maybe CompletionDict)
        -- .| ConduitCombinators.concatMap (map BS.pack . T.unpack . content . delta . head . choices)
        -- .| ConduitCombinators.mapM_ (liftIO . send . byteString)
        -- .| getMessage (decode :: BL.ByteString -> Maybe Completion)
        -- .| ConduitCombinators.concatMap (map content . delta)
        .| awaitForever (liftIO . send . byteString)

-- streamingAPIRequest :: Network.HTTP.Conduit.Request -> 
--     (Network.HTTP.Conduit.Response (C.ConduitM () byteString IO ()) -> IO ResponseReceived) -> IO ResponseReceived
-- streamingAPIRequest req respond = do
--     manager <- newManager tlsManagerSettings
--     withResponse req manager $ \res -> 
--         respond $ responseStream status200 [("Content-Type", "application/json")] $ \write flush -> do
--             responseBody res C.$$+- ConduitList.mapM_ (liftIO . write . (<> "\n"))
--             liftIO flush

createCompletion :: Lazy.ByteString -> Maybe Completion
createCompletion x = decode x :: Maybe Completion

getMessage' :: Maybe Completion -> Char8.ByteString
getMessage' comp = do
    case comp of
        Just jsonData -> Char8.pack $ Text.unpack $ content $ delta $ head $ choices jsonData
        Nothing -> Char8.pack "Failure "

motherResponse request respond = do
-- リクエストの作成
    let authorization = Char8.pack $ "Bearer " ++ myApiKey
    let request = "https://api.openai.com/v1/chat/completions"
        messages = [
            Data.Aeson.object [
                "role" .= ("system" :: String),
                "content" .= ("私のお母さんになりきって答えてください。" :: String),
                "role" .= ("user" :: String),
                "content" .= ("お母さん、年金の仕組みを教えて。" :: String)]
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
        HTTPClient.requestBody = RequestBodyLBS requestBody,
        HTTPClient.requestHeaders = headers }

    respond $ responseStream status200[("Content-Type", "application/json;charset=UTF-8"), ("Access-Control-Allow-Origin", "*")] $ streamBody request'

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
    content <- LazyChar8.readFile filePath
    let response = responseLBS
            status200
            [("Content-Type", "text/html")]
            content
    respond response

-- APIキーの設定
myApiKey = "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"