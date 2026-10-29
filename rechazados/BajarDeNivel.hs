{-# LANGUAGE DataKinds, Safe #-}
-- Bajar de nivel con aplanar: un secreto adentro de una caja pública sigue siendo secreto.
-- espera: Couldn't match type ‘Secreto’ with ‘Publico’
module BajarDeNivel where

import Etiquetas

lavar :: Etiquetado Secreto String -> IO ()
lavar clave = publicar (aplanar (etiquetar clave :: Etiquetado Publico (Etiquetado Secreto String)))
