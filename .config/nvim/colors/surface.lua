-- =============================================================================
-- INFO
-- =============================================================================
-- [/.config/nvim/colors/surface.lua]
-- 
-- Author      : Pascal Malouin (https://github.com/alterEGO-Linux)
-- Created     : 2026-09-11 13:10:25 UTC
-- Updated     : 2026-09-11 13:10:25 UTC
-- Description : Surface Neovim colorscheme.
-- -----------------------------------------------------------------------------

vim.cmd("highlight clear")

if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
end

vim.g.colors_name = "surface"

local tty = vim.env.TERM == "linux"

-- Full Surface palette
local p = {
    bg       = "#0d1012",
    bg_alt   = "#0b252c",
    surface  = "#12343c",
    selection = "#19505d",

    fg       = "#d9f4ef",
    muted    = "#71969a",
    subtle   = "#426a70",

    blue     = "#4bb7d8",
    cyan     = "#70e1d1",
    seafoam  = "#9ad8c8",
    sand     = "#d8c7a5",

    yellow   = "#e6c985",
    orange   = "#e99b6d",
    coral    = "#ff7a7a",
    red      = "#e85d75",
    purple   = "#b8a1e3",
}

local function hl(group, options)
    vim.api.nvim_set_hl(0, group, options)
end

-- Editor
hl("Normal",       { fg = p.fg, bg = p.bg, ctermfg = 15, ctermbg = 0 })
hl("NormalNC",     { fg = p.fg, bg = p.bg_alt, ctermfg = 15, ctermbg = 0 })
hl("NormalFloat",  { fg = p.fg, bg = p.bg_alt, ctermfg = 15, ctermbg = 0 })
hl("FloatBorder",  { fg = p.blue, bg = p.bg_alt, ctermfg = 6, ctermbg = 0 })

hl("CursorLine",   { bg = p.bg_alt, ctermbg = 8 })
hl("CursorColumn", { bg = p.bg_alt, ctermbg = 8 })
hl("ColorColumn",  { bg = p.surface, ctermbg = 8 })

hl("LineNr",       { fg = p.subtle, ctermfg = 8 })
hl("CursorLineNr", { fg = p.cyan, bold = true, ctermfg = 14, bold = true })
hl("SignColumn",   { fg = p.muted, bg = p.bg, ctermfg = 8, ctermbg = 0 })

hl("Visual",       { bg = p.selection, ctermbg = 6 })
hl("Search",       { fg = p.bg, bg = p.sand, ctermfg = 0, ctermbg = 11 })
hl("IncSearch",    { fg = p.bg, bg = p.coral, ctermfg = 0, ctermbg = 9 })
hl("MatchParen",   { fg = p.cyan, bg = p.surface, bold = true,
                     ctermfg = 14, ctermbg = 8, bold = true })

-- Interface
hl("StatusLine",   { fg = p.bg, bg = p.blue, bold = true,
                     ctermfg = 0, ctermbg = 6, bold = true })
hl("StatusLineNC", { fg = p.muted, bg = p.surface,
                     ctermfg = 7, ctermbg = 8 })
hl("WinSeparator", { fg = p.surface, ctermfg = 8 })

hl("Pmenu",        { fg = p.fg, bg = p.bg_alt, ctermfg = 15, ctermbg = 8 })
hl("PmenuSel",     { fg = p.bg, bg = p.cyan, bold = true,
                     ctermfg = 0, ctermbg = 14, bold = true })

hl("Directory",    { fg = p.blue, bold = true, ctermfg = 6, bold = true })
hl("Title",        { fg = p.cyan, bold = true, ctermfg = 14, bold = true })
hl("Question",     { fg = p.seafoam, ctermfg = 10 })
hl("MoreMsg",      { fg = p.seafoam, ctermfg = 10 })
hl("WarningMsg",   { fg = p.yellow, ctermfg = 11 })
hl("ErrorMsg",     { fg = p.coral, bold = true, ctermfg = 9, bold = true })

-- Syntax
hl("Comment",      { fg = p.muted, italic = not tty, ctermfg = 8 })
hl("Constant",     { fg = p.sand, ctermfg = 11 })
hl("String",       { fg = p.seafoam, ctermfg = 10 })
hl("Character",    { fg = p.seafoam, ctermfg = 10 })
hl("Number",       { fg = p.orange, ctermfg = 3 })
hl("Boolean",      { fg = p.orange, bold = true, ctermfg = 3, bold = true })
hl("Float",        { fg = p.orange, ctermfg = 3 })

hl("Identifier",   { fg = p.fg, ctermfg = 15 })
hl("Function",     { fg = p.blue, ctermfg = 6 })

hl("Statement",    { fg = p.cyan, bold = true, ctermfg = 14, bold = true })
hl("Conditional",  { fg = p.cyan, ctermfg = 14 })
hl("Repeat",       { fg = p.cyan, ctermfg = 14 })
hl("Label",        { fg = p.sand, ctermfg = 11 })
hl("Operator",     { fg = p.cyan, ctermfg = 14 })
hl("Keyword",      { fg = p.purple, ctermfg = 13 })
hl("Exception",    { fg = p.coral, ctermfg = 9 })

hl("PreProc",      { fg = p.purple, ctermfg = 13 })
hl("Include",      { fg = p.purple, ctermfg = 13 })
hl("Define",       { fg = p.purple, ctermfg = 13 })
hl("Macro",        { fg = p.yellow, ctermfg = 11 })

hl("Type",         { fg = p.sand, ctermfg = 11 })
hl("StorageClass", { fg = p.sand, ctermfg = 11 })
hl("Structure",    { fg = p.sand, ctermfg = 11 })
hl("Special",      { fg = p.orange, ctermfg = 3 })
hl("Delimiter",    { fg = p.muted, ctermfg = 8 })

hl("Underlined",   { fg = p.blue, underline = true,
                     ctermfg = 6, underline = true })
hl("Todo",         { fg = p.bg, bg = p.yellow, bold = true,
                     ctermfg = 0, ctermbg = 11, bold = true })
hl("Error",        { fg = p.coral, bold = true, ctermfg = 9, bold = true })

-- Diagnostics
hl("DiagnosticError", { fg = p.red, ctermfg = 9 })
hl("DiagnosticWarn",  { fg = p.yellow, ctermfg = 11 })
hl("DiagnosticInfo",  { fg = p.blue, ctermfg = 6 })
hl("DiagnosticHint",  { fg = p.seafoam, ctermfg = 10 })

-- Diff and Git
hl("DiffAdd",    { fg = p.seafoam, bg = p.bg_alt, ctermfg = 10, ctermbg = 0 })
hl("DiffChange", { fg = p.yellow, bg = p.bg_alt, ctermfg = 11, ctermbg = 0 })
hl("DiffDelete", { fg = p.red, bg = p.bg_alt, ctermfg = 9, ctermbg = 0 })
hl("DiffText",   { fg = p.bg, bg = p.blue, ctermfg = 0, ctermbg = 6 })
