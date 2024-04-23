BUILDER    := bin/build-theme
MINIFY     := bin/MinifyTheme
THEME_SRC  := $(shell find src -name '*.tmuxtheme')
INCLUDES   := $(shell find src -name '*.tmuxsh')
THEMES     := $(patsubst src/%,%,$(THEME_SRC))
TESTS      := $(addsuffix .test,$(THEMES))
INSTALLDIR := $(HOME)/.tmux/plugins/tmux-themepack
RSYNC      := $(shell command -v rsync)
RSYNCARGS  := -ac --cvs-exclude --info=STATS,PROGRESS2

.PHONY: build
build: $(THEMES)

.PHONY: install
install: $(THEMES)
	$(RSYNC) $(RSYNCARGS) ./ $(INSTALLDIR)
	$(MINIFY) $(INSTALLDIR)

.PHONY: clean
clean:
	@echo $(shell find * -name "*.tmuxtheme" -not -path "src/*" -print -exec rm {} +  )
	@echo $(shell find * -name "*.bak" -not -path "src/*" -print -exec rm {} +  )
	@echo $(shell find $(INSTALLDIR) -name "*.bak" -not -path "src/*" -print -exec rm {} +  )

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

$(THEMES): %.tmuxtheme: src/%.tmuxtheme $(INCLUDES)
	$(BUILDER) "src/$@" "$@"

$(TESTS): %.test: src/%.test
