IOSEVKA_VERSION = v33.2.6

INSTALL_DIR = ~/.local/share/fonts/iosevka-personal/

# colors
GREEN := $(shell tput setaf 2)
RESET := $(shell tput sgr0)

all: build

build: private-build-plans.toml
	# check dependencies
	which git npm ttfautohint

	git clone --depth=1 --branch ${IOSEVKA_VERSION} https://github.com/be5invis/Iosevka.git

	# copy custom build plan to Iosevka dir
	cp private-build-plans.toml Iosevka/

	# install dependencies and build font
	cd Iosevka && npm install --no-audit && npm run build -- ttf::IosevkaPersonal

	# copy built fonts
	mkdir -p build
	cp -r Iosevka/dist/IosevkaPersonal/TTF/*.ttf build/

docker-build: Makefile private-build-plans.toml
	@echo "$(GREEN)>>> Building customized Iosevka font in Docker...$(RESET)"

	# host directory is created by Docker with root owner if absent
	mkdir -p build

	# font is build in docker container
	docker build --build-arg IOSEVKA_VERSION=$(IOSEVKA_VERSION) --tag iosevka-builder:$(IOSEVKA_VERSION) .
	docker run --rm \
	           --user $(shell id -u):$(shell id -g) \
	           --volume $(shell pwd)/build:/iosevka-personal/build \
	           iosevka-builder:$(IOSEVKA_VERSION)

	# sentinel file to make task as run
	@touch docker-build

install: build
	@echo "$(GREEN)>>> Installing font to user HOME directory...$(RESET)"
	@mkdir -p $(INSTALL_DIR)
	@cp --recursive --update build/*.ttf $(INSTALL_DIR)/
	@fc-cache --force --verbose

uninstall:
	@echo "$(GREEN)>>> Uninstalling theme from user HOME directory...$(RESET)"
	rm --interactive=once --recursive $(INSTALL_DIR)
	@fc-cache --force

clean:
	@echo "$(GREEN)>>> Cleaning generated font...$(RESET)"
	rm -rf build/ docker-build Iosevka/

.PHONY: all clean uninstall
