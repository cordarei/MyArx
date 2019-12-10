.PHONY: build

build-firefox: make-extension-folder build move-firefox-manifest move-icons

make-extension-folder:
	mkdir -p extension

build:
	pulp browserify --to extension/myarx.js

move-firefox-manifest:
	cp -f manifest.json extension/manifest.json && cp -f static/pdfviewer.html extension/

move-icons:
	cp -f static/*.png extension/

watch-and-fx:
	pulp --watch --before clear --then 'make build-firefox && echo "Deployed! open about:debugging#/runtime/this-firefox"' --else 'Failed' build

