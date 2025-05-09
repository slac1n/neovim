return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		-- import lspconfig plugin
		local lspconfig = require("lspconfig")

		-- import mason_lspconfig plugin
		local mason_lspconfig = require("mason-lspconfig")

		-- import cmp-nvim-lsp plugin
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		local keymap = vim.keymap -- for conciseness

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				-- Buffer local mappings.
				-- See `:help vim.lsp.*` for documentation on any of the below functions
				local opts = { buffer = ev.buf, silent = true }

				-- set keybinds
				opts.desc = "Show LSP references"
				keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

				opts.desc = "Go to declaration"
				keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

				opts.desc = "Show LSP definitions"
				keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

				opts.desc = "Show LSP implementations"
				keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

				opts.desc = "Show LSP type definitions"
				keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

				opts.desc = "See available code actions"
				keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

				opts.desc = "Smart rename"
				keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

				opts.desc = "Show buffer diagnostics"
				keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

				opts.desc = "Show line diagnostics"
				keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

				opts.desc = "Go to previous diagnostic"
				keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

				opts.desc = "Go to next diagnostic"
				keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

				opts.desc = "Show documentation for what is under cursor"
				keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

				opts.desc = "Restart LSP"
				keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
			end,
		})

		-- used to enable autocompletion (assign to every lsp server config)
		local capabilities = cmp_nvim_lsp.default_capabilities()

		-- Change the Diagnostic symbols in the sign column (gutter)
		-- (not in youtube nvim video)
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		mason_lspconfig.setup_handlers({
			-- default handler for installed servers
			function(server_name)
				lspconfig[server_name].setup({
					capabilities = capabilities,
				})
			end,
			["marksman"] = function()
				-- configure markdown server
				lspconfig["marksman"].setup({
					capabilities = capabilities,
					on_attach = on_attach,
				})
			end,
			["ltex"] = function()
				-- configure latex server
				lspconfig["ltex"].setup({
					capabilities = capabilities,
					on_attach = on_attach,
					settings = {
						ltex = {
							language = "auto", -- Replace "en" with the appropriate language code
						},
					},
				})
			end,
			-- ["basedpyright"] = function()
			-- 	-- configure python server
			-- 	lspconfig["basedpyright"].setup({
			-- 		capabilities = capabilities,
			-- 		on_attach = on_attach,
			-- 		-- settings = {
			-- 		-- 	python = {
			-- 		-- 		pythonPath = vim.fn.exepath("python"),
			-- 		-- 	},
			-- 		-- },
			-- 	})
			-- end,
			["ruff"] = function()
				lspconfig["ruff"].setup({
					capabilities = capabilities,
					on_attach = on_attach,
					init_options = {
						settings = {
							-- Ruff language server settings go here
							configurationPreference = "filesystemFirst",
						},
					},
				})
			end,
			["omnisharp"] = function()
				-- configure omnisharp server
				lspconfig["omnisharp"].setup({
					capabilities = capabilities,
					on_attach = on_attach,
					cmd = {
						"omnisharp",
						"--languageserver",
						"--hostPID",
						tostring(vim.fn.getpid()),
					},
					settings = {
						RoslynExtensionsOptions = {
							enableDecompilationSupport = false,
							enableImportCompletion = true,
							enableAnalyzersSupport = true,
						},
						FormattingOptions = {
							OrganizeImports = true,
						},
					},
					root_dir = function(fname)
						local lspconfig = require("lspconfig")
						local primary = lspconfig.util.root_pattern("*.sln")(fname)
						local fallback = lspconfig.util.root_pattern("*.csproj")(fname)
						return primary or fallback
					end,
				})
			end,
		})
	end,
}
