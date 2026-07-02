return {
	-- colorscheme
	{
		"nvim-lua/plenary.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd("colorscheme pureblack")
		end,
	},

	-- Telescope
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
			{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
		},
		config = function()
			require("telescope").setup({
				defaults = {
					mappings = {
						i = { ["<Esc>"] = require("telescope.actions").close },
					},
					layout_strategy = "horizontal",
					layout_config = {
						horizontal = {
							height = 0.4,
							width = 0.99,
							anchor = "S",
							preview_width = 0.5,
						},
					},
				},
			})
		end,
	},

	-- Dashboard
	{
		"nvimdev/dashboard-nvim",
		event = "VimEnter",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("dashboard").setup({
				theme = "doom",
				config = {
					header = { "", "" },
					center = {
						{
							icon = "   ",
							desc = "SPC ff  Find files                          ",
							action = "Telescope find_files",
							key = "f",
							key_hl = "Number",
							icon_hl = "Title",
							desc_hl = "Comment",
						},
						{
							icon = "   ",
							desc = "SPC fg  Live grep                           ",
							action = "Telescope live_grep",
							key = "g",
							key_hl = "Number",
							icon_hl = "Title",
							desc_hl = "Comment",
						},
						{
							icon = "   ",
							desc = "SPC e   File explorer                       ",
							action = "Neotree toggle",
							key = "e",
							key_hl = "Number",
							icon_hl = "Title",
							desc_hl = "Comment",
						},
						{
							icon = "   ",
							desc = "SPC h   Bookmarks                           ",
							action = "lua require('arrow').open_prompt()",
							key = "h",
							key_hl = "Number",
							icon_hl = "Title",
							desc_hl = "Comment",
						},
						{
							icon = "   ",
							desc = "New file                                    ",
							action = "enew",
							key = "n",
							key_hl = "Number",
							icon_hl = "Title",
							desc_hl = "String",
						},
						{
							icon = "   ",
							desc = "Config                                      ",
							action = "edit ~/.config/nvim/init.lua",
							key = "c",
							key_hl = "Number",
							icon_hl = "Title",
							desc_hl = "String",
						},
						{
							icon = "󰩈  ",
							desc = "Quit                                        ",
							action = "qa",
							key = "q",
							key_hl = "Number",
							icon_hl = "Title",
							desc_hl = "String",
						},
					},
					footer = {},
				},
			})
		end,
	},

	-- Docstring generator
	{
		"danymat/neogen",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		keys = {
			{ "<leader>d", "<cmd>Neogen<cr>", desc = "Generate docstring" },
		},
		opts = {
			languages = {
				python = {
					template = { annotation_convention = "google_docstrings" },
				},
			},
		},
	},

	-- Git signs
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "▁" },
				topdelete = { text = "▔" },
				changedelete = { text = "▎" },
			},
		},
	},

	-- Smooth scrolling
	{
		"karb94/neoscroll.nvim",
		config = function()
			require("neoscroll").setup({
				mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "zt", "zz", "zb" },
				hide_cursor = true,
				stop_eof = true,
				easing_function = "sine",
			})
		end,
	},

	-- Arrow (file bookmarks)
	{
		"otavioschwanck/arrow.nvim",
		lazy = false,
		opts = {
			show_icons = true,
			leader_key = "<leader>h",
		},
	},

	-- File explorer
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		keys = {
			{ "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle file tree" },
		},
		opts = {
			window = {
				width = 25,
				position = "right",
				mappings = {
					["<Esc>"] = "close_window",
				},
			},
			filesystem = {
				filtered_items = { visible = true },
			},
			close_if_last_window = true,
			enable_git_status = true,
			follow_current_file = { enabled = true },
		},
	},

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
		lazy = false,
		config = function()
			local ts = require("nvim-treesitter")
			ts.setup()
			ts.install({ "python", "bash", "json", "yaml", "toml", "html", "css", "c", "cpp", "rust" })
			vim.api.nvim_create_autocmd("FileType", {
				pattern = {
					"python",
					"bash",
					"json",
					"yaml",
					"toml",
					"lua",
					"markdown",
					"html",
					"css",
					"c",
					"cpp",
					"rust",
				},
				callback = function()
					pcall(vim.treesitter.start)
				end,
			})
		end,
	},

	-- LSP
	{
		"williamboman/mason.nvim",
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
			"neovim/nvim-lspconfig",
		},
		config = function()
			require("mason").setup()

			local function file_exists(path)
				return path and vim.uv.fs_stat(path) ~= nil
			end

			local function get_python_path(root_dir)
				-- prefer active conda/virtualenv
				local env_python = {
					vim.env.CONDA_PREFIX and (vim.env.CONDA_PREFIX .. "/bin/python") or nil,
					vim.env.VIRTUAL_ENV and (vim.env.VIRTUAL_ENV .. "/bin/python") or nil,
				}
				for _, path in ipairs(env_python) do
					if file_exists(path) then
						return path
					end
				end
				-- fallback to in-project .venv
				local root_python = {
					root_dir and (root_dir .. "/.venv/bin/python") or nil,
					root_dir and (root_dir .. "/venv/bin/python") or nil,
				}
				for _, path in ipairs(root_python) do
					if file_exists(path) then
						return path
					end
				end
				return vim.fn.exepath("python") ~= "" and vim.fn.exepath("python") or vim.fn.exepath("python3")
			end

			vim.lsp.config("pyright", {
				root_dir = function(fname)
					local markers =
						{ "pyrightconfig.json", "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" }
					for _, marker in ipairs(markers) do
						local root = vim.fs.root(fname, marker)
						if root then
							return root
						end
					end
					return vim.fn.fnamemodify(fname, ":h")
				end,
				before_init = function(_, config)
					local python = get_python_path(config.root_dir)
					config.settings = config.settings or {}
					config.settings.python = config.settings.python or {}
					config.settings.python.pythonPath = python
				end,
				settings = {
					python = {
						analysis = {
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
							typeCheckingMode = "basic",
						},
					},
				},
			})

			vim.lsp.config("lua_ls", {
				settings = {
					Lua = { diagnostics = { globals = { "vim" } } },
				},
			})

			require("mason-lspconfig").setup({
				ensure_installed = {
					"pyright",
					"lua_ls",
					"clangd",
					"rust_analyzer",
					"html",
					"cssls",
					"marksman",
					"texlab",
				},
			})

			vim.lsp.enable({ "pyright", "lua_ls", "clangd", "rust_analyzer", "html", "cssls", "marksman", "texlab" })
		end,
	},

	-- Auto-close brackets
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
	},

	-- Autocompletion
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
		},
		config = function()
			local cmp = require("cmp")
			cmp.setup({
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						else
							cmp.complete()
						end
					end, { "i", "s" }),
					["<CR>"] = cmp.mapping.confirm({ select = false }),
					["<Tab>"] = cmp.mapping.select_next_item(),
				}),
				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
				},
			})
		end,
	},

	-- Auto-formatting
	{
		"stevearc/conform.nvim",
		event = "BufWritePre",
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "isort", "black" },
			},
			formatters = {
				black = {
					prepend_args = { "--line-length", "120" },
				},
			},
			format_on_save = {
				timeout_ms = 500,
				lsp_fallback = true,
			},
		},
	},

	-- Linting
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPost", "BufWritePost", "BufNewFile" },
		config = function()
			local lint = require("lint")
			lint.linters_by_ft = {
				python = { "flake8", "mypy" },
			}
			lint.linters.flake8.args = {
				"--max-line-length=120",
				"--extend-ignore=E203,W503",
				"-",
			}
			lint.linters.mypy = vim.tbl_extend("force", lint.linters.mypy, {
				args = {
					"--ignore-missing-imports",
					"--show-column-numbers",
					"--show-error-end",
					"--hide-error-context",
					"--no-color-output",
					"--no-error-summary",
					"--no-pretty",
				},
			})
			lint.linters.pylint = vim.tbl_extend("force", lint.linters.pylint or {}, {
				args = {
					"--disable=import-error,missing-module-docstring,wrong-import-position,consider-using-from-import",
					"-f",
					"json",
					"--from-stdin",
					function()
						return vim.api.nvim_buf_get_name(0)
					end,
				},
			})
			vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave", "BufEnter" }, {
				callback = function()
					lint.try_lint()
				end,
			})
		end,
	},

	-- Auto-install linters via Mason
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim" },
		opts = {
			ensure_installed = { "flake8", "mypy", "pylint" },
		},
	},

	-- LaTeX
	{
		"lervag/vimtex",
		lazy = false,
		init = function()
			vim.g.vimtex_view_method = "skim"
		end,
	},

	-- Tab out of quotes and brackets in insert mode
	{
		"abecodes/tabout.nvim",
		event = "InsertCharPre",
		dependencies = { "nvim-treesitter/nvim-treesitter", "hrsh7th/nvim-cmp" },
		config = function()
			require("tabout").setup({
				tabkey = "<Tab>",
				backwards_tabkey = "<S-Tab>",
				act_as_tab = true,
				completion = true,
				ignore_beginning = true,
				tabouts = {
					{ open = "'", close = "'" },
					{ open = '"', close = '"' },
					{ open = "`", close = "`" },
					{ open = "(", close = ")" },
					{ open = "[", close = "]" },
				},
			})
		end,
	},
}
