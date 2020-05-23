let g:dispatch_is_always_copen=1
augroup qfpost
    au!
    " au QuickFixCmdPost caddexpr normal :echom "blub bla"
    " au QuickFixCmdPost caddexpr Copen
    " au QuickFixCmdPost * echom expand('<amatch>').' '.len(getqflist()).' '.localtime()
augroup END
fun! _qf_ensure() abort
    copen
    wincmd p
    " if ! qf#IsQfWindow(winnr())
    "     echom 222
    "     wincmd p
    " endif
endf
