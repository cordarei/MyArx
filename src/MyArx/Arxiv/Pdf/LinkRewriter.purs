module MyArx.Arxiv.Pdf.LinkRewriter
  ( swapArxivAnchors
  ) where

import Prelude
import Effect (Effect, foreachE)
import Effect.Console (log)
import Data.Maybe (Maybe(..))
import Data.Either (Either(..))
import Data.Tuple (Tuple(..))

import Web.DOM.Document (getElementsByTagName)
import Web.DOM.Element (Element, getAttribute, setAttribute)
import Web.DOM.HTMLCollection (toArray)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toDocument)
import Web.HTML.Window (document)

import MyArx.Arxiv.Urls (runArxivParser, PageType(..), absURL)

swapArxivAnchors :: Effect Unit
swapArxivAnchors
  = window
  >>= document
  >>= toDocument >>> getElementsByTagName "a"
  >>= toArray
  >>= flip foreachE processLink

processLink :: Element -> Effect Unit
processLink a = getAttribute "href" a >>= case _ of
  Nothing -> pure unit
  Just link -> runArxivParser link >>= case _ of
    Left err -> pure unit
    Right (Tuple atype aid) -> when (atype == PDF) do
      setAttribute "href" (absURL aid) a
      log $ "rewrote " <> link <> " -> " <> absURL aid


