VERSION := $(shell cat VERSION)
ARCHIVE_NAME := portx-$(VERSION)

.PHONY: build clean

build:
	@echo "Building PORTX $(VERSION)..."
	@if exist "$(ARCHIVE_NAME).zip" del "$(ARCHIVE_NAME).zip"
	@7za a -tzip "$(ARCHIVE_NAME).zip" . -x!.git -x!.claude -x!*.zip -x!Makefile
	@echo "Build complete: $(ARCHIVE_NAME).zip"

clean:
	@if exist "portx-*.zip" del "portx-*.zip"
	@echo "Cleaned build artifacts"

release: build
	@echo "Release $(VERSION) ready: $(ARCHIVE_NAME).zip"