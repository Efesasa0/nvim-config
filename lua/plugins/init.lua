-- Plugin specifications for lazy.nvim

return {
	-- Colorscheme (pure black - no plugin needed)
	{
		"nvim-lua/plenary.nvim", -- placeholder dependency
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd("colorscheme pureblack")
		end,
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

	-- Bufferline (tab bar for open files)
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		event = "VimEnter",
		opts = {
			options = {
				mode = "buffers",
				separator_style = "thin",
				show_close_icon = false,
				show_buffer_close_icons = false,
				diagnostics = false,
				offsets = {
					{ filetype = "neo-tree", text = "Files", text_align = "center" },
				},
			},
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

	-- Auto-close brackets
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
	},

	-- Auto-formatting
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
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

	-- Completion
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
					["<C-Space>"] = cmp.mapping.complete(),
					["<CR>"] = cmp.mapping.confirm({ select = false }),
					["<Tab>"] = cmp.mapping.select_next_item(),
					["<S-Tab>"] = cmp.mapping.select_prev_item(),
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
				filtered_items = {
					visible = true,
				},
			},
			close_if_last_window = true,
			enable_git_status = true,
			follow_current_file = { enabled = true },
		},
	},

	-- AI code completion (off by default, toggle with <leader>ai)
	{
		"supermaven-inc/supermaven-nvim",
		config = function()
			local completion_preview = require("supermaven-nvim.completion_preview")
			require("supermaven-nvim").setup({
				disable_inline_completion = false,
				disable_keymaps = true,
			})
			-- Force stop on startup so nothing runs until explicitly toggled
			local api = require("supermaven-nvim.api")
			vim.defer_fn(function()
				if api.is_running() then
					api.stop()
				end
			end, 100)
			vim.keymap.set("i", "<C-a>", function()
				completion_preview.on_accept_suggestion()
			end, { desc = "Accept Supermaven suggestion" })
			vim.keymap.set("n", "<leader>ai", function()
				local sm = require("supermaven-nvim.api")
				if sm.is_running() then
					sm.stop()
					vim.notify("Supermaven OFF", vim.log.levels.WARN)
				else
					sm.start()
					vim.notify("Supermaven ON", vim.log.levels.INFO)
				end
			end, { desc = "Toggle Supermaven AI" })
		end,
	},

	-- LSP Management (Mason)
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
				-- Prefer active conda/virtualenv when Neovim is launched from it.
				local env_python = {
					vim.env.CONDA_PREFIX and (vim.env.CONDA_PREFIX .. "/bin/python") or nil,
					vim.env.VIRTUAL_ENV and (vim.env.VIRTUAL_ENV .. "/bin/python") or nil,
				}
				for _, path in ipairs(env_python) do
					if file_exists(path) then
						return path
					end
				end

				-- Fallback to common in-project environments.
				local root_python = {
					root_dir and (root_dir .. "/.venv/bin/python") or nil,
					root_dir and (root_dir .. "/venv/bin/python") or nil,
				}
				for _, path in ipairs(root_python) do
					if file_exists(path) then
						return path
					end
				end

				if vim.fn.exepath("python") ~= "" then
					return vim.fn.exepath("python")
				end
				return vim.fn.exepath("python3")
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
				ensure_installed = { "pyright", "lua_ls" },
			})

			vim.lsp.enable({ "pyright", "lua_ls" })
		end,
	},

	-- Linting (flake8, mypy, pylint)
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPost", "BufWritePost", "BufNewFile" },
		config = function()
			local lint = require("lint")
			lint.linters_by_ft = {
				python = { "flake8", "mypy", "pylint" },
			}
			lint.linters.flake8.args = {
				"--max-line-length=88",
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
					"--disable=import-error",
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

	-- Auto-install linters/formatters via Mason
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim" },
		opts = {
			ensure_installed = {
				"flake8",
				"mypy",
				"pylint",
			},
		},
	},

	-- Telescope (fuzzy finder)
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		keys = {
			{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
			{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
			{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find buffers" },
			{ "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
			{ "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "All keybindings" },
		},
		config = function()
			require("telescope").setup({
				defaults = {
					mappings = {
						i = {
							["<Esc>"] = require("telescope.actions").close,
						},
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

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		lazy = false,
		main = "nvim-treesitter",
		opts = {
			ensure_installed = { "python", "lua" },
			highlight = { enable = true },
		},
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
					template = {
						annotation_convention = "google_docstrings",
					},
				},
			},
		},
	},

	-- Colorful Markdown Rendering
	{
		"OXY2DEV/markview.nvim",
		lazy = false,
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
	},

	-- Jupyter Notebook support
	{
		"benlubas/molten-nvim",
		version = "^1.0.0",
		lazy = false,
		build = ":UpdateRemotePlugins",
		init = function()
			-- Output window settings
			vim.g.molten_output_win_max_height = 20
			vim.g.molten_auto_open_output = true
			vim.g.molten_wrap_output = true
			vim.g.molten_virt_text_output = true
			vim.g.molten_virt_lines_off_by_1 = true

			-- Keybindings
			vim.keymap.set("n", "<leader>mi", "<cmd>MoltenInit<cr>", { desc = "Initialize Molten" })
			vim.keymap.set("n", "<leader>ml", "<cmd>MoltenEvaluateLine<cr>", { desc = "Molten evaluate line" })
			vim.keymap.set("n", "<leader>mr", "<cmd>MoltenReevaluateCell<cr>", { desc = "Molten re-evaluate cell" })
			vim.keymap.set("v", "<leader>mv", ":<C-u>MoltenEvaluateVisual<cr>", { desc = "Molten evaluate visual" })
			vim.keymap.set("n", "<leader>mc", "<cmd>MoltenHideOutput<cr>", { desc = "Molten hide output" })
			vim.keymap.set("n", "<leader>md", "<cmd>MoltenDelete<cr>", { desc = "Molten delete cell" })
		end,
	},
}
