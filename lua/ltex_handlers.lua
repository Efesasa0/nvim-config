local M = {}

local cache_dir = vim.fn.stdpath("config") .. "/ltex-cache"

local function ensure_dir()
	vim.fn.mkdir(cache_dir, "p")
end

local function read_json(name)
	local path = cache_dir .. "/" .. name .. ".json"
	if vim.uv.fs_stat(path) then
		local ok, content = pcall(vim.fn.readfile, path)
		if ok then
			local ok2, tbl = pcall(vim.fn.json_decode, table.concat(content, "\n"))
			if ok2 and type(tbl) == "table" then
				return tbl
			end
		end
	end
	return {}
end

local function write_json(name, tbl)
	ensure_dir()
	local path = cache_dir .. "/" .. name .. ".json"
	vim.fn.writefile({ vim.fn.json_encode(tbl) }, path)
end

function M.load_settings()
	return {
		dictionary = read_json("dictionary"),
		hiddenFalsePositives = read_json("hiddenFalsePositives"),
		disabledRules = read_json("disabledRules"),
	}
end

local function merge_entries(existing_data, incoming)
	for lang, values in pairs(incoming or {}) do
		existing_data[lang] = existing_data[lang] or {}
		local seen = {}
		for _, v in ipairs(existing_data[lang]) do
			seen[v] = true
		end
		for _, v in ipairs(values) do
			if not seen[v] then
				table.insert(existing_data[lang], v)
				seen[v] = true
			end
		end
	end
	return existing_data
end

local function push(client, key, data)
	if not client then
		return
	end
	client.config.settings = client.config.settings or {}
	client.config.settings.ltex = client.config.settings.ltex or {}
	client.config.settings.ltex[key] = data
	client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
end

local function handler(name, arg_key, settings_key, label)
	return function(cmd, ctx)
		local args = cmd.arguments and cmd.arguments[1] or {}
		local incoming = args[arg_key] or {}
		local data = merge_entries(read_json(name), incoming)
		write_json(name, data)
		local client = vim.lsp.get_client_by_id(ctx.client_id)
		push(client, settings_key, data)
		local sample
		for _, values in pairs(incoming) do
			if values[1] then
				sample = values[1]
				break
			end
		end
		vim.notify(label .. (sample and (": " .. sample) or ""))
	end
end

function M.setup()
	vim.lsp.commands = vim.lsp.commands or {}
	vim.lsp.commands["_ltex.addToDictionary"] =
		handler("dictionary", "words", "dictionary", "Added to LTeX dictionary")
	vim.lsp.commands["_ltex.hideFalsePositives"] =
		handler("hiddenFalsePositives", "falsePositives", "hiddenFalsePositives", "Hid false positive")
	vim.lsp.commands["_ltex.disableRules"] =
		handler("disabledRules", "ruleIds", "disabledRules", "Disabled LTeX rule")
end

return M
