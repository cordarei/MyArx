"use strict";

// module MyArx.Arxiv.Pdf.Redirector

function listenBeforeRequestsImpl (urlPatterns, listener) {
  console.log(
    "[myarx]",
    "triggering foreign `chrome.webRequest.onBeforeRequest.addListener`",
    "urls", urlPatterns
  );
  chrome.webRequest.onBeforeRequest.addListener(
    listener,
    { urls: urlPatterns },
    ["blocking"]
  );
}
exports.listenBeforeRequestsImpl = listenBeforeRequestsImpl;

function getUrlImpl(url) {
  console.log(
    "[myarx]",
    "triggering foreign `getUrl`",
    "url", url
  );
  return chrome.runtime.getURL(url);
};
exports.getUrlImpl = getUrlImpl;


