.PHONY: build

build-firefox: make-extension-folder build move-static

make-extension-folder:
	mkdir -p extension

move-static:
	cp -f static/manifest.json extension/ && cp -f static/pdfviewer.html extension/ && cp -f static/*.png extension/

build: build-content build-background build-pdfviewer
build-content:
	pulp browserify -O --main MyArx.Content.Main    --to extension/content.js
build-background:
	pulp browserify -O --main MyArx.Background.Main --to extension/background.js
build-pdfviewer:
	pulp browserify -O --main MyArx.PdfViewer.Main --to extension/pdfviewer.js

watch:
	pulp --watch --before clear --then 'make build' --else 'echo Failed' build

package: build
	tar cf myarx.tar extension/
