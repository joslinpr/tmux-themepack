BUILDER    := bin/build-theme
MINIFY     := bin/MinifyTheme
INSTALLDIR := $(HOME)/.tmux/plugins/tmux-themepack
RSYNC      := $(shell command -v rsync)
RSYNCARGS  := -ac --cvs-exclude --info=STATS,PROGRESS2
# Paul Themes
PAUL_THEME_SRC  := $(shell find src/paul -name '*.tmuxtheme')
PAUL_INCLUDES   := $(shell find src/paul -name '*.tmuxsh')
PAUL_THEMES     := $(patsubst src/%,%,$(PAUL_THEME_SRC))
PAUL_TESTS      := $(addsuffix .test,$(PAUL_THEMES))

# Powerline Themes
PL_THEME_SRC  := $(shell find src/powerline -name '*.tmuxtheme')
PL_INCLUDES   := $(shell find src/powerline -name '*.tmuxsh')
PL_THEMES     := $(patsubst src/%,%,$(PL_THEME_SRC))
PL_TESTS      := $(addsuffix .test,$(PL_THEMES))

# 10 jobs in parallel
MAKEFLAGS += -j10

.PHONY: build
build: $(PAUL_THEMES) $(PL_THEMES)

.PHONY: install
install: $(PAUL_THEMES) $(PL_THEMES)
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
	$(foreach file,$(PAUL_THEMES), \
		$(BUILDER) "src/$(file)" | diff -q "$(file)" - && \
	) true
	$(foreach file,$(PL_THEMES), \
		$(BUILDER) "src/$(file)" | diff -q "$(file)" - && \
	) true

.PHONY: testmake
testmake :
	@printf "PAUL_THEME_SRC=$(PAUL_THEME_SRC)\n\n"
	@printf "PAUL_INCLUDES=$(PAUL_INCLUDES)\n\n"
	@printf "PAUL_THEMES=$(PAUL_THEMES)\n\n"
	@printf "PL_THEME_SRC=$(PL_THEME_SRC)\n\n"
	@printf "PL_INCLUDES=$(PL_INCLUDES)\n\n"
	@printf "PL_THEMES=$(PL_THEMES)\n\n"

# .SILENT: $(PAUL_THEMES)
$(PAUL_THEMES): %.tmuxtheme: src/%.tmuxtheme $(PAUL_INCLUDES)
	$(BUILDER) "src/$@" "$@"

# .SILENT: $(PL_THEMES)
$(PL_THEMES): %.tmuxtheme: src/%.tmuxtheme $(PL_INCLUDES)
	$(BUILDER) "src/$@" "$@"

$(PAUL_TESTS): %.test: src/%.test
$(PL_TESTS): %.test: src/%.test

.PHONY: list
list:
	@LC_ALL=C $(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | grep -E -v -e '^[^[:alnum:]]' -e '^$@$$'

#  vim: set ai et nu cin sts=0 sw=8 ts=8 tw=78 filetype=make :
