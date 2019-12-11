module MyArx.Arxiv.Pdf.Redirector where

import Prelude
import Effect
import Effect.Console
import Effect.Uncurried
import Data.Maybe
import Foreign
import Control.Monad
import Data.Array.NonEmpty
import Data.String.Pattern
import Data.Either

import MyArx.Arxiv.Types
import MyArx.Arxiv.UrlParser 


pdfviewer = "pdfviewer.html"
pdfviewerTarget = "pdfviewer.html?target="

redirectPattern = "*://arxiv.org/*.pdf"
--absRedirectPattern = "*://arxiv.org/*.pdf?abstract"
{-- viewerRedirectPattern = "*://arxiv.org/*.pdf?viewer" --}

getType :: UrlMetadata -> PageType
getType md = md.pageType

getId :: UrlMetadata -> ArxivId
getId md = md.arxivId

type Details =
  { documentUrl :: Foreign -- String
  -- ^ URL of the document in which the resource will be loaded. For example, if
  -- the web page at "https://example.com" contains an image or an iframe, then
  -- the documentUrl for the image or iframe will be "https://example.com". For
  -- a top-level document, documentUrl is undefined.
  , url :: String
  -- Target of the request
  }

foreign import listenBeforeRequestsImpl
    :: forall e . EffectFn2
        (NonEmptyArray Pattern)
        (EffectFn1 Details (Maybe {redirectUrl::String}))
        Unit
      -- Really returns a webRequest.BlockingResponse:
      -- https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/webRequest/BlockingResponse

foreign import getUrlImpl :: EffectFn1 String String


-- Redirect to custom PDF page.
--
-- Note: https://arxiv.org/pdf/<id> is the direct link
--       then the url is renamed to https://arxiv.org/pdf/<id>.pdf
--       we capture only the last url (the one that ends with '.pdf').
-- Redirect the PDF page to custom PDF container page.
redirectToPdfViewer :: Effect Unit
redirectToPdfViewer = runEffectFn2 listenBeforeRequestsImpl (singleton $ Pattern redirectPattern) (mkEffectFn1 redirect)
  where
    redirect :: Details -> Effect (Maybe {redirectUrl::String})
    redirect details = do
      -- Request from this plugin itself (embedded PDF).
      -- if isNull details.documentUrl || isUndefined details.documentUrl
      -- then pure Nothing
      runArxivParser details.url >>= case _ of
        Left err -> log err *> pure Nothing
        Right md -> do
          url' <- runEffectFn1 getUrlImpl (pdfviewerTarget <> pdfURL md.arxivId)
          log $ "Redirecting: " <> details.url <> " to " <> url'
          pure $ Just { redirectUrl : url' }

pdfRedirector :: Effect Unit
pdfRedirector = do
  log $ show $ Pattern redirectPattern
  log $ "starting redirection"
  redirectToPdfViewer

-- =============== BUTTON STUFF ================ --
-- -- Listen for any changes to the URL of any tab.
-- chrome.tabs.onUpdated.addListener(app.updateBrowserActionState);
-- -- Called to enable button if url of a tab changes and matches.
-- app.updateBrowserActionState = function (tabId, changeInfo, tab) {
--   var avail = app.checkURL(tab.url)
--   if (avail) {
--     chrome.browserAction.enable(tabId);
--   } else {
--     chrome.browserAction.disable(tabId);
--   }
-- };
-- -- Extension button click to modify title.
-- chrome.browserAction.onClicked.addListener(app.run);
-- -- Run this when the button clicked.
-- app.run = function (tab) {
--   if (!app.checkURL(tab.url)) {
--     console.log(app.name, "Error: Not arXiv page.");
--     return;
--   }
--   var type = app.getType(tab.url);
--   app.openAbstractTab(tab.index, tab.url, type);
-- }
-- -- Open the abstract / PDF page using the current URL.
-- openAbstractTab activeTabIdx md =
--   case md.pageType of
--     PDF ->
--     Abstract ->
--     where
--       abs' = absURL md.arxivId
--       pdf' = pdfURL md.arxivId
-- 
--   -- Create the abstract page in new tab.
--   chrome.tabs.create({ "url": newURL }, (tab) => {
--     console.log(app.name, "Opened abstract page in new tab.");
--     -- Move the target tab next to the active tab.
--     chrome.tabs.move(tab.id, {
--       index: activeTabIdx + 1
--     }, function (tab) {
--       console.log(app.name, "Moved abstract tab.");
--     });
--   });
-- }
-- ============= END BUTTON STUFF ============== --

-- ============= BOOKMARK STUFF ================ --
-- -- If the custom PDF page is bookmarked, bookmark the original PDF link instead.
-- app.modifyBookmark = function (id, bookmarkInfo) {
--   var prefix = chrome.runtime.getURL(app.pdfviewerTarget);
--   if (!bookmarkInfo.url.startsWith(prefix)) {
--     return;
--   }
--   console.log(app.name, "Updating bookmark with id: " + id + ", url: " + bookmarkInfo.url);
--   var url = bookmarkInfo.url.substr(prefix.length);
--   chrome.bookmarks.update(id, {
--     url: url
--   }, () => {
--     console.log(app.name, "Updated bookmark with id: " + id + " to URL: " + url);
--   });
-- }
-- -- Capture bookmarking custom PDF page.
-- chrome.bookmarks.onCreated.addListener(app.modifyBookmark);
-- =========== END BOOKMARK STUFF ============== --

-- {---
-- chrome.webRequest.onBeforeRequest.addListener(
--   (requestDetails) => {
--     const url = requestDetails.url;
--     if (url.endsWith(".pdf")) {
--       return {
--         redirectUrl: "https://arxiv.org/abs/" + app.getId(requestDetails.url, "PDF")
--       };
--     }
--   },
--   { urls: ["*://arxiv.org/*.pdf$"] },
--   ["blocking"]
-- );
-- chrome.webRequest.onBeforeRequest.addListener(
--   (requestDetails) => {
--     // Redirect to custom PDF page.
--     console.log("in viewer redirect, requesturl is", requestDetails.documentUrl, requestDetails.url)
--     if (requestDetails.documentUrl !== undefined) {
--       // Request from this plugin itself (embedded PDF).
--       return;
--     }
--     console.log("viewer found, redirecting")
--     const url = chrome.runtime.getURL(
--       app.pdfviewerTarget + requestDetails.url.replace(/\?viewer$/, '')
--     );
--     console.log(app.name, "Redirecting: " + requestDetails.url + " to " + url);
--     return { redirectUrl: url };
--   },
--   { urls: ["*://arxiv.org/pdf/*viewer$"] },
--   ["blocking"]
-- );
-- 
-- ---}
