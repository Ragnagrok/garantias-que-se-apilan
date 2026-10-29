{-# LANGUAGE DataKinds, Safe #-}
-- Downgrade with flatten: a secret inside a public box is still secret.
-- expects: Couldn't match type ‘Secret’ with ‘Public’
module Downgrade where

import Labels

launder :: Labeled Secret String -> IO ()
launder key = publish (flatten (label key :: Labeled Public (Labeled Secret String)))
