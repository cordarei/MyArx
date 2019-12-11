module MyArx.Arxiv.UrlParserTests where

import Prelude

import Control.Monad.Error.Class
import Data.Either
import Data.Show (class Show)
import Effect
import Effect.Aff (launchAff_)
import Effect.Exception (Error)
import Text.Parsing.Parser (Parser)
import Test.Spec (pending, describe, it, Spec)
import Test.Spec.Assertions -- (shouldEqual)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (runSpec)

import MyArx.Arxiv.UrlParser

arxUrl :: String
arxUrl = "https://arxiv.org/pdf/1912.01412.pdf"

containerUrl :: String
containerUrl = "moz-extension://97205841-c952-45fe-9e07-e95b14fc0e0a/pdfviewer.html?target="

containerUrlFull :: String
containerUrlFull = containerUrl <> arxUrl

main :: Spec Unit
main =
  describe ("Parsers on moz-extension:://<extensionid>/pdfviewer.html?target=<arxiv>/pdf/<aid>.pdf") do
    describe "mozext" $ mozext `runOn` containerUrlFull
    describe "mozext *> pdfviewerWithTarget" $ (mozext *> pdfviewerWithTarget) `runOn` containerUrlFull
    describe "mozext *> pdfviewerWithTarget *> protocol" $ (mozext *> pdfviewerWithTarget *> protocol) `runOn` containerUrlFull
    describe "viewerUrl" $ (viewerUrl) `runOn` containerUrlFull
  where
    runOn :: forall x . Show x => Parser String x -> String -> Spec Unit
    runOn p s = it ("parses " <> s) $ runMyArxParser p s >>= (flip shouldSatisfy isRight)

