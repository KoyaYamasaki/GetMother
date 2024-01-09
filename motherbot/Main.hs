{-# LANGUAGE OverloadedStrings #-}
import OpenAI.Client

import Network.Wai
import Network.Wai.Handler.Warp (run)
import Network.HTTP.Types
import Network.HTTP.Client
import Network.HTTP.Client.TLS
import System.Environment (setEnv, getEnv)
import qualified Data.Text as T
import qualified Data.ByteString as LBS

request :: ChatCompletionRequest
request = ChatCompletionRequest 
        {
            chcrModel = ModelId "gpt-3.5-turbo",
            chcrMessages = 
            [ ChatMessage {
                chmContent = Just "Write a hello world program in Haskell",
                chmRole = "user",
                chmFunctionCall = Nothing,
                chmName = Nothing
            }
            ],
            chcrFunctions = Nothing,
            chcrTemperature = Nothing,
            chcrTopP = Nothing,
            chcrN = Nothing,
            chcrStream = Nothing,
            chcrStop = Nothing,
            chcrMaxTokens = Nothing,
            chcrPresencePenalty = Nothing,
            chcrFrequencyPenalty = Nothing,
            chcrLogitBias = Nothing,
            chcrUser = Nothing
        }

app :: Application
app request respond = do
    case pathInfo request of
        [] -> serveResponse "" "" respond
        -- ["mother"] -> getMother request respond
        -- ["motherlist"] -> serveResponse "metadata/mother.json" "application/json" respond
        -- ["randommother"] -> getRandomMother respond
        -- ["randommary"] -> getRandomMary respond
        -- _ -> handle404 respond


serveResponse :: FilePath -> String -> (Network.Wai.Response -> IO ResponseReceived) -> IO ResponseReceived
serveResponse filePath contentType respond = do
    setEnv "key" ""
    manager <- newManager tlsManagerSettings
    apiKey <- T.pack <$> getEnv "key"
        -- create a openai client that automatically retries up to 4 times on network
        -- errors
    let client = makeOpenAIClient apiKey manager 4
    result <- completeChat client request        
    case result of
        Left failure -> print failure
        Right success -> print $ chrChoices success
    -- let tes = "<!DOCTYPE html><html><head><title>Hello Page</title></head><body><h1>" ++ getChrObject result ++ "</h1></body></html>"
    let txt = getChrObject chatResponse
    let response = responseLBS
            status200
            [("Content-Type", "text/plain")]
            "obj"
    respond response

main :: IO ()
main = do
    putStrLn "Starting server on http://localhost:8001"
    run 8001 app

getResult :: ChatResponse -> String
getResult result =
    case result of
    Left failure -> "failure"
    Right success -> getChrObject success

getChrObject :: Either ChatResponse a -> String
getChrObject (ChatResponse _ x _ _ _) = Left T.unpack x
getChrObject _ = Right "empty"
