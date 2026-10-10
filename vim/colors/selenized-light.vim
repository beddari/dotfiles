" selenized-light.vim — matches Ghostty selenized-light theme
" Based on Selenized Light (Solarized Light) color palette

set background=light
hi clear
if exists('syntax_on')
  syntax reset
endif
let g:colors_name = 'selenized-light'

" Palette
" bg:        #FEF3DA
" bg_dark:   #EEE8D5
" bg_hl:     #DDD6C1
" fg:        #506268
" fg_dim:    #839496
" comment:   #93A1A1
" red:       #DC322F
" green:     #859900
" yellow:    #B58900
" blue:      #268BD2
" magenta:   #D33682
" cyan:      #2AA198
" orange:    #CB4B16
" brviolet:  #565a9c

" UI elements
hi Normal       guifg=#506268 guibg=#FEF3DA
hi NormalFloat  guifg=#506268 guibg=#EEE8D5
hi Cursor       guifg=#FDF6E3 guibg=#506268
hi CursorLine   guibg=#DDD6C1
hi CursorLineNr guifg=#B58900 guibg=#FEF3DA
hi LineNr       guifg=#93A1A1
hi SignColumn   guibg=#FEF3DA
hi ColorColumn  guibg=#EEE8D5
hi VertSplit    guifg=#93A1A1 guibg=#FEF3DA
hi StatusLine   guifg=#506268 guibg=#EEE8D5 gui=NONE
hi StatusLineNC guifg=#93A1A1 guibg=#EEE8D5 gui=NONE
hi TabLine      guifg=#93A1A1 guibg=#EEE8D5 gui=NONE
hi TabLineFill  guibg=#EEE8D5
hi TabLineSel   guifg=#506268 guibg=#FEF3DA gui=bold
hi Pmenu        guifg=#506268 guibg=#EEE8D5
hi PmenuSel     guifg=#506268 guibg=#DDD6C1
hi PmenuSbar    guibg=#EEE8D5
hi PmenuThumb   guibg=#93A1A1
hi Folded       guifg=#268BD2 guibg=#EEE8D5
hi FoldColumn   guifg=#93A1A1 guibg=#FEF3DA
hi NonText      guifg=#93A1A1
hi SpecialKey   guifg=#93A1A1
hi Visual       guibg=#DDD6C1
hi Search       guifg=#FDF6E3 guibg=#B58900
hi IncSearch    guifg=#FDF6E3 guibg=#CB4B16
hi MatchParen   guifg=#CB4B16 gui=bold
hi Directory    guifg=#268BD2

" Diagnostics
hi ErrorMsg     guifg=#DC322F guibg=NONE
hi WarningMsg   guifg=#B58900 guibg=NONE
hi MoreMsg      guifg=#859900
hi Question     guifg=#268BD2
hi Title        guifg=#268BD2 gui=bold

" Diff
hi DiffAdd      guibg=#d5e8c0
hi DiffChange   guibg=#EEE8D5
hi DiffDelete   guifg=#DC322F guibg=#f5d0cf
hi DiffText     guibg=#DDD6C1

" Syntax highlighting
hi Comment      guifg=#93A1A1 gui=italic
hi Constant     guifg=#CB4B16
hi String       guifg=#859900
hi Character    guifg=#859900
hi Number       guifg=#CB4B16
hi Boolean      guifg=#CB4B16
hi Float        guifg=#CB4B16
hi Identifier   guifg=#D33682
hi Function     guifg=#268BD2
hi Statement    guifg=#D33682
hi Conditional  guifg=#D33682
hi Repeat       guifg=#D33682
hi Label        guifg=#268BD2
hi Operator     guifg=#2AA198
hi Keyword      guifg=#D33682
hi Exception    guifg=#D33682
hi PreProc      guifg=#2AA198
hi Include      guifg=#2AA198
hi Define       guifg=#D33682
hi Macro        guifg=#2AA198
hi PreCondit    guifg=#2AA198
hi Type         guifg=#268BD2
hi StorageClass guifg=#D33682
hi Structure    guifg=#D33682
hi Typedef      guifg=#D33682
hi Special      guifg=#2AA198
hi SpecialChar  guifg=#2AA198
hi Tag          guifg=#DC322F
hi Delimiter    guifg=#839496
