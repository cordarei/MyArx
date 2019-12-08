module Main where

import Prelude (Unit, discard, eq, flip, pure, unit, unlessM, void, when, ($), (<>), (==), (>=>), (>>=), (>>>))
import Control.Monad.Except.Trans (runExceptT)
import Data.Either (Either(..))
import Data.Maybe (Maybe(Just, Nothing))
import Data.Tuple (Tuple(Tuple))
import Effect (Effect, foreachE)
import Effect.Console (log)
import Effect.Timer (setTimeout)

import Web.DOM.Document (getElementsByTagName)
import Web.DOM.Element (Element, getAttribute, setAttribute)
import Web.DOM.HTMLCollection (toArray)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toDocument)
import Web.HTML.Location (hostname)
import Web.HTML.Window (location, document)

import ArxivUrlParser (PageType(..), absURL, runArxivParser)


main :: Effect Unit
main = do
  log "Running Arxiv abstract rewriter!"
  void $ setTimeout  500 swapArxivAnchors -- once for speedy connections
  void $ setTimeout 1500 swapArxivAnchors -- once for slow connections
  void $ setTimeout 2500 swapArxivAnchors -- ...maybe twice for extra slow connections


inArxiv :: Effect Boolean
inArxiv = window >>= (location >=> hostname >=> ((eq "arxiv.org") >>> pure))

swapArxivAnchors :: Effect Unit
swapArxivAnchors = unlessM (inArxiv) $
  window >>= document >>= toDocument >>> getElementsByTagName "a" >>= toArray >>= flip foreachE processLink
  where
    processLink :: Element -> Effect Unit
    processLink a = getAttribute "href" a >>= case _ of
      Nothing -> pure unit
      Just link -> runExceptT (runArxivParser link) >>= case _ of
        Left err -> pure unit
        Right (Tuple atype aid) -> when (atype == PDF) do
          setAttribute "href" (absURL aid) a
          log $ "rewrote " <> link <> " -> " <> absURL aid


