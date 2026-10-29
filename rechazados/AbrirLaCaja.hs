{-# LANGUAGE DataKinds, Safe #-}
-- Abrir la caja a mano para sacar el secreto: el constructor no se exporta.
-- espera: Illegal term-level use of the type constructor ‘Etiquetado’
module AbrirLaCaja where

import Etiquetas

filtrar :: Etiquetado Secreto String -> IO ()
filtrar (Etiquetado s) = putStrLn s
