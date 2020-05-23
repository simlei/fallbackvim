hi EasyMotionTarget2First cterm=bold ctermbg=none ctermfg=blue
hi EasyMotionTarget2Second cterm=bold ctermbg=none ctermfg=blue
augroup easymotion_colors
    au!
    au ColorScheme * hi EasyMotionTarget2First cterm=bold ctermbg=none ctermfg=blue
    au ColorScheme * hi EasyMotionTarget2Second cterm=bold ctermbg=none ctermfg=blue
    " au VimEnter * hi link EasyMotionTarget2First  ErrorMsg
    " au VimEnter * hi link EasyMotionTarget2Second ErrorMsg
augroup END

