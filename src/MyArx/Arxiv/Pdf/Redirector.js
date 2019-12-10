"use strict";

// module MyArx.Arxiv.Pdf.Redirector

function listenBeforeRequestsImpl (urlPatterns, listener) {
  console.log("[myarx]", "listenBeforeRequestsImpl", urlPatterns)
  chrome.webRequest.onBeforeRequest.addListener(
    listener,
    { urls: urlPatterns },
    ["blocking"]
  );
}
exports.listenBeforeRequestsImpl = listenBeforeRequestsImpl;

function getUrlImpl(url) {
  console.log("[myarx]", "getUrl", url)
  chrome.runtime.getURL(url);
};
exports.getUrlImpl = getUrlImpl;


