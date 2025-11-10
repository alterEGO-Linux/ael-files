" ------------------------------------------------------------------------ INFO
" [/home/ghost/.vimrc]
" author        : Pascal Malouin @https://github.com/fantomH
" created       : 2021-02-23 02:54:43 UTC
" updated       : 2025-11-10 01:04:50 UTC
" description   : VIM main configuration file.

" // GENERAL CONFIGURATION ------------------------------------------------- //

  " // Forces vim to act like vim, not like vi.
  set nocompatible

  " // <leader>
  let mapleader = '-'

  " // Highlights the cursorline.
  set cursorline

  " // Disable the creation of swap files.
  set noswapfile

  " // Used with colored column.
  set colorcolumn=80

  " // Command section bigger.
  set cmdheight=2

" // ARROW KEYS ------------------------------------------------------------ //

  " // Disables arrow keys.
  " noremap <UP> <NOP>
  " noremap <RIGHT> <NOP>
  " noremap <LEFT> <NOP>
  " noremap <DOWN> <NOP>

" // BASE64 DECODER -------------------------------------------------------- //

  " // Decode inplace base64 text.
  " // ref. <https://stackoverflow.com/a/7849399/10500496>
  vnoremap <leader>64 y:let @"=system('base64 --decode', @")<cr>gvP

" // CHANGE CASES ---------------------------------------------------------- //

  " // Upper case.
  inoremap <C-u> <ESC>viwUea
  nnoremap <C-u> viwUea

  " // Lower case.
  inoremap <C-l> <ESC>viwu
  nnoremap <C-l> viwu

" // COMMENTS TOGGLE ------------------------------------------------------- //

  " // (ref) Stackoverflow, 'What's a quick way to comment/uncomment lines in Vim?'
  " // (ref) <https://stackoverflow.com/a/22246318>

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

" // EDIT/SOURCE .vimrc ---------------------------------------------------- //

  nnoremap <leader>ev :tabedit $MYVIMRC<CR>
  nnoremap <leader>so :source $MYVIMRC<CR>

" // ENCODING -------------------------------------------------------------- //

  " // The encoding displayed.
  set encoding=utf8

  " // The encoding written to file.
  set fileencoding=utf8

  " // set BOM ...WARNING: doesn't work, need to set manually.
  " set bomb

" // ESC ------------------------------------------------------------------- //

  inoremap ,, <ESC>
  vnoremap ,, <ESC>

" // FILE EXPLORER --------------------------------------------------------- //

  " // NerdTree-like
  " // (ref) https://shapeshed.com/vim-netrw/
  let g:netrw_banner = 0
  let g:netrw_liststyle = 3
  let g:netrw_browse_split = 4
  let g:netrw_altv = 1
  let g:netrw_winsize = 25

  autocmd FileType netrw silent! wincmd H | vertical resize 35

  " // Toggle netrw
  " // (ref) https://vi.stackexchange.com/a/20832
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

" // FOLDING --------------------------------------------------------------- //

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

" // HELP ------------------------------------------------------------------ //

  " // View man pages of word under cursor.
  nnoremap <leader>k :silent execute '!man <cword>'<cr>:redraw!<cr>

  " // View Python documentation of word under cursor.
  nnoremap <leader>hp :silent execute '!pydoc <cword>'<cr>:redraw!<cr>

" // HIGHLIGHT LINES ------------------------------------------------------- //

  " // (ref) <https://vimtricks.com/p/highlight-specific-lines/>

  " // Highlight the current line.
  nnoremap <silent> <Leader>hl :call matchadd('LineHighlight', '\%'.line('.').'l')<CR>

  " // Clear all the highlighted lines.
  nnoremap <silent> <Leader>hc :call clearmatches()<CR>

" :----------/ HTML MAPPING

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

" // LINEBREAK/WRAP -------------------------------------------------------- //

  set linebreak
  set wrap
  set showbreak=[......]
  " set showbreak==>\ \ 

  " // Toggle linewrap.
  map <leader>w :setlocal wrap!<CR>

" // LINE NUMBERS ---------------------------------------------------------- //

  set number
  set relativenumber

  " // Toggle line numbering
  nnoremap <leader>ln :set number! relativenumber!<CR>

" // lorem ----------------------------------------------------------------- //

  inoremap lorem<TAB> Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse sodales, dolor ut lobortis rhoncus, mauris leo condimentum metus, vel elementum arcu ipsum aliquam est. Integer a scelerisque turpis, at ultrices nisl. Nunc fermentum quam elementum, sagittis velit id, porta tellus. Nunc quis suscipit felis. Etiam et leo scelerisque, gravida elit nec, aliquet justo. Phasellus et neque vel turpis hendrerit fringilla sed in arcu. Suspendisse id enim lacinia libero auctor pellentesque. Proin sed sem non neque pellentesque vehicula. Nunc sapien justo, tincidunt vitae ultrices eu, consectetur sit amet orci.

" // MOUSE ----------------------------------------------------------------- //

  " set mouse=a

" // SAVE FILE ------------------------------------------------------------- //

  " // CTRL+s to save file
  " // (ref) <https://stackoverflow.com/questions/3446320/in-vim-how-to-map-save-to-ctrl-s>
  " // Requires `stty -ixon` in the sourced shell rc file
  inoremap <C-s> <ESC>:write<CR>
  nnoremap <C-s> :write<CR>

" // SCROLL OFFSET --------------------------------------------------------- //

  " // When scrolling, keeps the cursor at the vertical center.
  " // Use so=999 for centered
  " // (ref) <http://vim.wikia.com/wiki/make_search_results_appear_in_the_middle_of_the_screen>
  set scrolloff=999

" // SEARCH ---------------------------------------------------------------- //

  " // Fuzzy find and wildmenu.
  set path+=**
  set wildmenu

  " // text search
  " // Search ignorecase.
  set ignorecase

  " // Search highlight.
  set hlsearch

  " // Toggle search highlighting                      
  nnoremap <F3> :set hlsearch!<CR> 

  " // Clear search
  nnoremap <leader>cs :let @/ = ""<CR>

" // SPELLCHECKER ---------------------------------------------------------- //

  " // Toggle spell checker. Default "en_us".
  nnoremap <F5> :setlocal spell! spelllang=en_us<CR>

  " // Switch Language
  function! ToggleSpellLang()
    if &spelllang =~# 'en_us'
      setlocal spelllang=fr
      echo "Spell language: French (fr)"
    else
      setlocal spelllang=en_us
      echo "Spell language: English (en_us)"
    endif
  endfunction

  nnoremap <leader>sl :call ToggleSpellLang()<CR>

" // STATUSLINE ------------------------------------------------------------ //

  function! StatusFlags() abort
    if &readonly
      return &modified ? '**READONLY [+]**' : '**READONLY**'
    endif
    return &modified ? '**MODIFIED**' : ''
  endfunction

  set laststatus=2
  set statusline=
  set statusline+=\ BUFFER\ [%n]                                        " // Buffer
  set statusline+=\ FILE\ [%{fnamemodify(expand('%'),':h:t')}/%t]       " // Direct parent directory + filename.
  set statusline+=\ INFO\ [%{&ft}/%{&fenc!=''?&fenc:&enc}/%{&ff}]       " // Filetype / Encoding / File format.
  set statusline+=\ %=                                                  " // Align right.
  set statusline+=\ ROW\ [%l/%L\ (%03p%%)]                              " // Rownumber/total (%) 
  set statusline+=\ COL\ [%03c]                                         " // Column Number. 
  set statusline+=\ %{StatusFlags()}                                    " // Modified, readonly, readonly modified.

" // TAB & INDENT ---------------------------------------------------------- //

  set tabstop=2
  " // shiftround : rounds indent to multiple of shiftwidth.
  " // Applies to < and > in normal mode. <C-t> and <C-d> in insert mode
  " // always round the indent.
  set shiftround
  set shiftwidth=2
  set expandtab

" // TAGS ------------------------------------------------------------------ //

  inoremap "<TAB> ""<left>
  inoremap '<TAB> ''<left>
  inoremap (<TAB> ()<left>
  inoremap [<TAB> []<left>
  inoremap {<TAB> {}<left>
  inoremap {<CR> {<CR>}<ESC>O
  inoremap {;<CR> {<CR>};<ESC>O

" // TIMESTAMP ------------------------------------------------------------- //

  " //Insert timestamp.
  " //ex: 2022-03-25 15:49:24 UTC
  nnoremap <F12> "=system('echo -n $(date --utc "+%F %H:%M:%S %Z" )')<CR>p

  " //Insert timestamp as ID.
  " //ex: 202203251549
  nnoremap <F9> "=system('echo -n $(date --utc "+%Y%m%d%H%M")')<CR>p

" // COPY & PASTE ---------------------------------------------------------- //

  " // Enable clipboard ability with xclip (X11) or wl-clipboard (Wayland).
  " // ref. Andrew [8xx8] Kulakov 'VIM Copy/Paste' <https://coderwall.com/p/hmki3q/vim-copy-paste>

  if !empty($WAYLAND_DISPLAY)
      " // Running in Wayland, use wl-clipboard
      vnoremap <F7> y:call system("wl-copy", getreg("\""))<CR>
      nnoremap <S-F7> :call setreg("\"", system("wl-paste"))<CR>p
  elseif !empty($DISPLAY)
      " // Running in X11, use xclip
      vnoremap <F7> y:call system("xclip -i -selection clipboard", getreg("\""))<CR>:call system("xclip -i", getreg("\""))<CR>
      nnoremap <S-F7> :call setreg("\"", system("xclip -o -selection clipboard"))<CR>p
  endif

" // BIONIC READING -------------------------------------------------------- //

" // Bionic Reading: bold head, dim tail (adaptive to background)

  function! s:SetBionic() abort
    if &background ==# 'dark'
      " // Dark background.
      highlight default BionicHead cterm=BOLD ctermfg=WHITE gui=BOLD guifg=#FFFFFF
      highlight default BionicTail cterm=NONE ctermfg=GRAY gui=NONE guifg=#6A6A6A
    else
      " // Light background
      highlight default BionicHead cterm=BOLD ctermfg=BLACK gui=BOLD guifg=#000000
      highlight default BionicTail cterm=NONE ctermfg=GRAY gui=NONE guifg=#9A9A9A
    endif
  endfunction

  call s:SetBionic()

  augroup BionicReading
    autocmd!
    autocmd ColorScheme * call s:SetBionic()
    autocmd OptionSet background call s:SetBionic()
  augroup END

  function! ToggleBionic() abort
    " // Turn off if already on.
    if exists('w:bionic_head_id')
      call matchdelete(w:bionic_head_id)
      call matchdelete(w:bionic_tail_id)
      unlet w:bionic_head_id w:bionic_tail_id
      echo "Bionic Reading: off"
      return
    endif

    " // Head
    let w:bionic_head_id = matchadd('BionicHead', '\<\k\{1,4}', 10)

    " // Tail
    let w:bionic_tail_id = matchadd('BionicTail', '\<\k\{,4}\zs\k\+', 10)

    echo "Bionic Reading: on"
  endfunction

  nnoremap <silent> <leader>b :call ToggleBionic()<CR>

" // PLUGINS - INSTALL ----------------------------------------------------- //

  syntax enable
  filetype plugin on

  " // vim-plug //

  if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  endif

  call plug#begin('~/.vim/plugged')

  " // coloscheme iceberg //
  " // (url) <https://github.com/cocopon/iceberg.vim>
  Plug 'cocopon/iceberg.vim'

  " // jedi //
  Plug 'https://github.com/davidhalter/jedi-vim.git'

  " // fzf //
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'

  " // markdown-preview //
  " :https://github.com/iamcco/markdown-preview.vim
  Plug 'iamcco/markdown-preview.vim'

  " // ultisnips //
  " // (url) <https://github.com/SirVer/ultisnips>
  Plug 'SirVer/ultisnips'

  " // YouCompleteMe //
  Plug 'Valloric/YouCompleteMe'

  call plug#end()

  " // Automatically install missing plugins.
  " // (ref) <https://github.com/junegunn/vim-plug/wiki/extra#automatically-install-missing-plugins-on-startup>
  autocmd VimEnter *
    \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
    \|   PlugInstall --sync | q
    \| endif

  " // Disable automatic indent on from vim-plug
  filetype indent off

" // PLUGINS - FZF --------------------------------------------------------- //

  " // Buffers list.
  nnoremap <silent> <leader>ls :Buffers<CR>

  " // Open files in $HOME.
  nnoremap <silent> <C-o> :Files ~<CR>

  " // Open files starting at root.
  nnoremap <silent> <leader>sys :Files /<CR>

  " // Find lines containing.
  nnoremap <silent> <C-f> :BLines<CR>

  " // AEL files.
  nnoremap <leader>ael :call fzf#run(fzf#wrap({'source': 'rg --files --hidden --glob "!.git" ~/.local/share/ael-files/'}))<CR>

  " // FZF Spellcheck selector //
  " // Select Spellcheck suggestion.
  function! FzfSpelling()
    " //Ensure spell is enabled.
    if &spell == 0
      setlocal spell
    endif

    " //Get the list of spelling suggestions
    let suggestions = spellsuggest(expand('<cword>'))

    if empty(suggestions)
      echo "No suggestions available."
      return
    endif

    " //Select
    call fzf#run(fzf#wrap({
          \ 'source': suggestions,
          \ 'sink':   function('FzfReplaceWord')
          \ }))
  endfunction

  function! FzfReplaceWord(choice)
    " //Replace the current word with the selection.
    execute "normal! ciw" . a:choice
  endfunction

  nnoremap <leader>z :call FzfSpelling()<CR>

  " // PLUGINS - markdown-preview ------------------------------------------ //
  nnoremap <silent> <leader>vm <Plug>MarkdownPreview
  nnoremap <silent> <leader>sm <Plug>StopMarkdownPreview

  " // PLUGINS -  ultisnips ------------------------------------------------ //
  " // Since we use YouCompleteMe, some triggers were changed.
  " // In file types not covered by YouCompleteMe, it looks like you have to 
  " // complete the word to select it.
  nnoremap <silent> <leader>eu :Files ~/.vim/UltiSnips/<CR>
  let g:UltiSnipsExpandTrigger="<c-j>"
  let g:UltiSnipsEditSplit="vertical"
  let g:UltiSnipsJumpForwardTrigger="<c-k>"
  let g:UltiSnipsJumpBackwardTrigger="<c-j>"

" // COLORSCHEME ----------------------------------------------------------- //

  set t_Co=256
  set background=dark

  " // colorschemes //

  " // base16-3024 <https://github.com/RRethy/nvim-base16/blob/master/colors/base16-3024.vim>
  " colorscheme base16-3024

  " // blaquemagick <https://github.com/xero/blaquemagick.vim/blob/master/colors/blaquemagick.vim>
  " colorscheme blaquemagick

  " // iceberg <https://github.com/cocopon/iceberg.vim/blob/master/src/iceberg.vim>
  colorscheme iceberg

  " // silenthill <https://github.com/evilwaveforms/silenthill.vim>
  " colorscheme silenthill


  " // general //
  
  highlight ColorColumn     cterm=NONE       ctermfg=NONE      ctermbg=235      " // Column 80.
  highlight CursorLine      cterm=NONE       ctermfg=NONE      ctermbg=235      " // Cursor Line.
  highlight LineHighlight   cterm=NONE       ctermfg=0         ctermbg=10       " // Highlights lines. Custom.
  highlight LineNr          cterm=NONE       ctermfg=248       ctermbg=235      " // Linenumber column.
  highlight MatchParen      cterm=NONE       ctermfg=NONE      ctermbg=NONE     " // Parenthesis/bracket.
  highlight Normal          cterm=NONE       ctermfg=NONE      ctermbg=NONE     " // Set the background to transparent with cterm(fg/bg) to NONE.
  highlight Search          cterm=NONE       ctermfg=16        ctermbg=178      " // Search results.
  highlight StatusLine      cterm=NONE       ctermfg=248       ctermbg=235      " // Status Line
  highlight StatusLineNC    cterm=NONE       ctermfg=236       ctermbg=235      " // Non-active Status Line.
  highlight Visual          cterm=NONE       ctermfg=16        ctermbg=11       " // Visual selection.

  " // Prog. Language //
  highlight Comment         cterm=ITALIC     ctermfg=109       ctermbg=NONE     " // Comments.
  highlight Function        cterm=BOLD       ctermfg=150       ctermbg=NONE     " // Function.
  highlight Statement       cterm=ITALIC     ctermfg=110       ctermbg=NONE     " // Statement

  " :-( html/md )
  " :(ref) http://vimdoc.sourceforge.net/htmldoc/syntax.html

  " highlight htmlTagName     cterm=BOLD    ctermfg=WHITE ctermbg=NONE
  " highlight link htmlTag    htmlTagName
  " highlight link htmlEndTag htmlTagName
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

  " :-( window's tab )
  " hi TabLineSel         term=BOLD cterm=BOLD ctermfg=white      ctermbg=30      " :Focused
  " hi TabLine            term=NONE cterm=NONE ctermfg=246        ctermbg=238     " :Unfocused
  " hi TabLineFill        term=NONE cterm=NONE ctermfg=NONE       ctermbg=238     " :Rest of the line

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

  " :-( shell )
  " hi shDerefVar         term=NONE      cterm=BOLD      ctermfg=cyan   ctermbg=NONE " :Shell variables (default in vim81/syntax/sh.vim)
