module MyArx.Arxiv
  ( inArxiv
  ) where

import Prelude
import Effect (Effect)
import Data.Either (Either)
import Data.Tuple (Tuple)

import Web.HTML (window)
import Web.HTML.Location (hostname, href)
import Web.HTML.Window (location)

import MyArx.Arxiv.Urls (runArxivParser, PageType, ArxivId)

inArxiv :: Effect Boolean
inArxiv = window >>= (location >=> hostname >=> ((eq "arxiv.org") >>> pure))

currentId :: Effect (Either String (Tuple PageType ArxivId))
currentId = window >>= location >>= href >>= runArxivParser
