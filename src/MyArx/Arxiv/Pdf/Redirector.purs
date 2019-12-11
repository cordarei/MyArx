module MyArx.Arxiv.Pdf.Redirector where

import Prelude
import Effect
import Effect.Console
import Effect.Uncurried
import Data.Maybe
import Foreign
import Control.Monad
import Data.Array.NonEmpty
import Data.String.Pattern
import Data.Either

import MyArx.Arxiv.Types
import MyArx.Arxiv.UrlParser

redirectAll :: Effect Unit
redirectAll = do
  redirectToPdfViewer
  redirectToAbstract

pdfviewerTarget = "pdfviewer.html?target="
absRedirectPattern = Pattern "*://arxiv.org/pdf/*.pdf"
viewerRedirectPattern = Pattern "*://arxiv.org/pdf/*.pdf?viewer"

type Details =
  { documentUrl :: Foreign -- String
  -- ^ URL of the document in which the resource will be loaded. For example, if
  -- the web page at "https://example.com" contains an image or an iframe, then
  -- the documentUrl for the image or iframe will be "https://example.com". For
  -- a top-level document, documentUrl is undefined.
  , url :: String
  -- Target of the request
  }

foreign import listenBeforeRequestsImpl
    :: forall e . EffectFn2
        (NonEmptyArray Pattern)
        (EffectFn1 Details {redirectUrl::String})
        Unit

foreign import getUrlImpl :: EffectFn1 String String

-- Redirect viewer requests to custom PDF page.
redirectToPdfViewer :: Effect Unit
redirectToPdfViewer
  = director viewerRedirectPattern (pdfURL >>> append pdfviewerTarget >>> runEffectFn1 getUrlImpl)

-- Redirect pdfs to abstract
redirectToAbstract :: Effect Unit
redirectToAbstract
  = director absRedirectPattern (absURL >>> pure)

director :: Pattern -> (ArxivId -> Effect String) -> Effect Unit
director pattern mkurl
  = runEffectFn2
      listenBeforeRequestsImpl
      (singleton pattern)
      (mkEffectFn1 redirect)
  where
    redirect :: Details -> Effect {redirectUrl::String}
    redirect details = do
      runMyArxParser arxivUrl details.url >>= case _ of
        Left err -> log err *> pure {redirectUrl:""}
        Right md -> do
          url' <- mkurl md.arxivId
          log $ "Redirecting: " <> details.url <> " to " <> url'
          pure $ { redirectUrl : url' }


