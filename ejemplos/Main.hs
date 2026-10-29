{-# LANGUAGE DataKinds, Safe #-}
-- | Lo que sí compila: el modelo transforma datos públicos y confiables,
-- y el resultado puede publicarse o ejecutarse.
module Main (main) where

import Data.Char (toUpper)
import qualified Capas as C

type Modelo = String -> String

-- Un "modelo" cualquiera. El tipo no depende de lo que haga.
modelo :: Modelo
modelo = map toUpper

main :: IO ()
main = do
  putStrLn "Escribí un pedido:"
  pedido <- C.leerPedido
  C.publicar (fmap modelo pedido)
  C.ejecutar (fmap (C.Comando . modelo) pedido)
