IMAGE   := mscorefonts-builder
UBUNTU  := ubuntu:24.04
FONTS   ?= $(CURDIR)/fonts

.PHONY: all image deb lint test test-swap clean

all: deb

image:
	docker build -t $(IMAGE) .

# Build from a copy of the tree so dpkg-buildpackage artifacts stay out of it.
deb: image
	mkdir -p dist
	docker run --rm -v "$(CURDIR)":/src:ro -v "$(abspath $(FONTS))":/fonts:ro \
		-v "$(CURDIR)/dist":/dist $(IMAGE) sh -ec '\
		cp -r /src /build/pkg && rm -rf /build/pkg/dist /build/pkg/fonts; \
		cp -r /fonts /build/pkg/fonts && cd /build/pkg; \
		dpkg-buildpackage -us -uc -b; \
		cp ../*.deb ../*.buildinfo ../*.changes /dist/'

lint: image
	docker run --rm -v "$(CURDIR)/dist":/dist:ro $(IMAGE) \
		sh -c 'lintian --info --display-info /dist/*.deb'

test:
	docker run --rm -v "$(CURDIR)/dist":/dist:ro -v "$(CURDIR)/tests":/tests:ro \
		$(UBUNTU) sh /tests/install-test.sh

# Needs network: installs the real ttf-mscorefonts-installer first.
test-swap:
	docker run --rm -v "$(CURDIR)/dist":/dist:ro -v "$(CURDIR)/tests":/tests:ro \
		$(UBUNTU) sh /tests/swap-test.sh

clean:
	rm -rf dist
