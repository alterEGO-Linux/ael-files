" :----------------------------------------------------------------------- INFO
" :[~/.vimrc]
" /created       : 2021-02-23 02:54:43 UTC
" /updated       : 2024-03-23 02:15:26 UTC
" /description   : VIM main configuration file.

" :---------- [ GENERAL CONFIG ]

  "" Forces vim to act like vim, not like vi.
  set nocompatible

  " :<leader>
  let mapleader = '-'

  " :Highlights the cursor line.
  set cursorline

  " :Disable the creation of swap files.
  set noswapfile

  " :Used with colored column.
  set colorcolumn=80

" :---------- [ ARROW KEYS ]

  " :Disables arrow keys.
  " noremap <UP> <NOP>
  " noremap <RIGHT> <NOP>
  " noremap <LEFT> <NOP>
  " noremap <DOWN> <NOP>

" :---------- [ BASE 64 ]

  " :Decode inplace base64 text.
  " :ref. https://stackoverflow.com/a/7849399/10500496
  vnoremap <leader>64 y:let @"=system('base64 --decode', @")<cr>gvP

" :---------- [ CHANGE CASES ]

  " :Upper case.
  inoremap <C-u> <ESC>viwUea
  nnoremap <C-u> viwUea

  " :Lower case.
  inoremap <C-l> <ESC>viwu
  nnoremap <C-l> viwu

" :---------- [ COMMENTS TOGGLE ]

  " :Stackoverflow
  " :What's a quick way to comment/uncomment lines in Vim?
  " :https://stackoverflow.com/a/22246318

  autocmd FileType c,cpp,java,scala let b:comment_leader = '//'
  autocmd FileType sh,ruby,python   let b:comment_leader = '#'
  autocmd FileType conf,fstab       let b:comment_leader = '#'
  autocmd FileType tex              let b:comment_leader = '%'
  autocmd FileType mail             let b:comment_leader = '>'
  autocmd FileType vim              let b:comment_leader = '"'
  function! CommentToggle()
      execute ':silent! s/\([^ ]\)/' . b:comment_leader . ' \1/'
      execute ':silent! s/^\( *\)' . b:comment_leader . ' \?' . b:comment_leader . ' \?/\1/'
  endfunction
  vnoremap <leader>c :call CommentToggle()<CR>
  nnoremap <leader>c :call CommentToggle()<CR>

" :---------- [ EDIT/SOURCE .vimrc ]

  nnoremap <leader>ev :tabedit $MYVIMRC<CR>
  nnoremap <leader>so :source $MYVIMRC<CR>

" :---------- [ ENCODING ]

  " :The encoding displayed.
  set encoding=utf8

  " :The encoding written to file.
  set fileencoding=utf8

  " :set BOM ...WARNING: doesn't work, need to set manually.
  " set bomb

" :---------- [ ESC ]

  inoremap ,, <ESC>
  vnoremap ,, <ESC>

" :---------- [ FILE EXPLORER ]

  " :NerdTree-like
  " :Vim: you don't need NERDtree or (maybe) netrw
  " :https://shapeshed.com/vim-netrw/
  let g:netrw_banner = 0
  let g:netrw_liststyle = 3
  let g:netrw_browse_split = 4
  let g:netrw_altv = 1
  let g:netrw_winsize = 25
  " augroup ProjectDrawer
    " autocmd!
    " autocmd VimEnter * :Vexplore
  " augroup END

  " :Toggle netrw
  " :ref. https://vi.stackexchange.com/a/20832
  function! ToggleNetrw()
          let i = bufnr("$")
          let wasOpen = 0
          while (i >= 1)
              if (getbufvar(i, "&filetype") == "netrw")
                  silent exe "bwipeout " . i
                  let wasOpen = 1 
              endif
              let i-=1
          endwhile
      if !wasOpen
          silent Vexplore
      endif
  endfunction
  map <F4> :call ToggleNetrw()<CR>

" :---------- [ FOLDING ]

  function! AELFoldText()
      " :TODO: Add folding level

      let nl = v:foldend - v:foldstart + 1
      let linetext = getline(v:foldstart)
      let linetext = substitute(linetext, '---------*', '', 'g')
      let linetext = substitute(linetext, '{..\d\=', '', 'g')
      let linetext = substitute(linetext, '##\|<!--\|-->\|""', '', 'g')
      let linetext = substitute(linetext, '^\s*', '', '')
      let padding = repeat(' ', 78 - strlen(linetext) - 7 - strlen(nl))
      let txt = '[+] ' . linetext . padding. '| ' . nl . ' |'
      return txt
  endfunction
  set foldtext=AELFoldText()

" :---------- [ HELP ]

  " :View man pages of word under cursor.
  nmap <leader>k :silent execute '!man <cword>'<cr>:redraw!<cr>

  " :View Python documentation of word under cursor.
  nmap <leader>hp :silent execute '!pydoc <cword>'<cr>:redraw!<cr>

" :---------- [ HIGHLIGHT LINES ]

  " :ref. https://vimtricks.com/p/highlight-specific-lines/

  " :Highlight the current line.
  nnoremap <silent> <Leader>hl :call matchadd('LineHighlight', '\%'.line('.').'l')<CR>

  " :Clear all the highlighted lines.
  nnoremap <silent> <Leader>hc :call clearmatches()<CR>

" :---------- [ HTML MAPPING ]

  " augroup filetype_html, filetype_htmldjango
    " autocmd!

    " (* Create a document *)
    
    " autocmd FileType html inoremap html<TAB> 
    " \<!DOCTYPE html><CR>
    " \<html lang="en"><CR>
    " \<head><CR>
    " \<space><space><meta charset="UTF-8"><CR>
    " \<space><space><meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes"><CR>
    " \<space><space><meta http-equiv="X-UA-Compatible" content="ie=edge"><CR>
    " \<space><space><title></title><CR>
    " \</head><CR>
    " \<CR>
    " \<body><CR>
    " \<CR>
    " \</body><CR>
    " \</html><ESC>?<title><CR>cit

    " (* a + target="_blank" *)

    " autocmd FileType html inoremap <buffer>a<TAB> 
    " \<a href="" target="_blank"></a><ESC>?=""<CR>ei

    " (* blockquote *)

    " autocmd FileType html inoremap <buffer>bq<TAB> 
    " \<blockquote></blockquote><ESC>2bli

    " (* bold *)

    " autocmd FileType html inoremap b<TAB> 
    " \<b></b><ESC>3hi

    " (* linebreak *)

    " autocmd FileType html inoremap br<TAB> 
    " \<br<space>/><ESC>a

    " (* code *)

    " autocmd FileType html inoremap code<TAB> 
    " \<code></code><ESC>6hi

    " (* comment *)

    " autocmd FileType html inoremap cmt<TAB> 
    " \<!--<space><space>--><ESC>3hi

    " (* div *)

    " autocmd FileType html inoremap div<TAB> 
    " \<div><CR><space><space><CR></div><ESC>2k0viwyjPj0.k$a

    " (* h1 *)

    " autocmd FileType html inoremap h1<TAB> 
    " \<h1></h1><ESC>4hi

    " (* h2 *)

    " autocmd FileType html inoremap h2<TAB> 
    " \<h2></h2><ESC>4hi

    " (* h3 *)

    " autocmd FileType html inoremap h3<TAB> 
    " \<h3></h3><ESC>4hi

    " (* h4 *)

    " autocmd FileType html inoremap h4<TAB> 
    " \<h4></h4><ESC>4hi

    " (* h5 *)

    " autocmd FileType html inoremap h5<TAB> 
    " \<h5></h5><ESC>4hi

    " (* horizontal line *)

    " autocmd FileType html inoremap hr<TAB> 
    " \<hr><CR><ESC>a

    " (* italic *)

    " autocmd FileType html inoremap em<TAB> 
    " \<em></em><ESC>4hi

    " (* li *)

    " autocmd FileType html inoremap li<TAB> 
    " \<li></li><ESC>4hi

    " (* paragraph *)

    " autocmd FileType html inoremap p<TAB> 
    " \<p></p><ESC>3hi

    " (* preformated text *)

    " autocmd FileType html inoremap pre<TAB> 
    " \<pre><ESC>Vypa/<ESC>O

    " (* autocomplete tags *)

    "... ref. https://stackoverflow.com/a/532656
    " autocmd FileType html inoremap /<TAB> 
    " \</<C-x><C-o><ESC>

  " augroup end

" :---------- [ LINEBREAK and WRAP ]

  set linebreak
  set wrap
  " set showbreak=[......]
  set showbreak==>\ \ 

  " :Toggle linewrap.
  map <leader>w :setlocal wrap!<CR>

" :---------- [ LINE NUMBER ]

  set number
  set relativenumber

  " :Toggle line numbering
  nnoremap <leader>ln :set number! relativenumber!<CR>

" :[* lorem *]

  inoremap lorem<TAB> Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse sodales, dolor ut lobortis rhoncus, mauris leo condimentum metus, vel elementum arcu ipsum aliquam est. Integer a scelerisque turpis, at ultrices nisl. Nunc fermentum quam elementum, sagittis velit id, porta tellus. Nunc quis suscipit felis. Etiam et leo scelerisque, gravida elit nec, aliquet justo. Phasellus et neque vel turpis hendrerit fringilla sed in arcu. Suspendisse id enim lacinia libero auctor pellentesque. Proin sed sem non neque pellentesque vehicula. Nunc sapien justo, tincidunt vitae ultrices eu, consectetur sit amet orci.

" :---------- [ MOUSE ]

  " set mouse=a

" :[* preview window *]

  " :Sends preview window to the right.
  " :StackExchange
  " :A fixed position for preview windows
  " :https://vi.stackexchange.com/questions/12597/a-fixed-position-for-preview-windows
  " augroup previewWindowPosition
    " au!
    " autocmd BufWinEnter * call PreviewWindowPosition()
  " augroup END
  " function! PreviewWindowPosition()
    " if &previewwindow
        " wincmd L
    " endif
  " endfunction 

" :---------- [ RUN SCRIPT ]

  " :(* python *)
  " :Requires tmux, with a second pane open.

  function! RunPython()
      let pycmd = systemlist('command -v python')[0]
      let filename = expand('%:p')
      silent! call system('tmux send-key -t 1 "' . pycmd . ' ' . filename . '" enter;')
  endfunction
  nnoremap <leader>p :call RunPython()<CR>

  " :(* kill script *)
  " :Kills the script.
  nnoremap <leader>ss :!tmux send-keys -t 1 "C-c";<CR><C-l>

" :---------- [ SAVE FILE ]

  " :CTRL+s to save file
  " :ref. https://stackoverflow.com/questions/3446320/in-vim-how-to-map-save-to-ctrl-s
  " :Requires `stty -ixon` in a sourced rc file
  inoremap <C-s> <ESC>:write<CR>
  nnoremap <C-s> :write<CR>

" :---------- [ SCROLL OFFSET ]

  " :When scrolling, keeps the cursor at the vertical center.
  " :Use so=999 for centered
  " :ref. http://vim.wikia.com/wiki/make_search_results_appear_in_the_middle_of_the_screen
  set scrolloff=999

" :---------- [ SEARCH ]

  " :Fuzzy find and wildmenu.
  set path+=**
  set wildmenu

  " :(* text search *)
  " :Search ignorecase.
  set ignorecase

  " :Search highlight.
  set hlsearch

  " :Toggle search highlighting                      
  nnoremap <F3> :set hlsearch!<CR> 

  " :(* clear search *)
  nnoremap <leader>cs :let @/ = ""<CR>

" :---------- [ SPELLCHECKER ]

  " :Toggle spell checker.
  map <F5> :setlocal spell! spelllang=en_us<CR>

" :---------- [ STATUSLINE ]

  set laststatus=2
  set statusline=
  set statusline+=\ %<%F\ "File+path
  set statusline+=\ buffer:[%n] "buffernr
  set statusline+=\ %y\ "FileType 
  set statusline+=\ %{''.(&fenc!=''?&fenc:&enc).''} "Encoding 
  set statusline+=\ %{(&bomb?\",BOM\":\"\")}\ "Encoding2 
  set statusline+=\ %{&ff}\ "FileFormat (dos/unix..) 
  set statusline+=\ %=\ row:%l/%L\ (%03p%%)\ "Rownumber/total (%) 
  set statusline+=\ col:%03c\ "Colnr 
  set statusline+=\ %m%r%w\ %P\ \ "Modified? Readonly? Top/bot.

" :---------- [ TAB and INDENT ]

  set tabstop=2
  " :shiftround : rounds indent to multiple of shiftwidth.
  " :Applies to < and > in normal mode. <C-t> and <C-d> in insert mode
  " :always round the indent.
  set shiftround
  set shiftwidth=2
  set expandtab

" :---------- [ TAGS ]

  inoremap "<TAB> ""<left>
  inoremap '<TAB> ''<left>
  inoremap (<TAB> ()<left>
  inoremap [<TAB> []<left>
  inoremap {<TAB> {}<left>
  inoremap {<CR> {<CR>}<ESC>O
  inoremap {;<CR> {<CR>};<ESC>O

" :---------- [ TIMESTAMP ]

  " :Insert timestamp.
  " :ex: 2022-03-25 15:49:24 UTC
  nnoremap <F12> "=system('echo -n $(date --utc "+%F %H:%M:%S %Z" )')<CR>p

  " :Insert timestamp as ID.
  " :ex: 202203251549
  nnoremap <F9> "=system('echo -n $(date --utc "+%Y%m%d%H%M")')<CR>p

" :-----/ COPY & PASTE /-----:

  " :Enable clipboard ability with xclip or wl-copy.
  " :Works both on Wayland and X-11.
  " :/ref/ Andrew [8xx8] Kulakov 'VIM Copy/Paste' <https://coderwall.com/p/hmki3q/vim-copy-paste>
  " :/ref/ https://stackoverflow.com/a/70047595/10500496
  " map <F7> y:call system("wl-copy || xclip -i -selection clipboard", getreg("\""))<cr>
  " map <S-F7> :call setreg("\"",system("wl-paste || xclip -o -selection clipboard"))<cr>p")")")"))
  " nnoremap <F7> :let @+=@0<CR>:call system('wl-copy < /dev/stdin || xclip -i -selection clipboard', getreg("\""))<CR>
  " nnoremap <F7> :call system('echo ' . shellescape(@0) . ' | wl-copy || echo ' . shellescape(@0) . ' | xclip -i -selection clipboard')<CR>
  vmap <F7> y:call system("xclip -i -selection clipboard", getreg("\""))<cr>:call system("xclip -i", getreg("\""))<cr>
  nmap <S-F7> :call setreg("\"",system("xclip -o -selection clipboard"))<cr>p")")")"))

" :---------- [ PLUGINS - INSTALL ]

  syntax enable
  filetype plugin on

  " :(* vim-plug *)

  if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  endif

  call plug#begin('~/.vim/plugged')

  " :(* coloscheme iceberg *)
  " :https://github.com/cocopon/iceberg.vim
  Plug 'cocopon/iceberg.vim'

  " :(* jedi *)
  Plug 'https://github.com/davidhalter/jedi-vim.git'

  " :(* fzf *)
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'

  " :(* markdown-preview *)
  " :https://github.com/iamcco/markdown-preview.vim
  Plug 'iamcco/markdown-preview.vim'

  " :(* syntastic *)
  " :Syntax checker.
  " :https://github.com/vim-syntastic/syntastic
  " Plug 'vim-syntastic/syntastic'

  " :(* ultisnips *)
  " :https://github.com/SirVer/ultisnips
  Plug 'SirVer/ultisnips'

  " :(* YouCompleteMe *)
  Plug 'Valloric/YouCompleteMe'

  call plug#end()

  " :Automatically install missing plugins.
  " :ref. https://github.com/junegunn/vim-plug/wiki/extra#automatically-install-missing-plugins-on-startup
  autocmd VimEnter *
    \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
    \|   PlugInstall --sync | q
    \| endif

  " :Disable automatic indent on from vim-plug
  filetype indent off

" :---------- [ PLUGINS - CONFIGS ]

  " :(* fzf.vim *)

  " :Buffers list.
  nnoremap <silent> <leader>ls :Buffers<CR>

  " :Open files in $HOME.
  nnoremap <silent> <C-o> :Files ~<CR>

  " :Open files from /.
  nnoremap <silent> <leader>sys :Files /<CR>

  " :Find lines containing.
  nnoremap <silent> <C-f> :BLines<CR>

  " :(* emmet-vim *)     

  " :Enable emmet-vim tab completion 
  " imap <expr> <tab> emmet#expandAbbrIntelligent("\<tab>")

  " :(* syntastic *)
  " map <leader>sx :SyntasticToggleMode<CR>

  " :(* markdown-preview *)
  nmap <silent> <leader>vm <Plug>MarkdownPreview
  nmap <silent> <leader>sm <Plug>StopMarkdownPreview

  " :(* ultisnips *)
  " :Since we use YouCompleteMe, some triggers were changed.
  " :In file types not covered by YouCompleteMe, it looks like you have to 
  " :complete the word to select it.
  let g:UltiSnipsExpandTrigger="<c-j>"
  let g:UltiSnipsEditSplit="vertical"
  let g:UltiSnipsJumpForwardTrigger="<c-k>"
  let g:UltiSnipsJumpBackwardTrigger="<c-j>"

" :---------- [ COLORSCHEME ]

  " :(* colors *)
  " :   0  Black
  " :  10  Lime

  set t_Co=256

  " :(* colorschemes *)

  " :arstotzka: https://github.com/daylerees/colour-schemes/blob/master/vim/colors/arstotzka.vim
  " colorscheme arstotzka

  " :base16-3024: https://github.com/RRethy/nvim-base16/blob/master/colors/base16-3024.vim
  " colorscheme base16-3024

  " :blaquemagick: https://github.com/xero/blaquemagick.vim/blob/master/colors/blaquemagick.vim
  " colorscheme blaquemagick

  " :iceberg: https://github.com/cocopon/iceberg.vim/blob/master/src/iceberg.vim
  colorscheme iceberg

  " :silenthill: https://github.com/evilwaveforms/silenthill.vim
  " colorscheme silenthill

  set background=dark

  " :(* bionic reading *)
  " :ref. https://stackoverflow.com/questions/4167425/custom-syntax-highlighting-in-vim
  nnoremap <silent> <leader>b :syn match bionic /\w\{,3}\zs\(\W\\|\w\)\{-}\(\s\\|\n\)\ze/<CR>
  highlight bionic          cterm=NONE    ctermfg=GREY

  " :(* general *)
  highlight ColorColumn     cterm=NONE    ctermfg=NONE  ctermbg=238
  highlight Comment         cterm=NONE    ctermfg=grey  ctermbg=NONE
  highlight CursorLine      cterm=NONE    ctermfg=NONE  ctermbg=238
  highlight Function        cterm=BOLD    ctermfg=150   ctermbg=NONE
  highlight LineHighlight   cterm=NONE    ctermfg=0     ctermbg=10
  highlight LineNr          cterm=NONE    ctermfg=246   ctermbg=238
  highlight MatchParen      cterm=NONE    ctermfg=NONE  ctermbg=NONE
  " :Sets the background to transparent with cterm(fg/bg) to NONE.
  highlight Normal          cterm=NONE    ctermfg=NONE  ctermbg=NONE
  highlight Search          cterm=NONE    ctermfg=16    ctermbg=11
  highlight Statement       cterm=ITALIC  ctermfg=110   ctermbg=NONE
  highlight StatusLine      cterm=NONE    ctermfg=246   ctermbg=238
  highlight StatusLineNC    cterm=NONE    ctermfg=0     ctermbg=238
  highlight Visual          cterm=NONE    ctermfg=16    ctermbg=11

  " :(* html/md *)
  " :ref. http://vimdoc.sourceforge.net/htmldoc/syntax.html
  highlight htmlTagName     cterm=BOLD    ctermfg=WHITE ctermbg=NONE
  highlight link htmlTag    htmlTagName
  highlight link htmlEndTag htmlTagName
  " hi htmlBold gui=bold guifg=#af0000 ctermfg=124
  " hi htmlItalic cterm=ITALIC ctermfg=27
  " hi htmlH1    term=NONE cterm=BOLD ctermfg=15  ctermbg=NONE

  " hi Constant           term=NONE cterm=NONE ctermfg=125  ctermbg=NONE
  " hi Cursor             term=NONE cterm=NONE ctermfg=242  ctermbg=NONE
  " hi DiffAdd            term=NONE cterm=NONE ctermfg=103  ctermbg=NONE
  " hi DiffChange         term=NONE cterm=NONE ctermfg=NONE ctermbg=16
  " hi DiffDelete         term=NONE cterm=NONE ctermfg=251  ctermbg=16
  " hi DiffText           term=NONE cterm=NONE ctermfg=251  ctermbg=101
  " hi Directory          term=NONE cterm=NONE ctermfg=101  ctermbg=16
  " hi Error              term=NONE cterm=NONE ctermfg=238  ctermbg=66
  " hi ErrorMsg           term=NONE cterm=NONE ctermfg=66   ctermbg=16
  " hi FoldColumn         term=NONE cterm=NONE ctermfg=238  ctermbg=NONE
  " hi Folded             term=NONE cterm=NONE ctermfg=23  ctermbg=NONE
  " hi Identifier         term=NONE cterm=NONE ctermfg=101   ctermbg=NONE
  " hi IncSearch          term=NONE cterm=NONE ctermfg=247  ctermbg=247
  " hi NonText            term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE
  " hi Normal             term=NONE cterm=NONE ctermfg=249  ctermbg=NONE
  " hi PreProc            term=NONE cterm=BOLD ctermfg=66   ctermbg=NONE
  " hi Special            term=NONE cterm=NONE ctermfg=6   ctermbg=NONE
  " hi SpecialKey         term=NONE cterm=NONE ctermfg=99  ctermbg=NONE
  " hi String             term=NONE cterm=NONE ctermfg=26   ctermbg=NONE

  " :(* window's tab *)
  " :Focused
  hi TabLineSel         term=BOLD cterm=BOLD ctermfg=white      ctermbg=30
  " :Unfocused
  hi TabLine            term=NONE cterm=NONE ctermfg=246        ctermbg=238
  " :Rest of the line
  hi TabLineFill        term=NONE cterm=NONE ctermfg=NONE       ctermbg=238

  " hi Todo               term=NONE cterm=NONE ctermfg=251  ctermbg=66
  " hi Type               term=NONE cterm=NONE ctermfg=96  ctermbg=NONE
  " hi VertSplit          term=NONE cterm=NONE ctermfg=NONE  ctermbg=NONE
  " hi WarningMsg         term=NONE      cterm=NONE      ctermfg=103    ctermbg=NONE
  " hi CursorLineNr       term=NONE      cterm=NONE      ctermbg=237    ctermfg=16
  " hi Pmenu              term=NONE      cterm=NONE      ctermfg=249    ctermbg=16
  " hi PmenuSel           term=NONE      cterm=NONE      ctermfg=238    ctermbg=66
  " hi PmenuSbar          term=NONE      cterm=NONE      ctermfg=238    ctermbg=66
  " hi PmenuThumb         term=NONE      cterm=NONE      ctermfg=238    ctermbg=66
  " hi Underlined         term=underline cterm=underline ctermfg=NONE   ctermbg=NONE

  " hi! link diffAdded       DiffAdd
  " hi! link diffRemoved     DiffDelete
  " hi! link diffChanged     DiffChange
  " hi! link MoreMsg         Normal
  " hi! link Question        DiffChange
  " hi! link VimHiGroup      VimGroup

  " :(* shell *)
  " :Shell variables (default in vim81/syntax/sh.vim).
  " hi shDerefVar         term=NONE      cterm=BOLD      ctermfg=cyan   ctermbg=NONE

" :------------------------------------------------------------- FIN ¯\_(ツ)_/¯
