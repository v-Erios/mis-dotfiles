-- ========================================================================== --
-- CONFIGURACIÓN DEL SERVIDOR DE JAVA (JDTLS)
-- ========================================================================== --

local home = os.getenv("HOME")
local jdtls = require("jdtls")

-- 1. Encontrar la raíz del proyecto (donde está el pom.xml, .git, etc.)
local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
local root_dir = require("jdtls.setup").find_root(root_markers)

-- Si no estamos dentro de un proyecto de Java válido, no hacemos nada
if root_dir == "" then
    return
end

-- 2. Crear un "Workspace" aislado para que los proyectos no se mezclen
local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
local workspace_dir = home .. "/.cache/jdtls/workspace/" .. project_name

-- 3. Configuración principal
local config = {
    -- Como usamos Mason, el comando 'jdtls' ya está en nuestro sistema
    cmd = {
        "jdtls",
        "-data", workspace_dir,
    },
    root_dir = root_dir,

    -- Ajustes internos del autocompletado
    settings = {
        java = {
            signatureHelp = { enabled = true },
            contentProvider = { preferred = "fernflower" },
            completion = {
                favoriteStaticMembers = {
                    "org.junit.Assert.*",
                    "org.junit.Assume.*",
                    "org.junit.jupiter.api.Assertions.*",
                    "org.junit.jupiter.api.Assumptions.*",
                    "org.junit.jupiter.api.DynamicContainer.*",
                    "org.junit.jupiter.api.DynamicTest.*",
                },
            },
        }
    },

    -- 4. Atajos de teclado que SOLO se activarán al abrir archivos .java
    on_attach = function(client, bufnr)
        local opts = { silent = true, buffer = bufnr }
        
        -- Los clásicos del IDE
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts) -- Ir a definición
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)       -- Ver documentación
        
        -- Magia pura de Java
        vim.keymap.set('n', '<leader>oi', jdtls.organize_imports, opts) -- Organizar Imports
        vim.keymap.set('n', '<leader>ev', jdtls.extract_variable, opts) -- Extraer variable
    end,
}

-- ¡Encender los motores!
jdtls.start_or_attach(config)
