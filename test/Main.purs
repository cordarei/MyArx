module Test.Main where

import Prelude

import Effect (Effect)
import Effect.Aff (launchAff_)
import Test.Spec (pending, describe, it)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (runSpec)

import MyArx.Arxiv.UrlParserTests as UrlParserTests

main :: Effect Unit
main = launchAff_ $ runSpec [consoleReporter] do
  describe "MyArx.Arxiv.UrlParser"
    UrlParserTests.main


