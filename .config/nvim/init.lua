-- ############################################################################ [[ Globals ]]

-- Leader must be set before lazy.nvim loads plugins
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
-- Lua bytecode cache for faster startup
vim.loader.enable()
-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- ############################################################################ [[ Options ]]

-- Force Neovim to always request dark assets
vim.o.background = 'dark'
-- Make line numbers default
vim.o.number = true
vim.o.relativenumber = false
-- Enable mouse mode, can be useful for resizing splits for example!
vim.o.mouse = 'a'
-- Don't show the mode, since it's already in the status line
vim.o.showmode = false
-- Sync clipboard between OS and Neovim.
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)
-- Enable break indent
vim.o.breakindent = true
-- Stops Neovim from creating .swp files (recovery files).
vim.o.swapfile = false
-- Stops Neovim from making a backup copy of a file before saving it.
vim.o.backup = false
-- Enable undo/redo changes even after closing and reopening a file
vim.o.undofile = true
-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true
-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'
-- Decrease update time
vim.o.updatetime = 250
-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300
-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true
-- Sets how neovim will display certain whitespace characters in the editor.
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'
-- Show which line your cursor is on
vim.o.cursorline = true
-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 5
-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
vim.o.confirm = true
-- Enables 24-bit RGB color in the terminal (required for modern themes)
vim.o.termguicolors = true
-- Makes the completion menu (pop-up menu) slightly transparent
vim.o.pumblend = 10
-- Makes floating windows (like documentation or diagnostics) slightly transparent
vim.o.winblend = 10
-- Enables pixel-perfect scrolling for long lines wrapped onto multiple rows
vim.o.smoothscroll = true
-- Uses Treesitter (code analysis) to determine where code blocks can be folded
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
-- Keeps all code blocks unfolded (open) by default when you open a file
vim.o.foldenable = false
-- Allow backspace on indent, eol, and start
vim.o.backspace = 'indent,eol,start'
-- Defines how selection works; 'exclusive' means the character under the cursor is not included
vim.o.selection = 'exclusive'
-- Allows special keys (like Shift + Arrows) to start and stop text selection
vim.o.keymodel = 'startsel,stopsel'
-- A tab character looks like 4 spaces wide.
vim.o.tabstop = 4
-- While editing, hitting Tab feels like 4 spaces.
vim.o.softtabstop = 4
-- The amount of space used for automated indentation (like when you hit Enter)
vim.o.shiftwidth = 4
-- Converts all tabs into actual spaces.
vim.o.expandtab = true
--  Automatically indents the next line based on the code logic (like after a {).
vim.o.smartindent = true
-- Long lines won't wrap to the next row
vim.o.wrap = false
-- Stops highlighting all matches after you finish a search.
vim.o.hlsearch = false
-- Highlights matches as you type your search query.
vim.o.incsearch = true

-- ############################################################################ [[ Basic Autocommands ]]

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('HighlightYank', { clear = true }),
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 500,
        })
    end,
})

-- ############################################################################ [[ Plugins ]]

vim.pack.add({
    -- [[ Colorscheme ]]
    'https://github.com/folke/tokyonight.nvim',
    -- [[ Snacks ]]
    'https://github.com/nvim-tree/nvim-web-devicons',
    'https://github.com/folke/snacks.nvim',
    -- [[ UI ]]
    'https://github.com/folke/which-key.nvim',
    'https://github.com/echasnovski/mini.nvim',
    'https://github.com/stevearc/oil.nvim',
})

-- ############################################################################ [[ Plugins ]] Colorscheme

---@class tokyonight.Config
require('tokyonight').setup({
    style = 'night',
    transparent = false,
    terminal_colors = true,
    styles = {
        comments = { italic = true },
        keywords = { bold = true },
        functions = {},
        variables = {},
    },
    on_colors = function(colors)
        colors.git.change = colors.yellow
        colors.git.add = colors.green2
    end,
    on_highlights = function(highlights, colors)
        highlights.NormalFloat = { fg = colors.fg, bg = colors.bg_dark }
        highlights.FloatBorder = { fg = colors.blue, bg = colors.bg_dark }
        highlights.FloatTitle = { fg = colors.blue, bg = colors.bg_dark, bold = true }
    end,
})
vim.cmd.colorscheme('tokyonight')

-- ############################################################################ [[ Plugins ]] Snacks

---@type snacks.Config
require('snacks').setup({
    bigfile = { enabled = true },
    explorer = { enabled = true },
    picker = {
        enabled = true,
        hidden = true,
        ignored = true,
    },
    project = {
        dirs = {
            '~/projects',
        },
    },
    indent = {
        enabled = true,
        only_scope = true,
        only_current = true,
        scope = { hl = 'SnacksIndent1', bold = true, underline = true },
        animate = { enabled = false },
    },
    scope = { enabled = false },
    terminal = {
        win = { position = 'bottom', height = 15 },
    },
    notifier = { enabled = true },
    statuscolumn = { enabled = true },
    zen = { enabled = false },
    dashboard = {
        enabled = true,
        sections = {
            { section = 'header' },
            { icon = ' ', title = 'Projects', section = 'projects', indent = 2, padding = 1 },
            { icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1 },
            { icon = ' ', title = 'Keymaps', section = 'keys', indent = 2, padding = 1 },
        },
    },
})

-- ############################################################################ [[ Plugins ]] UI

-- which-key
require('which-key').setup({
    delay = 0,
    icons = { mappings = vim.g.have_nerd_font },
    spec = {
        { '<leader>s', group = '[S]earch' },
    },
})

-- mini.nvim (only icons + statusline)
require('mini.icons').setup()
require('mini.ai').setup({ n_lines = 500 })
require('mini.surround').setup()
local statusline = require('mini.statusline')
statusline.setup({ use_icons = vim.g.have_nerd_font })
---@diagnostic disable-next-line: duplicate-set-field
statusline.section_location = function() return '%2l:%-2v' end

-- oil
require('oil').setup({
    columns = { 'icon' },
    keymaps = {
        ['<C-l>'] = false,
        ['<C-j>'] = false,
        ['<M-h>'] = 'actions.select_split',
        ['q'] = 'actions.close',
        ['<Esc>'] = 'actions.close',
    },
    view_options = { show_hidden = true },
})

-- ############################################################################ [[ Keymaps ]]

local map = vim.keymap.set

-- [[ Global ]]
map({ 'n', 'i' },           '<C-t>', '<cmd>enew<CR>',     { silent = true, desc = 'New tab' })
map({ 'n', 'i' },           '<C-w>', '<cmd>bdelete!<CR>', { silent = true, desc = 'Close Tab' })
map({ 'n', 'i', 'v', 't' }, '<C-q>', '<cmd>qa!<cr>',      { desc = 'Exit Nvim (Force)' })
-- Select All
map({ 'n', 'i' }, '<C-a>', '<Esc>ggVG', { desc = 'Select All' })
-- Save
map({ 'n', 'v' }, '<C-s>', '<Esc>:w<CR>',  { desc = 'Save' })
map('i',          '<C-s>', '<Esc>:w<CR>i', { desc = 'Save' })
-- Copy/Paste/Cut
map('n', '<C-c>', '"+yy',       { desc = 'Copy Line' })
map('i', '<C-c>', '<Esc>"+yyi', { desc = 'Copy Line' })
map('v', '<C-c>', '"+y',        { desc = 'Copy Selection' })
map('n', '<C-v>', '"+p',        { desc = 'Paste' })
map('i', '<C-v>', '<C-r>+',     { desc = 'Paste' })
map('n', '<C-x>', '"+dd',       { desc = 'Cut line' })
map('i', '<C-x>', '<Esc>"+ddi', { desc = 'Cut line' })
map('v', '<C-x>', '"+x',        { desc = 'Cut selection' })
-- Move by words
map('i', '<C-Left>',   '<C-O>b',  { desc = 'Move word backward' })
map('i', '<C-Right>',  '<C-O>w',  { desc = 'Move word forward' })
-- Move the current line
map({ 'n', 'i' }, '<A-Up>',   '<Esc>:m .-2<CR>==gi', { desc = 'Move line up' })
map({ 'n', 'i' }, '<A-Down>', '<Esc>:m .+1<CR>==gi', { desc = 'Move line down' })
-- Undo/Redo
map({ 'n', 'i' }, '<C-z>', '<Esc>u',     { desc = 'Undo' })
map({ 'n', 'i' }, '<C-y>', '<Esc><C-r>', { desc = 'Redo' })
-- Jump Back/Forward
map('n', '<A-Left>',  '<C-o>',      { desc = 'Jump Back' })
map('i', '<A-Left>',  '<C-o><C-o>', { desc = 'Jump Back' })
map('n', '<A-Right>', '<C-i>',      { desc = 'Jump Forward' })
map('i', '<A-Right>', '<C-o><C-i>', { desc = 'Jump Forward' })
-- Better Indenting
map('n', '<Tab>',   '>>',    { desc = 'Indent line' })
map('i', '<Tab>',   '<C-t>', { desc = 'Indent line' })
map('v', '<Tab>',   '>gv',   { desc = 'Indent selected block' })
map('n', '<S-Tab>', '<<',    { desc = 'Outdent line' })
map('i', '<S-Tab>', '<C-d>', { desc = 'Outdent line' })
map('v', '<S-Tab>', '<gv',   { desc = 'Outdent selected block' })
-- Delete by words
map('i', '<C-H>',      '<C-W>',   { desc = 'Delete word backward' })
map('i', '<C-Delete>', '<C-O>dw', { desc = 'Delete word forward' })
-- Delete in Visual mode without copying it
map('v', '<BS>',     '"_d', { desc = 'Delete selection' })
map('v', '<Delete>', '"_d', { desc = 'Delete selection' })

-- [[ Focus Navigation ]]
map({ 'n' }, '<S-Left>',  '<C-o><C-w>h', { desc = 'Move focus left' })
map({ 'n' }, '<S-Right>', '<C-o><C-w>l', { desc = 'Move focus right' })
map({ 'n' }, '<S-Up>',    '<C-o><C-w>k', { desc = 'Move focus up' })
map({ 'n' }, '<S-Down>',  '<C-o><C-w>j', { desc = 'Move focus down' })

-- [[ Tools & Plugins ]]
map('n', '<leader>d', function() Snacks.dashboard.open() end,         { desc = '[D]ashboard' })
map('n', '<leader>o', require('oil').toggle_float,                    { desc = '[O]il' })
map('n', '<leader>i', function() Snacks.toggle.indent():toggle() end, { desc = 'Toggle [I]ndent Visibility' })

-- [[ Search ]]
map({ 'n', 'i' }, '<C-f>',   function() Snacks.picker.lines() end, { desc = 'Search in File' })
map({ 'n', 'i' }, '<C-S-f>', function() Snacks.picker.grep() end,  { desc = 'Global Search (Grep)' })
map('n', '<leader>sl', function() Snacks.picker.lines() end,       { desc = '[S]earch [L]ine' })
map('n', '<leader>sg', function() Snacks.picker.grep() end,        { desc = '[S]earch by [G]rep' })
map('n', '<leader>sf', function() Snacks.picker.smart() end,       { desc = '[S]earch [F]iles (Smart)' })
map('n', '<leader>sF', function() Snacks.picker.files() end,       { desc = '[S]earch [F]iles' })
map('n', '<leader>sw', function() Snacks.picker.grep_word() end,   { desc = '[S]earch current [W]ord' })
map('n', '<leader>sp', function() Snacks.picker.projects() end,    { desc = '[S]earch [P]rojects' })
map('n', '<leader>sr', function() Snacks.picker.resume() end,      { desc = '[S]earch [R]esume' })
map('n', '<leader>sR', ':%s//g<Left><Left>',                       { desc = '[S]earch and [R]eplace in current File' })
map('n', '<leader>sk', function() Snacks.picker.keymaps() end,     { desc = '[S]earch [K]eymaps' })
map('n', '<Esc>',      '<cmd>nohlsearch<CR>',                      { desc = 'Clear search highlights' })

-- [[ Terminal ]]
map({ 'n', 'i', 't' }, '<C-j>', function() Snacks.terminal.toggle() end, { desc = 'Toggle Terminal' })

