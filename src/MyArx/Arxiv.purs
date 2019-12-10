module MyArx.Arxiv where

import Prelude
import Effect (Effect)
import Effect.Aff
import Effect.Class
import Effect.Console
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

data Action
  = InArxiv
  | OutsideArxiv
  | InContainer

instance showAction :: Show Action where
  show InArxiv = "InArxiv"
  show OutsideArxiv = "OutsideArxiv"
  show InContainer = "InContainer"


inArxiv :: Effect Boolean
inArxiv = window >>= (location >=> hostname >=> ((eq "arxiv.org") >>> pure))

direct :: Effect Action
direct = window >>= \w -> do
  hn <- (location >=> hostname) w
  log hn
  pure $ if (hn == "arxiv.org")
         then InArxiv
         else if (hn == "")
           then InContainer
           else OutsideArxiv

currentId :: Effect (Either String UrlMetadata)
currentId = window >>= location >>= href >>= runArxivParser

currentIdT :: forall m . MonadEffect m => ExceptT String m UrlMetadata
currentIdT = ExceptT $ liftEffect currentId

currentDocument :: Effect HTMLDocument
currentDocument = window >>= document

