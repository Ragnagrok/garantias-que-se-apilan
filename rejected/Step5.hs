{-# LANGUAGE DataKinds, Safe #-}
-- Step 5 from the slide: mix the key with a public request and publish the result.
-- expects: Couldn't match type ‘Secret’ with ‘Public’
module Step5 where

import Labels

type Model = String -> String

step5 :: Model -> Labeled Secret String -> Labeled Public String -> IO ()
step5 model key request =
  publish (fmap (\(k, r) -> model (r ++ k)) (combine key request))
