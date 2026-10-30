# Configuration

Run `python code_dump.py` and use **Settings** in the menu - no manual JSON editing needed.
`settings.json` is created automatically on first run; if it is empty or broken it is restored to defaults
(a broken file is kept as `settings.json.bak`). Reset any time: menu option 6 or `python code_dump.py --reset`.

## Options (global `defaults`, overridable per project in `overrides`)
| Key | Default | Meaning |
|---|---|---|
| `only_extensions` | `[]` | File types to include. **Empty = all types.** |
| `skip_folders` | node_modules, dist, build, ... | Folder names to skip (wildcards ok) |
| `skip_files` | `*.log *.tmp .env*` | File patterns to skip |
| `skip_if_contains` | `.g.dart generated ...` | Skip paths containing this text |
| `max_file_mb` | 10 | Skip bigger files |
| `include_hidden` | false | Include dotfiles |
| `use_gitignore` | true | Respect the project's `.gitignore` |
| `show_tree` / `show_token_estimate` | true | Tree and rough token count in report |
| `sort_by` | path | `path` or `size` |
| `split_tokens` | 0 | Split report into parts of ~N tokens |
| `copy_to_clipboard` | false | Copy report (single part) to clipboard |
| `output_dir` | `.` | Relative to settings file |
| `backup` | keep, no zip, 30 days | `{keep, compress, days}` |

Root keys: `active` (master switch), `skip_menu` (always run headless), `projects`
(`{name, path, active, overrides}`; relative paths are relative to `settings.json`).
Old v1 keys (`enabled`, `global`, `include_extensions`, `exclude_dirs`, ...) are still read.

## CLI
`python code_dump.py` menu · `DIR [-o FILE]` direct · `--all` · `-p NAME` · `--dry-run` · `--no-menu` · `--no-config` · `--reset`
