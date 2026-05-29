# Changelog


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
