local g = vim.g
local o = vim.opt

-----------------------------------------------------------
-- General
-----------------------------------------------------------
g.mapleader = " "
g.maplocalleader = "\\"

o.autowrite = true -- Enable auto write
-- only set clipboard if not in ssh, to make sure the OSC 52
-- integration works automatically. Requires Neovim >= 0.10.0
o.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Sync with system clipboard
o.swapfile = false -- Don't use swapfile
o.completeopt = "menuone,noinsert,noselect" -- Autocomplete options
g.autoformat = true

-----------------------------------------------------------
-- Neovim UI
-----------------------------------------------------------
o.completeopt = "menu,menuone,noselect"
o.conceallevel = 2 -- Hide * markup for bold and italic, but not markers with substitutions
o.confirm = true -- Confirm to save changes before exiting modified buffer
o.cursorline = true -- Enable highlighting of the current line
o.expandtab = true -- Use spaces instead of tabs
o.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}
o.foldlevel = 99
o.formatoptions = "jcroqlnt" -- tcqj

o.ignorecase = true -- Ignore case
o.number = true -- Show line number

o.relativenumber = true -- Relative line numbers
o.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
o.showmatch = true -- Highlight matching parenthesis
o.foldmethod = "marker" -- Enable folding (default 'foldmarker')
o.colorcolumn = "80" -- Line lenght marker at 80 columns
o.splitright = true -- Vertical split to the right
o.splitbelow = true -- Horizontal split to the bottom
o.ignorecase = true -- Ignore case letters when search
o.smartcase = true -- Ignore lowercase for the whole pattern
o.smartindent = true -- Insert indents automatically
o.linebreak = true -- Wrap on word boundary
o.termguicolors = true -- Enable 24-bit RGB colors
o.laststatus = 3 -- Set global statusline

o.scrolloff = 4 -- Lines of context
o.undofile = true
o.undolevels = 10000

o.updatetime = 200 -- Save swap file and trigger CursorHold
o.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
o.wildmode = "longest:full,full" -- Command-line completion mode
o.wrap = false -- Disable line wrap
o.foldmethod = "indent"

-----------------------------------------------------------
-- Tabs, indent
-----------------------------------------------------------
o.expandtab = true -- Use spaces instead of tabs
o.shiftwidth = 4 -- Shift 4 spaces when tab
o.tabstop = 8 -- 1 tab == 4 spaces
o.smartindent = true -- Autoindent new lines

-----------------------------------------------------------
-- Memory, CPU
-----------------------------------------------------------
o.hidden = true -- Enable background buffers
o.history = 100 -- Remember N lines in history
o.synmaxcol = 240 -- Max column for syntax highlight
o.updatetime = 250 -- ms to wait for trigger an event

-----------------------------------------------------------
-- Startup
-----------------------------------------------------------
-- Disable nvim intro
o.shortmess:append("sI")

-- Disable builtin plugins
local disabled_built_ins = {
  "2html_plugin",
  "getscript",
  "getscriptPlugin",
  "gzip",
  "logipat",
  "netrw",
  "netrwPlugin",
  "netrwSettings",
  "netrwFileHandlers",
  "matchit",
  "tar",
  "tarPlugin",
  "rrhelper",
  "spellfile_plugin",
  "vimball",
  "vimballPlugin",
  "zip",
  "zipPlugin",
  "tutor",
  "rplugin",
  "synmenu",
  "optwin",
  "compiler",
  "bugreport",
  "ftplugin",
}

for _, plugin in pairs(disabled_built_ins) do
  g["loaded_" .. plugin] = 1
end
