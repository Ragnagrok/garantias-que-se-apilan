{-# LANGUAGE DataKinds, Safe #-}
-- Inyección de instrucciones: ejecutar un comando armado a partir de un mail.
-- espera: Couldn't match type ‘Dudoso’ with ‘Confiable’
module SeguirMail where

import Capas

type Planificador = String -> Comando

seguirMail :: Planificador -> IO ()
seguirMail planificar = do
  mail <- leerMail
  ejecutar (fmap planificar mail)
