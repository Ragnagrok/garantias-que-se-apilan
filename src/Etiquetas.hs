{-# LANGUAGE DataKinds, KindSignatures, TypeFamilies, Safe #-}
-- | Una sola capa: confidencialidad.
module Etiquetas
  ( Nivel (..), Join, Etiquetado
  , etiquetar, aplanar, combinar
  , leerClave, leerPedido, publicar
  ) where

data Nivel = Publico | Secreto

-- El join del retículo: el más chico de los niveles que están por encima de los dos.
type family Join (a :: Nivel) (b :: Nivel) :: Nivel where
  Join Publico b = b
  Join Secreto b = Secreto

-- El constructor no se exporta: desde afuera nadie abre la caja.
newtype Etiquetado (l :: Nivel) a = Etiquetado a

instance Functor (Etiquetado l) where
  fmap f (Etiquetado x) = Etiquetado (f x)

etiquetar :: a -> Etiquetado l a
etiquetar = Etiquetado

-- El join de la mónada usa el join del retículo.
aplanar :: Etiquetado a (Etiquetado b x) -> Etiquetado (Join a b) x
aplanar (Etiquetado (Etiquetado x)) = Etiquetado x

-- No es una primitiva: sale de fmap y aplanar.
combinar :: Etiquetado a x -> Etiquetado b y -> Etiquetado (Join a b) (x, y)
combinar ex ey = aplanar (fmap (\x -> fmap (\y -> (x, y)) ey) ex)

-- Lo que entra del mundo ya viene etiquetado...
leerClave :: IO (Etiquetado Secreto String)
leerClave = Etiquetado <$> readFile ".env"

leerPedido :: IO (Etiquetado Publico String)
leerPedido = Etiquetado <$> getLine

-- ...y lo único que sale exige el nivel más bajo.
publicar :: Etiquetado Publico String -> IO ()
publicar (Etiquetado s) = putStrLn s
