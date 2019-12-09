module Main where

import Prelude (Unit, discard, void, (*>), ($))
import Control.Bind (ifM)
import Effect (Effect)
import Effect.Console (log)
import Effect.Timer (setTimeout)

import MyArx.Arxiv (inArxiv)
import MyArx.Arxiv.Abstract (abstractRewriter)
import MyArx.Arxiv.Pdf.Redirector (pdfRedirector)
{-- import MyArx.Arxiv.Pdf.Viewer () --}
import MyArx.Arxiv.Pdf.LinkRewriter (swapArxivAnchors)

main :: Effect Unit
main = log "MyArx is running" *> ifM inArxiv inArxivAction outsideArxivAction
  where
    inArxivAction = void do
      abstractRewriter
      pdfRedirector
    outsideArxivAction = do
      log "MyArx is scanning for pdf links to redirect"
      void $ setTimeout  500 swapArxivAnchors -- once for speedy connections
      void $ setTimeout 1500 swapArxivAnchors -- once for slow connections
      void $ setTimeout 2500 swapArxivAnchors -- ...maybe twice for extra slow connections


