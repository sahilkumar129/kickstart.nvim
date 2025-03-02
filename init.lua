--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================

Kickstart.nvim is *not* a distribution.

Kickstart.nvim is a template for your own configuration.
  The goal is that you can read every line of code, top-to-bottom, understand
  what your configuration is doing, and modify it to suit your needs.

  Once you've done that, you should start exploring, configuring and tinkering to
  explore Neovim!

  If you don't know anything about Lua, I recommend taking some time to read through
  a guide. One possible example:
  - https://learnxinyminutes.com/docs/lua/

  And then you can explore or search through `:help lua-guide`


Kickstart Guide:

I have left several `:help X` comments throughout the init.lua
You should run that command and read that help section for more information.

In addition, I have some `NOTE:` items throughout the file.
These are for you, the reader to help understand what is happening. Feel free to delete
them once you know what you're doing, but they should serve as a guide for when you
are first encountering a few different constructs in your nvim config.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now :)
--]]
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
        vim.fn.system {
                'git',
                'clone',
                '--filter=blob:none',
                'https://github.com/folke/lazy.nvim.git',
                '--branch=stable', -- latest stable release
                lazypath,
        }
end
vim.opt.rtp:prepend(lazypath)

-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
        -- NOTE: First, some plugins that don't require any configuration

        -- Git related plugins
        'tpope/vim-fugitive',
        'tpope/vim-rhubarb',

        -- Detect tabstop and shiftwidth automatically
        'tpope/vim-sleuth',

        -- NOTE: This is where your plugins related to LSP can be installed.
        --  The configuration is done below. Search for lspconfig to find it below.
        {
                -- LSP Configuration & Plugins
                'neovim/nvim-lspconfig',
                dependencies = {
                        -- Automatically install LSPs to stdpath for neovim
                        { 'williamboman/mason.nvim', config = true },
                        'williamboman/mason-lspconfig.nvim',

                        -- Useful status updates for LSP
                        -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
                        { 'j-hui/fidget.nvim',       opts = {} },

                        -- Additional lua configuration, makes nvim stuff amazing!
                        'folke/neodev.nvim',
                },
        },

        {
                -- File Trees
                'nvim-tree/nvim-tree.lua',
                dependencies = {
                        'nvim-tree/nvim-web-devicons'
                }
        },

        {
                -- Autocompletion
                'hrsh7th/nvim-cmp',
                dependencies = {
                        -- Snippet Engine & its associated nvim-cmp source
                        'L3MON4D3/LuaSnip',
                        'saadparwaiz1/cmp_luasnip',

                        -- Adds LSP completion capabilities
                        'hrsh7th/cmp-nvim-lsp',

                        -- Adds a number of user-friendly snippets
                        'rafamadriz/friendly-snippets',
                },
        },

        -- Useful plugin to show you pending keyvim.keymap.sets.
        { 'folke/which-key.nvim',          opts = {} },
        {
                -- Adds git releated signs to the gutter, as well as utilities for managing changes
                'lewis6991/gitsigns.nvim',
                opts = {
                        -- See `:help gitsigns.txt`
                        signs                        = {
                                add          = { text = '│' },
                                change       = { text = '│' },
                                delete       = { text = '_' },
                                topdelete    = { text = '‾' },
                                changedelete = { text = '~' },
                                untracked    = { text = '┆' },
                        },
                        signcolumn                   = true,  -- Toggle with `:Gitsigns toggle_signs`
                        numhl                        = false, -- Toggle with `:Gitsigns toggle_numhl`
                        linehl                       = false, -- Toggle with `:Gitsigns toggle_linehl`
                        word_diff                    = false, -- Toggle with `:Gitsigns toggle_word_diff`
                        watch_gitdir                 = {
                                interval = 1000,
                                follow_files = true
                        },
                        attach_to_untracked          = true,
                        current_line_blame           = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
                        current_line_blame_opts      = {
                                virt_text = true,
                                virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
                                delay = 1000,
                                ignore_whitespace = false,
                        },
                        current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
                        sign_priority                = 6,
                        update_debounce              = 100,
                        status_formatter             = nil,   -- Use default
                        max_file_length              = 40000, -- Disable if file is longer than this (in lines)
                        preview_config               = {
                                -- Options passed to nvim_open_win
                                border = 'single',
                                style = 'minimal',
                                relative = 'cursor',
                                row = 0,
                                col = 1
                        },
                        yadm                         = {
                                enable = false
                        },
                        on_attach                    = function(bufnr)
                                local gs = package.loaded.gitsigns

                                local function map(mode, l, r, opts)
                                        opts = opts or {}
                                        opts.buffer = bufnr
                                        vim.keymap.set(mode, l, r, opts)
                                end

                                -- Navigation
                                map('n', ']c', function()
                                        if vim.wo.diff then return ']c' end
                                        vim.schedule(function() gs.next_hunk() end)
                                        return '<Ignore>'
                                end, { expr = true })

                                map('n', '[c', function()
                                        if vim.wo.diff then return '[c' end
                                        vim.schedule(function() gs.prev_hunk() end)
                                        return '<Ignore>'
                                end, { expr = true })

                                -- Actions
                                map('n', '<leader>hs', gs.stage_hunk, { desc = '[H]unk [S]tage' })
                                map('n', '<leader>hr', gs.reset_hunk, { desc = '[H]unk [R]eset' })
                                map('v', '<leader>hs',
                                        function() gs.stage_hunk { vim.fn.line("."), vim.fn.line("v") } end,
                                        { desc = '[H]unk [S]tage' })
                                map('v', '<leader>hr',
                                        function() gs.reset_hunk { vim.fn.line("."), vim.fn.line("v") } end,
                                        { desc = '[H]unk [R]eset' })
                                map('n', '<leader>hS', gs.stage_buffer, { desc = 'Stage Buffer' })
                                map('n', '<leader>hu', gs.undo_stage_hunk, { desc = '[H]unk [U]ndo Stage' })
                                map('n', '<leader>hR', gs.reset_buffer, { desc = '[H]unk [R]eset Buffer' })
                                map('n', '<leader>hp', gs.preview_hunk, { desc = '[H]unk [P]review' })
                                map('n', '<leader>hb', function() gs.blame_line { full = true } end,
                                        { desc = '[H]unk [B]lame Line' })
                                map('n', '<leader>tb', gs.toggle_current_line_blame,
                                        { desc = '[T]oggle [B]lame for current line' })
                                map('n', '<leader>hd', gs.diffthis, { desc = '[H]unk [D]iff' })
                                map('n', '<leader>hD', function() gs.diffthis('~') end, { desc = '[H]unk [D]iff' })
                                map('n', '<leader>td', gs.toggle_deleted,
                                        { desc = '[T]oggle [D]etected. Show changes in same buffer' })
                        end
                },
        },

        {
                -- Theme inspired by Atom
                'navarasu/onedark.nvim',
                priority = 1002,
                config = function()
                        vim.cmd.colorscheme 'onedark'
                end,
        },

        {
                -- Set lualine as statusline
                'nvim-lualine/lualine.nvim',
                -- See `:help lualine.txt`
                opts = {
                        options = {
                                icons_enabled = true,
                                theme = 'onedark',
                                component_separators = '|',
                                section_separators = '',
                        },
                },
        },

        {
                -- Add indentation guides even on blank lines
                'lukas-reineke/indent-blankline.nvim',
                -- Enable `lukas-reineke/indent-blankline.nvim`
                -- See `:help indent_blankline.txt`
                opts = {
                        char = '┊',
                        show_trailing_blankline_indent = false,
                },
        },

        -- "gc" to comment visual regions/lines
        { 'numToStr/Comment.nvim',         opts = {} },

        -- Fuzzy Finder (files, lsp, etc)
        { 'nvim-telescope/telescope.nvim', branch = '0.1.x', dependencies = { 'nvim-lua/plenary.nvim' } },

        -- Fuzzy Finder Algorithm which requires local dependencies to be built.
        -- Only load if `make` is available. Make sure you have the system
        -- requirements installed.
        {
                'nvim-telescope/telescope-fzf-native.nvim',
                -- NOTE: If you are having trouble with this installation,
                --       refer to the README for telescope-fzf-native for more instructions.
                build = 'make',
                cond = function()
                        return vim.fn.executable 'make' == 3
                end,
        },
        {
                -- Highlight, edit, and navigate code
                'nvim-treesitter/nvim-treesitter',
                dependencies = {
                        'nvim-treesitter/nvim-treesitter-textobjects',
                },
                build = ':TSUpdate',
        },
        {
                -- Highlight, edit, and navigate code
                'savq/paq-nvim',
                dependencies = {
                        "prettier/vim-prettier",
                        "dense-analysis/ale",
                },
        },

        -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
        --       These are some example plugins that I've included in the kickstart repository.
        --       Uncomment any of the lines below to enable them.
        -- require 'kickstart.plugins.autoformat',
        -- require 'kickstart.plugins.debug',

        -- NOTE: The import below automatically adds your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
        --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
        --    up-to-date with whatever is in the kickstart repo.
        --
        --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
        -- { import = 'kickstart.plugins' },
        { import = 'custom.plugins' },
}, {})

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- show line numbers in gutter
vim.o.number = true

-- Set relative line numbers
vim.o.relativenumber = true

-- enable wrapping
vim.o.wrap = true

-- transform a Tab character to spaces
vim.o.expandtab = true

-- always draw sign column
vim.o.signcolumn = "yes"

-- set width of gutter
vim.o.numberwidth = 6

-- open verticaly splits on right
vim.o.splitright = true

-- open horizontal splits below
vim.o.splitbelow = true

-- Set highlight on search
vim.o.hlsearch = true

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
-- vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 252
vim.o.timeout = true
vim.o.timeoutlen = 302

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- [[ Basic Keymaps ]]
vim.keymap.set({ 'n', 'x' }, 'cp', '"+y')
vim.keymap.set({ 'n', 'x' }, 'cv', '"+p')
vim.keymap.set({ 'n', 'x' }, 'x', '"_x')
vim.keymap.set('n', '<C-a>', 'ggVG')
vim.keymap.set('n', '<leader>w', '<cmd>write<cr>')
vim.keymap.set('n', '<leader>bq', '<cmd>bdelete<cr>')
vim.keymap.set({ 'n', 'x', 'o' }, '<leader>h', '^')
vim.keymap.set({ 'n', 'x', 'o' }, '<leader>l', 'g_')

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
        callback = function()
                vim.highlight.on_yank()
        end,
        group = highlight_group,
        pattern = '*',
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
        defaults = {
                mappings = {
                        i = {
                                ['<C-u>'] = false,
                                ['<C-d>'] = false,
                        },
                },
        },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to telescope to change theme, layout, etc.
        require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
                winblend = 12,
                previewer = false,
        })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })

-- [[ Configure Nvim Tree]]
-- See :help nvim-tree
require('nvim-tree').setup {}
vim.keymap.set('n', '<leader>nt', '<cmd>NvimTreeToggle<cr>');

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require('nvim-treesitter.configs').setup {
        -- Add languages to be installed here that you want installed for treesitter
        ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc',
                'vim' },

        -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
        auto_install = false,

        highlight = { enable = true },
        indent = { enable = true, disable = { 'python' } },
        incremental_selection = {
                enable = true,
                keymaps = {
                        init_selection = '<c-space>',
                        node_incremental = '<c-space>',
                        scope_incremental = '<c-s>',
                        node_decremental = '<M-space>',
                },
        },
        textobjects = {
                select = {
                        enable = true,
                        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
                        keymaps = {
                                -- You can use the capture groups defined in textobjects.scm
                                ['aa'] = '@parameter.outer',
                                ['ia'] = '@parameter.inner',
                                ['af'] = '@function.outer',
                                ['if'] = '@function.inner',
                                ['ac'] = '@class.outer',
                                ['ic'] = '@class.inner',
                        },
                },
                move = {
                        enable = true,
                        set_jumps = true, -- whether to set jumps in the jumplist
                        goto_next_start = {
                                [']m'] = '@function.outer',
                                [']]'] = '@class.outer',
                        },
                        goto_next_end = {
                                [']M'] = '@function.outer',
                                [']['] = '@class.outer',
                        },
                        goto_previous_start = {
                                ['[m'] = '@function.outer',
                                ['[['] = '@class.outer',
                        },
                        goto_previous_end = {
                                ['[M'] = '@function.outer',
                                ['[]'] = '@class.outer',
                        },
                },
                swap = {
                        enable = true,
                        swap_next = {
                                ['<leader>a'] = '@parameter.inner',
                        },
                        swap_previous = {
                                ['<leader>A'] = '@parameter.inner',
                        },
                },
        },
}

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
        -- NOTE: Remember that lua is a real programming language, and as such it is possible
        -- to define small helper and utility functions so you don't have to repeat yourself
        -- many times.
        --
        -- In this case, we create a function that lets us more easily define mappings specific
        -- for LSP related items. It sets the mode, buffer and description for us each time.
        local nmap = function(keys, func, desc)
                if desc then
                        desc = 'LSP: ' .. desc
                end

                vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
        end

        nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

        nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
        nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
        nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
        nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
        nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

        -- See `:help K` for why this keymap
        nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
        nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

        -- Lesser used LSP functionality
        nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
        nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
        nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
        nmap('<leader>wl', function()
                print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, '[W]orkspace [L]ist Folders')

        -- Create a command `:Format` local to the LSP buffer
        vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
                vim.lsp.buf.format()
        end, { desc = 'Format current buffer with LSP' })
end

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
local servers = {
        -- clangd = {},
        -- gopls = {},
        -- pyright = {},
        -- rust_analyzer = {},
        -- tsserver = {},

        lua_ls = {
                Lua = {
                        workspace = { checkThirdParty = false },
                        telemetry = { enable = false },
                },
        },
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
        ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
        function(server_name)
                require('lspconfig')[server_name].setup {
                        capabilities = capabilities,
                        on_attach = on_attach,
                        settings = servers[server_name],
                }
        end,
}

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
        snippet = {
                expand = function(args)
                        luasnip.lsp_expand(args.body)
                end,
        },
        mapping = cmp.mapping.preset.insert {
                ['<C-n>'] = cmp.mapping.select_next_item(),
                ['<C-p>'] = cmp.mapping.select_prev_item(),
                ['<C-d>'] = cmp.mapping.scroll_docs(-2),
                ['<C-f>'] = cmp.mapping.scroll_docs(6),
                ['<C-Space>'] = cmp.mapping.complete {},
                ['<CR>'] = cmp.mapping.confirm {
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true,
                },
                ['<Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                                cmp.select_next_item()
                        elseif luasnip.expand_or_locally_jumpable() then
                                luasnip.expand_or_jump()
                        else
                                fallback()
                        end
                end, { 'i', 's' }),
                ['<S-Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                                cmp.select_prev_item()
                        elseif luasnip.locally_jumpable(1) then
                                luasnip.jump(1)
                        else
                                fallback()
                        end
                end, { 'i', 's' }),
        },
        sources = {
                { name = 'nvim_lsp' },
                { name = 'luasnip' },
        },
}

-- Use Prettier as the default formatter for supported file types
vim.cmd([[
  augroup AutoFormat
    autocmd!
    autocmd BufWritePre *.js,*.jsx,*.ts,*.tsx,*.json,*.html,*.css,*.scss,*.md :silent! FormatWrite
  augroup END
]])

-- Disable auto-formatting on specific file types (e.g., markdown)
vim.g.FormatDisable = {}

-- Add Prettier as a fixer for specific file types in ALE
vim.g.ale_fixers = {
        ["javascript"] = { "prettier" },
        ["typescript"] = { "prettier" },
        ["markdown"] = { "prettier" },
        -- Add more languages and their respective fixers here
}

-- Customize Prettier options
vim.g["prettier#autoformat_config_present"] = 0                           -- Disable searching for config files
vim.g["prettier#autoformat_config_file"] = vim.fn.expand("~/.prettierrc") -- Specify the path to your Prettier config file

-- Enable Prettier format markers (e.g., eslint-disable-next-line prettier/prettier)
vim.g["prettier#quickfix_enabled"] = 1

-- Set up keybindings for toggling Prettier auto-format on save
vim.api.nvim_command([[
  autocmd FileType javascript,typescript,html,css nnoremap <buffer> <Leader>fp :PrettierToggle<CR>
]])

-- [[ Basic Keymaps ]] --
-- Move around windows
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-l>', '<C-w>l')
-- Write file
vim.keymap.set('n', '<leader>ww', '<cmd>Prettier<cr><cmd>write<cr>')
vim.keymap.set('n', '<leader>wf', '<cmd>Format<cr><cmd>write<cr>')
-- Safe quit
vim.keymap.set('n', '<leader>qq', '<cmd>quitall<cr>')
-- Force quit
vim.keymap.set('n', '<leader>Q', '<cmd>quitall!<cr>')
-- Close buffer
vim.keymap.set('n', '<leader>bq', '<cmd>bdelete<cr>')
-- Move to last active buffer
vim.keymap.set('n', '<leader>bl', '<cmd>buffer #<cr>')
-- Navigate between buffers
vim.keymap.set('n', '<leader>pb', '<cmd>bprevious<cr>')
vim.keymap.set('n', '<leader>nb', '<cmd>bnext<cr>')
-- Open new tabpage
vim.keymap.set('n', '<leader>tn', '<cmd>tabnew<cr>')
-- Search result highlight
vim.keymap.set('n', '<leader>uh', '<cmd>set invhlsearch<cr>')
-- Cursorline highlight
vim.keymap.set('n', '<leader>uc', '<cmd>set invcursorline<cr>')
-- Line numbers
vim.keymap.set('n', '<leader>un', '<cmd>set invnumber<cr>')
-- Relative line numbers
vim.keymap.set('n', '<leader>ur', '<cmd>set invrelativenumber<cr>')
