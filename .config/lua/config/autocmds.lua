local group = vim.api.nvim_create_augroup('AELConfig', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  group = group,
  pattern = 'netrw',
  callback = function() vim.cmd('wincmd H | vertical resize 35') end,
})
vim.api.nvim_create_autocmd('ColorScheme', {
  group = group,
  callback = function()
    vim.api.nvim_set_hl(0, 'ColorColumn', { bg = '#30343c' })
    vim.api.nvim_set_hl(0, 'LineHighlight', { fg = '#000000', bg = '#87d787' })
  end,
})
