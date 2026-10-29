{-# LANGUAGE DataKinds, Safe #-}
-- El paso 5 de la slide: mezclar la clave con un pedido público y publicar el resultado.
-- espera: Couldn't match type ‘Secreto’ with ‘Publico’
module Paso5 where

import Etiquetas

type Modelo = String -> String

paso5 :: Modelo -> Etiquetado Secreto String -> Etiquetado Publico String -> IO ()
paso5 modelo clave pedido =
  publicar (fmap (\(c, p) -> modelo (p ++ c)) (combinar clave pedido))
