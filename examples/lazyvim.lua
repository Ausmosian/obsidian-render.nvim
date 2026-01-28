-- Example LazyVim plugin configuration
-- Save this as ~/.config/nvim/lua/plugins/obsidian-render.lua

return {
	"Ausmosian/obsidian-render.nvim",

	-- Lazy load on keybinding
	keys = {
		{ "<leader>mo", desc = "Render markdown in Obsidian" },
	},

	-- Or lazy load on markdown files
	-- ft = "markdown",

	opts = {
		-- ============================================================================
		-- USER CONFIGURATION - Change these for your system
		-- ============================================================================

		-- Your Obsidian vault path (REQUIRED - change this!)
		vault_path = vim.fn.expand("~/vault"),

		-- Directory within vault for symlinks (set to nil or "" to use vault root)
		symlink_dir = "nvim-renders",

		-- Command to open URIs
		-- Linux: "xdg-open", macOS: "open", Windows: "start"
		open_command = "xdg-open",

		-- ============================================================================
		-- BEHAVIOR CONFIGURATION (optional)
		-- ============================================================================

		-- Whether to create symlink_dir if it doesn't exist
		create_symlink_dir = true,

		-- File extension to check for (only markdown files)
		file_extension = "md",

		-- Notification levels
		notify_on_success = true,
		notify_on_symlink_creation = true,
	},

	config = function(_, opts)
		local obsidian_render = require("obsidian-render")
		obsidian_render.setup(opts)

		-- Set up keybinding
		vim.keymap.set("n", "<leader>mo", obsidian_render.open_in_obsidian, {
			desc = "Render markdown in Obsidian",
			noremap = true,
			silent = true,
		})

		-- Optional: Additional keybindings
		-- vim.keymap.set("n", "<leader>mc", obsidian_render.cleanup_broken_symlinks, {
		--   desc = "Cleanup Obsidian symlinks",
		-- })
	end,
}
