-- ~/.config/nvim/lua/plugins/completion.lua
return {
    'saghen/blink.cmp',
    -- 非常に高速で設定がシンプルな、2026年現在の決定版補完プラグインです
    version = '*',

    opts = {
        -- キーマッピングの設定 (TabやEnter、矢印キーで直感的に操作できます)
        keymap = {
            -- preset = 'default' になっているとEnterで確定しないことが多いっす
            -- これを 'enter' に変えると、Enterで選択・確定ができるようになるっす！
            preset = 'enter',
        },
        -- 補完のソース（出処）に LSP（kotlin_language_server等）を指定
        sources = {
            default = { 'lsp', 'path', 'snippets', 'buffer' },
        },
    },
}
