# obsidian-render.nvim

A Neovim plugin to render markdown files in Obsidian with live refresh support via symlinks.

## ✨ Features

- 🔗 **Smart Symlinking**: Creates symlinks only on first render, subsequent opens are instant
- 🔄 **Live Refresh**: Changes in Neovim automatically reflect in Obsidian via symlinks
- 🚀 **Fast**: No metadata tracking, uses filesystem checks at runtime
- 🎯 **Simple**: One keybinding to render, automatic cleanup of broken symlinks
- ⚙️ **Configurable**: All paths and behaviors can be customized

## 📦 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

Add to your `~/.config/nvim/lua/plugins/obsidian-render.lua`:

```lua
return {
  "yourusername/obsidian-render.nvim",
  keys = {
    { "<leader>mo", desc = "Render markdown in Obsidian" },
  },
  opts = {
    vault_path = vim.fn.expand("~/Documents/ObsidianVault"), -- REQUIRED: Change to your vault path
    symlink_dir = "nvim-renders",                             -- Optional: subdirectory in vault
    open_command = "xdg-open",                                -- Linux: xdg-open, macOS: open, Windows: start
  },
  config = function(_, opts)
    local obsidian_render = require("obsidian-render")
    obsidian_render.setup(opts)
    
    -- Set up keybinding
    vim.keymap.set("n", "<leader>mo", obsidian_render.open_in_obsidian, {
      desc = "Render markdown in Obsidian",
    })
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "yourusername/obsidian-render.nvim",
  config = function()
    require("obsidian-render").setup({
      vault_path = vim.fn.expand("~/Documents/ObsidianVault"),
      symlink_dir = "nvim-renders",
      open_command = "xdg-open",
    })
    
    vim.keymap.set("n", "<leader>mo", require("obsidian-render").open_in_obsidian, {
      desc = "Render markdown in Obsidian",
    })
  end
}
```

## ⚙️ Configuration

### Default Configuration

```lua
{
  -- Your Obsidian vault path (REQUIRED)
  vault_path = vim.fn.expand("~/Documents/ObsidianVault"),
  
  -- Directory within vault for symlinks (set to nil or "" to use vault root)
  symlink_dir = "nvim-renders",
  
  -- Command to open URIs
  -- Linux: "xdg-open"
  -- macOS: "open"
  -- Windows: "start"
  open_command = "xdg-open",
  
  -- Whether to create symlink_dir if it doesn't exist
  create_symlink_dir = true,
  
  -- File extension to check for (only markdown files)
  file_extension = "md",
  
  -- Notification levels
  notify_on_success = true,
  notify_on_symlink_creation = true,
}
```

### Full Example with All Options

```lua
return {
  "yourusername/obsidian-render.nvim",
  keys = {
    { "<leader>mo", desc = "Render markdown in Obsidian" },
  },
  opts = {
    vault_path = vim.fn.expand("~/my-vault"),
    symlink_dir = "from-neovim",
    open_command = "xdg-open",
    create_symlink_dir = true,
    file_extension = "md",
    notify_on_success = false,        -- Disable "Opening..." notifications
    notify_on_symlink_creation = true, -- Keep symlink creation notifications
  },
  config = function(_, opts)
    local obsidian_render = require("obsidian-render")
    obsidian_render.setup(opts)
    
    -- Keybindings
    vim.keymap.set("n", "<leader>mo", obsidian_render.open_in_obsidian, {
      desc = "Render markdown in Obsidian",
    })
    
    -- Optional: Add to which-key
    local wk = require("which-key")
    wk.register({
      ["<leader>m"] = { name = "+markdown" },
      ["<leader>mo"] = { "Render in Obsidian" },
    })
  end,
}
```

## 🚀 Usage

### Commands

- `:ObsidianRender` - Render current markdown file in Obsidian
- `:ObsidianCleanup` - Clean up broken symlinks

### Keybindings

Default: `<leader>mo` (customize in your config)

### Workflow

1. **First time**: Open a markdown file in Neovim and press `<leader>mo`
   - Plugin creates a symlink in your Obsidian vault
   - Opens the file in Obsidian

2. **Subsequent times**: Press `<leader>mo`
   - Plugin detects existing symlink
   - Opens the file in Obsidian (no re-symlinking)

3. **Live editing**: Any changes you make in Neovim are automatically reflected in Obsidian in real-time! 🎉

## 🔧 How It Works

1. **Symlink Creation**: On first render, creates a symlink of your markdown file inside your Obsidian vault
2. **Filesystem Checks**: Uses native filesystem checks to verify symlink validity (no metadata/tracking files)
3. **Obsidian URI**: Opens Obsidian using the `obsidian://` URI protocol
4. **Live Refresh**: Since Obsidian watches the filesystem, changes in the symlink target (your Neovim file) automatically refresh in Obsidian

## 🎯 Platform Support

- ✅ **Linux** (tested on Ubuntu)
- ✅ **macOS** (change `open_command` to `"open"`)
- ✅ **Windows** (change `open_command` to `"start"`)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📝 License

MIT License - see LICENSE file for details

## 💡 Tips

- Use a dedicated subdirectory (like `nvim-renders`) to keep your vault organized
- Run `:ObsidianCleanup` periodically to remove broken symlinks
- The plugin respects your Obsidian theme and settings
- Works great with other Obsidian plugins!

## 🐛 Troubleshooting

**Obsidian doesn't open:**
- Verify `vault_path` is correct
- Check that Obsidian is installed and registered for `obsidian://` URIs
- Try running the URI manually: `xdg-open "obsidian://open?vault=VaultName&file=test.md"`

**Symlinks not working:**
- Ensure your filesystem supports symlinks
- Check permissions on both the source file and vault directory
- Verify `symlink_dir` exists or `create_symlink_dir` is `true`

**Live refresh not working:**
- Obsidian needs to have the vault open
- Check if Obsidian has file watching enabled in settings
- Verify the symlink points to the correct file: `ls -la vault/nvim-renders/`
