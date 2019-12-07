build:
	pulp browserify --to extension/arxites.js &&
build-ch: build
	cp -f manifest-chrome.json extension/manifest.js
build-fx: build
	cp -f manifest-firefox.json extension/manifest.js
