{-# LANGUAGE DataKinds, KindSignatures, TypeFamilies, Safe #-}
-- | Two layers: confidentiality (what may leave) and integrity (what may decide).
module Layers
  ( Conf (..), Integ (..), JoinC, JoinI, Labeled
  , label, flatten, combine
  , Command (..), readKey, readEmail, readRequest
  , publish, execute
  ) where

data Conf  = Public | Secret
data Integ = Trusted | Untrusted

type family JoinC (a :: Conf) (b :: Conf) :: Conf where
  JoinC Public b = b
  JoinC Secret b = Secret

type family JoinI (a :: Integ) (b :: Integ) :: Integ where
  JoinI Trusted   b = b
  JoinI Untrusted b = Untrusted

-- The two-layer lattice is the product: the join is computed coordinate by coordinate.
newtype Labeled (c :: Conf) (i :: Integ) a = Labeled a

instance Functor (Labeled c i) where
  fmap f (Labeled x) = Labeled (f x)

label :: a -> Labeled c i a
label = Labeled

flatten :: Labeled c i (Labeled c' i' x)
        -> Labeled (JoinC c c') (JoinI i i') x
flatten (Labeled (Labeled x)) = Labeled x

combine :: Labeled c i x -> Labeled c' i' y
        -> Labeled (JoinC c c') (JoinI i i') (x, y)
combine lx ly = flatten (fmap (\x -> fmap (\y -> (x, y)) ly) lx)

newtype Command = Command String

readKey :: IO (Labeled Secret Trusted String)
readKey = Labeled <$> readFile ".env"

-- An email is public, but what it says can't be trusted.
readEmail :: IO (Labeled Public Untrusted String)
readEmail = Labeled <$> getLine

-- The user's request is the only trusted source.
readRequest :: IO (Labeled Public Trusted String)
readRequest = Labeled <$> getLine

publish :: Labeled Public i String -> IO ()
publish (Labeled s) = putStrLn s

execute :: Labeled c Trusted Command -> IO ()
execute (Labeled (Command s)) = putStrLn ("executing: " ++ s)
