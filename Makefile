SHELL := /bin/bash

FONT_SRC_DIR := $(CURDIR)/fonts
# Allow overriding if fonts should be installed elsewhere.
FONT_INSTALL_DIR ?= $(HOME)/.local/share/fonts
INKSCAPE_APP := $(CURDIR)/AppRun
# Optional arguments forwarded to AppRun (e.g. ARGS="--verb=FileQuit").
ARGS ?=
RUN_DIR := $(CURDIR)/run
RUN_FILES := $(filter-out %/,$(wildcard $(RUN_DIR)/*))
RUN_TARGETS := $(notdir $(RUN_FILES))
APPLICATIONS_DIR ?= $(HOME)/.local/share/applications
DESKTOP_TEMPLATE := $(CURDIR)/org.inkscape.Inkscape.desktop
DESKTOP_INSTALL_PATH ?= $(APPLICATIONS_DIR)/inkscape-appimage.desktop
ICON_FILE := $(CURDIR)/org.inkscape.Inkscape.png

.PHONY: install-fonts inkscape fonts install $(RUN_TARGETS)

inkscape:
	@if [ ! -x "$(INKSCAPE_APP)" ]; then \
		echo "Cannot execute '$(INKSCAPE_APP)'. Make sure the AppImage is present and executable."; \
		exit 1; \
	fi
	@echo "Launching Inkscape..."
	@$(INKSCAPE_APP) $(ARGS)

$(RUN_TARGETS):
	@file="$(RUN_DIR)/$@"; \
	if [ ! -f "$$file" ]; then \
		echo "File '$$file' not found."; \
		exit 1; \
	fi; \
	if [ ! -x "$(INKSCAPE_APP)" ]; then \
		echo "Cannot execute '$(INKSCAPE_APP)'. Make sure the AppImage is present and executable."; \
		exit 1; \
	fi; \
	echo "Opening $$file with Inkscape..."; \
	$(INKSCAPE_APP) $(ARGS) "$$file"

fonts:
	@if [ ! -d "$(FONT_SRC_DIR)" ]; then \
		echo "Font directory '$(FONT_SRC_DIR)' does not exist."; \
		exit 1; \
	fi
	@mkdir -p "$(FONT_INSTALL_DIR)"
	@echo "Copying fonts from $(FONT_SRC_DIR) to $(FONT_INSTALL_DIR)..."
	@found_fonts=0; \
	installed=0; \
	while IFS= read -r -d '' font_path; do \
		found_fonts=1; \
		rel_path="$${font_path#$(FONT_SRC_DIR)/}"; \
		subdir="$$(dirname "$$rel_path")"; \
		dest_dir="$(FONT_INSTALL_DIR)"; \
		if [ "$$subdir" != "." ]; then \
			dest_dir="$$dest_dir/$$subdir"; \
		fi; \
		font_name="$$(basename "$$rel_path")"; \
		dest_file="$$dest_dir/$$font_name"; \
		mkdir -p "$$dest_dir"; \
		if [ -f "$$dest_file" ] && cmp -s "$$font_path" "$$dest_file"; then \
			echo "  - $$rel_path (already installed, skipped)"; \
			continue; \
		fi; \
		install -m 644 "$$font_path" "$$dest_dir/"; \
		installed=$$((installed + 1)); \
		echo "  - $$rel_path (installed/updated)"; \
		done < <(find "$(FONT_SRC_DIR)" -type f \( -iname '*.otf' -o -iname '*.ttf' -o -iname '*.ttc' \) -print0); \
		if [ $$found_fonts -eq 0 ]; then \
			echo "No .otf, .ttf or .ttc files were found in $(FONT_SRC_DIR)."; \
			exit 1; \
		fi; \
		if [ $$installed -eq 0 ]; then \
			echo "No new fonts needed installation."; \
		else \
			echo "Installed $$installed font(s)."; \
		fi; \
		if [ $$installed -gt 0 ]; then \
			if command -v fc-cache >/dev/null 2>&1; then \
				fc-cache -f "$(FONT_INSTALL_DIR)" >/dev/null; \
				echo "Font cache refreshed."; \
			else \
				echo "fc-cache not found; skipped font cache refresh."; \
			fi; \
		else \
			echo "Font cache unchanged (no new fonts installed)."; \
	fi
	@echo "Fonts installed to $(FONT_INSTALL_DIR)."

install:
	@if [ ! -x "$(INKSCAPE_APP)" ]; then \
		echo "Cannot execute '$(INKSCAPE_APP)'. Make sure the AppImage is present and executable."; \
		exit 1; \
	fi
	@if [ ! -f "$(DESKTOP_TEMPLATE)" ]; then \
		echo "Desktop entry template '$(DESKTOP_TEMPLATE)' not found."; \
		exit 1; \
	fi
	@if [ ! -f "$(ICON_FILE)" ]; then \
		echo "Icon file '$(ICON_FILE)' not found."; \
		exit 1; \
	fi
	@mkdir -p "$(APPLICATIONS_DIR)"
	@set -e; \
	tmp_file="$$(mktemp)"; \
	if ! sed \
		-e 's|^Exec=inkscape %F|Exec=$(INKSCAPE_APP) %F|' \
		-e 's|^Exec=inkscape$$|Exec=$(INKSCAPE_APP)|' \
		-e 's|^TryExec=inkscape|TryExec=$(INKSCAPE_APP)|' \
		-e 's|^Icon=org\.inkscape\.Inkscape|Icon=$(ICON_FILE)|' \
		"$(DESKTOP_TEMPLATE)" > "$$tmp_file"; then \
		rm -f "$$tmp_file"; \
		exit 1; \
	fi; \
	install -m 644 "$$tmp_file" "$(DESKTOP_INSTALL_PATH)"; \
	rm -f "$$tmp_file"
	@echo "Desktop file installed to $(DESKTOP_INSTALL_PATH)."
	@if command -v update-desktop-database >/dev/null 2>&1; then \
		echo "Refreshing desktop database..."; \
		update-desktop-database "$(APPLICATIONS_DIR)" >/dev/null && \
		echo "Desktop database refreshed."; \
	else \
		echo "update-desktop-database not found; please refresh desktop entries manually if needed."; \
	fi
	@echo "Inkscape AppImage is now available in file manager 'Open With' menus."

.PHONY: run-list
run-list:
	@if [ -z "$(RUN_TARGETS)" ]; then \
		echo "No runnable files found in $(RUN_DIR)."; \
	else \
		printf "Runnable files in %s:\n%s\n" "$(RUN_DIR)" "$(RUN_TARGETS)"; \
	fi
