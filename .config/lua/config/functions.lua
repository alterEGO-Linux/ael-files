local M = {}
function M.status_flags()
  if vim.bo.readonly then return vim.bo.modified and '**READONLY [+]**' or '**READONLY**' end
  return vim.bo.modified and '**MODIFIED**' or ''
end
function M.foldtext()
  local count = vim.v.foldend - vim.v.foldstart + 1
  local line = vim.fn.getline(vim.v.foldstart):gsub('%-+', ''):gsub('^%s+', '')
  local label = '[+] ' .. line
  return label .. string.rep(' ', math.max(1, 78 - #label - #tostring(count) - 4)) .. '| ' .. count .. ' |'
end
function M.toggle_netrw()
  local found = false
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].filetype == 'netrw' then
      vim.api.nvim_buf_delete(buf, { force = true })
      found = true
    end
  end
  if not found then vim.cmd('Vexplore') end
end
function M.ranger()
  if vim.fn.executable('ranger') ~= 1 then return vim.notify('ranger not installed', vim.log.levels.WARN) end
  local temp = vim.fn.tempname()
  local path = vim.api.nvim_buf_get_name(0)
  local start = path ~= '' and vim.fn.fnamemodify(path, ':h') or vim.fn.getcwd()
  vim.fn.system({ 'ranger', '--choosefile=' .. temp, start })
  if vim.fn.filereadable(temp) == 1 then
    local files = vim.fn.readfile(temp)
    if files[1] and files[1] ~= '' then vim.cmd.edit(vim.fn.fnameescape(files[1])) end
    vim.fn.delete(temp)
  end
  vim.cmd.redraw()
end
function M.toggle_spell_language()
  vim.opt_local.spelllang = vim.bo.spelllang == 'en_us' and 'fr' or 'en_us'
  vim.notify('Spell language: ' .. vim.bo.spelllang)
end
function M.toggle_bionic()
  local win = vim.api.nvim_get_current_win()
  local ns = vim.api.nvim_create_namespace('ael_bionic')
  if vim.w[win].ael_bionic then
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
    vim.w[win].ael_bionic = false
    return
  end
  local dark = vim.o.background == 'dark'
  vim.api.nvim_set_hl(0, 'AELBionicHead', { bold = true, fg = dark and '#ffffff' or '#000000' })
  vim.api.nvim_set_hl(0, 'AELBionicTail', { fg = dark and '#6a6a6a' or '#9a9a9a' })
  for i, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    local from = 1
    while true do
      local s, e = line:find('[%w_]+', from)
      if not s then break end
      local head = math.min(4, e - s + 1)
      vim.api.nvim_buf_set_extmark(0, ns, i - 1, s - 1, { end_col = s - 1 + head, hl_group = 'AELBionicHead' })
      if e > s - 1 + head then
        vim.api.nvim_buf_set_extmark(0, ns, i - 1, s - 1 + head, { end_col = e, hl_group = 'AELBionicTail' })
      end
      from = e + 1
    end
  end
  vim.w[win].ael_bionic = true
end
return M
