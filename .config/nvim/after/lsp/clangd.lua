-- Override of nvim-lspconfig's clangd config (merged on top of its defaults).
--
-- --query-driver tells clangd which compilers it may invoke to discover
-- built-in include paths and predefined macros. Without it, clangd only knows
-- about the host clang and cannot introspect cross-compilers like
-- xtensa-esp32-elf-g++, leading to missing toolchain headers and false
-- diagnostics in embedded projects.
--
-- The glob pattern is broad on purpose: it matches any compiler binary under
-- ~/.platformio as well as common system paths. For projects that use a
-- regular host compiler, the pattern simply never matches anything extra, so
-- clangd falls back to its normal built-in driver detection. In other words,
-- this flag is a no-op for non-embedded C/C++ projects.
return {
  cmd = {
    "clangd",
    "--query-driver=**/**/xtensa-*,**/arm-none-eabi-*",
    "--background-index",
  },
}
