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

{-- import MyArx.Arxiv.Types --}
{-- import MyArx.Arxiv.UrlParser --}


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

getUrl :: String -> String -> Effect Unit
getUrl = runEffectFn1 getUrlImpl

listenBeforeRequests :: Pattern -> (ArxivId -> Effect String) -> Effect Unit
listenBeforeRequests pattern callback
  = runEffectFn2
      listenBeforeRequestsImpl
      (singleton pattern)
      (mkEffectFn1 callback)


