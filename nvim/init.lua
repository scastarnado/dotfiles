-- Keep this file intentionally small: every section can be learned independently.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Editor defaults -----------------------------------------------------------
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.inccommand = "split"
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.wrap = false
vim.opt.undofile = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 400
vim.opt.termguicolors = true

-- Small, memorable keymaps. Run :map <key> to see each description.
local map = vim.keymap.set
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit window" })
map("n", "<leader>e", "<cmd>Explore<cr>", { desc = "Open file explorer" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
map("n", "<C-h>", "<C-w>h", { desc = "Focus left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Focus lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Focus upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Focus right window" })
map("v", "<", "<gv", { desc = "Indent left and reselect" })
map("v", ">", ">gv", { desc = "Indent right and reselect" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Explain diagnostic" })

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Briefly highlight copied text",
  callback = function()
    vim.highlight.on_yank({ timeout = 150 })
  end,
})

-- Plugin manager ------------------------------------------------------------
-- Git for Windows sometimes omits its Unix helpers from PATH. lazy.nvim uses
-- those helpers while checking submodules, so expose them when available.
if vim.fn.has("win32") == 1 then
  local git_exe = vim.fn.exepath("git")
  local git_root = vim.fn.fnamemodify(git_exe, ":h:h")
  local git_paths = {
    git_root .. "/usr/bin",
    git_root .. "/mingw64/bin",
    git_root .. "/mingw64/libexec/git-core",
  }
  for _, path in ipairs(git_paths) do
    if vim.fn.isdirectory(path) == 1 and not vim.env.PATH:find(path, 1, true) then
      vim.env.PATH = vim.env.PATH .. ";" .. path
    end
  end
end

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local output = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error("Could not install lazy.nvim:\n" .. output)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "python", "javascript", "typescript", "html", "c_sharp" },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
  { "neovim/nvim-lspconfig" },
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("tokyonight-night")
    end,
  },
}, {
  change_detection = { notify = false },
})

-- Language servers ----------------------------------------------------------
-- nvim-lspconfig supplies server definitions; Neovim's current API enables
-- them. Missing server executables are reported by :checkhealth vim.lsp.
-- ts_ls handles both TypeScript and JavaScript files.
-- Completion is intentionally absent so the editor supports learning without
-- suggesting or writing code on your behalf.
vim.lsp.enable({ "pyright", "ts_ls", "html", "csharp_ls" })

vim.api.nvim_create_autocmd("LspAttach", {
  desc = "Set beginner-friendly LSP keymaps",
  callback = function(event)
    local opts = function(desc)
      return { buffer = event.buf, desc = desc }
    end

    map("n", "gd", vim.lsp.buf.definition, opts("Go to definition"))
    map("n", "gD", vim.lsp.buf.declaration, opts("Go to declaration"))
    map("n", "gr", vim.lsp.buf.references, opts("Find references"))
    map("n", "gi", vim.lsp.buf.implementation, opts("Go to implementation"))
    map("n", "K", vim.lsp.buf.hover, opts("Show documentation"))
    map("n", "<leader>rn", vim.lsp.buf.rename, opts("Rename symbol"))
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts("Code actions"))
    map("n", "<leader>f", function()
      vim.lsp.buf.format({ async = true })
    end, opts("Format file"))
  end,
})

vim.diagnostic.config({
  severity_sort = true,
  underline = true,
  virtual_text = { spacing = 2, source = "if_many" },
  float = { border = "rounded", source = true },
})

-- Quick reference: :Lazy manages plugins, :LspInfo inspects language servers,
-- :checkhealth diagnoses setup problems, and :Tutor teaches Vim interactively.
