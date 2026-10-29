{-# LANGUAGE DataKinds, Safe #-}
-- Prompt injection: execute a command built from an email.
-- expects: Couldn't match type ‘Untrusted’ with ‘Trusted’
module FollowEmail where

import Layers

type Planner = String -> Command

followEmail :: Planner -> IO ()
followEmail plan = do
  email <- readEmail
  execute (fmap plan email)
