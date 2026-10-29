{-# LANGUAGE DataKinds, Safe #-}
-- | What does compile: the model transforms public, trusted data,
-- and the result can be published or executed.
module Main (main) where

import Data.Char (toUpper)
import qualified Layers as L

type Model = String -> String

-- Any "model" at all. The types don't depend on what it does.
model :: Model
model = map toUpper

main :: IO ()
main = do
  putStrLn "Type a request:"
  request <- L.readRequest
  L.publish (fmap model request)
  L.execute (fmap (L.Command . model) request)
