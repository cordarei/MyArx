module Main where

import Prelude
import Effect (Effect)
import Effect.Console (log)
import Data.List (filter, range, List)
import Data.Foldable (sum)

main :: Effect Unit
main = do
  log "Hello sailor!"
  log $ show $ euler1

euler1 :: Int
euler1 = sum multiples
  where
    multiples :: List Int
    multiples = filter (\n -> mod n 3 == 0 || mod n 5 == 0) (range 0 999)
