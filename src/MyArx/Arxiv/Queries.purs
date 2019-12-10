module MyArx.Arxiv.Queries where

import Prelude
import MyArx.Arxiv.Urls (PageType(..), ArxivId(..))
import Effect (Effect)
import Effect.Aff -- (Aff)
import Effect.Aff as Aff
import Effect.Aff.Class
import Effect.Class
import Affjax (Error, Response, get, printError)
import Affjax.ResponseFormat
import Web.DOM.Document (Document, getElementsByTagName)
import Effect.Exception (message)
import Web.DOM.HTMLCollection (item)
import Web.DOM.Text (wholeText, Text)
import Web.DOM.Text as Text
import Web.DOM.Element (Element)
import Web.DOM.Element as Element
import Data.Tuple (Tuple(..))
import Data.Tuple.Nested (Tuple3, tuple3)
import Data.Either
import Data.Maybe
import Control.Monad.Except.Trans (ExceptT(..), runExceptT)
import Control.Monad.Maybe.Trans (MaybeT(..), runMaybeT)
import Control.Monad.Trans.Class (lift)

newtype FirstAuthor = FirstAuthor String
newtype PublishYear = PublishYear String
newtype Title = Title String

getExport :: ArxivId -> ExceptT String Aff (Response Document)
getExport (ArxivId aid) = ExceptT do
  get document ("https://export.arxiv.org/api/query?id_list=" <> aid) >>= case _ of
    Left  err -> pure $ Left (printError err)
    Right res -> pure $ Right res

getMeta :: ArxivId -> ExceptT String Aff (Tuple3 Title FirstAuthor PublishYear)
getMeta aid = do
  res <- getExport aid
  t <- extractFrom res.body "title"     1 Title       -- The first title is query string, second one is paper name.
  a <- extractFrom res.body "name"      0 FirstAuthor
  y <- extractFrom res.body "published" 0 PublishYear
  pure $ tuple3 t a y

extractFrom :: forall a . Document -> String -> Int -> (String -> a) -> ExceptT String Aff a
extractFrom xml tag ix constructor = do
  els <- lift $ liftEffect (getElementsByTagName tag xml)
  mel <- lift $ liftEffect (item ix els)
  str <- innerHTML (tag <> show ix <> " tag") mel
  pure (constructor str)

innerHTML :: String -> Maybe Element -> ExceptT String Aff String
innerHTML s mel = lift (runMaybeT action) >>= maybe
  (ExceptT $ pure $ Left (s <> " not found"))
  (ExceptT <<< pure <<< Right)
  where
    action :: MaybeT Aff String
    action
      = MaybeT (pure mel)
      >>= Element.toNode >>> Text.fromNode >>> pure >>> MaybeT
      >>= wholeText >>> liftEffect


