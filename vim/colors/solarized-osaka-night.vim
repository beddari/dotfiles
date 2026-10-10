" solarized-osaka-night.vim — matches Ghostty solarized-osaka-night theme
" Based on Tokyo Night color palette

set background=dark
hi clear
if exists('syntax_on')
  syntax reset
endif
let g:colors_name = 'solarized-osaka-night'

" Palette
" bg:        #1a1b26
" bg_dark:   #15161e
" bg_hl:     #283457
" fg:        #c0caf5
" fg_dark:   #a9b1d6
" comment:   #565f89
" dark3:     #414868
" dark5:     #545c7e
" red:       #f7768e
" green:     #9ece6a
" yellow:    #e0af68
" blue:      #7aa2f7
" magenta:   #bb9af7
" cyan:      #7dcfff
" orange:    #ff9e64
" teal:      #1abc9c

" UI elements
hi Normal       guifg=#c0caf5 guibg=#1a1b26
hi NormalFloat  guifg=#c0caf5 guibg=#15161e
hi Cursor       guifg=#1a1b26 guibg=#c0caf5
hi CursorLine   guibg=#283457
hi CursorLineNr guifg=#e0af68 guibg=#1a1b26
hi LineNr       guifg=#414868
hi SignColumn   guibg=#1a1b26
hi ColorColumn  guibg=#15161e
hi VertSplit    guifg=#414868 guibg=#1a1b26
hi StatusLine   guifg=#c0caf5 guibg=#15161e gui=NONE
hi StatusLineNC guifg=#545c7e guibg=#15161e gui=NONE
hi TabLine      guifg=#545c7e guibg=#15161e gui=NONE
hi TabLineFill  guibg=#15161e
hi TabLineSel   guifg=#c0caf5 guibg=#1a1b26 gui=bold
hi Pmenu        guifg=#c0caf5 guibg=#15161e
hi PmenuSel     guifg=#c0caf5 guibg=#283457
hi PmenuSbar    guibg=#15161e
hi PmenuThumb   guibg=#414868
hi Folded       guifg=#7aa2f7 guibg=#15161e
hi FoldColumn   guifg=#414868 guibg=#1a1b26
hi NonText      guifg=#414868
hi SpecialKey   guifg=#414868
hi Visual       guibg=#283457
hi Search       guifg=#1a1b26 guibg=#e0af68
hi IncSearch    guifg=#1a1b26 guibg=#ff9e64
hi MatchParen   guifg=#ff9e64 gui=bold
hi Directory    guifg=#7aa2f7

" Diagnostics
hi ErrorMsg     guifg=#f7768e guibg=NONE
hi WarningMsg   guifg=#e0af68 guibg=NONE
hi MoreMsg      guifg=#9ece6a
hi Question     guifg=#7aa2f7
hi Title        guifg=#7aa2f7 gui=bold

" Diff
hi DiffAdd      guibg=#20303b
hi DiffChange   guibg=#1f2231
hi DiffDelete   guifg=#f7768e guibg=#37222c
hi DiffText     guibg=#394b70

" Syntax highlighting
hi Comment      guifg=#565f89 gui=italic
hi Constant     guifg=#ff9e64
hi String       guifg=#9ece6a
hi Character    guifg=#9ece6a
hi Number       guifg=#ff9e64
hi Boolean      guifg=#ff9e64
hi Float        guifg=#ff9e64
hi Identifier   guifg=#bb9af7
hi Function     guifg=#7aa2f7
hi Statement    guifg=#bb9af7
hi Conditional  guifg=#bb9af7
hi Repeat       guifg=#bb9af7
hi Label        guifg=#7aa2f7
hi Operator     guifg=#89ddff
hi Keyword      guifg=#bb9af7
hi Exception    guifg=#bb9af7
hi PreProc      guifg=#7dcfff
hi Include      guifg=#7dcfff
hi Define       guifg=#bb9af7
hi Macro        guifg=#7dcfff
hi PreCondit    guifg=#7dcfff
hi Type         guifg=#7aa2f7
hi StorageClass guifg=#bb9af7
hi Structure    guifg=#bb9af7
hi Typedef      guifg=#bb9af7
hi Special      guifg=#7dcfff
hi SpecialChar  guifg=#7dcfff
hi Tag          guifg=#f7768e
hi Delimiter    guifg=#a9b1d6
hi Debug        guifg=#f7768e
hi Underlined   gui=underline guifg=#7aa2f7
hi Error        guifg=#f7768e guibg=NONE
hi Todo         guifg=#1a1b26 guibg=#e0af68 gui=bold

" Spelling
hi SpellBad     guisp=#f7768e gui=undercurl
hi SpellCap     guisp=#e0af68 gui=undercurl
hi SpellLocal   guisp=#7dcfff gui=undercurl
hi SpellRare    guisp=#bb9af7 gui=undercurl

" Terminal colors
if has('terminal')
  let g:terminal_ansi_colors = [
    \ '#15161e', '#f7768e', '#9ece6a', '#e0af68',
    \ '#7aa2f7', '#bb9af7', '#7dcfff', '#a9b1d6',
    \ '#414868', '#f7768e', '#9ece6a', '#e0af68',
    \ '#7aa2f7', '#bb9af7', '#7dcfff', '#c0caf5'
    \ ]
endif
