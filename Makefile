build-chrome:  build move-chrome-manifest  move-icons
build-firefox: build move-firefox-manifest move-icons

build:
	pulp browserify --to extension/myarx.js
# move-chrome-manifest:
# 	cp -f manifest-chrome.json extension/manifest.json
move-firefox-manifest:
	cp -f manifest-firefox.json extension/manifest.json && cp -f static/pdfviewer.html extension/
move-icons:
	cp -f static/*.png extension/
watch-and-fx:
	pulp --watch --before clear --then 'make build-firefox && echo "Deployed! open about:debugging#/runtime/this-firefox"' --else 'Failed' build
