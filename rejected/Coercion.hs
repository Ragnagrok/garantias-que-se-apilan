{-# LANGUAGE DataKinds, Safe #-}
-- Force the type with unsafeCoerce. Under Safe Haskell, the module can't even be imported.
-- expects: Unsafe.Coerce: Can't be safely imported
module Coercion where

import Labels
import Unsafe.Coerce (unsafeCoerce)

launder :: Labeled Secret String -> IO ()
launder key = publish (unsafeCoerce key)
