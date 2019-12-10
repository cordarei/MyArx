module MyArx.Content.Main where

import Prelude -- (Unit, discard, void, (*>), ($), bind)
import Control.Bind (ifM)
import Effect (Effect)
import Effect.Console (log)
import Effect.Aff
import Effect.Class
import Effect.Timer (setTimeout)

import Data.Either
import Web.HTML.HTMLDocument (toDocument)
import Control.Monad.Except.Trans (runExceptT)

import MyArx.Arxiv -- (inArxiv, currentDocument, currentId)
import MyArx.Arxiv.Abstract (abstractRewriter)
import MyArx.Arxiv.Pdf.Redirector (pdfRedirector)
import MyArx.Arxiv.Queries (getMeta)
{-- import MyArx.Arxiv.Pdf.Viewer () --}
import MyArx.Arxiv.Pdf.LinkRewriter (swapArxivAnchors)

main :: Effect Unit
main
  = log "MyArx is running"
  *> ifM inArxiv (launchAff_ inArxivAction) outsideArxivAction
  where
    inArxivAction = runExceptT go >>= case _ of
      Left err -> liftEffect $ log err
      Right rt -> liftEffect $ abstractRewriter rt.doc rt.md
      where
        go = do
          doc <- liftEffect currentDocument
          url <- currentIdT
          ex <- getMeta url.arxivId
          pure { doc:doc, md: { url:url, ex:ex } }

    outsideArxivAction = do
      doc <- toDocument <$> currentDocument
      log "MyArx is scanning for pdf links to redirect"
      void $ setTimeout  500 (swapArxivAnchors doc) -- speedy connections
      void $ setTimeout 1500 (swapArxivAnchors doc) -- slow connections
      void $ setTimeout 2500 (swapArxivAnchors doc) -- ...also extra slow ones


