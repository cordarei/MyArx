# MyArx

This is a fork of [j3soon/arxiv-utils](https://github.com/j3soon/arxiv-utils) which is rewritten in purescript. The aim
of this fork is simply to include all original functionality of [arxiv-utils](https://github.com/j3soon/arxiv-utils) but to redirect all pdf links to the abstract page (instead of to the pdf viewer). In addition to this, the pdf viewer is made secondary to the original pdf page.

Features:
- Redirects all pdf links to abstracts. To bypass add "?" to the end of the pdf link.
- Removes the arxiv id from the abstract page's title
- Adds the following buttons to the abstract page:
  - "Direct Download" -- download link in format "<title>, <author1>, et.al, <publishyear>.pdf"
  - "Viewer" -- this makes the title of the pdf viewer identical to the page title
  - "Arxiv Vanity" -- A link to a mobile-friendly arxiv-vanity version of the paper

Features not included from [arxiv-utils](https://github.com/j3soon/arxiv-utils):
- Retitle support in Chrome
    - fixing this would require reviewing [`arxiv-utils:chrome/content.js#L142`](https://github.com/j3soon/arxiv-utils/blob/master/chrome/content.js#L142).
- The browser button to toggle views
- Retitling support in bookmarks



