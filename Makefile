DESTDIR = ~/.local/share/fonts

IOSEVKA_VERSION = v9.0.1
IOSEVKA_BUILD_PLAN = 'ttf::iosevka-personal'

# colors
GREEN := $(shell tput setaf 2)
RESET := $(shell tput sgr0)

.PHONY: clean

build: Dockerfile private-build-plans.toml
	@echo "$(GREEN)>>> Building Iosevka Builder docker image...$(RESET)"
	@docker build --build-arg IOSEVKA_VERSION=$(IOSEVKA_VERSION) --tag iosevka-builder:$(IOSEVKA_VERSION) .
	@mkdir -p build/ # host directory is created by Docker with root owner if absent
	@docker run --rm --user $(shell id -u):$(shell id -g) -v $(shell pwd)/build:/Iosevka/dist iosevka-builder:$(IOSEVKA_VERSION) $(IOSEVKA_BUILD_PLAN)

install: build
	@echo "$(GREEN)>>> Installing font to user HOME directory...$(RESET)"
	@mkdir -p $(DESTDIR)/Iosevka-Personal/
	@cp --recursive --update build/iosevka-personal/ttf/* $(DESTDIR)/Iosevka-Personal/
	@fc-cache --force --verbose $(DESTDIR)

uninstall:
	@echo "$(GREEN)>>> Uninstalling theme from user HOME directory...$(RESET)"
	rm --interactive=once --recursive $(DESTDIR)/Iosevka-Personal
	@fc-cache --force

clean:
	@echo "$(GREEN)>>> Cleaning generated font...$(RESET)"
	@rm -rf build/
