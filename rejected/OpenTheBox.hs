{-# LANGUAGE DataKinds, Safe #-}
-- Open the box by hand to get the secret out: the constructor isn't exported.
-- expects: Illegal term-level use of the type constructor ‘Labeled’
module OpenTheBox where

import Labels

leak :: Labeled Secret String -> IO ()
leak (Labeled s) = putStrLn s
