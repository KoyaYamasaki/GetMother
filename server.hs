{-# LANGUAGE OverloadedStrings #-}

import System.Random
import Network.Wai
import Network.HTTP.Types
import Network.Wai.Handler.Warp (run)
import qualified Data.ByteString.Lazy as LBS
import qualified Data.ByteString.Char8 (ByteString, unpack)

type ContentType = String

app :: Application
app request respond = do
    case pathInfo request of
        [] -> serveResponse "index.html" "text/html" respond
        -- ["mother"] -> getMother request respond
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

-- getMother :: Request -> (Response -> IO ResponseReceived) -> IO ResponseReceived
-- getMother request respond = do
--     let qs = queryString request
--     let imageId = maybe "1" BS.unpack $ join $ lookup "id" qs 
--         in responseMotherImage status200 [("Content-Type", "image/jpeg")] (LBS.pack $ "images/mother/mother" ++ imageId ++ ".jpg")
--     let imagePath = "images/mother/mother" ++ imageId ++ ".jpg"
--     content <- LBS.readFile randomImage
--     let response = responseLBS
--             status200
--             [("Content-Type", "image/jpeg")]
--             imagePath
--     respond response

getRandomMother :: (Response -> IO ResponseReceived) -> IO ResponseReceived
getRandomMother respond = do
    randomNum <- randomNumber 5
    let randomImage = "images/mother/mother" ++ show randomNum ++ ".jpg"
    content <- LBS.readFile randomImage
    let response = responseLBS
            status200
            [("Content-Type", "image/jpeg")]
            content
    respond response

getRandomMary :: (Response -> IO ResponseReceived) -> IO ResponseReceived
getRandomMary respond = do
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

-- maybeByteStringToString :: Maybe ByteString -> String
-- maybeByteStringToString maybeBS =
--     case maybeBS of
--         Just bs -> unpack bs
--         maybe -> "1"
