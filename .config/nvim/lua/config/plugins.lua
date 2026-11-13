local path = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(path) then
  local result = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', 'https://github.com/folke/lazy.nvim.git', path })
  if vim.v.shell_error ~= 0 then error('Unable to install lazy.nvim: ' .. result) end
end
vim.opt.rtp:prepend(path)
require('lazy').setup({
  { 'cocopon/iceberg.vim', priority = 1000, lazy = false, config = function() vim.cmd.colorscheme('iceberg') end },
  { 'junegunn/fzf', build = './install --bin', dependencies = { 'junegunn/fzf.vim' }, config = function()
    local map = vim.keymap.set
    map('n', '<leader>ls', '<cmd>Buffers<cr>')
    map('n', '<C-o>', '<cmd>Files ~<cr>')
    map('n', '<leader>sys', '<cmd>Files /<cr>')
    map('n', '<C-f>', '<cmd>BLines<cr>')
    map('n', '<leader>eu', '<cmd>Files ~/.config/nvim/UltiSnips<cr>')
    map('n', '<leader>ael', function()
      vim.fn['fzf#run'](vim.fn['fzf#wrap']({ source = 'rg --files --hidden --glob "!.git" ~/.local/share/ael-files/ ~/main/ael-barcode/ ~/main/ael-documentation/' }))
    end)
    map('n', '<leader>z', function()
      vim.wo.spell = true
      local suggestions = vim.fn.spellsuggest(vim.fn.expand('<cword>'))
      if #suggestions == 0 then return vim.notify('No spelling suggestions') end
      vim.fn['fzf#run'](vim.fn['fzf#wrap']({ source = suggestions, sink = function(choice)
        vim.cmd('normal! ciw')
        vim.api.nvim_put({ choice }, 'c', true, true)
      end }))
    end)
  end },
  { 'iamcco/markdown-preview.nvim', ft = { 'markdown' }, build = 'cd app && npm install', config = function()
    vim.keymap.set('n', '<leader>vm', '<cmd>MarkdownPreview<cr>')
    vim.keymap.set('n', '<leader>sm', '<cmd>MarkdownPreviewStop<cr>')
  end },
  { 'SirVer/ultisnips', init = function()
    vim.g.UltiSnipsExpandTrigger = '<c-j>'
    vim.g.UltiSnipsJumpForwardTrigger = '<c-k>'
    vim.g.UltiSnipsJumpBackwardTrigger = '<c-j>'
    vim.g.UltiSnipsEditSplit = 'vertical'
    vim.g.UltiSnipsSnippetDirectories = { vim.fn.stdpath('config') .. '/UltiSnips' }
  end },
  { 'neovim/nvim-lspconfig', config = function()
    if vim.fn.has('nvim-0.11') == 1 then
      vim.lsp.config('basedpyright', {})
      vim.lsp.config('bashls', {})
      vim.lsp.config('lua_ls', { settings = { Lua = { diagnostics = { globals = { 'vim' } } } } })
      vim.lsp.enable({ 'basedpyright', 'bashls', 'lua_ls' })
    end
  end },
  { 'hrsh7th/nvim-cmp', dependencies = { 'hrsh7th/cmp-nvim-lsp', 'hrsh7th/cmp-buffer', 'hrsh7th/cmp-path' }, config = function()
    local cmp = require('cmp')
    cmp.setup({ mapping = cmp.mapping.preset.insert({ ['<C-Space>'] = cmp.mapping.complete(), ['<CR>'] = cmp.mapping.confirm({ select = false }) }), sources = cmp.config.sources({ { name = 'nvim_lsp' }, { name = 'path' }, { name = 'buffer' } }) })
    if vim.fn.has('nvim-0.11') == 1 then vim.lsp.config('*', { capabilities = require('cmp_nvim_lsp').default_capabilities() }) end
  end },
})
