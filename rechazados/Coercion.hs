{-# LANGUAGE DataKinds, Safe #-}
-- Forzar el tipo con unsafeCoerce. Con Safe Haskell, el módulo ni siquiera se puede importar.
-- espera: Unsafe.Coerce: Can't be safely imported
module Coercion where

import Etiquetas
import Unsafe.Coerce (unsafeCoerce)

lavar :: Etiquetado Secreto String -> IO ()
lavar clave = publicar (unsafeCoerce clave)
