return {
    "nvim-treesitter/nvim-treesitter",
    -- Use the default branch 'master' (the previous 'main' branch does not exist)
    branch = "master",
    build = ":TSUpdate",
    -- Load treesitter lazily when a buffer is read (prevents config from running before the plugin is fully loaded)
    event = { "BufReadPost", "BufNewFile" },
    -- Also make the TS* commands available without having to open a buffer first
    cmd = { "TSInstall", "TSUpdateSync", "TSInstallInfo" },
    config = function()
        require("nvim-treesitter.configs").setup({
            -- Install parsers for common languages
            ensure_installed = { "lua", "vim", "vimdoc", "javascript", "typescript", "python", "html", "css", "json", "bash", "dart", "kotlin" },
            sync_install = false,
            auto_install = true,
            highlight = {
                enable = true, -- Enable high-quality syntax highlighting
                additional_vim_regex_highlighting = false,
            },
            indent = { enable = true }, -- Enable better auto-indentation
        })
    end,
}
