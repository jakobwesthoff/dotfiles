local M = {}

-- Load color from highlight colors and return as hex
function M.getColor(group, attr)
  local hl = vim.api.nvim_get_hl(0, { name = group })
  -- Return nil when the group lacks the requested attribute so callers can
  -- distinguish "no color" from a real value; folding it to 0 would render
  -- missing attributes as black instead.
  if hl[attr] == nil then
    return nil
  end

  return string.format("#%06x", hl[attr])
end

return M
