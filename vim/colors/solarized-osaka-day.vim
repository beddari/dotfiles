" solarized-osaka-day.vim — matches Ghostty solarized-osaka-day theme
" Based on Tokyo Night Day color palette

set background=light
hi clear
if exists('syntax_on')
  syntax reset
endif
let g:colors_name = 'solarized-osaka-day'

" Palette
" bg:        #e1e2e7
" bg_dark:   #d0d5e3
" bg_hl:     #b7c1e3
" fg:        #3760bf
" fg_dark:   #6172b0
" comment:   #a1a6c5
" red:       #f52a65
" green:     #587539
" yellow:    #8c6c3e
" blue:      #2e7de9
" magenta:   #9854f1
" cyan:      #007197
" orange:    #ff4774
" teal:      #118c74

" UI elements
hi Normal       guifg=#3760bf guibg=#e1e2e7
hi NormalFloat  guifg=#3760bf guibg=#d0d5e3
hi Cursor       guifg=#e1e2e7 guibg=#3760bf
hi CursorLine   guibg=#b7c1e3
hi CursorLineNr guifg=#8c6c3e guibg=#e1e2e7
hi LineNr       guifg=#a1a6c5
hi SignColumn   guibg=#e1e2e7
hi ColorColumn  guibg=#d0d5e3
hi VertSplit    guifg=#a1a6c5 guibg=#e1e2e7
hi StatusLine   guifg=#3760bf guibg=#d0d5e3 gui=NONE
hi StatusLineNC guifg=#a1a6c5 guibg=#d0d5e3 gui=NONE
hi TabLine      guifg=#a1a6c5 guibg=#d0d5e3 gui=NONE
hi TabLineFill  guibg=#d0d5e3
hi TabLineSel   guifg=#3760bf guibg=#e1e2e7 gui=bold
hi Pmenu        guifg=#3760bf guibg=#d0d5e3
hi PmenuSel     guifg=#3760bf guibg=#b7c1e3
hi PmenuSbar    guibg=#d0d5e3
hi PmenuThumb   guibg=#a1a6c5
hi Folded       guifg=#2e7de9 guibg=#d0d5e3
hi FoldColumn   guifg=#a1a6c5 guibg=#e1e2e7
hi NonText      guifg=#a1a6c5
hi SpecialKey   guifg=#a1a6c5
hi Visual       guibg=#b7c1e3
hi Search       guifg=#e1e2e7 guibg=#8c6c3e
hi IncSearch    guifg=#e1e2e7 guibg=#ff4774
hi MatchParen   guifg=#ff4774 gui=bold
hi Directory    guifg=#2e7de9

" Diagnostics
hi ErrorMsg     guifg=#f52a65 guibg=NONE
hi WarningMsg   guifg=#8c6c3e guibg=NONE
hi MoreMsg      guifg=#587539
hi Question     guifg=#2e7de9
hi Title        guifg=#2e7de9 gui=bold

" Diff
hi DiffAdd      guibg=#c8e6c0
hi DiffChange   guibg=#d0d5e3
hi DiffDelete   guifg=#f52a65 guibg=#f5c8cb
hi DiffText     guibg=#b7c1e3

" Syntax highlighting
hi Comment      guifg=#a1a6c5 gui=italic
hi Constant     guifg=#ff4774
hi String       guifg=#587539
hi Character    guifg=#587539
hi Number       guifg=#ff4774
hi Boolean      guifg=#ff4774
hi Float        guifg=#ff4774
hi Identifier   guifg=#9854f1
hi Function     guifg=#2e7de9
hi Statement    guifg=#9854f1
hi Conditional  guifg=#9854f1
hi Repeat       guifg=#9854f1
hi Label        guifg=#2e7de9
hi Operator     guifg=#007197
hi Keyword      guifg=#9854f1
hi Exception    guifg=#9854f1
hi PreProc      guifg=#007197
hi Include      guifg=#007197
hi Define       guifg=#9854f1
hi Macro        guifg=#007197
hi PreCondit    guifg=#007197
hi Type         guifg=#2e7de9
hi StorageClass guifg=#9854f1
hi Structure    guifg=#9854f1
hi Typedef      guifg=#9854f1
hi Special      guifg=#007197
hi SpecialChar  guifg=#007197
hi Tag          guifg=#f52a65
hi Delimiter    guifg=#6172b0
