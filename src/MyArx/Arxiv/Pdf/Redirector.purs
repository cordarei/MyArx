module MyArx.Arxiv.Pdf.Redirector where

import Prelude
import Effect
import Effect.Console
import Effect.Uncurried
import Foreign
import Control.Monad
import Data.Array.NonEmpty
import Data.Either
import Data.String.Pattern
import Data.Maybe

import MyArx.Arxiv.Types
import MyArx.Arxiv.UrlParser
import MyArx.Foreign


redirectAll :: Effect Unit
redirectAll = do
  redirectToPdfViewer
  redirectToAbstract

pdfviewerTarget = "pdfviewer.html?target="
absRedirectPattern = Pattern "*://arxiv.org/pdf/*.pdf"
viewerRedirectPattern = Pattern "*://arxiv.org/pdf/*.pdf?viewer"

-- Redirect viewer requests to custom PDF page.
redirectToPdfViewer :: Effect Unit
redirectToPdfViewer
  = redirector viewerRedirectPattern (pdfURL >>> append pdfviewerTarget >>> runEffectFn1 getUrlImpl)

-- Redirect pdfs to abstract
redirectToAbstract :: Effect Unit
redirectToAbstract
  = redirector absRedirectPattern (absURL >>> pure)

redirector :: Pattern -> (ArxivId -> Effect String) -> Effect Unit
redirector pattern mkurl = listenBeforeRequests pattern redirect
  where
    redirect :: Details -> Effect {redirectUrl::String}
    redirect details = do
      runMyArxParser arxivUrl details.url >>= case _ of
        Left err -> log err *> pure {redirectUrl:""}
        Right md -> do
          url' <- mkurl md.arxivId
          log $ "Redirecting: " <> details.url <> " to " <> url'
          pure $ { redirectUrl : url' }


