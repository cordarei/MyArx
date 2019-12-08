module Test.Main where

import Prelude
import Data.Either (isLeft, isRight)
import Effect (Effect)
import Main (arxivParser)
import Test.Assert (assert)

import Text.Parsing.Parser (runParser)

main :: Effect Unit
main = do
  assert (isLeft $ runParser "" arxivParser)
  testArxivLink "https" "arxiv.org"
  testArxivLink "http"  "arxiv.org"
  testArxivLink "https" "www.arxiv.org"
  testArxivLink "http"  "www.arxiv.org"
  assert (isLeft $ runParser "http://arxiv.org//pdf/" arxivParser)

testArxivLink :: String -> String -> Effect Unit
testArxivLink protocol baseurl = do
  assert $ isRight $ test $ protocol <> "://" <> baseurl <> "/pdf/1912.00646.pdf"
  assert $ isRight $ test $ protocol <> "://" <> baseurl <> "/pdf/1912.00646"
  assert $ isRight $ test $ protocol <> "://" <> baseurl <> "/pdf/1912.00646.pdf?viewer"
  assert $ isRight $ test $ protocol <> "://" <> baseurl <> "/pdf/1912.00646.pdf?download"
  assert $ isRight $ test $ protocol <> "://" <> baseurl <> "/abs/1912.00646"
  assert $ isRight $ test $ protocol <> "://" <> baseurl <> "/abs/1912.00646?extrastuff"
  where
    test str = runParser str arxivParser


