{-# LANGUAGE OverloadedStrings #-}

import System.Random
import Network.Wai
import Network.HTTP.Types
import Network.Wai.Handler.Warp (run)
import qualified Data.ByteString.Lazy as LBS

app :: Application
app request respond = do
    case pathInfo request of
        [] -> serveHtml "index.html" respond
        ["getMother"] -> getMother respond
        ["getMary"] -> getMary respond
        _ -> handle404 respond

serveHtml :: FilePath -> (Response -> IO ResponseReceived) -> IO ResponseReceived
serveHtml filePath respond = do
    -- content <- BS.readFile filePath
    content <- LBS.readFile filePath
    let response = responseLBS
            status200
            [("Content-Type", "text/html")]
            content
    respond response

getMother :: (Response -> IO ResponseReceived) -> IO ResponseReceived
getMother respond = do
    randomNum <- randomNumber 5
    let randomImage = "images/mother/mother" ++ show randomNum ++ ".jpg"
    content <- LBS.readFile randomImage
    let response = responseLBS
            status200
            [("Content-Type", "image/jpeg")]
            content
    respond response

getMary :: (Response -> IO ResponseReceived) -> IO ResponseReceived
getMary respond = do
    randomNum <- randomNumber 6
    let randomImage = "images/mary/mary" ++ show randomNum ++ ".jpg"
    content <- LBS.readFile randomImage
    let response = responseLBS
            status200
            [("Content-Type", "image/jpeg")]
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