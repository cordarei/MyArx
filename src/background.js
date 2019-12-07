// This background script is for adding the back to abstract button.
var app = {};
// All logs should start with this.
app.name = "[arXiv-utils]";
// For our PDF container.
app.pdfviewer = "pdfviewer.html";
app.pdfviewerTarget = "pdfviewer.html?target=";
// The match pattern for the URLs to redirect
// Note: https://arxiv.org/pdf/<id> is the direct link, then the url is renamed to https://arxiv.org/pdf/<id>.pdf
//       we capture only the last url (the one that ends with '.pdf').
// Adding some extra parameter such as https://arxiv.org/pdf/<id>.pdf?download can bypass this capture.
app.redirectPattern = "*://arxiv.org/*.pdf";
app.absRedirectPattern = "*://arxiv.org/*.pdf?abstract";
app.viewerRedirectPattern = "*://arxiv.org/*.pdf?viewer";
// Return the type parsed from the url. (Returns "PDF" or "Abstract")
app.getType = function (url) {
  if (url.endsWith(".pdf") || url.endsWith(".pdf?viewer")) {
    return "PDF";
  } else {
    return "Abstract";
  }
}

// Return the id parsed from the url.
app.getId = function (url, type) {
  var match;
  if (url.endsWith(".pdf")) {
    // match = url.match(/arxiv.org\/pdf\/([\S]*)\.pdf$/);
    // Must use below for other PDF serving URL.
    match = url.match(/arxiv.org\/[\S]*\/([^\/]*)\.pdf$/);
    // The first match is the matched string, the second one is the captured group.
    if (match === null || match.length !== 2) {
      return null;
    }
  } else if (url.endsWith(".pdf?viewer")) {
    // match = url.match(/arxiv.org\/pdf\/([\S]*)\.pdf$/);
    // Must use below for other PDF serving URL.
    match = url.match(/arxiv.org\/[\S]*\/([^\/]*)\.pdf\?viewer$/);
    // The first match is the matched string, the second one is the captured group.
    if (match === null || match.length !== 2) {
      return null;
    }
  } else {
    match = url.match(/arxiv.org\/abs\/([\S]*)$/);
    // The first match is the matched string, the second one is the captured group.
    if (match === null || match.length !== 2) {
      return null;
    }
  }
  return match[1];
}

// Open the abstract / PDF page using the current URL.
app.openAbstractTab = function (activeTabIdx, url, type) {
  // Retrieve the abstract url by modifying the original url.
  var newURL;
  if (type === "PDF") {
    var prefix = chrome.runtime.getURL(app.pdfviewerTarget);
    newURL = url.substr(prefix.length);
    var id = app.getId(newURL, type);
    newURL = "https://arxiv.org/abs/" + id;
  } else {
    var id = app.getId(url, type);
    newURL = "https://arxiv.org/pdf/" + id + ".pdf";
  }
  // Create the abstract page in new tab.
  chrome.tabs.create({ "url": newURL }, (tab) => {
    console.log(app.name, "Opened abstract page in new tab.");
    // Move the target tab next to the active tab.
    chrome.tabs.move(tab.id, {
      index: activeTabIdx + 1
    }, function (tab) {
      console.log(app.name, "Moved abstract tab.");
    });
  });
}
// Check if the URL is abstract or PDF page, returns true if the URL is either.
app.checkURL = function (url) {
  // var matchPDF = url.match(/arxiv.org\/pdf\/([\S]*)\.pdf$/);
  // Must use below for other PDF serving URL.
  var matchPDF = url.match(/arxiv.org\/[\S]*\/([^\/]*)\.pdf$/);
  var matchPDFViewer = url.match(/arxiv.org\/[\S]*\/([^\/]*)\.pdf\?viewer$/);
  var matchPDFToAbs = url.match(/arxiv.org\/[\S]*\/([^\/]*)\.pdf\?abstract/);
  var matchAbs = url.match(/arxiv.org\/abs\/([\S]*)$/);
  console.log(url);
  return (matchPDF !== null || matchPDFViewer !== null || matchPDFToAbs !== null || matchAbs !== null);
}
// Called when the url of a tab changes.
app.updateBrowserActionState = function (tabId, changeInfo, tab) {
  var avail = app.checkURL(tab.url)
  if (avail) {
    chrome.browserAction.enable(tabId);
  } else {
    chrome.browserAction.disable(tabId);
  }
};
// Redirect to custom PDF page.
app.redirect = function (requestDetails) {
  if (requestDetails.documentUrl !== undefined) {
    // Request from this plugin itself (embedded PDF).
    return;
  }
  var url = app.pdfviewerTarget + requestDetails.url;
  url = chrome.runtime.getURL(url);
  console.log(app.name, "Redirecting: " + requestDetails.url + " to " + url);
  return {
    redirectUrl: url
  };
}
// If the custom PDF page is bookmarked, bookmark the original PDF link instead.
app.modifyBookmark = function (id, bookmarkInfo) {
  var prefix = chrome.runtime.getURL(app.pdfviewerTarget);
  if (!bookmarkInfo.url.startsWith(prefix)) {
    return;
  }
  console.log(app.name, "Updating bookmark with id: " + id + ", url: " + bookmarkInfo.url);
  var url = bookmarkInfo.url.substr(prefix.length);
  chrome.bookmarks.update(id, {
    url: url
  }, () => {
    console.log(app.name, "Updated bookmark with id: " + id + " to URL: " + url);
  });
}
// Run this when the button clicked.
app.run = function (tab) {
  if (!app.checkURL(tab.url)) {
    console.log(app.name, "Error: Not arXiv page.");
    return;
  }
  var type = app.getType(tab.url);
  app.openAbstractTab(tab.index, tab.url, type);
}
// Listen for any changes to the URL of any tab.
chrome.tabs.onUpdated.addListener(app.updateBrowserActionState);
// Extension button click to modify title.
chrome.browserAction.onClicked.addListener(app.run);
// Redirect the PDF page to custom PDF container page.
// chrome.webRequest.onBeforeRequest.addListener(
//   app.redirect,
//   { urls: [app.redirectPattern] },
//   ["blocking"]
// );
//
chrome.webRequest.onBeforeRequest.addListener(
  (requestDetails) => {
    const url = requestDetails.url;
    if (url.endsWith(".pdf")) {
      return {
        redirectUrl: "https://arxiv.org/abs/" + app.getId(requestDetails.url, "PDF")
      };
    }
  },
  { urls: ["*://arxiv.org/*.pdf$"] },
  ["blocking"]
);
chrome.webRequest.onBeforeRequest.addListener(
  (requestDetails) => {
    // Redirect to custom PDF page.
    console.log("in viewer redirect, requesturl is", requestDetails.documentUrl, requestDetails.url)
    if (requestDetails.documentUrl !== undefined) {
      // Request from this plugin itself (embedded PDF).
      return;
    }
    console.log("viewer found, redirecting")
    const url = chrome.runtime.getURL(
      app.pdfviewerTarget + requestDetails.url.replace(/\?viewer$/, '')
    );
    console.log(app.name, "Redirecting: " + requestDetails.url + " to " + url);
    return { redirectUrl: url };
  },
  { urls: ["*://arxiv.org/pdf/*viewer$"] },
  ["blocking"]
);


// Capture bookmarking custom PDF page.
chrome.bookmarks.onCreated.addListener(app.modifyBookmark);
