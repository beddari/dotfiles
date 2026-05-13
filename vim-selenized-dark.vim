" selenized-dark.vim — matches Ghostty selenized-dark theme
" Based on Selenized Dark color palette

set background=dark
hi clear
if exists('syntax_on')
  syntax reset
endif
let g:colors_name = 'selenized-dark'

" Palette
" bg:        #053d48
" bg_dark:   #002B36
" bg_hl:     #274642
" fg:        #C8D7D8
" fg_dim:    #ADBCBC
" comment:   #506268
" red:       #FD564E
" green:     #80B83C
" yellow:    #e3b230
" blue:      #0096F5
" magenta:   #F275BE
" cyan:      #39c7b9
" orange:    #ED8649
" brmagenta: #A58CEC

" UI elements
hi Normal       guifg=#C8D7D8 guibg=#053d48
hi NormalFloat  guifg=#C8D7D8 guibg=#002B36
hi Cursor       guifg=#00212B guibg=#C8D7D8
hi CursorLine   guibg=#274642
hi CursorLineNr guifg=#e3b230 guibg=#053d48
hi LineNr       guifg=#506268
hi SignColumn   guibg=#053d48
hi ColorColumn  guibg=#002B36
hi VertSplit    guifg=#506268 guibg=#053d48
hi StatusLine   guifg=#C8D7D8 guibg=#002B36 gui=NONE
hi StatusLineNC guifg=#506268 guibg=#002B36 gui=NONE
hi TabLine      guifg=#506268 guibg=#002B36 gui=NONE
hi TabLineFill  guibg=#002B36
hi TabLineSel   guifg=#C8D7D8 guibg=#053d48 gui=bold
hi Pmenu        guifg=#C8D7D8 guibg=#002B36
hi PmenuSel     guifg=#C8D7D8 guibg=#274642
hi PmenuSbar    guibg=#002B36
hi PmenuThumb   guibg=#506268
hi Folded       guifg=#0096F5 guibg=#002B36
hi FoldColumn   guifg=#506268 guibg=#053d48
hi NonText      guifg=#506268
hi SpecialKey   guifg=#506268
hi Visual       guibg=#274642
hi Search       guifg=#00212B guibg=#e3b230
hi IncSearch    guifg=#00212B guibg=#ED8649
hi MatchParen   guifg=#ED8649 gui=bold
hi Directory    guifg=#0096F5

" Diagnostics
hi ErrorMsg     guifg=#FD564E guibg=NONE
hi WarningMsg   guifg=#e3b230 guibg=NONE
hi MoreMsg      guifg=#80B83C
hi Question     guifg=#0096F5
hi Title        guifg=#0096F5 gui=bold

" Diff
hi DiffAdd      guibg=#1a3320
hi DiffChange   guibg=#1f2a31
hi DiffDelete   guifg=#FD564E guibg=#3a1517
hi DiffText     guibg=#274642

" Syntax highlighting
hi Comment      guifg=#506268 gui=italic
hi Constant     guifg=#ED8649
hi String       guifg=#80B83C
hi Character    guifg=#80B83C
hi Number       guifg=#ED8649
hi Boolean      guifg=#ED8649
hi Float        guifg=#ED8649
hi Identifier   guifg=#F275BE
hi Function     guifg=#0096F5
hi Statement    guifg=#F275BE
hi Conditional  guifg=#F275BE
hi Repeat       guifg=#F275BE
hi Label        guifg=#0096F5
hi Operator     guifg=#39c7b9
hi Keyword      guifg=#F275BE
hi Exception    guifg=#F275BE
hi PreProc      guifg=#39c7b9
hi Include      guifg=#39c7b9
hi Define       guifg=#F275BE
hi Macro        guifg=#39c7b9
hi PreCondit    guifg=#39c7b9
hi Type         guifg=#0096F5
hi StorageClass guifg=#F275BE
hi Structure    guifg=#F275BE
hi Typedef      guifg=#F275BE
hi Special      guifg=#39c7b9
hi SpecialChar  guifg=#39c7b9
hi Tag          guifg=#FD564E
hi Delimiter    guifg=#ADBCBC
