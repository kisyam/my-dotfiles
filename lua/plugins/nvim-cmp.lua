return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp", -- provides completion for lsp
    "hrsh7th/cmp-nvim-lsp-signature-help", -- lsp help
    "hrsh7th/cmp-buffer", -- anything in open buffers
    "hrsh7th/cmp-path", -- file path
    "hrsh7th/cmp-cmdline", -- commands in neovim
    "hrsh7th/cmp-calc", -- calculator
    {
      "L3MON4D3/LuaSnip",
      version = "v2.*",
      build = "make install_jsregexp",
      opts = {
        history = true,
        delete_check_events = "TextChanged",
      },
      keys = {
        {
          "<tab>",
          function()
            return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
          end,
          expr = true,
          silent = true,
          mode = "i",
        },
        {
          "<tab>",
          function()
            require("luasnip").jump(1)
          end,
          mode = "s",
        },
        {
          "<s-tab>",
          function()
            require("luasnip").jump(-1)
          end,
          mode = { "i", "s" },
        },
      },
      dependencies = {
        "saadparwaiz1/cmp_luasnip",
        "onsails/lspkind-nvim",
        "honza/vim-snippets",
        "rafamadriz/friendly-snippets",
      },

      config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
        require("luasnip.loaders.from_snipmate").lazy_load()
        require("luasnip.loaders.from_lua").lazy_load()

        -- for snippet tab completion
        local has_words_before = function()
          unpack = unpack or table.unpack
          local line, col = unpack(vim.api.nvim_win_get_cursor(0))
          return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
        end

        local cmp = require("cmp")
        local lspkind = require("lspkind")
        local luasnip = require("luasnip")
        cmp.setup({
          formatting = {
            format = lspkind.cmp_format(), -- load icons
          },
          snippet = {
            expand = function(args)
              luasnip.lsp_expand(args.body) -- load luasnip
            end,
          },
          mapping = cmp.mapping.preset.insert({
            ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<C-e>"] = cmp.mapping.abort(),
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
            ["<Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
              elseif has_words_before() then
                cmp.complete()
              else
                fallback()
              end
            end, { "i", "s" }),

            ["<S-Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
              else
                fallback()
              end
            end, { "i", "s" }),
          }),
          sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "nvim_lsp_signature_help" },
            { name = "luasnip" },
          }, {
            { name = "buffer" },
            { name = "path" },
            { name = "calc" },
          }),
        })

        -- buffer source for / and ?
        cmp.setup.cmdline({ "/", "?" }, {
          mapping = cmp.mapping.preset.cmdline(),
          sources = {
            { name = "buffer" },
          },
        })

        -- cmdline and path sources for :
        cmp.setup.cmdline(":", {
          mapping = cmp.mapping.preset.cmdline(),
          sources = cmp.config.sources({
            { name = "path" },
          }, {
            { name = "cmdline" },
          }),
        })
      end,
    },
  },
}
