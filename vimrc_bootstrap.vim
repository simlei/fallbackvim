if expand("$VIMINIT") !=# '$VIMINIT'
    unlet $VIMINIT
endif
" vimruntime.bootstrap.vimrc | setup variable scopes / bootstrap{{{
if ! exists("vimruntime")
    call _VimRuntimeLog("vimruntime dictionary not found; it seems stock_vim_init.vim was not loaded", 1)
endif
if ! exists("vimruntime.bootstrap")
    let vimruntime.bootstrap = {}
endif
if ! exists("vimruntime.bootstrap.vimrc")
    let vimruntime.bootstrap.vimrc = {}
endif

let vimruntime.bootstrap.dir = expand('<sfile>:p:h')
let vimruntime.bootstrap.vimrc.scriptfile = expand('<sfile>:p')
let vimruntime.bootstrap.vimrc.optutils = fnamemodify(vimruntime.bootstrap.vimrc.scriptfile, ':p:h')."/opt/bootstrap_vimrc_utils.vim"
"}}}
" source optional utils from .../opt/{{{
if filereadable(vimruntime.bootstrap.vimrc.optutils)
    exec printf('source %s', vimruntime.bootstrap.vimrc.optutils)
endif
"}}}

let vimruntime.bootstrap.vimrc.sourced = []
let vimruntime.bootstrap.vimrc.sourced_lastrun = []

"sourcing definitions in function and command, execution for first time
fun! _SourceAllVimrc() abort
    let g:vimruntime.bootstrap.vimrc.sourced_lastrun = []
    try
    for rcfile in g:vimruntime.stock_vim_init.vimrc_spec.rc
        execute printf("source %s", rcfile)
        call add(g:vimruntime.bootstrap.vimrc.sourced, rcfile)
        call add(g:vimruntime.bootstrap.vimrc.sourced_lastrun, rcfile)
    endfor
    " finally
        " let wrapupRcfile = g:vimruntime.bootstrap.dir . "/wrapup/wrapup.vim"
        " execute printf("source %s", wrapupRcfile)
        " call add(g:vimruntime.bootstrap.vimrc.sourced, wrapupRcfile)
        " call add(g:vimruntime.bootstrap.vimrc.sourced_lastrun, wrapupRcfile)
    endtry
endf

" Set it off...
let $MYVIMRC=expand("<sfile>:p")
call _SourceAllVimrc()
