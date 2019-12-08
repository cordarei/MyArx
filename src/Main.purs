module Main where

import Prelude
import Control.Alt
import Control.Monad (unlessM)
import Control.Monad.Maybe.Trans (runMaybeT, MaybeT(..))
import Control.Monad.Except.Trans (runExceptT, except, throwError, ExceptT(..))
import Control.Monad.Trans.Class (lift)
import Data.Maybe (Maybe(Just, Nothing))
import Data.Either -- (Either(Left, Right), note, either)
import Data.Tuple (Tuple(Tuple))
import Effect (Effect, foreachE)
import Effect.Console (log)

import Web.DOM.Document (Document, getElementsByTagName)
import Web.DOM.Element (Element, getAttribute, setAttribute)
import Web.DOM.HTMLCollection (HTMLCollection, toArray)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toDocument)
import Web.HTML.Location (hostname)
import Web.HTML.Window (location, document)
import Effect.Timer

import ArxivUrlParser

main :: Effect Unit
main = do
  log "Hello sailor!"
  currentDomain >>= log
  void $ setTimeout 2000 swapArxivAnchors

currentDomain :: Effect String
currentDomain = window >>= (location >=> hostname)

inArxiv :: String -> Boolean
inArxiv s = s == "arxiv.org"

getAnchors :: Document -> Effect HTMLCollection
getAnchors = getElementsByTagName "a"

swapArxivAnchors :: Effect Unit
swapArxivAnchors = unlessM (inArxiv <$> currentDomain) do
  log "in something not arxiv"
  window >>= document >>= toDocument >>> getAnchors >>= toArray >>= flip foreachE processLink
  where
    processLink :: Element -> Effect Unit
    processLink a = runMaybeT (getLink a) >>= case _ of
      Nothing -> pure unit
      Just link -> do
        log link
        runExceptT (rewritePDFlinks a link) >>= case _ of
          Left err ->pure unit
          Right _ -> log $ "rewrote " <> link

    getLink :: Element -> MaybeT Effect String
    getLink anchor = MaybeT $ getAttribute "href" anchor

    rewritePDFlinks :: Element -> String -> ExceptT String Effect Unit
    rewritePDFlinks a s = do
      Tuple atype aid <- runArxivParser s
      if (atype == PDF) then (lift $ setAttribute "href" (absURL aid) a) else throwError "skipped abstract link"

