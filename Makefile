.PHONY: build

build-firefox: make-extension-folder build move-static

make-extension-folder:
	mkdir -p extension

move-static:
	cp -f static/manifest.json extension/ && cp -f static/pdfviewer.html extension/ && cp -f static/*.png extension/

build: build-content build-background
build-content:
	pulp browserify -O --main MyArx.Content.Main    --to extension/content.js
build-background:
	pulp browserify -O --main MyArx.Background.Main --to extension/background.js


watch-content:
	pulp --watch --before clear --then 'make build-conten' --else 'echo Failed' build
watch-background:
	pulp --watch --before clear --then 'make build-background' --else 'echo Failed' build

