{-# LANGUAGE DataKinds, KindSignatures, TypeFamilies, Safe #-}
-- | Dos capas: confidencialidad (qué puede salir) e integridad (qué puede decidir).
module Capas
  ( Conf (..), Integ (..), JoinC, JoinI, Etiquetado
  , etiquetar, aplanar, combinar
  , Comando (..), leerClave, leerMail, leerPedido
  , publicar, ejecutar
  ) where

data Conf  = Publico | Secreto
data Integ = Confiable | Dudoso

type family JoinC (a :: Conf) (b :: Conf) :: Conf where
  JoinC Publico b = b
  JoinC Secreto b = Secreto

type family JoinI (a :: Integ) (b :: Integ) :: Integ where
  JoinI Confiable b = b
  JoinI Dudoso    b = Dudoso

-- El retículo de dos capas es el producto: el join se calcula coordenada por coordenada.
newtype Etiquetado (c :: Conf) (i :: Integ) a = Etiquetado a

instance Functor (Etiquetado c i) where
  fmap f (Etiquetado x) = Etiquetado (f x)

etiquetar :: a -> Etiquetado c i a
etiquetar = Etiquetado

aplanar :: Etiquetado c i (Etiquetado c' i' x)
        -> Etiquetado (JoinC c c') (JoinI i i') x
aplanar (Etiquetado (Etiquetado x)) = Etiquetado x

combinar :: Etiquetado c i x -> Etiquetado c' i' y
         -> Etiquetado (JoinC c c') (JoinI i i') (x, y)
combinar ex ey = aplanar (fmap (\x -> fmap (\y -> (x, y)) ey) ex)

newtype Comando = Comando String

leerClave :: IO (Etiquetado Secreto Confiable String)
leerClave = Etiquetado <$> readFile ".env"

-- Un mail es público, pero no se puede confiar en lo que dice.
leerMail :: IO (Etiquetado Publico Dudoso String)
leerMail = Etiquetado <$> getLine

-- El pedido del usuario es la única fuente confiable.
leerPedido :: IO (Etiquetado Publico Confiable String)
leerPedido = Etiquetado <$> getLine

publicar :: Etiquetado Publico i String -> IO ()
publicar (Etiquetado s) = putStrLn s

ejecutar :: Etiquetado c Confiable Comando -> IO ()
ejecutar (Etiquetado (Comando s)) = putStrLn ("ejecutando: " ++ s)
