-- =============================================================================
-- Neovim Configuration - Zed Keymap Compatible
-- =============================================================================

-- Leader key
vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"

-- =============================================================================
-- Basic Options
-- =============================================================================
vim.opt.number = true
vim.opt.relativenumber = false
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
vim.o.autowriteall = true
vim.o.autoread = true

-- Treesitter-based folding
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldlevel = 99

-- Auto-save & auto-reload every 5 seconds (GoLand-style)
local timer = vim.uv.new_timer()
timer:start(5000, 5000, vim.schedule_wrap(function()
  -- Auto-save modified buffers
  pcall(vim.cmd, "silent! wall")
  -- Auto-reload externally changed files
  pcall(vim.cmd, "checktime")
end))

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
  -- Theme: Cyberdream
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.o.background = "dark"
      vim.cmd.colorscheme("cyberdream")
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
      "rafamadriz/friendly-snippets",
      "saadparwaiz1/cmp_luasnip",
    },
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
  },

  -- Sticky context: show current function/method at top
  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      max_lines = 3,
    },
  },

  -- File tree (matching Zed project panel)
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  -- Telescope (matching Zed file finder / search)
  {
    "nvim-telescope/telescope.nvim",
    branch = "master",
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
      require("outline").setup({
        outline_items = {
          auto_update_events = {
            follow = { "CursorMoved" },
            items = { "InsertLeave", "BufWritePost" },
          },
        },
      })
      -- Refresh outline only when entering a normal code buffer
      vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
        callback = function()
          local bt = vim.bo.buftype
          local ft = vim.bo.filetype
          if bt == "" and ft ~= "NvimTree" and ft ~= "Outline" and ft ~= "OutlineHelp" then
            local outline = require("outline")
            if outline.is_open and outline.is_open() then
              pcall(outline.refresh)
            end
          end
        end,
      })
    end,
  },

  -- Git signs + blame
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        current_line_blame = true,
        signs_staged_enable = true,
      })
    end,
  },

  -- Git diff viewer (file history, line history)
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- Auto pairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup()
    end,
  },

  -- Formatter
  {
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          go = { "goimports" },
        },
        format_on_save = {
          timeout_ms = 2000,
          lsp_format = "fallback",
        },
      })
    end,
  },

  -- Multi-cursor (matching Zed vim::SelectNext / AddSelectionBelow)
  {
    "mg979/vim-visual-multi",
    init = function()
      vim.g.VM_maps = {
        ["Find Under"] = "mc",
        ["Find Subword Under"] = "mc",
        ["Skip Region"] = "mx",
        ["Remove Region"] = "mX",
        ["Add Cursor Down"] = "<C-Down>",
        ["Add Cursor Up"] = "<C-Up>",
        ["Visual Cursors"] = "\\\\cr",
      }
    end,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = { theme = "auto" },
        sections = {
          lualine_c = { { "filename", path = 1 } },
        },
      })
    end,
  },

  -- Markdown preview (matching Zed markdown::OpenPreviewToTheSide)
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview" },
    build = "cd app && npm install",
    ft = { "markdown" },
  },

  -- Neotest (GoLand-style test runner)
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "fredrikaverpil/neotest-golang",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-golang")({
            go_test_args = { "-v", "-count=1" },
            runner = "go",
          }),
        },
        discovery = {
          enabled = false,
        },
      })
    end,
  },

  -- Claude Code
  {
    "greggh/claude-code.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("claude-code").setup({
        window = {
          position = "vertical",
          split_ratio = 0.3,
        },
        keymaps = {
          toggle = {
            normal = "<leader>ac",
            terminal = "<leader>ac",
          },
        },
      })
    end,
  },

  -- Git conflict resolver
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    config = function()
      require("git-conflict").setup({
        default_mappings = false,
      })
    end,
  },

  -- Buffer line (tab bar)
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({
        options = {
          custom_filter = function(buf)
            local bt = vim.bo[buf].buftype
            local ft = vim.bo[buf].filetype
            if bt == "terminal" then return false end
            if ft == "NvimTree" or ft == "Outline" or ft == "claude-code" then return false end
            return true
          end,
        },
      })
    end,
  },
})

-- =============================================================================
-- Mason + LSP Setup (nvim 0.11+ compatible)
-- =============================================================================
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "gopls", "lua_ls", "elixirls" },
})
vim.api.nvim_create_user_command("MasonInstallFormatters", function()
  vim.cmd("MasonInstall goimports")
end, {})

local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- LSP keymaps via LspAttach autocmd
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local opts = { noremap = true, silent = true, buffer = ev.buf }
    local map = vim.keymap.set

    map("n", "gd", vim.lsp.buf.definition, opts)
    map("n", "fu", function() require("telescope.builtin").lsp_references() end, opts)
    map("n", "K", vim.lsp.buf.hover, opts)
    map("n", "gs", vim.lsp.buf.type_definition, opts)
    map("n", "gn", vim.lsp.buf.rename, opts)
    map("n", "gi", function() require("telescope.builtin").lsp_implementations() end, opts)
    map("n", "ge", function() vim.diagnostic.jump({ count = 1 }) end, opts)
    map("n", "gE", function() vim.diagnostic.jump({ count = -1 }) end, opts)
    map("n", "gp", vim.lsp.buf.signature_help, opts)
    map("n", "<A-CR>", vim.lsp.buf.code_action, opts)
    map("n", "<leader>rn", vim.lsp.buf.rename, opts)
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

-- elixir-ls (Mason managed)
vim.lsp.config("elixirls", {
  capabilities = capabilities,
})
vim.lsp.enable("elixirls")

-- =============================================================================
-- nvim-cmp Setup
-- =============================================================================
local cmp = require("cmp")
local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })

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
    local ft = ev.match
    local lang = vim.treesitter.language.get_lang(ft)
    if not lang then return end
    local ok, _ = pcall(vim.treesitter.start, ev.buf)
    if not ok then
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
  git = {
    ignore = false,
  },
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

-- Redo (Shift-U)
map("n", "U", "<C-r>", opts)

-- Pane navigation (Zed: workspace::ActivateNextPane → ctrl-w / esc)
map("n", "<C-w>", "<C-w>w", opts)

-- File tree (Zed: project_panel::ToggleFocus)
map("n", "<leader>t", ":NvimTreeToggle<CR>", opts)
map("n", "fo", ":NvimTreeFindFile<CR>", opts)

-- File finder (Zed: file_finder::Toggle)
map("n", "<leader>ff", function() require("telescope.builtin").find_files({ no_ignore = true }) end, opts)
-- Global search (Zed: workspace::NewSearch)
map("n", "<leader>fg", function() require("telescope.builtin").live_grep({ additional_args = { "--no-ignore" } }) end, opts)
-- Buffer / tab switcher (Zed: tab_switcher::Toggle)
map("n", "<leader>sw", "<cmd>Telescope buffers<CR>", opts)

-- Buffer navigation (Zed: pane::ActivateNextItem / ActivatePreviousItem)
map("n", "<leader>n", "<cmd>BufferLineCycleNext<CR>", opts)
map("n", "<leader>p", "<cmd>BufferLineCyclePrev<CR>", opts)

-- Close buffer (Zed: shift-B shift-D → pane::CloseActiveItem)
-- Switch to nearest code buffer before deleting, to preserve layout
map("n", "BD", function()
  local cur = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  -- Find another listed, normal file buffer
  local target = nil
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= cur and vim.bo[buf].buflisted and vim.bo[buf].buftype == "" then
      target = buf
      break
    end
  end
  -- No file buffer left → create empty [No Name] buffer
  if not target then
    target = vim.api.nvim_create_buf(true, false)
  end
  -- Pin the window to the target buffer, then delete old one
  vim.api.nvim_win_set_buf(win, target)
  pcall(vim.api.nvim_buf_delete, cur, {})
end, opts)

-- Go back / forward (Zed: pane::GoBack / GoForward)
map("n", "gb", "<C-o>", opts)
map("n", "gf", "<C-i>", opts)

-- Split right (Zed: pane::SplitRight)
map("n", "<leader><Right>", ":vsplit<CR>", opts)

-- Symbols / outline (Zed: project_symbols::Toggle)
map("n", "<leader>fs", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", opts)
-- Outline toggle (Zed: outline::Toggle → ctrl-s)
map("n", "<C-s>", "<cmd>Outline<CR>", opts)
-- Outline panel (Zed: outline_panel::ToggleFocus)
map("n", "<leader>ol", "<cmd>Outline<CR>", opts)

-- Diagnostics list (Zed: diagnostics::Deploy)
map("n", "<leader>e", "<cmd>Telescope diagnostics<CR>", opts)
-- Show line diagnostics
map({"n", "v"}, "<leader>se", function() vim.diagnostic.open_float() end, opts)

-- Yank relative path with line number (e.g. src/foo.lua:42)
map("n", "<leader>rp", function()
  local path = vim.fn.fnamemodify(vim.fn.expand("%"), ":.")
  local line = vim.fn.line(".")
  local result = path .. ":" .. line
  vim.fn.setreg("+", result)
  vim.notify(result)
end, opts)

-- Git history of selected lines (diffview.nvim)
map("v", "<leader>hl", function()
  local file = vim.fn.expand("%")
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  vim.cmd("DiffviewFileHistory -L" .. start_line .. "," .. end_line .. ":" .. file)
end, opts)
map("n", "<leader>hl", function()
  vim.cmd("DiffviewFileHistory " .. vim.fn.expand("%"))
end, opts)

-- Neotest keymaps (GoLand-style test runner)
map("n", "<leader>tr", function() require("neotest").run.run() end, opts)                -- 커서 위치 테스트 실행
map("n", "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, opts) -- 현재 파일 테스트 실행
map("n", "<leader>to", function() require("neotest").output_panel.toggle() end, opts)    -- 출력 패널 토글
map("n", "<leader>ts", function() require("neotest").summary.toggle() end, opts)         -- 테스트 요약 패널 토글
map("n", "<leader>go", function()                                                       -- go run . (현재 파일의 패키지)
  local dir = vim.fn.expand("%:p:h")
  require("toggleterm").exec("cd " .. dir .. " && go run .", 1)
end, opts)

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

-- Multi-cursor: \cr → visual cursors (explicit mapping to prevent c operator)
map("v", "<leader>cr", "<Plug>(VM-Visual-Cursors)", opts)

-- Diffview open/close
map("n", "gdo", "<cmd>DiffviewOpen<CR>", opts)
map("n", "gdc", "<cmd>DiffviewClose<CR>", opts)

-- Gitsigns base toggle (HEAD vs master)
map("n", "gdm", function() require("gitsigns").change_base("master", true) end, opts)
map("n", "gdh", function() require("gitsigns").reset_base(true) end, opts)

-- Git conflict (\gc prefix)
map("n", "<leader>gco", "<cmd>GitConflictChooseOurs<CR>", opts)
map("n", "<leader>gct", "<cmd>GitConflictChooseTheirs<CR>", opts)
map("n", "<leader>gcb", "<cmd>GitConflictChooseBoth<CR>", opts)
map("n", "<leader>gc0", "<cmd>GitConflictChooseNone<CR>", opts)
map("n", "<leader>gcn", "<cmd>GitConflictNextConflict<CR>", opts)
map("n", "<leader>gcp", "<cmd>GitConflictPrevConflict<CR>", opts)
map("n", "<leader>gcl", "<cmd>GitConflictListQf<CR>", opts)

-- Go generate (current file's package, run from module root)
map("n", "<leader>gg", function()
  local dir = vim.fn.expand("%:.:h")
  vim.cmd("!go generate ./" .. dir .. "/")
end, opts)

-- Treesitter folding (\tf prefix)
map("n", "<leader>tfc", "zc", opts)
map("n", "<leader>tfo", "zo", opts)

-- Layout preset (<leader>lp)
-- Left: nvim-tree | Center: code | Right: outline | Far right: claude-code | Bottom: terminal
map("n", "<leader>lp", function()
  -- Close all panels first
  pcall(vim.cmd, "NvimTreeClose")
  pcall(vim.cmd, "OutlineClose")
  pcall(function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].buftype == "terminal" then
        vim.api.nvim_win_close(win, true)
      end
    end
  end)

  -- Single code window
  vim.cmd("only")

  -- Bottom: toggleterm
  vim.cmd("botright 15split")
  vim.cmd("terminal")
  local term_win = vim.api.nvim_get_current_win()
  vim.wo[term_win].winfixheight = true
  vim.cmd("wincmd k") -- back to code

  -- Left: nvim-tree (width 30)
  vim.cmd("NvimTreeOpen")
  vim.cmd("vertical resize 30")
  vim.wo.winfixwidth = true
  vim.cmd("wincmd l") -- back to code

  -- Right: outline (width 30)
  vim.cmd("OutlineOpen")
  vim.defer_fn(function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].filetype == "Outline" then
        vim.api.nvim_set_current_win(win)
        vim.cmd("vertical resize 30")
        vim.wo[win].winfixwidth = true
        break
      end
    end

    -- Far right: claude-code
    vim.cmd("ClaudeCode")
    vim.defer_fn(function()
      -- Focus back to code window
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.bo[buf].filetype
        local bt = vim.bo[buf].buftype
        if ft ~= "NvimTree" and ft ~= "Outline" and bt ~= "terminal"
          and vim.api.nvim_win_get_config(win).relative == "" then
          vim.api.nvim_set_current_win(win)
          break
        end
      end
    end, 200)
  end, 200)
end, opts)

-- Disable netrw (nvim-tree replaces it)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
