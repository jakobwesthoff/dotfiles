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

function M.newColorWithBase(hl, base, overrides)
  overrides = overrides or {}
  local new_color = {}
  -- Copy all properties from base highlight group
  local subst = vim.api.nvim_get_hl(0, { name = base })
  for k, v in pairs(subst) do
    new_color[k] = v
  end

  -- Override with everything else given
  for k, v in pairs(overrides) do
    new_color[k] = v
  end
  vim.api.nvim_set_hl(0, hl, new_color)
end

return M
