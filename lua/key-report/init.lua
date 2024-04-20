local Path = require "plenary.path"
local data_path = string.format("%s/key_report.json", vim.fn.stdpath "data")

local KR = {}
local H = {
  cache = {
    key_counts = {},
  },
}

KR.config = {}

KR.setup = function(config)
  KR.config = vim.tbl_extend("force", KR.config, config or {})
  H.create_autocommands()
end

H.create_autocommands = function()
  -- BufEnter: due to Lazy.nvim overriding keymaps, maybe have best way to do this
  vim.api.nvim_create_autocmd({ "BufEnter", "VimEnter" }, {
    callback = function()
      H.override_keymaps()
    end,
  })

  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      -- H.sync_report_from_file()
      H.write_report_file()
    end,
  })
end

H.override_keymaps = function()
  local all_modes = { "n", "v", "i" }

  for _, mode in ipairs(all_modes) do
    local keymaps = vim.api.nvim_get_keymap(mode)

    for _, key in ipairs(keymaps) do
      vim.keymap.set(mode, key.lhs, H.get_keymap_callback(key), H.get_keymap_options(key))
    end
  end
end

H.get_keymap_callback = function(keymap)
  return function()
    vim.schedule(function()
      H.update_key_counts(keymap) -- FIXME: call 1, but count 2
    end)

    if keymap.callback then
      return keymap.callback()
    end

    if keymap.rhs:find "<Cmd>" then
      local cmd = keymap.rhs:gsub("<Cmd>", "")
      cmd = cmd:gsub("<CR>", "")
      return vim.cmd(cmd)
    end

    -- If start with : then it's a command
    if keymap.rhs:sub(1, 1) == ":" then
      local cmd = keymap.rhs:sub(2)
      cmd = cmd:gsub("<CR>", "")
      return vim.cmd(cmd)
    end

    return keymap.rhs
  end
end

H.get_keymap_options = function(keymap)
  return {
    desc = keymap.desc,
    noremap = keymap.noremap == 1,
    silent = keymap.silent == 1,
    expr = keymap.expr == 1,
    replace_keycodes = keymap.replace_keycodes == 1,
  }
end

H.update_key_counts = function(keymap)
  local lhs = keymap.lhs

  if H.cache.key_counts[lhs] then
    H.cache.key_counts[lhs] = H.cache.key_counts[lhs] + 1
  else
    H.cache.key_counts[lhs] = 1
  end
end

H.write_report_file = function()
  local file = Path:new(data_path)
  file:write(vim.json.encode(H.cache.key_counts), "w")
end

H.sync_report_from_file = function()
  local file = Path:new(data_path)

  if file:exists() then
    local report_from_file = vim.json.decode(file:read())

    -- merge the counts from the file with the current counts
    for key, count in pairs(report_from_file) do
      if H.cache.key_counts[key] then
        H.cache.key_counts[key] = H.cache.key_counts[key] + count
      else
        H.cache.key_counts[key] = count
      end
    end
  end
end

return KR
