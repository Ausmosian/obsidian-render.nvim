# Publishing Your Plugin to GitHub - Complete Guide

## 📦 Plugin Structure

Your plugin is now structured as a proper Neovim plugin:

```
obsidian-render.nvim/
├── .gitignore
├── LICENSE
├── README.md
├── examples/
│   └── lazyvim.lua          # Example configuration for users
├── lua/
│   └── obsidian-render/
│       └── init.lua         # Main plugin code
└── plugin/
    └── obsidian-render.lua  # Auto-load file
```

## 🚀 Publishing to GitHub

### Step 1: Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: `obsidian-render.nvim` (must end with .nvim)
3. Description: "Render markdown files in Obsidian from Neovim with live refresh"
4. Make it **Public**
5. **Don't** initialize with README (we already have one)
6. Click "Create repository"

### Step 2: Initialize Git and Push

```bash
# Navigate to your plugin directory
cd /path/to/obsidian-render.nvim

# Initialize git
git init

# Add all files
git add .

# Make first commit
git commit -m "Initial commit: Obsidian markdown renderer for Neovim"

# Add your GitHub repository as remote (replace 'yourusername')
git remote add origin https://github.com/yourusername/obsidian-render.nvim.git

# Push to GitHub
git branch -M main
git push -u origin main
```

### Step 3: Add Topics/Tags on GitHub

Go to your repository page and add these topics:
- `neovim`
- `neovim-plugin`
- `obsidian`
- `markdown`
- `lazyvim`
- `vim-plugin`

This helps people discover your plugin!

## 📝 Users Can Now Install Your Plugin

### For LazyVim Users

Tell users to create `~/.config/nvim/lua/plugins/obsidian-render.lua`:

```lua
return {
  "yourusername/obsidian-render.nvim",
  keys = {
    { "<leader>mo", desc = "Render markdown in Obsidian" },
  },
  opts = {
    vault_path = vim.fn.expand("~/Documents/ObsidianVault"), -- Change this!
    symlink_dir = "nvim-renders",
    open_command = "xdg-open", -- "open" for macOS, "start" for Windows
  },
  config = function(_, opts)
    local obsidian_render = require("obsidian-render")
    obsidian_render.setup(opts)
    
    vim.keymap.set("n", "<leader>mo", obsidian_render.open_in_obsidian, {
      desc = "Render markdown in Obsidian",
    })
  end,
}
```

Then restart Neovim or run `:Lazy sync`

## 🎯 Making Your Plugin Popular

### 1. Write Good Documentation
- ✅ Clear installation instructions (you have this!)
- ✅ Screenshots/GIFs showing the plugin in action
- ✅ Troubleshooting section (you have this!)
- ✅ Configuration examples (you have this!)

### 2. Share Your Plugin
- Post on Reddit: r/neovim
- Share on Twitter/X with #neovim hashtag
- Submit to awesome-neovim: https://github.com/rockerBOO/awesome-neovim

### 3. Add a Demo GIF

Create a GIF showing:
1. Opening a markdown file in Neovim
2. Pressing `<leader>mo`
3. Obsidian opening with the file
4. Editing in Neovim and showing live refresh in Obsidian

Use tools like:
- **asciinema** (for terminal recording)
- **Peek** (for screen recording)
- **OBS Studio** (full-featured)

Add to your README:
```markdown
## 🎬 Demo

![Demo](https://user-images.githubusercontent.com/yourimage.gif)
```

### 4. Create a Release

After your first push:
1. Go to your repo → Releases → "Create a new release"
2. Tag: `v1.0.0`
3. Title: `v1.0.0 - Initial Release`
4. Description: List features
5. Publish release

### 5. Optional: Add to Neovim Plugin Managers Lists

Submit PR to these repos to get listed:
- https://github.com/rockerBOO/awesome-neovim
- https://dotfyle.com/submit

## 📊 Tracking Usage

GitHub automatically shows:
- ⭐ Stars (people who like it)
- 👁️ Watchers (people following updates)
- 🍴 Forks (people modifying it)

## 🔄 Updating Your Plugin

When you make changes:

```bash
# Make your changes to the code
git add .
git commit -m "Add feature: XYZ"
git push

# Optional: Create a new release
# Tag it as v1.1.0, v1.2.0, etc.
```

## 🐛 Handling Issues

Users can report bugs via GitHub Issues. Make sure to:
1. Enable Issues in your repo settings
2. Create issue templates (optional but helpful)
3. Respond to issues promptly
4. Label them appropriately (bug, enhancement, question)

## 📜 License Note

The plugin uses MIT License (most permissive). Users can:
- ✅ Use commercially
- ✅ Modify
- ✅ Distribute
- ✅ Sublicense

Just requires attribution.

## 🎉 That's It!

Your plugin is now:
- ✅ Properly structured
- ✅ Ready to publish
- ✅ Easy for users to install
- ✅ Open source and shareable

Good luck with your plugin! 🚀
