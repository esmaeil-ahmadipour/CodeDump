# Changelog


## [3.0.0] - 2026-10-30

### Added
- Built-in interactive menu in `code_dump.py` (run projects, run `./code`, manage projects, settings, dry-run preview, reset). Settings are now edited from the menu, no manual JSON editing needed
- Per-project settings (`overrides`) editable from the menu; overridden options are marked with `*`
- Presets: `flutter`, `node`, `python`, `all`
- All file types are included when `only_extensions` is empty (binary files detected by NUL bytes, multi-encoding decoding)
- Folder tree and rough token estimate at the top of each report
- `.gitignore` support (`use_gitignore`), hidden files option (`include_hidden`)
- `sort_by`, `split_tokens` (split report into parts), `copy_to_clipboard`, `output_dir`
- Real backup options: `backup.keep`, `backup.compress` (zip), `backup.days` (auto-delete old backups)
- CLI flags: `--all`, `-p/--project NAME`, `--dry-run`, `--no-menu`, `--reset`
- `settings.json` is created automatically on first run

### Changed
- Settings option names are clearer: `include_extensions` -> `only_extensions`, `exclude_dirs` -> `skip_folders`, `exclude_files` -> `skip_files`, `exclude_patterns` -> `skip_if_contains`, `max_file_size_mb` -> `max_file_mb`, `global` -> `defaults`, `enabled` -> `active`, `options` -> `overrides`. Old names are still read
- Relative project paths are resolved against the location of `settings.json`
- `run.bat`, `run.ps1`, `run_macos.command` are now one-line launchers; `bin.sh` replaced by `run.sh` (no `jq` dependency)
- `CONFIGURATION.md` and tests rewritten for the new settings

### Fixed
- Empty or invalid `settings.json` is restored to defaults on first run (invalid file kept as `settings.json.bak`)
- `skip_if_contains` now matches the project-relative path instead of the full path
- Projects located under a folder named like a skipped folder (e.g. `build`) are no longer ignored entirely
- The report file no longer includes itself
- Files that are valid text but not UTF-8 are no longer dropped

### Removed
- Unused options: `output_format`, `skip_menu` logic in shell scripts, `version` checks


## [2.0.0] - 2026-05-30

### Added
- Dual mode menu in bin.sh: Mode 1 for ./code folder, Mode 2 for settings.json
- `--no-config` flag in code_dump.py to bypass settings.json entirely
- JSON validation before processing projects (requires jq)
- Automatic backup with timestamp for Mode 2 projects
- Project name support from settings.json for reports

### Changed
- Mode 1 now uses `--no-config` flag to prevent settings.json interference
- Improved error messages for JSON syntax errors
- Cross-platform support verified: Linux, macOS, Windows

### Fixed
- target_dir variable scope issue when using --no-config
- Read prompt error in non-interactive environments (GitHub Actions)


## [1.0.0] - 2026-05-20

### Added
- Initial release of CodeDump
- Extract all text files from any project into single report
- Multi-project support via settings.json
- JSON configuration with validation
- Headless mode for automation (skip_menu)
- Auto backup with timestamp and retention policy
- 20+ file format support (.js, .py, .dart, .json, .md, .sh, etc.)
- Filter system: exclude dirs, files, and patterns
- Markdown output with syntax highlighting
- Cross-platform: Linux, macOS, Windows (WSL)
- Interactive menu with 2 operation modes
- GitHub promo banner at top of all reports
  - Repository link: https://github.com/esmaeil-ahmadipour/CodeDump
  - Star request for community support

### Technical
- Python 3.8+ required
- Bash 4.0+ required
- jq optional but recommended
