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
import Data.ByteString.Builder
import Data.ByteString.Builder (byteString)
import Control.Monad.IO.Class (liftIO)
import Control.Monad.Trans.Resource (runResourceT)
import qualified Data.Conduit.Combinators as CC
import qualified Data.ByteString.Lazy as BL
import qualified Data.Text as T
import qualified Network.HTTP.Client as HC
import Data.ByteString (toStrict)

streamBody :: Network.HTTP.Conduit.Request -> (Builder -> IO ()) -> IO () -> IO ()
streamBody req send flush = runResourceT $ do

    runConduit $ httpSource req responseBody
        -- .| CC.map BL.fromStrict
        -- .| CC.map createCompletion
        -- .| CC.map (decode :: BL.ByteString -> Maybe CompletionDict)
        -- .| CC.concatMap (map BS.pack . T.unpack . content . delta . head . choices)
        -- .| CC.mapM_ (liftIO . send . byteString . getMessage)
        -- .| getMessage (decode :: BL.ByteString -> Maybe Completion)
        -- .| CC.concatMap (map content . delta)
        .| awaitForever (liftIO . send . byteString)

createCompletion :: BL.ByteString -> Maybe CompletionDict
createCompletion x = decode x :: Maybe CompletionDict

getMessage' :: Maybe CompletionDict -> BS.ByteString
getMessage' comp = do
    case comp of
        Just jsonData -> BS.pack $ T.unpack $ content $ delta $ head $ choices $ completion jsonData
        Nothing -> BS.pack "Failure "

app :: Application
app request respond = do
-- リクエストの作成
    let authorization = BS.pack $ "Bearer " ++ myApiKey
    let request = "https://api.openai.com/v1/chat/completions"
        messages = [
            Data.Aeson.object [
                "role" .= ("system" :: String),
                "content" .= ("What is the best album from 2023?" :: String)]
            ]
        requestBody = encode $ Data.Aeson.object [
            "model" .= ("gpt-3.5-turbo" :: String),
            "messages" .= messages,
            "stream" .= (True :: Bool),
            "max_tokens" .= (100 :: Int)]
        responseBody = encode $ Data.Aeson.object [
            "responseType" .= ("stream" :: String)]

        headers :: [Header]
        headers = [("Authorization", authorization), ("Content-Type", "application/json")]

    initialRequest <- liftIO $ parseRequest request
    let request' = initialRequest {
        method = "POST",
        HC.requestBody = RequestBodyLBS requestBody,
        HC.requestHeaders = headers }

    respond $ responseStream status200 [("Content-Type", "text/plain")] $ streamBody request'

main :: IO ()
main = do
    putStrLn "Starting server on http://localhost:8001"
    run 8001 app

-- APIキーの設定
myApiKey = ""