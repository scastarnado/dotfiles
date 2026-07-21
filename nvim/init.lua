-- A fast, batteries-included Neovim config that still makes you write the code.
-- Requires Neovim 0.11+ and Git. No completion engine or AI plugin is included.

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

-- Options -------------------------------------------------------------------
local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.breakindent = true
opt.linebreak = true
opt.wrap = false
opt.showmode = false

opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.smartindent = true

opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"
opt.hlsearch = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.signcolumn = "yes"
opt.splitbelow = true
opt.splitright = true
opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.updatetime = 200
opt.timeoutlen = 350
opt.completeopt = { "menuone", "noselect" }
opt.termguicolors = true
opt.confirm = true
opt.laststatus = 3
opt.pumheight = 10
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.fillchars = { eob = " ", fold = " ", foldopen = "", foldclose = "" }
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true

-- Keymaps -------------------------------------------------------------------
local map = vim.keymap.set
local silent = { silent = true }

map({ "n", "v" }, "<Space>", "<Nop>", silent)
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit window" })
map("n", "<leader>Q", "<cmd>qa<cr>", { desc = "Quit Neovim" })
map("n", "<leader>x", "<cmd>bdelete<cr>", { desc = "Close buffer" })
map("n", "<leader>X", "<cmd>bdelete!<cr>", { desc = "Force-close buffer" })

map("n", "<C-h>", "<C-w>h", { desc = "Focus left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Focus lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Focus upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Focus right window" })
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Grow window" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Shrink window" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Narrow window" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Widen window" })

map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "[q", "<cmd>cprevious<cr>", { desc = "Previous quickfix" })
map("n", "]q", "<cmd>cnext<cr>", { desc = "Next quickfix" })
map("n", "[l", "<cmd>lprevious<cr>", { desc = "Previous location" })
map("n", "]l", "<cmd>lnext<cr>", { desc = "Next location" })

map("n", "J", "mzJ`z", { desc = "Join lines without moving cursor" })
map("n", "<C-d>", "<C-d>zz", { desc = "Half-page down, centered" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half-page up, centered" })
map("n", "n", "nzzzv", { desc = "Next search result, centered" })
map("n", "N", "Nzzzv", { desc = "Previous search result, centered" })
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })
map("v", "<", "<gv", { desc = "Indent left and reselect" })
map("v", ">", ">gv", { desc = "Indent right and reselect" })
map("x", "<leader>p", '"_dP', { desc = "Paste without replacing register" })
map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
map("n", "<leader>Y", '"+Y', { desc = "Yank line to system clipboard" })
map({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without replacing register" })
map("n", "<leader>tt", "<cmd>split | terminal<cr>", { desc = "Open terminal" })

-- Autocommands --------------------------------------------------------------
local group = vim.api.nvim_create_augroup("scastarnado", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  desc = "Briefly highlight yanked text",
  callback = function()
    vim.highlight.on_yank({ timeout = 150 })
  end,
})
vim.api.nvim_create_autocmd("BufReadPost", {
  group = group,
  desc = "Return to the last edit position",
  callback = function(event)
    local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
    local lines = vim.api.nvim_buf_line_count(event.buf)
    if mark[1] > 0 and mark[1] <= lines then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
vim.api.nvim_create_autocmd("VimResized", {
  group = group,
  desc = "Equalize splits after resize",
  command = "wincmd =",
})
vim.api.nvim_create_autocmd("TermOpen", {
  group = group,
  desc = "Use a clean terminal buffer",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.cmd.startinsert()
  end,
})

-- Plugin manager ------------------------------------------------------------
if vim.fn.has("win32") == 1 then
  local git_root = vim.fn.fnamemodify(vim.fn.exepath("git"), ":h:h")
  for _, path in ipairs({
    git_root .. "/usr/bin",
    git_root .. "/mingw64/bin",
    git_root .. "/mingw64/libexec/git-core",
  }) do
    if vim.fn.isdirectory(path) == 1 and not vim.env.PATH:find(path, 1, true) then
      vim.env.PATH = vim.env.PATH .. ";" .. path
    end
  end
end

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local output = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error("Could not install lazy.nvim:\n" .. output)
  end
end
opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = { style = "night", transparent = false, styles = { sidebars = "dark", floats = "dark" } },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight")
    end,
  },
  { "nvim-tree/nvim-web-devicons", lazy = true },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      parsers = { "bash", "c", "c_sharp", "css", "git_config", "git_rebase", "html", "javascript", "json", "lua", "luadoc", "markdown", "markdown_inline", "python", "query", "typescript", "vim", "vimdoc", "yaml" },
      filetypes = { "bash", "c", "cs", "css", "gitconfig", "gitrebase", "html", "javascript", "javascriptreact", "json", "lua", "markdown", "python", "query", "typescript", "typescriptreact", "vim", "yaml" },
    },
    config = function(_, opts)
      require("nvim-treesitter").install(opts.parsers)
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = opts.filetypes,
        callback = function()
          pcall(vim.treesitter.start)
          vim.wo.foldmethod = "expr"
          vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
  },
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files hidden=true<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Grep project" },
      { "<leader>fb", "<cmd>Telescope buffers sort_mru=true ignore_current_buffer=true<cr>", desc = "Find buffers" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Search help" },
      { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Search keymaps" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document symbols" },
      { "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "Workspace symbols" },
      { "<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Search current buffer" },
      { "<leader><leader>", "<cmd>Telescope resume<cr>", desc = "Resume last picker" },
    },
    opts = function()
      return {
        defaults = {
          prompt_prefix = "   ",
          selection_caret = "  ",
          path_display = { "smart" },
          mappings = { i = { ["<Esc>"] = require("telescope.actions").close } },
        },
        pickers = { find_files = { follow = true } },
      }
    end,
  },
  {
    "stevearc/oil.nvim",
    lazy = false,
    keys = { { "-", "<cmd>Oil<cr>", desc = "Open parent directory" }, { "<leader>e", "<cmd>Oil<cr>", desc = "File explorer" } },
    opts = {
      default_file_explorer = true,
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      view_options = { show_hidden = true },
      float = { padding = 2, max_width = 90, max_height = 30, border = "rounded" },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ha", function() require("harpoon"):list():add() end, desc = "Harpoon add file" },
      { "<leader>hh", function() local h = require("harpoon"); h.ui:toggle_quick_menu(h:list()) end, desc = "Harpoon menu" },
      { "<leader>1", function() require("harpoon"):list():select(1) end, desc = "Harpoon file 1" },
      { "<leader>2", function() require("harpoon"):list():select(2) end, desc = "Harpoon file 2" },
      { "<leader>3", function() require("harpoon"):list():select(3) end, desc = "Harpoon file 3" },
      { "<leader>4", function() require("harpoon"):list():select(4) end, desc = "Harpoon file 4" },
    },
    opts = {},
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = { add = { text = "▎" }, change = { text = "▎" }, delete = { text = "" }, topdelete = { text = "" }, changedelete = { text = "▎" } },
      on_attach = function(buf)
        local gs = package.loaded.gitsigns
        local function bmap(mode, lhs, rhs, desc)
          map(mode, lhs, rhs, { buffer = buf, desc = desc })
        end
        bmap("n", "]h", gs.next_hunk, "Next Git hunk")
        bmap("n", "[h", gs.prev_hunk, "Previous Git hunk")
        bmap("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
        bmap("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
        bmap("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage selection")
        bmap("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset selection")
        bmap("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
        bmap("n", "<leader>hb", gs.blame_line, "Blame line")
        bmap("n", "<leader>hd", gs.diffthis, "Diff file")
      end,
    },
  },
  { "tpope/vim-fugitive", cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit" }, keys = { { "<leader>gg", "<cmd>Git<cr>", desc = "Git status" } } },
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    keys = { { "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Undo tree" } },
  },
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Workspace diagnostics" },
      { "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Document symbols" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix list" },
    },
  },
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = { { "<leader>cf", function() require("conform").format({ async = true, lsp_format = "fallback" }) end, mode = { "n", "v" }, desc = "Format buffer" } },
    opts = {
      notify_on_error = true,
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "isort", "black" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        html = { "prettierd", "prettier", stop_after_first = true },
        css = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
      },
    },
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", function() require("flash").jump() end, mode = { "n", "x", "o" }, desc = "Flash jump" },
      { "S", function() require("flash").treesitter() end, mode = { "n", "x", "o" }, desc = "Flash Treesitter" },
    },
  },
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = { n_lines = 500 },
  },
  {
    "echasnovski/mini.surround",
    event = "VeryLazy",
    opts = { mappings = { add = "gsa", delete = "gsd", find = "gsf", find_left = "gsF", highlight = "gsh", replace = "gsr", update_n_lines = "gsn" } },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      delay = 300,
      spec = {
        { "<leader>c", group = "code" }, { "<leader>f", group = "find" },
        { "<leader>g", group = "git" }, { "<leader>h", group = "hunks/harpoon" },
        { "<leader>t", group = "toggle/terminal" }, { "<leader>x", group = "diagnostics" },
      },
    },
  },
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Do not save session" },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { options = { theme = "tokyonight", globalstatus = true, component_separators = "", section_separators = { left = "", right = "" } } },
  },
}, {
  change_detection = { notify = false },
  ui = { border = "rounded" },
  performance = { rtp = { disabled_plugins = { "gzip", "netrwPlugin", "tarPlugin", "tohtml", "tutor", "zipPlugin" } } },
})

-- LSP and diagnostics -------------------------------------------------------
-- LSP provides understanding, navigation and refactoring. Completion is
-- deliberately not configured: no nvim-cmp, blink.cmp, snippets or AI.
vim.lsp.enable({ "pyright", "ts_ls", "html", "csharp_ls" })

vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  desc = "Set LSP keymaps",
  callback = function(event)
    local function lmap(mode, lhs, rhs, desc)
      map(mode, lhs, rhs, { buffer = event.buf, desc = desc })
    end
    lmap("n", "gd", vim.lsp.buf.definition, "Go to definition")
    lmap("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
    lmap("n", "gr", vim.lsp.buf.references, "Find references")
    lmap("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
    lmap("n", "gy", vim.lsp.buf.type_definition, "Go to type definition")
    lmap("n", "K", vim.lsp.buf.hover, "Hover documentation")
    lmap("n", "<C-k>", vim.lsp.buf.signature_help, "Signature help")
    lmap("n", "<leader>cr", vim.lsp.buf.rename, "Rename symbol")
    lmap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
    lmap("n", "<leader>cl", "<cmd>LspInfo<cr>", "LSP information")
    lmap("n", "<leader>th", function()
      local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
      vim.lsp.inlay_hint.enable(not enabled, { bufnr = event.buf })
    end, "Toggle inlay hints")
  end,
})

map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Previous diagnostic" })
map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next diagnostic" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })

vim.diagnostic.config({
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  virtual_text = { spacing = 2, source = "if_many", prefix = "●" },
  signs = { text = { [vim.diagnostic.severity.ERROR] = "󰅚", [vim.diagnostic.severity.WARN] = "󰀪", [vim.diagnostic.severity.INFO] = "󰋽", [vim.diagnostic.severity.HINT] = "󰌶" } },
  float = { border = "rounded", source = true, header = "" },
})

-- :Lazy manages plugins, :LspInfo inspects servers, :ConformInfo inspects
-- formatters, :checkhealth diagnoses setup, and :Tutor teaches Vim itself.
