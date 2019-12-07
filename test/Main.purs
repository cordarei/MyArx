module Test.Main where

import Prelude
import Effect (Effect)
import Main (euler1)
import Test.Assert (assert)

main :: Effect Unit
main = do
  assert (euler1 == 233168)
