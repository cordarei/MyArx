module MyArx.Background.Main where

import Prelude
import Effect (Effect)
import Effect.Console (log)
import Data.Either (Either(..))

import MyArx.Arxiv
import MyArx.Arxiv.Pdf.Redirector

main :: Effect Unit
main = do
  log "MyArx is launching listeners"
  pdfRedirector


