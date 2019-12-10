module Main where

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
main = do
  log "MyArx is running"
  x <- direct
  log $ show x
  pdfRedirector
  case x of

    InArxiv -> launchAff_ $ runExceptT go >>= case _ of
      Left err -> liftEffect $ log err
      Right rt -> liftEffect $ abstractRewriter rt.doc rt.md

    OutsideArxiv -> do
      doc <- toDocument <$> currentDocument
      log "MyArx is scanning for pdf links to redirect"
      void $ setTimeout  500 (swapArxivAnchors doc) -- speedy connections
      void $ setTimeout 1500 (swapArxivAnchors doc) -- slow connections
      void $ setTimeout 2500 (swapArxivAnchors doc) -- ...also extra slow ones
    _ -> do
       log $ "something unexpected"

  {-- *> ifM inArxiv (launchAff_ inArxivAction) outsideArxivAction --}
  where
    go = do
      doc <- liftEffect currentDocument
      url <- currentIdT
      ex <- getMeta url.arxivId
      pure { doc:doc, md: { url:url, ex:ex } }

