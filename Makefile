BUILD_DIR = build/IosevkaPersonal/TTF/
INSTALL_DIR = ~/.local/share/fonts/iosevka-personal/

IOSEVKA_VERSION = v33.2.4
IOSEVKA_BUILD_PLAN = 'ttf::IosevkaPersonal'

# colors
GREEN := $(shell tput setaf 2)
RESET := $(shell tput sgr0)

all: build

build: $(BUILD_DIR)/IosevkaPersonal-Regular.ttf
$(BUILD_DIR)/IosevkaPersonal-Regular.ttf: Dockerfile private-build-plans.toml
	@echo "$(GREEN)>>> Building customized Iosevka font...$(RESET)"

	# host directory is created by Docker with root owner if absent
	@mkdir -p $(BUILD_DIR)

	# font is build in docker container
	@docker build --build-arg IOSEVKA_VERSION=$(IOSEVKA_VERSION) --tag iosevka-builder:$(IOSEVKA_VERSION) .
	@docker run --rm \
	            --user $(shell id -u):$(shell id -g) \
	            --volume $(shell pwd)/build:/Iosevka/dist \
	            iosevka-builder:$(IOSEVKA_VERSION) $(IOSEVKA_BUILD_PLAN)

install: $(INSTALL_DIR)/IosevkaPersonal-Regular.ttf
$(INSTALL_DIR)/IosevkaPersonal-Regular.ttf: $(BUILD_DIR)/IosevkaPersonal-Regular.ttf
	@echo "$(GREEN)>>> Installing font to user HOME directory...$(RESET)"
	@mkdir -p $(INSTALL_DIR)
	@cp --recursive --update $(BUILD_DIR)/*.ttf $(INSTALL_DIR)/
	@fc-cache --force --verbose

uninstall:
	@echo "$(GREEN)>>> Uninstalling theme from user HOME directory...$(RESET)"
	rm --interactive=once --recursive $(INSTALL_DIR)
	@fc-cache --force

clean:
	@echo "$(GREEN)>>> Cleaning generated font...$(RESET)"
	@rm -rf build/

.PHONY: all clean uninstall
