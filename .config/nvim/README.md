# AEL Neovim configuration

Lua-based migration of the supplied `.vimrc`. Intended for Neovim 0.11+.

## Install

```bash
sudo pacman -S --needed neovim git ripgrep fzf ranger wl-clipboard nodejs npm python-pynvim
# Back up any existing Neovim configuration first:
mv ~/.config/nvim ~/.config/nvim.backup  # only if the directory exists
mkdir -p ~/.config/nvim
cp -a nvim-clean/. ~/.config/nvim/
nvim
```

Install LSP servers separately (example: `npm install -g basedpyright bash-language-server` and a Lua language server package). Plugins are bootstrapped by lazy.nvim on first launch. UltiSnips requires a working Python 3 provider.

## Deliberate changes / limitations

- YouCompleteMe and jedi-vim are replaced with built-in LSP + nvim-cmp. LSP servers are **not** installed automatically.
- Native `gc` / `gcc` comments replace the old filetype-specific substitution function (Neovim 0.10+).
- Scrolloff is 8 rather than 999; restore 999 in `options.lua` if desired.
- Original `lorem<Tab>` text is shortened.
- Bionic Reading is a snapshot of the current buffer; toggle off/on to refresh after edits. This is not a live renderer.
- Existing snippets must be copied into `~/.config/nvim/UltiSnips`.
- The old final `ael_fuzz_home_command` global is omitted because its consuming plugin was not in the plugin list.
- `:source $MYVIMRC` reloads only init.lua and can re-register mappings; restart Neovim after plugin changes.
- Verify key mappings in your terminal: Ctrl-S may require `stty -ixon`, and Shift-F7 is not always distinguishable.
