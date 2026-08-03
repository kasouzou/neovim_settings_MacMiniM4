return {
    "neovim/nvim-lspconfig",
    -- mason.nvim と連携させて自動インストールできるように依存関係を追加
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
    },
    config = function()
        local M = {}
        local map = vim.keymap.set

        -- 1. 【自動管理】Mason の初期化と Kotlin サーバーの指定
        -- ※ sourcekit-lsp はツールチェーン付属のものを使うため、Masonの自動インストールには含めないっす！
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = { "kotlin_language_server", "lua_ls" },
        })

        -- 2. キーマッピング（共通の接続時処理）
        vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(args)
                local bufnr = args.buf
                local function opts(desc)
                    return { buffer = bufnr, desc = "LSP " .. desc }
                end

                map("n", "gD", vim.lsp.buf.declaration, opts "Go to declaration")
                map("n", "gd", vim.lsp.buf.definition, opts "Go to definition")
                map("n", "gi", vim.lsp.buf.implementation, opts "Go to implementation")
                map("n", "<leader>sh", vim.lsp.buf.signature_help, opts "Show signature help")
                map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts "Add workspace folder")
                map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts "Remove workspace folder")
                map("n", "<leader>wl", function()
                    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                end, opts "List workspace folders")
                map("n", "<leader>D", vim.lsp.buf.type_definition, opts "Go to type definition")
                map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts "Code action")
                map("n", "gr", vim.lsp.buf.references, opts "Show references")
            end,
        })

        -- 3. セマンティックトークンの無効化設定
        M.on_init = function(client, _)
            if client:supports_method "textDocument/semanticTokens" then
                client.server_capabilities.semanticTokensProvider = nil
            end
        end

        -- 4. 補完用ケーパビリティの設定
        M.capabilities = vim.lsp.protocol.make_client_capabilities()
        M.capabilities.textDocument.completion.completionItem = {
            documentationFormat = { "markdown", "plaintext" },
            snippetSupport = true,
            preselectSupport = true,
            insertReplaceSupport = true,
            labelDetailsSupport = true,
            deprecatedSupport = true,
            commitCharactersSupport = true,
            tagSupport = { valueSet = { 1 } },
            resolveSupport = {
                properties = { "documentation", "detail", "additionalTextEdits" },
            },
        }

        -- 5. 【最新】すべてのサーバーに共通の初期設定を適用 (Neovim 0.11+)
        vim.lsp.config("*", {
            capabilities = M.capabilities,
            on_init = M.on_init,
        })

        -- 6. 【最新】個別サーバーの設定と有効化
        vim.lsp.config("lua_ls", {
            settings = {
                Lua = {
                    diagnostics = { globals = { "vim" } },
                    workspace = {
                        library = {
                            vim.fn.expand "$VIMRUNTIME/lua",
                            vim.fn.expand "$VIMRUNTIME/lua/vim/lsp",
                            "${3rd}/luv/library",
                        },
                    },
                },
            },
        })

        -- ★ここを変更：Kotlin LSPがAndroidプロジェクト（build.gradle.kts）を完璧に認識する設定
        vim.lsp.config("kotlin_language_server", {
            root_markers = { "build.gradle.kts", "build.gradle", "settings.gradle.kts", ".git" },
            settings = {
                kotlin = {
                    compiler = {
                        jvm = { target = "17" } -- システムのJava 17に追従
                    }
                }
            },
            init_options = {
                storagePath = vim.fn.resolve(vim.fn.stdpath("cache") .. "/kotlin_language_server")
            }
        })

        -- 【追加】SourceKit-LSP（Swift）固有の設定
        -- 共通の M.capabilities に、記事にあった監視ファイルや診断の設定を安全にマージして適用するっす！
        vim.lsp.config("sourcekit", {
            cmd = { "xcrun", "sourcekit-lsp" },
            filetypes = { "swift" },
            root_markers = {
                ".git",
                "compile_commands.json",
                ".sourcekit-lsp",
                "Package.swift",
            },
            get_language_id = function(_, ftype)
                return ftype
            end,
            capabilities = vim.tbl_deep_extend("force", M.capabilities, {
                workspace = {
                    didChangeWatchedFiles = {
                        dynamicRegistration = true,
                    },
                },
                textDocument = {
                    diagnostic = {
                        dynamicRegistration = true,
                        relatedDocumentSupport = true,
                    },
                },
            }),
        })

        -- 使用する言語サーバーの一覧（lua_ls も再度戻しておきます。ここに sourcekit を追加っす！）
        local servers = { "lua_ls", "kotlin_language_server", "sourcekit" }

        -- 一括で有効化
        for _, lsp in ipairs(servers) do
            vim.lsp.enable(lsp)
        end
    end
}
