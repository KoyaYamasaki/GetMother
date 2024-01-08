{-# LANGUAGE OverloadedStrings #-}

import System.Random
import Network.Wai
import Network.HTTP.Types
import Network.Wai.Handler.Warp (run)
import qualified Data.ByteString.Lazy as LBS
import qualified Data.ByteString.Char8 as C8BS
import Data.Maybe (fromMaybe)

type ContentType = String

app :: Application
app request respond = do
    case pathInfo request of
        [] -> serveResponse "index.html" "text/html" respond
        ["mother"] -> getMother request respond
        ["motherlist"] -> serveResponse "metadata/mother.json" "application/json" respond
        ["randommother"] -> getRandomMother respond
        ["randommary"] -> getRandomMary respond
        _ -> handle404 respond

serveResponse :: FilePath -> ContentType -> (Response -> IO ResponseReceived) -> IO ResponseReceived
serveResponse filePath contentType respond = do
    content <- LBS.readFile filePath
    let response = responseLBS
            status200
            [("Content-Type", "text/html")]
            content
    respond response

getMother :: Request -> (Response -> IO ResponseReceived) -> IO ResponseReceived
getMother request respond = do
    let defaultVal = Just $ C8BS.pack "1" 
    let mQueryString = fromMaybe defaultVal $ Prelude.lookup "id" $ queryString request
    let imagePath = "images/mother/mother" ++ maybeByteStringToString mQueryString ++ ".jpg"
    content <- LBS.readFile imagePath
    let response = responseLBS
            status200
            [("Content-Type", "image/jpeg"),
            ("Access-Control-Allow-Origin", "*,*")]
            content
    respond response

getRandomMother :: (Response -> IO ResponseReceived) -> IO ResponseReceived
getRandomMother respond = do
    randomNum <- randomNumber 5
    let randomImage = "images/mother/mother" ++ show randomNum ++ ".jpg"
    content <- LBS.readFile randomImage
    let response = responseLBS
            status200
            [("Content-Type", "image/jpeg"), 
            ("Access-Control-Allow-Origin", "*,*")]
            content
    respond response

getRandomMary :: (Response -> IO ResponseReceived) -> IO ResponseReceived
getRandomMary respond = do
    randomNum <- randomNumber 6
    let randomImage = "images/mary/mary" ++ show randomNum ++ ".jpg"
    content <- LBS.readFile randomImage
    let response = responseLBS
            status200
            [("Content-Type", "image/jpeg"),
            ("Access-Control-Allow-Origin", "*,*")]
            content
    respond response

handle404 :: (Response -> IO ResponseReceived) -> IO ResponseReceived
handle404 respond = do
    let response = responseLBS
            status404
            [("Content-Type", "text/html")]
            "<!DOCTYPE html><html><head><title>Not Found</title></head><body><h1>404 - Not Found</h1></body></html>"
    respond response

main :: IO ()
main = do
    putStrLn "Starting server on http://localhost:8000"
    run 8000 app

randomNumber :: Int -> IO Int
randomNumber range = randomRIO (1, range)

maybeByteStringToString :: Maybe C8BS.ByteString -> String
maybeByteStringToString maybeBS =
    case maybeBS of
        Just bs -> C8BS.unpack bs
        maybe -> "1"
