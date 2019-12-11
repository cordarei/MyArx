module MyArx.Arxiv where

import Prelude
import Effect (Effect)
import Effect.Aff
import Effect.Class
import Effect.Console
import Data.Either (Either(..))
import Data.Tuple (Tuple)
import Data.Maybe
import Data.String
import Data.String.Regex

import Web.HTML (window)
import Web.HTML.Location (hostname, href)
import Web.HTML.Window (location, document)
import Web.HTML.HTMLDocument (HTMLDocument)
import Web.HTML.HTMLDocument as HTML
import Web.DOM.Document (Document)

import Control.Monad.Except.Trans (ExceptT(..))
import MyArx.Arxiv.UrlParser
import MyArx.Arxiv.Types

direct :: Effect MyArxState
direct = window >>= \w -> (location >=> hostname) w >>= direct' >>> pure

direct' :: String -> MyArxState
direct' hn
  | hn == "arxiv.org" = InArxiv
  | otherwise  = case (regex "[0-9A-Za-z-]{36}" (parseFlags "")) of
    Left err -> OutsideArxiv
    Right rg -> maybe OutsideArxiv (const InContainer) (match rg hn)

currentId :: Effect (Either String UrlMetadata)
currentId = window >>= \w -> do
  loc <- location w
  hostname loc >>= log
  direct' <$> hostname loc  >>= case _ of
    InContainer -> log "InContainer" *> href loc >>= runMyArxParser viewerUrl
    _           -> log "NotInContianer" *> href loc >>= runMyArxParser arxivUrl

currentIdT :: forall m . MonadEffect m => ExceptT String m UrlMetadata
currentIdT = ExceptT $ liftEffect currentId

currentDocument :: Effect HTMLDocument
currentDocument = window >>= document

setTitle :: HTMLDocument -> Title -> PageType -> Effect Unit
setTitle doc title typ
  = HTML.setTitle (show title <> " | " <> show typ) doc


