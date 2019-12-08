module Main where

import Prelude
import Control.Alt
import Data.Maybe (Maybe(Just, Nothing))
import Data.Either (Either(Left, Right))
import Data.Tuple (Tuple(Tuple))
import Effect (Effect, foreachE)
import Effect.Console (log)

import Web.DOM.Document (Document, getElementsByTagName)
import Web.DOM.Element (getAttribute, setAttribute)
import Web.DOM.HTMLCollection (HTMLCollection)
import Web.HTML (window)
import Web.HTML.Window (location, document)
import Web.HTML.Location (hostname)

import Data.Array as Array
import Data.String.CodeUnits (fromCharArray, toCharArray)
import Text.Parsing.Parser
import Text.Parsing.Parser.Combinators
import Text.Parsing.Parser.String
import Text.Parsing.Parser.Token

main :: Effect Unit
main = do
  log "Hello sailor!"
  currentDomain >>= log

currentDomain :: Effect String
currentDomain = window >>= (location >=> hostname)

inArxiv :: String -> Boolean
inArxiv s = not $ s == "arxiv.org"

getAnchors :: Document -> Effect HTMLCollection
getAnchors = getElementsByTagName "a"

data PageType = PDF | Abstract
newtype ArxivId = ArxivId String

absURL :: ArxivId -> String
absURL (ArxivId i)= "https://www.arxiv.org/abs/" <> i

arxivParser :: Parser String (Tuple PageType ArxivId)
arxivParser = protocol *> domain *> page
  where
    protocol :: Parser String Unit
    protocol = do
      void (string "http")
      optional (char 's')
      void (string "://")

    domain :: Parser String Unit
    domain = do
      optional (string "www.")
      void (string "arxiv.org/")

    page :: Parser String (Tuple PageType ArxivId)
    page = do
      stype <- try (string "pdf") <|> string "abs"
      void (char '/')
      l <- fromCharArray <$> Array.many digit
      void (char '.')
      r <- fromCharArray <$> Array.many digit
      pure $ Tuple (if stype == "pdf" then PDF else Abstract) (ArxivId $ l <> "." <> r)

swapArxivAnchors :: Effect Unit
swapArxivAnchors = currentDomain >>= \d -> do
  if inArxiv d
  then pure unit
  else do
    as <- getAnchors =<< document =<< window
    foreachE as $ \a -> do
      mlink <- getAttribute "href" a
      case mlink of
        Nothing -> pure unit
        Just link -> case runParser arxivParser link of
            Left _ -> pure unit
            Right (Tuple atype aid) -> do
               setAttribute "href" (absURL aid) a

-- let current_domain = window.location.hostname;
-- if (current_domain !== "arxiv.org") {
--     let arxiv_pdf_pattern = /http(s)?:\/\/[www.]?arxiv.org\/pdf\//;
--     let anchors = document.getElementsByTagName('a');
--     for (let anchor of anchors) {
--         let href_ = anchor.href;
--         if (href_.search(arxiv_pdf_pattern) != -1) {
--             href_ = href_.replace(".pdf", "");
--             href_ = href_.replace("arxiv.org/pdf/", "arxiv.org/abs/");
--             anchor.href = href_;
--         }
--     }
-- }