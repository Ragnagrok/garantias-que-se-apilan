{-# LANGUAGE DataKinds, KindSignatures, TypeFamilies, Safe #-}
-- | A single layer: confidentiality.
module Labels
  ( Level (..), Join, Labeled
  , label, flatten, combine
  , readKey, readRequest, publish
  ) where

data Level = Public | Secret

-- The lattice join: the smallest level above both.
type family Join (a :: Level) (b :: Level) :: Level where
  Join Public b = b
  Join Secret b = Secret

-- The constructor isn't exported: from outside, nobody opens the box.
newtype Labeled (l :: Level) a = Labeled a

instance Functor (Labeled l) where
  fmap f (Labeled x) = Labeled (f x)

label :: a -> Labeled l a
label = Labeled

-- The monad's join uses the lattice's join.
flatten :: Labeled a (Labeled b x) -> Labeled (Join a b) x
flatten (Labeled (Labeled x)) = Labeled x

-- Not a primitive: it falls out of fmap and flatten.
combine :: Labeled a x -> Labeled b y -> Labeled (Join a b) (x, y)
combine lx ly = flatten (fmap (\x -> fmap (\y -> (x, y)) ly) lx)

-- What comes in from the world arrives already labeled...
readKey :: IO (Labeled Secret String)
readKey = Labeled <$> readFile ".env"

readRequest :: IO (Labeled Public String)
readRequest = Labeled <$> getLine

-- ...and the only way out demands the lowest level.
publish :: Labeled Public String -> IO ()
publish (Labeled s) = putStrLn s
