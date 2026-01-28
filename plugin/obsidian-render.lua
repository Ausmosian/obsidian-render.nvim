-- plugin/obsidian-render.lua
-- Auto-setup if user doesn't configure

if vim.g.obsidian_render_setup_done then
  return
end

vim.g.obsidian_render_setup_done = true

-- This runs only if the plugin is installed but user hasn't called setup()
-- Useful for minimal setup without configuration
