{-# LANGUAGE OverloadedStrings #-}
module ResponseJson (
  Completion(..),
  Choice(..),
  Delta(..)
) where

import Data.Aeson
import Data.Text
import Control.Applicative
import Control.Monad
import qualified Data.ByteString.Lazy as B

import GHC.SysTools.Ar (ArchiveEntry(filename))
import Data.ByteString (ByteString)

-- 返却されるデータ型
data Completion = Completion {
  id :: Text,
  object :: Text,
  created :: Int,
  model :: Text,
  system_fingerprint :: Maybe Text,
  choices :: [Choice]
} deriving Show

instance FromJSON Completion where
  parseJSON (Object v) =
    Completion <$> v .: "id"
               <*> v .: "object"
               <*> v .: "created"
               <*> v .: "model"
               <*> v .:? "system_fingerprint"
               <*> v .: "choices"
  parseJSON _ = mzero

data Choice = Choice {
  index :: Int,
  delta :: Delta,
  logprobs :: Maybe Text,
  finish_reason :: Maybe Text
} deriving Show

instance FromJSON Choice where
  parseJSON (Object v) =
    Choice <$> v .: "index"
           <*> v .: "delta"
           <*> v .:? "logprobs"
           <*> v .:? "finish_reason"
  parseJSON _ = mzero

data Delta = Delta {
  role :: Text,
  content :: Text
} deriving Show

instance FromJSON Delta where
  parseJSON (Object v) =
    Delta <$> v .: "role"
          <*> v .: "content"
  parseJSON _ = mzero