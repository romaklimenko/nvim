local M = {}

-- Mac uses Command aliases and preserves native Ctrl keys by default.
-- Windows/WSL retain the existing VS Code-like Ctrl mappings.
function M.vscode_ctrl()
  local style = vim.g.editor_keymap_style or vim.env.NVIM_KEYMAP_STYLE
  if style == "native" then
    return false
  elseif style == "vscode" then
    return true
  end
  return vim.fn.has("mac") == 0
end

function M.map(mode, ctrl, command, action, description, opts)
  opts = vim.tbl_extend("force", { silent = true, desc = description }, opts or {})
  if ctrl and M.vscode_ctrl() then
    vim.keymap.set(mode, ctrl, action, opts)
  end
  if command then
    vim.keymap.set(mode, command, action, opts)
  end
end

return M
