return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
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
