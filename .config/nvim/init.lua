-- =============================================================================
-- Neovim Configuration - Zed Keymap Compatible
-- =============================================================================

-- Leader key
vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"

-- =============================================================================
-- Basic Options
-- =============================================================================
vim.o.number = true
vim.o.relativenumber = false
vim.o.encoding = "UTF-8"
vim.o.clipboard = "unnamed"
vim.o.termguicolors = true
vim.o.signcolumn = "yes"
vim.o.cursorline = true
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.scrolloff = 5
vim.o.updatetime = 250
vim.o.timeoutlen = 500
vim.o.linespace = 2
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.wrap = false
vim.o.ignorecase = true
vim.o.smartcase = true

-- =============================================================================
-- Bootstrap lazy.nvim
-- =============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- =============================================================================
-- Plugins
-- =============================================================================
require("lazy").setup({
  -- Theme: Ayu Dark (matching Zed)
  {
    "Shatur/neovim-ayu",
    lazy = false,
    priority = 1000,
    config = function()
      require("ayu").setup({ mirage = false })
      vim.cmd.colorscheme("ayu-dark")
    end,
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
  },

  -- File tree (matching Zed project panel)
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  -- Telescope (matching Zed file finder / search)
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- Terminal toggle (matching Zed terminal panel)
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = 15,
        open_mapping = false,
        direction = "horizontal",
      })
    end,
  },

  -- Symbols outline (matching Zed outline panel)
  {
    "hedyhli/outline.nvim",
    config = function()
      require("outline").setup()
    end,
  },

  -- Multi-cursor (matching Zed vim::SelectNext / AddSelectionBelow)
  { "mg979/vim-visual-multi" },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({ options = { theme = "ayu_dark" } })
    end,
  },

  -- Markdown preview (matching Zed markdown::OpenPreviewToTheSide)
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview" },
    build = "cd app && npm install",
    ft = { "markdown" },
  },

  -- Buffer line (tab bar)
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup()
    end,
  },
})

-- =============================================================================
-- Mason + LSP Setup (nvim 0.11+ compatible)
-- =============================================================================
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "gopls", "lua_ls" },
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- LSP keymaps via LspAttach autocmd
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local opts = { noremap = true, silent = true, buffer = ev.buf }
    local map = vim.keymap.set

    map("n", "gd", vim.lsp.buf.definition, opts)
    map("n", "fu", vim.lsp.buf.references, opts)
    map("n", "K", vim.lsp.buf.hover, opts)
    map("n", "gs", vim.lsp.buf.type_definition, opts)
    map("n", "gn", vim.lsp.buf.rename, opts)
    map("n", "gi", vim.lsp.buf.implementation, opts)
    map("n", "ge", function() vim.diagnostic.jump({ count = 1 }) end, opts)
    map("n", "gE", function() vim.diagnostic.jump({ count = -1 }) end, opts)
    map("n", "<A-CR>", vim.lsp.buf.code_action, opts)
    map("n", "<leader>rn", vim.lsp.buf.rename, opts)
    map("n", "<leader>cr", vim.lsp.buf.rename, opts)
  end,
})

-- gopls (matching Zed lsp.gopls settings)
vim.lsp.config("gopls", {
  capabilities = capabilities,
  settings = {
    gopls = {
      completeUnimported = true,
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
})
vim.lsp.enable("gopls")

-- lua_ls
vim.lsp.config("lua_ls", {
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
    },
  },
})
vim.lsp.enable("lua_ls")

-- elixir-ls (if available)
local elixir_ls_path = vim.fn.expand("~/.config/nvim/ls/language_server.sh")
if vim.fn.filereadable(elixir_ls_path) == 1 then
  vim.lsp.config("elixirls", {
    cmd = { elixir_ls_path },
    capabilities = capabilities,
  })
  vim.lsp.enable("elixirls")
end

-- =============================================================================
-- nvim-cmp Setup
-- =============================================================================
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
    { name = "path" },
  }),
})

-- =============================================================================
-- Treesitter (nvim 0.11+)
-- =============================================================================
require("nvim-treesitter").setup()
-- Auto-install parsers on FileType
vim.api.nvim_create_autocmd("FileType", {
  callback = function(ev)
    local ok, _ = pcall(vim.treesitter.start, ev.buf)
    if not ok then
      -- parser not installed yet, try to install
      local ft = ev.match
      local lang = vim.treesitter.language.get_lang(ft) or ft
      pcall(vim.cmd, "TSInstall " .. lang)
    end
  end,
})
-- Pre-install common parsers
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyDone",
  once = true,
  callback = function()
    local parsers = { "elixir", "heex", "eex", "go", "gomod", "lua", "javascript", "typescript", "json", "yaml", "markdown" }
    for _, p in ipairs(parsers) do
      pcall(vim.cmd, "TSInstall! " .. p)
    end
  end,
})

-- =============================================================================
-- nvim-tree (matching Zed ProjectPanel)
-- =============================================================================
require("nvim-tree").setup({
  on_attach = function(bufnr)
    local api = require("nvim-tree.api")
    local opts = function(desc)
      return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end
    api.config.mappings.default_on_attach(bufnr)
    vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
  end,
})

-- =============================================================================
-- Keymaps: Zed-compatible
-- =============================================================================
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Pane navigation (Zed: workspace::ActivateNextPane → ctrl-w / esc)
map("n", "<C-w>", "<C-w>w", opts)

-- File tree (Zed: project_panel::ToggleFocus)
map("n", "<leader>t", ":NvimTreeToggle<CR>", opts)
map("n", "fo", ":NvimTreeFindFile<CR>", opts)

-- File finder (Zed: file_finder::Toggle)
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", opts)
-- Global search (Zed: workspace::NewSearch)
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", opts)
-- Buffer / tab switcher (Zed: tab_switcher::Toggle)
map("n", "<leader>sw", "<cmd>Telescope buffers<CR>", opts)

-- Buffer navigation (Zed: pane::ActivateNextItem / ActivatePreviousItem)
map("n", "<leader>n", ":bnext<CR>", opts)
map("n", "<leader>p", ":bprevious<CR>", opts)

-- Close buffer (Zed: shift-B shift-D → pane::CloseActiveItem)
map("n", "BD", ":bd<CR>", opts)

-- Go back / forward (Zed: pane::GoBack / GoForward)
map("n", "gb", "<C-o>", opts)
map("n", "gf", "<C-i>", opts)

-- Split right (Zed: pane::SplitRight)
map("n", "<leader><Right>", ":vsplit<CR>", opts)

-- Symbols / outline (Zed: project_symbols::Toggle)
map("n", "<C-o>", "<cmd>Telescope lsp_document_symbols<CR>", opts)
-- Outline toggle (Zed: outline::Toggle → ctrl-s)
map("n", "<C-s>", "<cmd>Outline<CR>", opts)
-- Outline panel (Zed: outline_panel::ToggleFocus)
map("n", "<leader>ol", "<cmd>Outline<CR>", opts)

-- Diagnostics list (Zed: diagnostics::Deploy)
map("n", "<leader>e", "<cmd>Telescope diagnostics<CR>", opts)

-- Redo (Zed: editor::Redo)
map("n", "<leader>r", "<C-r>", opts)

-- Terminal toggle (Zed: terminal_panel::ToggleFocus)
map("n", "mn", "<cmd>ToggleTerm<CR>", opts)
map("t", "mn", "<cmd>ToggleTerm<CR>", opts)
-- Terminal escape to normal mode
map("t", "<Esc>", "<C-\\><C-n>", opts)

-- Task runner (Zed: task::Spawn) — open terminal for commands
map("n", "<leader>rt", "<cmd>ToggleTerm<CR>", opts)

-- Markdown preview (Zed: markdown::OpenPreviewToTheSide)
map("n", "<leader>mp", "<cmd>MarkdownPreview<CR>", opts)

-- Open excerpts / quickfix (Zed: editor::OpenExcerpts)
map("n", "<leader><CR>", "<cmd>copen<CR>", opts)

-- Visual mode: move lines (Zed: editor::MoveLineUp/Down in visual)
map("v", "<A-S-Up>", ":move '<-2<CR>gv=gv", opts)
map("v", "<A-S-Down>", ":move '>+1<CR>gv=gv", opts)

-- Normal mode line move too (convenience)
map("n", "<A-S-Up>", ":move .-2<CR>==", opts)
map("n", "<A-S-Down>", ":move .+1<CR>==", opts)

-- Insert mode arrow keys (preserved from original config)
map("i", "<C-h>", "<Left>", opts)
map("i", "<C-j>", "<Down>", opts)
map("i", "<C-k>", "<Up>", opts)
map("i", "<C-l>", "<Right>", opts)

-- Multi-cursor: vim-visual-multi defaults
-- mc → SelectNext is handled by vim-visual-multi (<C-n> by default)
-- Remap to match Zed's mc
vim.g.VM_maps = {
  ["Find Under"] = "mc",
  ["Find Subword Under"] = "mc",
  ["Add Cursor Down"] = "<C-Down>",
  ["Add Cursor Up"] = "<C-Up>",
}

-- Disable netrw (nvim-tree replaces it)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
