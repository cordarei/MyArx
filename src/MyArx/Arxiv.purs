module MyArx.Arxiv where

import Prelude
import Effect (Effect)
import Effect.Aff
import Effect.Class
import Data.Either (Either)
import Data.Tuple (Tuple)

import Web.HTML (window)
import Web.HTML.Location (hostname, href)
import Web.HTML.Window (location, document)
import Web.HTML.HTMLDocument (HTMLDocument)
import Web.DOM.Document (Document)

import Control.Monad.Except.Trans (ExceptT(..))
import MyArx.Arxiv.UrlParser (runArxivParser)
import MyArx.Arxiv.Types

inArxiv :: Effect Boolean
inArxiv = window >>= (location >=> hostname >=> ((eq "arxiv.org") >>> pure))

currentId :: Effect (Either String UrlMetadata)
currentId = window >>= location >>= href >>= runArxivParser

currentIdT :: forall m . MonadEffect m => ExceptT String m UrlMetadata
currentIdT = ExceptT $ liftEffect currentId

currentDocument :: Effect HTMLDocument
currentDocument = window >>= document

