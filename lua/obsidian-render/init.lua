-- lua/obsidian-render/init.lua
-- Main plugin module for obsidian-render.nvim

local M = {}

-- Default configuration
M.config = {
	-- Your Obsidian vault path (REQUIRED)
	vault_path = vim.fn.expand("~/Documents/ObsidianVault"),

	-- Directory within vault for symlinks (set to nil or "" to use vault root)
	symlink_dir = "nvim-renders",

	-- Command to open URIs (xdg-open for Ubuntu, open for macOS, start for Windows)
	open_command = "xdg-open",

	-- Whether to create symlink_dir if it doesn't exist
	create_symlink_dir = true,

	-- File extension to check for (only markdown files)
	file_extension = "md",

	-- Notification levels
	notify_on_success = true,
	notify_on_symlink_creation = true,

	-- Obsidian window behavior
	obsidian = {
		-- Open in a new window or existing window
		-- Options: nil (default), "new-pane", "new-tab", "split-vertical", "split-horizontal", "new-window"
		open_in = nil,

		-- View mode: "source" (edit mode) or "preview" (reading mode)
		mode = nil, -- nil = use Obsidian's default
	},
}

-- Get the full symlink path for a file
function M.get_symlink_path(filename)
	local base_path = M.config.vault_path
	if M.config.symlink_dir and M.config.symlink_dir ~= "" then
		base_path = base_path .. "/" .. M.config.symlink_dir
	end
	return base_path .. "/" .. filename
end

-- Check if symlink exists and points to the correct source file
function M.check_symlink(source_file, symlink_path)
	-- Check if symlink exists
	if vim.fn.filereadable(symlink_path) == 0 then
		return false, "not_exists"
	end

	-- Check if it's actually a symlink
	local is_symlink = vim.fn.getftype(symlink_path) == "link"
	if not is_symlink then
		return false, "not_symlink"
	end

	-- Check if it points to our source file
	local target = vim.fn.resolve(symlink_path)
	if target ~= source_file then
		return false, "wrong_target"
	end

	return true, "valid"
end

-- Create symlink if it doesn't exist or is invalid
function M.ensure_symlink(source_file)
	local filename = vim.fn.fnamemodify(source_file, ":t")
	local symlink_path = M.get_symlink_path(filename)

	-- Check existing symlink
	local is_valid, status = M.check_symlink(source_file, symlink_path)

	if is_valid then
		return symlink_path, filename, false -- already exists and valid
	end

	-- Create symlink directory if needed
	if M.config.symlink_dir and M.config.symlink_dir ~= "" and M.config.create_symlink_dir then
		local symlink_dir_path = M.config.vault_path .. "/" .. M.config.symlink_dir
		vim.fn.mkdir(symlink_dir_path, "p")
	end

	-- Remove old symlink/file if it exists but is invalid
	if status ~= "not_exists" then
		vim.fn.delete(symlink_path)
	end

	-- Create symlink
	local cmd = string.format('ln -sf "%s" "%s"', source_file, symlink_path)
	local result = vim.fn.system(cmd)

	if vim.v.shell_error == 0 then
		return symlink_path, filename, true -- newly created
	else
		vim.notify("Failed to create symlink: " .. result, vim.log.levels.ERROR)
		return nil, nil, false
	end
end

-- Open file in Obsidian
function M.open_in_obsidian()
	local current_file = vim.fn.expand("%:p")

	-- Check if current file is a markdown file
	if vim.fn.expand("%:e") ~= M.config.file_extension then
		vim.notify("Current file is not a markdown file", vim.log.levels.WARN)
		return
	end

	-- Check if file exists
	if vim.fn.filereadable(current_file) == 0 then
		vim.notify("Current file does not exist or is not saved", vim.log.levels.WARN)
		return
	end

	-- Ensure symlink exists
	local symlink_path, filename, newly_created = M.ensure_symlink(current_file)

	if not symlink_path then
		return
	end

	-- Notify user
	if newly_created then
		if M.config.notify_on_symlink_creation then
			vim.notify("Created symlink and opening in Obsidian...", vim.log.levels.INFO)
		end
	else
		if M.config.notify_on_success then
			vim.notify("Opening in Obsidian...", vim.log.levels.INFO)
		end
	end

	-- Get vault name
	local vault_name = vim.fn.fnamemodify(M.config.vault_path, ":t")

	-- Construct Obsidian URI
	-- If using symlink_dir, include it in the path
	local file_path = filename
	if M.config.symlink_dir and M.config.symlink_dir ~= "" then
		file_path = M.config.symlink_dir .. "/" .. filename
	end

	-- Build URI with optional parameters
	local uri_params = {
		"vault=" .. vim.uri_encode(vault_name),
		"file=" .. vim.uri_encode(file_path),
	}

	-- Add optional window behavior
	if M.config.obsidian.open_in then
		table.insert(uri_params, "open-in=" .. M.config.obsidian.open_in)
	end

	-- Add optional view mode
	if M.config.obsidian.mode then
		table.insert(uri_params, "mode=" .. M.config.obsidian.mode)
	end

	local uri = "obsidian://open?" .. table.concat(uri_params, "&")

	-- Open Obsidian with configured open command
	vim.fn.system(string.format('%s "%s" 2>/dev/null &', M.config.open_command, uri))

	-- Additional info about live refresh
	if newly_created and M.config.notify_on_symlink_creation then
		vim.notify(
			"💡 Live refresh: Changes in Neovim will reflect in Obsidian automatically via symlink",
			vim.log.levels.INFO
		)
	end
end

-- Cleanup: remove broken symlinks in the vault directory
function M.cleanup_broken_symlinks()
	local symlink_dir_path = M.config.vault_path
	if M.config.symlink_dir and M.config.symlink_dir ~= "" then
		symlink_dir_path = symlink_dir_path .. "/" .. M.config.symlink_dir
	end

	-- Check if directory exists
	if vim.fn.isdirectory(symlink_dir_path) == 0 then
		vim.notify("Symlink directory does not exist: " .. symlink_dir_path, vim.log.levels.WARN)
		return
	end

	-- Find all symlinks in the directory
	local cmd = string.format('find "%s" -maxdepth 1 -type l -name "*.%s"', symlink_dir_path, M.config.file_extension)
	local symlinks = vim.fn.systemlist(cmd)

	local removed = 0
	for _, symlink in ipairs(symlinks) do
		-- Check if symlink target exists
		local target = vim.fn.resolve(symlink)
		if vim.fn.filereadable(target) == 0 then
			-- Broken symlink, remove it
			vim.fn.delete(symlink)
			removed = removed + 1
		end
	end

	if removed > 0 then
		vim.notify(string.format("Cleaned up %d broken symlink(s)", removed), vim.log.levels.INFO)
	else
		vim.notify("No broken symlinks found", vim.log.levels.INFO)
	end
end

-- Setup function called by lazy.nvim
function M.setup(opts)
	-- Merge user config with defaults
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})

	-- Create user commands
	vim.api.nvim_create_user_command("ObsidianRender", M.open_in_obsidian, {
		desc = "Render current markdown file in Obsidian",
	})

	vim.api.nvim_create_user_command("ObsidianCleanup", M.cleanup_broken_symlinks, {
		desc = "Clean up broken Obsidian symlinks",
	})
end

return M
