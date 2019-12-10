module MyArx.Arxiv.Queries where

import Prelude (identity, bind, pure, show, ($), (<<<), (<>), (>>=), (>>>))
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Affjax (get, printError)
import Affjax.ResponseFormat
import Web.DOM.Document (Document, getElementsByTagName)
import Web.DOM.HTMLCollection (item)
import Web.DOM.HTMLCollection as HTML
import Web.DOM.Text as Text
import Web.DOM.Element (Element)
import Web.DOM.Element as Element
import Web.DOM.Node as Node
import Web.DOM.DOMParser (makeDOMParser, parseXMLFromString)
import Data.Either (Either(..), either)
import Data.Maybe (Maybe, maybe)
import Control.Monad.Except.Trans (ExceptT(..))
import Control.Monad.Error.Class (throwError)
import Control.Monad.Maybe.Trans (MaybeT(..), runMaybeT)
import Control.Monad.Trans.Class (lift)
import Data.Maybe (Maybe(..))
import Data.Array (head)
import Data.String.Common (split)
import Data.String.Pattern (Pattern(..))

import MyArx.Arxiv.Types
  (ArxivId(..), ExportMetadata, FirstAuthor(..), PublishYear(..), Title(..))


getExport :: ArxivId -> ExceptT String Aff Document
getExport (ArxivId aid) = do
  res <- ExceptT $
    get string ("https://export.arxiv.org/api/query?id_list=" <> aid)
      >>= either (pure <<< Left <<< printError) (pure <<< Right)
  ExceptT $ liftEffect (makeDOMParser >>= parseXMLFromString res.body)


getMeta :: ArxivId -> ExceptT String Aff ExportMetadata
getMeta aid = do
  doc <- getExport aid
  -- The first title is query string, second one is paper name.
  t <- extractFrom doc "title"     1 Title
  a <- extractFrom doc "name"      0 FirstAuthor
  y <- extractFromWith doc "published" 0 PublishYear (split (Pattern "-") >>> head)
  pure { title: t, firstAuthor: a, publishYear: y }


extractFrom
  :: forall a
  .  Document
  -> String
  -> Int
  -> (String -> a)
  -> ExceptT String Aff a
extractFrom xml tag ix constructor =
  extractFromWith xml tag ix constructor Just

extractFromWith
  :: forall a
  .  Document
  -> String
  -> Int
  -> (String -> a)
  -> (String -> Maybe String)
  -> ExceptT String Aff a
extractFromWith xml tag ix constructor cb = do
  els <- liftEffect (getElementsByTagName tag xml)
  mel <- liftEffect (item ix els)
  str <- innerHTML (tag <> " " <> show ix <> " tag") mel
  case cb str of
    Nothing -> throwError $ "failed to postprocess " <> tag <> " " <> show ix
    Just rt -> pure (constructor rt)


innerHTML :: String -> Maybe Element -> ExceptT String Aff String
innerHTML s mel = lift (runMaybeT action) >>= maybe
  (ExceptT $ pure $ Left (s <> " not found"))
  (ExceptT <<< pure <<< Right)
  where
    action :: MaybeT Aff String
    action
      = MaybeT (pure mel)
      >>= Element.toNode
      >>> Node.textContent
      >>> liftEffect

