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
    -- TEMA VISUAL: TokyoNight (Configuración segura para evitar errores E185)
    { 
        "folke/tokyonight.nvim", 
        lazy = false, 
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("tokyonight")
        end
    },

    -- EXPLORADOR DE ARCHIVOS: Nvim-Tree
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("nvim-tree").setup()
        end
    },
    -- 3. TREESITTER: Resaltado de sintaxis inteligente
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate", -- Mantiene los analizadores actualizados
        config = function()
            require("nvim-treesitter.configs").setup({
                -- Una lista de lenguajes iniciales para tu arsenal
                ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "java", "javascript", "python", "html" },

                -- Instalar automáticamente analizadores de nuevos lenguajes al abrir archivos
                auto_install = true,

                highlight = {
                    enable = true, -- ¡La magia que enciende los colores inteligentes!
                    additional_vim_regex_highlighting = false,
                },
            })
        end
    },
    -- 4. EL CEREBRO: LSP (Autocompletado y errores)
    {
        "williamboman/mason.nvim",
        dependencies = {
            "williamboman/mason-lspconfig.nvim",
            "neovim/nvim-lspconfig",
        },
        config = function()
            -- 1. Iniciar la App Store
            require("mason").setup()

            -- 2. Pedirle que instale automáticamente estos lenguajes
            require("mason-lspconfig").setup({
                ensure_installed = { "lua_ls", "pyright" }, -- Lua y Python para empezar
            })

            -- 4. Tus nuevos superpoderes (Atajos de teclado de IDE)
            -- Pulsar 'K' mayúscula para ver la documentación de lo que tienes bajo el cursor
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
            -- Pulsar 'gd' para ir a la definición de una variable o función
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
        end
    },
    -- 5. JAVA IDE: Soporte avanzado para Java (¡El que faltaba!)
    {
        "mfussenegger/nvim-jdtls",
    },
    -- 6. MOTOR DE AUTOCOMPLETADO VISUAL (El menú emergente)
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp", -- Conecta el menú con nuestros motores de Mason
            "L3MON4D3/LuaSnip",     -- Motor para expandir fragmentos de código (snippets)
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-Space>'] = cmp.mapping.complete(), -- Forzar menú con Ctrl+Espacio
                    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Intro para aceptar sugerencia
                    ['<Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item() -- Bajar por el menú con Tabulador
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                    ['<S-Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item() -- Subir por el menú con Shift+Tab
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' }, -- Sugerencias inteligentes del motor (Java, Python, etc.)
                    { name = 'luasnip' },  -- Fragmentos de código
                })
            })
        end
    }
})

-- ========================================================================== --
-- FIN DEL ARCHIVO
-- ========================================================================== --
