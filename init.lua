-- ========================================================================== --
-- 1. CONFIGURACIÓN BÁSICA (Preferencias de Javi)
-- ========================================================================== --

-- Activar los números de línea y números relativos para movernos rápido
vim.opt.number = true
vim.opt.relativenumber = true
-- Hola
-- Configuración de sangría (estilo Java: 4 espacios)
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Sincronizar con el portapapeles de macOS (Cmd+C / Cmd+V)
vim.opt.clipboard = "unnamedplus"

-- Mejorar la experiencia visual
vim.opt.termguicolors = true


-- ========================================================================== --
-- 2. BOOTSTRAP DE LAZY.NVIM (El instalador automático)
-- ========================================================================== --

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)


-- ========================================================================== --
-- 3. CONFIGURACIÓN DE PLUGINS
-- ========================================================================== --
require("lazy").setup({
    -- 1. TEMA VISUAL: TokyoNight
    { 
        "folke/tokyonight.nvim", 
        lazy = false, 
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("tokyonight")
        end
    },

    -- 2. ESTÉTICA: Barra de estado (Lualine) y Pestañas (Bufferline)
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function() require('lualine').setup({ options = { theme = 'tokyonight' } }) end
    },
    {
        'akinsho/bufferline.nvim',
        version = "*",
        dependencies = 'nvim-tree/nvim-web-devicons',
        config = function() require("bufferline").setup({}) end
    },

    -- 3. EXPLORADOR Y SINTAXIS
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function() require("nvim-tree").setup() end
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "lua", "vim", "java", "python" },
                highlight = { enable = true },
            })
        end
    },

    -- 4. EL CEREBRO: Mason y LSP
    {
        "williamboman/mason.nvim",
        dependencies = { "williamboman/mason-lspconfig.nvim", "neovim/nvim-lspconfig" },
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup({ ensure_installed = { "lua_ls", "jdtls" } })
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
        end
    },

    -- 5. JAVA ESPECIALIZADO
    { "mfussenegger/nvim-jdtls" },

    -- 6. AUTOCOMPLETADO Y SNIPPETS (Atajos de código)
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",     -- Conecta LuaSnip con el menú
            "rafamadriz/friendly-snippets", -- El diccionario de atajos (sout, psvm, etc.)
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            
            -- Cargar los atajos estilo VSCode (Java, etc.)
            require("luasnip.loaders.from_vscode").lazy_load()

            cmp.setup({
                snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
                mapping = cmp.mapping.preset.insert({
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
                    ['<Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
                        else fallback() end
                    end, { 'i', 's' }),
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                })
            })
        end
    }
})
-- FIN DEL ARCHIVO
-- ========================================================================== --
