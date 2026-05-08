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
vim.o.scrolloff = 0
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
-- Only use OSC 52 if we are in an SSH session
if vim.env.SSH_TTY then
    vim.g.clipboard = {
        name = 'OSC 52',
        copy = {
            ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
            ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
        },
        paste = {
            ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
            ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
        },
    }
else
    -- Sync clipboard between OS and Neovim.
    vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)
end

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
    -- [[ Editor Utilities ]]
    'https://github.com/windwp/nvim-autopairs',
    'https://github.com/nvim-treesitter/nvim-treesitter-context',
    'https://github.com/brenoprata10/nvim-highlight-colors',
    'https://github.com/lambdalisue/suda.vim',
    -- [[ Git ]]
    'https://github.com/lewis6991/gitsigns.nvim',
    -- [[ UI ]]
    'https://github.com/folke/which-key.nvim',
    'https://github.com/echasnovski/mini.nvim',
    'https://github.com/akinsho/bufferline.nvim',
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

-- ############################################################################ [[ Plugins ]] Editor Utilities

-- autopairs
require('nvim-autopairs').setup({})

-- treesitter-context
require('treesitter-context').setup({ max_lines = 3 })

-- nvim-highlight-colors
require('nvim-highlight-colors').setup({
    render = 'background',
    exclude_filetypes = { 'c', 'cpp' },
})

-- suda
vim.g.suda_smart_edit = 1

-- ############################################################################ [[ Plugins ]] Git

-- gitsigns
require('gitsigns').setup({
    signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_', show_count = true },
        topdelete = { text = '‾', show_count = true },
        changedelete = { text = '~', show_count = true },
    },
})

-- ############################################################################ [[ Plugins ]] UI

-- which-key
require('which-key').setup({
    delay = 0,
    icons = { mappings = vim.g.have_nerd_font },
    spec = {
        { '<leader>s', group = '[S]earch' },
        { '<leader>g', group = '[G]it' },
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

-- bufferline
require('bufferline').setup({
    options = {
        mode = 'buffers',
        diagnostics = 'nvim_lsp',
        offsets = { { filetype = 'snacks_layout_box', text = 'Explorer' } },
        separator_style = 'slant',
        always_show_bufferline = true,
        enforce_regular_tabs = true,
    },
    highlights = {
        buffer_selected = { bold = true, italic = false },
        indicator_selected = { bold = true },
    },
})

-- oil
require('oil').setup({
    columns = { 'icon' },
    keymaps = {
        ['q'] = 'actions.close',
        ['<Esc>'] = 'actions.close',
    },
    view_options = { show_hidden = true },
})

-- ############################################################################ [[ Keymaps ]]

local map = vim.keymap.set
local gs = require('gitsigns')

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
map('v',          '<A-Up>',   ":m '<-2<CR>gv=gv",    { desc = 'Move selection up' })
map('v',          '<A-Down>', ":m '>+1<CR>gv=gv",    { desc = 'Move selection down' })
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
-- Comment/Uncomment
map('n', '<C-/>', 'gcc',       { remap = true, desc = 'Comment line' })
map('n', '<C-_>', 'gcc',       { remap = true, desc = 'Comment line' })
map('i', '<C-/>', '<Esc>gccA', { remap = true, desc = 'Comment line' })
map('i', '<C-_>', '<Esc>gccA', { remap = true, desc = 'Comment line' })
map('v', '<C-/>', 'gc',        { remap = true, desc = 'Comment selection' })
map('v', '<C-_>', 'gc',        { remap = true, desc = 'Comment selection' })
-- Delete by words
map('i', '<C-H>',      '<C-W>',   { desc = 'Delete word backward' })
map('i', '<C-Delete>', '<C-O>dw', { desc = 'Delete word forward' })
-- Delete in Visual mode without copying it
map('v', '<BS>',     '"_d', { desc = 'Delete selection' })
map('v', '<Delete>', '"_d', { desc = 'Delete selection' })

-- [[ Tab Navigation ]]
map({ 'n', 'i' }, '<C-Tab>',   '<C-^>',                           { silent = true })
map({ 'n', 'i' }, '<F1>',      '<cmd>BufferLineGoToBuffer 1<CR>', { silent = true })
map({ 'n', 'i' }, '<F2>',      '<cmd>BufferLineGoToBuffer 2<CR>', { silent = true })
map({ 'n', 'i' }, '<F3>',      '<cmd>BufferLineGoToBuffer 3<CR>', { silent = true })
map({ 'n', 'i' }, '<F4>',      '<cmd>BufferLineGoToBuffer 4<CR>', { silent = true })
map({ 'n', 'i' }, '<F5>',      '<cmd>BufferLineGoToBuffer 5<CR>', { silent = true })

-- [[ Focus Navigation ]]
map({ 'n' }, '<S-Left>',  '<C-o><C-w>h', { desc = 'Move focus left' })
map({ 'n' }, '<S-Right>', '<C-o><C-w>l', { desc = 'Move focus right' })
map({ 'n' }, '<S-Up>',    '<C-o><C-w>k', { desc = 'Move focus up' })
map({ 'n' }, '<S-Down>',  '<C-o><C-w>j', { desc = 'Move focus down' })

-- [[ Tools & Plugins ]]
map({ 'n', 'i' }, '<C-e>',     Snacks.explorer.open,                  { desc = 'Explorer' })
map('n',          '<leader>d', Snacks.dashboard.open,                 { desc = '[D]ashboard' })
map('n',          '<leader>o', require('oil').toggle_float,           { desc = '[O]il' })
map('n', '<leader>i', function() Snacks.toggle.indent():toggle() end, { desc = 'Toggle [I]ndent Visibility' })

-- [[ Search ]]
map({ 'n', 'i' }, '<C-f>',   Snacks.picker.lines, { desc = 'Search in File' })
map({ 'n', 'i' }, '<C-S-f>', Snacks.picker.grep,  { desc = 'Global Search (Grep)' })
map('n', '<leader>sl', Snacks.picker.lines,       { desc = '[S]earch [L]ine' })
map('n', '<leader>sg', Snacks.picker.grep,        { desc = '[S]earch by [G]rep' })
map('n', '<leader>sf', Snacks.picker.smart,       { desc = '[S]earch [F]iles (Smart)' })
map('n', '<leader>sF', Snacks.picker.files,       { desc = '[S]earch [F]iles' })
map('n', '<leader>sw', Snacks.picker.grep_word,   { desc = '[S]earch current [W]ord' })
map('n', '<leader>sp', Snacks.picker.projects,    { desc = '[S]earch [P]rojects' })
map('n', '<leader>sr', Snacks.picker.resume,      { desc = '[S]earch [R]esume' })
map('n', '<leader>sR', ':%s//g<Left><Left>',      { desc = '[S]earch and [R]eplace in current File' })
map('n', '<leader>sk', Snacks.picker.keymaps,     { desc = '[S]earch [K]eymaps' })
map('n', '<Esc>',      '<cmd>nohlsearch<CR>',     { desc = 'Clear search highlights' })

-- [[ Git ]]
map('n', '<leader>gs', gs.stage_hunk,                { desc = '[S]tage Hunk' })
map('n', '<leader>gr', gs.reset_hunk,                { desc = '[R]eset Hunk' })
map('n', '<leader>gp', gs.preview_hunk,              { desc = '[P]review Hunk' })
map('n', '<leader>gS', gs.stage_buffer,              { desc = '[S]tage File' })
map('n', '<leader>gR', gs.reset_buffer,              { desc = '[R]eset File' })
map('n', '<leader>gb', gs.toggle_current_line_blame, { desc = '[B]lame Toggle' })
map('n', '<leader>gB', function()
    gs.blame_line({ full = true })
end,                                                 { desc = '[B]lame Line' })
map('n', '<leader>gt', function()
    Snacks.picker.git_log({ follow = true, current_file = true, })
end,                                                 { desc = '[T]imeline' })
map('n', '<leader>gd', function()
    if vim.wo.diff then vim.cmd('diffoff!') vim.cmd('only')
    else gs.diffthis() end
end,                                                 { desc = '[D]iff Toggle' })
vim.api.nvim_create_user_command('GitDiff', function(opts)
    if opts.args == "status" then
        Snacks.picker.git_diff()
    else
        local base = opts.args ~= "" and opts.args or nil
        gs.diffthis(base)
    end
end, { nargs = '?' })

-- [[ Terminal ]]
map({ 'n', 'i', 't' }, '<C-j>', Snacks.terminal.toggle, { desc = 'Toggle Terminal' })

-- [[ URL ]]
map('n', '<leader>w', function()
    local target = vim.fn.expand('<cfile>')
    if target:match('^https?://') then
        vim.ui.open(target)
    else
        vim.notify('No URL found under cursor', vim.log.levels.WARN)
    end
end, { desc = '[W]eb open URL' })

