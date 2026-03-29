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

.PHONY: install-fonts inkscape fonts $(RUN_TARGETS)

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


.PHONY: run-list
run-list:
	@if [ -z "$(RUN_TARGETS)" ]; then \
		echo "No runnable files found in $(RUN_DIR)."; \
	else \
		printf "Runnable files in %s:\n%s\n" "$(RUN_DIR)" "$(RUN_TARGETS)"; \
	fi
