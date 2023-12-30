{-# LANGUAGE OverloadedStrings #-}
module Main where

import System.Random
import qualified Network.Wai.Handler.Warp as Warp
import qualified Network.Wai as Wai
import qualified Network.HTTP.Types as HTypes

main :: IO ()
main = Warp.run 8000 router

router :: Wai.Application
router req res =
  case Wai.pathInfo req of
    []             -> mainPage req
    ["getMother"]  -> getMother req
    _              -> notFoundApp req

mainPage :: Wai.Application
mainPage req send 
  = send $ Wai.responseFile HTypes.status200 [(HTypes.hContentType, "text/html")] "index.html" Nothing

getMother :: Wai.Application
getMother req send
  = send $ Wai.responseFile HTypes.status200 [(HTypes.hContentType, "image/jpeg")] "images/mother1.jpg" Nothing

notFoundApp :: Wai.Application
notFoundApp req send
  = send $ Wai.responseBuilder HTypes.status404 [] "not found"

-- getMotherImage :: String
-- getMotherImage =
--     "images/mother" ++ getImageNumber getStdGen ++ ".jpg"

-- getImageNumber gen = show $ take 1 $ randomRs ('1', '5') gen