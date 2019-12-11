module MyArx.PdfViewer.Main where

import Prelude
import Control.Monad.Except.Trans (runExceptT, ExceptT(..))
import Data.Either
import Data.Maybe
import Effect
import Effect.Console
import Effect.Class
import Effect.Aff
import Web.DOM.Document
import Web.DOM.Element as El
import Web.DOM.Node as Node
import Web.DOM.NonElementParentNode (getElementById)
import Web.HTML.HTMLDocument (toDocument)

import MyArx.Arxiv
import MyArx.Arxiv.Queries
import MyArx.Arxiv.Types

main :: Effect Unit
main = launchAff_ $ do
  runExceptT (ExceptT (liftEffect currentId) >>= getAllMeta) >>= case _ of
    Left err -> liftEffect $ log err
    Right md -> liftEffect do
      doc <- currentDocument
      setTitle doc md.ex.title md.url.pageType
      injectPDF (toDocument doc) md.url.arxivId

-- // Extract the pdf url from 'pdfviewer.html?target=<pdfURL>'.
-- app.extractURL = function () {
--   var url = new URL(window.location.href);
--   return url.searchParams.get("target");
-- }

-- Inject embedded PDF.
injectPDF :: Document -> ArxivId -> Effect Unit
injectPDF doc aid = do
  log $ "Injecting PDF: " <> url
  pdf <- createElement "object" doc
  El.setAttribute "type" "application/pdf" pdf
  El.setAttribute "data" url pdf
  getElementById "container" (toNonElementParentNode doc) >>= case _ of
    Nothing -> log "no container found!"
    Just ct -> void $ Node.appendChild (El.toNode pdf) (El.toNode ct)
  where
    url :: URL
    url = pdfURL aid <> "?noredirect"


