BUILDER    := bin/build-theme
MINIFY     := bin/MinifyTheme
THEME_SRC  := $(shell find src -name '*.tmuxtheme')
INCLUDES   := $(shell find src -name '*.tmuxsh')
THEMES     := $(patsubst src/%,%,$(THEME_SRC))
TESTS      := $(addsuffix .test,$(THEMES))
INSTALLDIR := $(HOME)/.tmux/plugins/tmux-themepack
RSYNC      := $(shell command -v rsync)
RSYNCARGS  := -ac --cvs-exclude --info=STATS,PROGRESS2

# 10 jobs in parallel
MAKEFLAGS += -j10

.PHONY: build
build: $(THEMES)

.PHONY: install
install: $(THEMES)
	@echo Rsyncing
	@$(RSYNC) $(RSYNCARGS) ./ $(INSTALLDIR)
	@echo Minify installed files
	@$(MINIFY)  $(INSTALLDIR)
	@echo Cleanup .bak files
	@find $(INSTALLDIR) -name "*.bak" -not -path "src/*" -exec rm {} +

.PHONY: clean
clean:
	find * -name "*.tmuxtheme" -not -path "src/*" -print -exec rm {} +
	find * -name "*.bak" -not -path "src/*" -print -exec rm {} +
	find $(INSTALLDIR) -name "*.bak" -not -path "src/*" -print -exec rm {} +

.PHONY: lint
lint:
	cd test && golangci-lint run -v

.PHONY: test
test: needs-build
	cd test && go test -count=1 -v ./...

.PHONY: needs-build
needs-build:
	$(foreach file,$(THEMES), \
		$(BUILDER) "src/$(file)" | diff -q "$(file)" - && \
	) true

.PHONY: testmake
testmake :
	@printf "THEME_SRC=$(THEME_SRC)\n\n"
	@printf "INCLUDES=$(INCLUDES)\n\n"
	@printf "THEMES=$(THEMES)\n\n"

.SILENT: $(THEMES)
$(THEMES): %.tmuxtheme: src/%.tmuxtheme $(INCLUDES)
	$(BUILDER) "src/$@" "$@"

$(TESTS): %.test: src/%.test

#  vim: set ai et nu cin sts=0 sw=8 ts=8 tw=78 filetype=make :
