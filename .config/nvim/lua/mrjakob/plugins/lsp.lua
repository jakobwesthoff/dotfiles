return {
  {
    -- Main LSP Configuration
    "neovim/nvim-lspconfig",
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      { "williamboman/mason.nvim", config = true }, -- NOTE: Must be loaded before dependants
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",

      -- Useful status updates for LSP.
      -- LSP and notify updates in the down right corner
      {
        "j-hui/fidget.nvim",
        -- Workaround for neovim/neovim#18576: `hl_blend_attrs()` in
        -- `src/nvim/highlight.c` forces bg=NONE to -1 before calling
        -- `rgb_blend()`, which produces black via bitwise arithmetic on
        -- the negative value. With a transparent colorscheme (Normal
        -- bg=NONE) this makes any floating window using winblend show a
        -- black background instead of being transparent.
        --
        -- Fixed upstream in PR #34302 (merged June 2025, milestone 0.12).
        -- Not backported to 0.11.x. Until we upgrade to 0.12, we use
        -- normal_hl="NormalFloat" (has real bg via gruvbox-material
        -- customize callback) and winblend=0 (blending is pointless when
        -- the underlying bg is NONE anyway).
        --
        -- Separate issue: vim.o.winborder leaks into fidget's window on
        -- reposition because fidget's `nvim_win_set_config()` omits the
        -- border field. Fix on jakobwesthoff/fidget.nvim branch
        -- fix/preserve-border-on-reposition, not yet upstreamed.
        --
        -- TODO: Remove this workaround after upgrading to Neovim 0.12+
        --   and revert to fidget defaults (winblend=100, normal_hl="Comment").
        -- TODO: Upstream the fidget winborder reposition fix.
        opts = {
          notification = {
            override_vim_notify = true,
            window = {
              normal_hl = "NormalFloat",
              winblend = 0,
            },
          },
        },
      },

      -- Allows extra capabilities provided by blink.cmp
      "saghen/blink.cmp",
    },
    config = function()
      -- =========================================================
      -- Per-server LSP configuration via vim.lsp.config()
      -- =========================================================

      -- Broadcast blink.cmp capabilities to all servers via wildcard config.
      -- This replaces the old per-server capabilities merging loop.
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      -- --query-driver tells clangd which compilers it may invoke to discover
      -- built-in include paths and predefined macros. Without it, clangd only
      -- knows about the host clang and cannot introspect cross-compilers like
      -- xtensa-esp32-elf-g++, leading to missing toolchain headers and false
      -- diagnostics in embedded projects.
      --
      -- The glob pattern is broad on purpose: it matches any compiler binary
      -- under ~/.platformio as well as common system paths. For projects that
      -- use a regular host compiler, the pattern simply never matches anything
      -- extra, so clangd falls back to its normal built-in driver detection.
      -- In other words, this flag is a no-op for non-embedded C/C++ projects.
      vim.lsp.config("clangd", {
        cmd = {
          "clangd",
          "--query-driver=**/**/xtensa-*,**/arm-none-eabi-*",
          "--background-index",
        },
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            completion = {
              callSnippet = "Replace",
            },
            diagnostics = { disable = { "missing-fields" } },
          },
        },
      })

      -- Restrict yamlls to the "yaml" filetype so it never attaches to helm
      -- templates (which have filetype "helm" via ftdetect/helm.lua).
      vim.lsp.config("yamlls", {
        filetypes = { "yaml" },
      })

      -- =========================================================
      -- LspAttach autocmd — buffer-local behavior on attach
      -- =========================================================

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          -- Highlight references of the word under the cursor on CursorHold,
          -- clear them on CursorMoved.
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
              end,
            })
          end

          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            vim.keymap.set("n", "<leader>uh", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
            end, { desc = "Toggle [U]i Inlay [H]ints" })
          end
        end,
      })

      -- =========================================================
      -- LSP handler overrides and diagnostic config
      -- =========================================================

      -- Show window/showMessage requests using vim.notify instead of logging to messages
      vim.lsp.handlers["window/showMessage"] = function(_, params, ctx)
        local message_type = params.type
        local message = params.message
        local client_id = ctx.client_id
        local client = vim.lsp.get_client_by_id(client_id)
        local client_name = client and client.name or string.format("id=%d", client_id)
        if not client then
          vim.notify("LSP[" .. client_name .. "] client has shut down after sending " .. message, vim.log.levels.ERROR)
        end
        if message_type == vim.lsp.protocol.MessageType.Error then
          vim.notify("LSP[" .. client_name .. "] " .. message, vim.log.levels.ERROR)
        else
          message = ("LSP[%s][%s] %s\n"):format(client_name, vim.lsp.protocol.MessageType[message_type], message)
          vim.notify(message, vim.log.levels[message_type])
        end
        return params
      end

      -- Change diagnostic symbols in the sign column (gutter)
      local signs = { ERROR = "", WARN = "", INFO = "", HINT = "" }
      local diagnostic_signs = {}
      for type, icon in pairs(signs) do
        diagnostic_signs[vim.diagnostic.severity[type]] = icon
      end
      vim.diagnostic.config({ signs = { text = diagnostic_signs } })

      -- =========================================================
      -- Mason — install servers and tools
      -- =========================================================

      require("mason").setup()

      require("mason-tool-installer").setup({
        ensure_installed = {
          -- LSP servers
          "lua_ls",
          "marksman",
          "ts_ls",
          "taplo",
          "phpactor",
          "shellcheck",
          "bashls",
          "dockerls",
          "docker_compose_language_service",
          "helm_ls",
          "yamlls",
          "jsonls",
          "clangd",
          -- Formatters / linters
          "stylua",
          "prettierd",
        },
      })

      -- mason-lspconfig's automatic_enable (default: true) calls
      -- vim.lsp.enable() for installed servers, picking up the
      -- vim.lsp.config() settings defined above.
      require("mason-lspconfig").setup({})
    end,
  },
  -- LSP Plugins
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = "luvit-meta/library", words = { "vim%.uv" } },
      },
    },
  },
  -- Rustacean vim for all our Rust needs
  -- INFO: We can't install rust-analyzer via Mason, as this will conflict with
  -- rustaceanvim. Therefore ensure it is installed manually for example using
  -- rustup and available in the path. This has the added benefit, of having
  -- the rust-analyzer in the version fitting our current rust installation:
  --
  -- ```shell
  -- rustup component add rust-analyzer
  -- ```
  {
    "mrcjkb/rustaceanvim",
    version = "^5", -- Recommended
    lazy = false, -- This plugin is already lazy
  },
}
