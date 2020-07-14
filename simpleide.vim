
fun! _SetupIDEProjectVars() abort
    " if ! exists('g:project')
        let g:project = {}
        let g:project.loc = {}
        let g:project.vim = {}
        let g:project.vim.loc = {}
        let g:project.vim.dispatch = {}
    " endif
endf
fun! _SetupIDEProject(idesrc) abort
    call _SetupIDEProjectVars()
    let idedir=fnamemodify(a:idesrc, ":h")
    let projdir=fnamemodify(idedir, ":h")

    let g:project.loc.Droot = projdir
    let g:project.loc.Dprojectroot = idedir

    " e.g. the dispatch file is something for the shell, too
    let g:project.loc.Fdispatches = g:project.loc.Dprojectroot . "/dispatches.bash"

    let g:project.vim.loc.Droot = idedir . "/vim"
    let g:project.vim.loc.Dsessions = g:project.vim.loc.Droot . "/" . "sessions"
    let g:project.vim.loc.Dregs = g:project.vim.loc.Droot . "/" . "regs"
    let g:project.vim.loc.Frc = a:idesrc

    " plugins are so common to configure that they are pulled in to main NS
    let g:project.vim.dispatch.opts = "-compiler=python"
    " let g:project.vim.dispatch.opts = ""
    let g:project.vim.dispatch.Flist = g:project.loc.Fdispatches

    let g:project.name = "#UNSET#"
    if ! exists("g:_simpleide_projname")
        let g:_simpleide_projname = "#UNSET#"
    endif
    if g:_simpleide_projname !=# "#UNSET#"
        let g:project.name = g:_simpleide_projname
    endif

    " configure by environment if available
    if g:project.name !=# "#UNSET#"
        " extend g:project directories and files
        call extend(g:project.loc, Envsdict("g:project__" . g:project.name . "__F", "F"))
        call extend(g:project.loc, Envsdict("g:project__" . g:project.name . "__D", "D"))
        call extend(g:project.loc, Envsdict("g:project__" . g:project.name . "__X", "X"))
    endif

    call mkdir(g:project.vim.loc.Dsessions, "p")

    call _PerformProjectSettings()


    nmap <F10>S :source <C-r>=g:project.vim.loc.Dsessions<CR>/session_
    nmap <F10>s :Obsession! <C-r>=g:project.vim.loc.Dsessions<CR>/session_

    exec printf("cd %s", fnameescape(g:project.loc.Droot))

    nmap <F10>rcpe :e <C-r>=g:project.vim.loc.Frc<CR><CR>
    nmap <F10>rcv :source <C-r>=$MYVIMRC<CR> <bar> source <C-r>=g:project.vim.loc.Frc<CR><CR>

    " Debug
    nmap <F10>rcpP o<C-r>=string(g:project)<CR><Esc>:.s/'/"/g<CR>:.!python -mjson.tool<CR>

endf

fun! _PerformProjectSettings() abort
    " bridge let effective = new
    let g:_dispatch_opts = g:project.vim.dispatch.opts
    let g:_dispatch_listfile = g:project.vim.dispatch.Flist
    let g:_regfiles_dir = g:project.vim.loc.Dregs
endf

command! -nargs=1 ShortcutExt call _shortcutExt(<f-args>)
fun! _shortcutExt(key) abort
    call feedkeys("\<plug>(ext)".a:key, "i")
endf

fun! _project_currentproject_selection() abort
    let selection = readfile($project__currentproject__Droot . "/lastselection.txt")
    return selection
endfun
command! -nargs=+ GetExtSel call _project_currentproject_selection_reg(<f-args>)
fun! _project_currentproject_selection_reg(regname, ...) abort
    let mode=get(a:, 1, "V")
    let sel = _project_currentproject_selection()
    call filter(sel, {i,x -> ! empty(trim(x))})
    if len(sel) == 0
        call setreg(a:regname, "", mode)
    elseif len(sel) == 1
        call setreg(a:regname, sel[0], mode)
    else
        call setreg(a:regname, sel, mode)
    endif
endfun



fun! _project_register_as_vimide() abort
    if ! exists("v:servername") || empty(v:servername)
        if g:project.name ==# "#UNSET#"
            let servername = "ADHOC"
        else
            let servername = g:project.name
        endif
        call remote_startserver(servername)
        echom "started server: " . servername
    endif
    call system("currentproject_vimide_setservername " . v:servername)
endfun
