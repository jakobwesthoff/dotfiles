return {
  "windwp/nvim-ts-autotag",
  -- Loaded at startup: the plugin attaches to buffers on FileType, so loading
  -- it later (e.g. on InsertEnter) leaves every tag buffer opened before that
  -- point without auto-close and auto-rename. Its README notes lazy loading
  -- is unnecessary.
  opts = {},
}
