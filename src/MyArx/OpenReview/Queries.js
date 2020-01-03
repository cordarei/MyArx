"use strict";

// module MyArx.OpenReview.Queries

function extractBibtex () {
  decodeURIComponent(document.getElementsByClassName("action-bibtex-modal").item(0).getAttribute("data-bibtex"))
};

exports.extractBibtex = extractBibtex;
