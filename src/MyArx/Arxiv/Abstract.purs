module MyArx.Arxiv.Abstract where

import Prelude
import Effect
import Effect.Console
import Effect.Aff

import Web.DOM.Document (Document, createElement)
import Web.DOM.Document as Document
import Web.DOM.ParentNode
import Web.DOM.Element
import Web.DOM.Node
import Web.DOM.NodeList
import Web.HTML.HTMLDocument (HTMLDocument, toDocument)
import Web.HTML.HTMLDocument as HTML

import Data.Tuple
import Data.Tuple.Nested
import Data.Either
import Data.Maybe
import Effect.Class (liftEffect)
import Control.Monad
import Control.Monad.Except.Trans (runExceptT)

import MyArx.Arxiv (currentId)
import MyArx.Arxiv.Types
import MyArx.Arxiv.Queries

abstractRewriter
  :: HTMLDocument
  -> Metadata
  -> Effect Unit
abstractRewriter doc md = do
  setTitle doc md.ex.title md.url.pageType
  addAllLinks (toDocument doc) md.url.arxivId md.ex

setTitle :: HTMLDocument -> Title -> PageType -> Effect Unit
setTitle doc title typ
  = HTML.setTitle (show title <> " | " <> show typ) doc

addAllLinks
  :: Document
  -> ArxivId
  -> ExportMetadata
  -> Effect Unit
addAllLinks doc aid md
  = querySelector
    (QuerySelector ".full-text > ul")
    (Document.toParentNode doc)
   >>= case _ of
    Nothing ->
      log "Error: Items selected by '.full-text > ul' not found"
    Just ul -> do
      let addLink = appendOne ul
      makeListItemWithCallback doc
        ("https://arxiv.org/pdf/" <> show aid <> ".pdf?download")
        "Direct Download"
        (\el -> do
          setAttribute "download" (filename md) el
          setAttribute "type" "application/pdf" el
        ) >>= addLink
      makeListItem doc
        ("https://arxiv.org/pdf/" <> show aid <> ".pdf?viewer")
        "Viewer"
        >>= addLink
      makeListItem doc
        ("https://arxiv.org/pdf/" <> show aid <> ".pdf?abstract")
        "Abstract Redirect"
        >>= addLink
      makeListItem doc
        ("https://www.arxiv-vanity.com/papers/" <> show aid)
        "Arxiv-Vanity"
        >>= addLink


appendOne :: Element -> Node -> Effect Unit
appendOne ul li = do
  void $ appendChild li (toNode ul)
  linkname <- textContent li
  log $ "Added " <> linkname <> " to links"


makeListItem
  :: Document
  -> URL
  -> String
  -> Effect Node
makeListItem doc url text =
  makeListItemWithCallback doc url text (const $ pure unit)

makeListItemWithCallback
  :: Document
  -> URL
  -> String
  -> (Element -> Effect Unit)
  -> Effect Node
makeListItemWithCallback doc url text cb = do
  li <- toNode <$> createElement "li" doc
  a <- createElement "a" doc
  setAttribute "href" url a
  setTextContent text (toNode a)
  cb a
  void $ appendChild (toNode a) li
  pure li

