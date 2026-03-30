This bundle ships Inkscape’s AppImage alongside a few helper targets to launch it
and manage fonts without needing system-wide installs.

## Targets

- `make inkscape` — runs `AppRun`, forwarding optional `ARGS=...` if you want
  to pass CLI flags such as `ARGS="--verb=FileQuit"`.
- `make fonts` — copies every `.otf/.ttf/.ttc` inside `fonts/` into
  `~/.local/share/fonts` (override with
  `FONT_INSTALL_DIR=/path`) and refreshes `fc-cache`. Re-running only installs
  newly added or changed files.
- `make install` — installs a `.desktop` launcher (defaulting to
  `~/.local/share/applications/inkscape-appimage.desktop`, configurable through
  `APPLICATIONS_DIR` or `DESKTOP_INSTALL_PATH`) that points to this bundle’s
  AppImage and icon, then refreshes the desktop database if available.
- `make <file>` — for any file under `run/`, you can run
  `make filename.svg` to open it directly in Inkscape. Bash tab-completion
  works because each file becomes its own Make target. Optional `ARGS=...`
  still applies.
- `make run-list` — prints the files currently detected in `run/` so you can
  confirm which `make <file>` targets exist.

## Notes

- Keep the `AppRun` binary executable (`chmod +x AppRun`) or the `inkscape`
  targets will fail.
- Put new fonts or documents into `fonts/` and `run/` respectively before
  invoking the targets.
