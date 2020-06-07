set nocompatible
let $MYVIMRC=expand("<sfile>:p")
exec printf('source %s', expand("<sfile>:p:h")."/bootstrap_RTP.vim")

let mapleader = ","

nmap <C-w><Del><Home> ,k-<C-w>p<C-w><Del><Del><C-m>

exec printf('source %s', expand("<sfile>:p:h")."/fzf.vim")
exec printf('source %s', expand("<sfile>:p:h")."/java_lsp.vim")
exec printf('source %s', expand("<sfile>:p:h")."/easymotion-colors.vim")
exec printf('source %s', expand("<sfile>:p:h")."/qf.vim")
exec printf('source %s', expand("<sfile>:p:h")."/simpleide.vim")

"" registers
let g:_regfiles_dir=expand("~/.vim/regs")
nmap <F10>" :e <C-r>=g:_regfiles_dir<CR><CR>

nnoremap Q q
nmap <nowait> ,q <plug>(Mac_Play)
nmap <nowait> q <plug>(Mac_RecordNew)
nmap ;qh :DisplayMacroHistory<cr>

nmap ;qk <plug>(Mac_RotateBack)
nmap ;qj <plug>(Mac_RotateForward)

nmap ;qa <plug>(Mac_Append)
nmap ;qA <plug>(Mac_Prepend)

nmap [m <plug>(Mac_RotateBack)
nmap ]m <plug>(Mac_RotateForward)

" me = macro execute named
nmap <leader>me <plug>(Mac_SearchForNamedMacroAndPlay)
nmap <leader>ms <plug>(Mac_SearchForNamedMacroAndSelect)
nmap <leader>mng <plug>(Mac_NameCurrentMacro)
nmap <leader>mnf <plug>(Mac_NameCurrentMacroForFileType)

command! -nargs=1 Rege call _Open_Regfile(<f-args>)
fun! _Open_Regfile(regname) abort
    execute printf("e ++enc=ISO-8859-1 %s", g:_regfiles_dir . "/" . a:regname . ".reg")
endf
fun! _On_Regfile(path) abort
    setlocal fileencoding=ISO-8859-1
    let matchl = matchlist(a:path, '\([a-z]\)\.reg')
    if empty(matchl)
        return 0
    endif
    let regname=matchl[1]
    let modefile=fnamemodify(a:path, ':p:h')."/.".regname.'.mode'
    if ! empty(glob(modefile))
        let modeFirstline=trim(readfile(modefile)[0])
        if modeFirstline ==# "v" || modeFirstline ==# "V"
            let regmode=modeFirstline
        else
            echoerr "in ".modefile.", first line is neither V nor v"
            return 0
        endif
    else
        let regmode="v"
    endif
    let b:regmode=regmode
    let b:regname=regname
    nmap <buffer> <F11><Space> :call _Reg_ReadFromBuf()<CR>
    nmap <buffer> <F11>W :call _Reg_WriteToBuf()<CR>
    " let b:regmode="v"
endf

fun! _Reg_ReadFromBuf() abort
    " normal! m`
    " execute "normal G$".b:regmode."gg".'"'.b:regname.'y'
    echom string(readfile(expand("%")))
    " normal! ``
endf
fun! _Reg_WriteToBuf() abort
    normal ggdG
    execute printf('normal "%sP', b:regname)
    return 0
    if getregtype(b:regname) ==# "V"
        normal Gdd
    endif
    let modefile=fnamemodify(expand("%"), ':p:h')."/.".b:regname.'.mode'
    call writefile([b:regmode], modefile)
endf

augroup Regfiles
  au!
  au BufReadPre  *.reg call _On_Regfile(expand("<afile>"))
  au BufReadPost  *.reg setlocal ft=
augroup END


let $PYTHONUNBUFFERED="TRUE"

let pandoc#modules#disabled = ["chdir"]

let g:vim_resize_disable_auto_mappings = 1

imap <Insert>B eval "$TSE_BOOTSTRAP_RC"<Esc>o

nmap <F10><F10>R :echo trim(system("kbreload"))<CR><CR>
tmap <F10><F10>R <C-w>:echo trim(system("kbreload"))<CR><CR>

" Environment_dicts
function! Envsdict(prefix, ...) abort
    let filtered = environ()
    call filter(filtered, {i,x -> stridx(i, a:prefix) == 0})
    let prefixrepl=get(a:, 1, a:prefix)
    let mapped = {}
    for [k,v] in items(filtered)
        let key_body = k[len(a:prefix):]
        let newkey = prefixrepl . key_body
        let mapped[newkey] = v
    endfor
    return mapped
endfunction

" Kill subprocesses

nmap ;<Space>K :call _kill_dispatch()<CR>
fun! _kill_dispatch() abort
    let qftitle = getqflist({'title':1})["title"]
    if empty(qftitle)
        echoerr "could not find quickfix pid"
        return 0
    else
        let m = matchlist(qftitle, 'job\/\(\d*\)')
        if empty(m)
            echoerr "could not find quickfix pid"
            return 0
        else
            let pid = m[1]
            let outputlist = systemlist(printf("pgrep -P %s", pid))
            if v:shell_error == 0
                let childpid = outputlist[0]
                let output = system(printf('kill %s', childpid))
                if v:shell_error == 0
                    echom "killed child process: " . childpid . " of dispatch parent: " . pid
                else
                    echoerr "could not kill child process: " . childpid . " of dispatch parent: " . pid . " -- " . output
                    echoerr printf("could not get child process id of %s, maybe already dead & parent still kicking?", pid)
                endif
            else
                echoerr printf("could not get child process id of %s, maybe already dead & parent still kicking?", pid) . " -- " . join(outputlist, "\n")
            endif

        endif
    endif
endf

" Fugitive
nmap ;FM :Gvdiffsplit!<CR>
nmap ;Fm :Git merge<CR>
nmap ;FW :Gwrite<CR>

" Python crutches
imap <Insert>pp print(f"")<Left><Left>
imap <Insert>pld implicitly("prog.logger").debug(f"")<Left><Left>
imap <Insert>pLd implicitly("prog.logger").debug(f"{=}")<Left><Left><Left><Left>
imap <Insert>pli implicitly("prog.logger").info(f"")<Left><Left>
imap <Insert>pLi implicitly("prog.logger").info(f"{=}")<Left><Left><Left><Left>

command! GoWS e /home/simon/sandbox/featurelist/ct_functionlist/ws/
nmap <F10>g. :GoWS<CR>


nmap <Leader><Space>tj :TagbarOpen fjc<CR>j<CR>
nmap <Leader><Space>tk :TagbarOpen fjc<CR>k<CR>
nmap <Leader><Space>tt :TagbarOpen fj<CR>
" Windows nav

tmap <C-w><Del><Del> <C-w>:bdelete!<CR>
tmap <C-w><Del><Space> <C-w>:Bdelete!<CR>
nmap <C-w><Del><Del> :bdelete!<CR>
nmap <C-w><Del><Space> :Bdelete!<CR>

" terminal api...
" dirvish...

" if exists('g:vimplugin_running')
"     exec printf("set rtp+=%s", '$HOME/.vim/eclim')
" endif

" sync up lines and zz
nmap <F10>= :let _linenr=line(".")<CR>zz<C-w>p:<C-r>=_linenr<CR><CR>zz<C-w>p

command! -nargs=1 Viewer execute printf('Spawn xdg-open %s', fnameescape(<f-args>))

" go to getcwd()
nmap <silent> <F10>dg :exec printf('e %s/', getcwd(-1))<CR>
nmap <silent> <F10>dR :exec printf('cd %s', getcwd(-1))<CR>

" debug messages
nmap <F10>D :Messages<CR>G

" Fzf utils, baseline

" Java LSP, baseline


" Good Additions!

nmap <silent> gyf :let @+=expand("%:p").":".line(".")<CR>:let @"=@+<CR>

fun! _Write_Executable() abort
    call feedkeys(":let _name='' | exec 'w '._name | call system('chmod +x '._name)\<Home>\<Right>\<Right>\<Right>\<Right>\<Right>\<Right>\<Right>\<Right>\<Right>\<Right>\<Right>")
endf

nmap <F10>! gg0i#!/usr/bin/env bash<CR><CR><Esc>:if empty(getreg("%")) <bar> call _Write_Executable() <bar> else <bar> call system("chmod +x ".expand("%:p")) <bar> endif<CR>
nmap <F10>% :let @=expand("%:p")<Home><Right><Right><Right><Right><Right>
nmap ;s :set nospell<CR>

"" Good stuff!
xmap <F10>y mz:w !xclip -i -selection clipboard<CR>u'z
autocmd VimLeave * call system("xsel -ib", getreg('+'))

" Gvim maps this...
nmap <F10> <Nop>

command! ProjectRC exec printf("source %s", g:project_rcfile)
" Statusline {{{

let g:_statusline_cfg={
            \ "fugitive":0,
            \ "shorten":4,
            \ "bufnr": 1
            \ }
" command! -nargs=+ -bar SLine echo printf("g:_statusline_cfg %s".<f-args>) | set statusline=%!_My_Statusline()
command! -nargs=+ -bar SLine call lh#let#to("g:_statusline_cfg.".<f-args>) | let &statusline='%!_My_Statusline()'

fun! g:_My_Statusline() abort
    let shortenStr = '%{_Path_minimize_fordisplay(expand("%"), '.get(g:_statusline_cfg, "shorten", 2).')." "}'
    let fugitiveStr = get(g:_statusline_cfg, "fugitive", 1) ? '%{flagship#call("FugitiveStatusline")}' : ''
    let bufnrStr = get(g:_statusline_cfg, "bufnr", 1) ? 'b#%-4.3n|' : ''
    let result=   '%{flagship#in(winnr()==1?1:-1)}'
                \.'%<'
                \.shortenStr
                \.'%{flagship#surround(flagship#filetype())}'
                \.'%w'
                \.'%m'
                \.'%r'
                \.fugitiveStr
                \.'%='
                \.bufnrStr
                \.'%-14.('
                \.'%l,'
                \.'%c'
                \.'%V'
                \.'%) '
                \.'%P'
                \.'%{flagship#in(0)}'
    return result
endf
set statusline=%!_My_Statusline()
"}}}

augroup flagship
     au!
     " autocmd User Flags call Hoist("window", "|b#%-10.3n|")
augroup END

set laststatus=2
set showtabline=2

let g:tablabel = "%N%{flagship#tabmodified()} %{flagship#tabcwds('shorten',',')}"

fun! _Path_minimize(path, ...) abort
    let length = get(a:, 1, 1)
    let suffix=get(a:, 2, "")
    return substitute(a:path, '\([^/]\+\)', '\=_Path_Part_Shrink(submatch(1), length, suffix)', "g")
endf
fun! _Path_Part_Shrink(part, length, suffix) abort
    if len(a:part) <= a:length + strchars(a:suffix)
        return a:part
    endif
    return a:part[:a:length-1].a:suffix
endf
let g:_ellipsis = '…'
fun! _Path_minimize_fordisplay(path, by) abort
    if a:by == 0
        return a:path
    endif
    if empty(a:path)
        return a:path
    endif
    let path=substitute(a:path, '/$', '', '')
    let leading=fnamemodify(path, ":h")
    let tail=fnamemodify(path, ":t")
    return lh#path#join([_Path_minimize(leading, a:by, g:_ellipsis), tail])
endf


" Dispatch stuff
nmap ;<Space><CR>    :Dispatch<CR>
nmap ;<Space><Space> :Dispatch<CR>

nmap ;<Space>gm :e <C-r>=g:_dispatch_listfile<CR><CR>
nmap ;<Space>gf :e <C-r>=substitute(execute('FocusDispatch'), '^\n[^/]*\([^ ]*\).*', '\1', '')<CR><CR>
nmap ;<Space>f :FocusDispatch <C-r>=_GetDispatchOpts()<CR> <C-r>5
nmap ;<Space>F :FocusDispatch! <C-r>=_GetDispatchOpts()<CR> <C-r>5
nmap ;<Space><Space> :Dispatch <C-r>=_GetDispatchOpts()<CR><CR>
nmap ;<Space>5 :Dispatch <C-r>=_GetDispatchOpts()<CR> <C-r>5<CR>
nmap ;<Space>mM :let g:_dispatch_listfile = expand("%:p")<CR>
nmap ;<Space>ma :let @z=expand("%:p")<CR>:sp<CR>;<Space>gmGo<C-r>z<Esc>
nmap ;<Space>? :nmap ;<lt>Space><CR>

fun! _GetDispatchOpts() abort
    return g:_dispatch_opts
endf
let g:_dispatch_opts = ""
nmap ;<Space>mf :call SelectOne(funcref("_Dispatch_Focus_Receiver"), _Dispatch_ParseFile(g:_dispatch_listfile))<CR>
nmap ;<Space>m<Space> :call SelectOne(funcref("_Dispatch_Receiver"), _Dispatch_ParseFile(g:_dispatch_listfile))<CR>
nmap ;<Space>M<Space> :call SelectOne(funcref("_Dispatch_Receiver_Manual"), _Dispatch_ParseFile(g:_dispatch_listfile))<CR>
nmap ;<Space>; ,cp<C-w><up>,cp

" let g:_dispatch_opts = "-compiler=pyscript"

fun! _Linemacros(lines) abort
    let result = []
    for item in a:lines
        let flattenpat  = '\(.*\){@\*\(.\{-}\)@}\(.*\)'
        let pat  = '{@\(.\{-}\)@}'
        " expand listmacros first!
        let flattenlist=matchlist(item, flattenpat)
        if ! empty(flattenlist)
            let flattenhead=flattenlist[1]
            let flattenbody=flattenlist[2]
            let flattentail=flattenlist[3]
            let flattenevald=eval(flattenbody)
            if type(flattenevald) == type("string")
                let result += [flattenhead . flattenevald . flattentail]
            elseif type(flattenevald) == type([])
                for part in flattenevald
                    if type(part) == type("string")
                        let result += [flattenhead . part . flattentail]
                    else
                        let result += [flattenhead . string(part) . flattentail]
                    endif
                endfor
            else
                let result += [flattenhead . string(flattenevald) . flattentail]
            endif
        else
            let item = substitute(item, pat, '\=eval(submatch(1))', 'g')
            let result += [item]
        endif
    endfor
    return result
endfun
fun! _dispatch_execglob(globstring) abort
    return filter(glob(a:globstring,0,1), {i,x->executable(x)})
endfun
fun! _Dispatch_ParseFile(file) abort
    let result = []
    let lines = filter(readfile(a:file), { i,x -> ! empty(trim(x))})
    let result = _Linemacros(lines)
    return result
endfun
fun! _Dispatch_Receiver(file) abort
    if empty(a:file) | return | endif
    exec printf("Dispatch %s %s", g:_dispatch_opts, a:file)
endf
fun! _Dispatch_Receiver_Manual(file) abort
    if empty(a:file) | return | endif
    call feedkeys(printf("\<Esc>:Dispatch %s %s", g:_dispatch_opts, a:file))
    " exec printf("Dispatch %s %s", g:_dispatch_opts, a:file)
    " Copen
endf
fun! _Dispatch_Focus_Receiver(file) abort
    if empty(a:file) | return | endif
    exec printf("FocusDispatch %s %s", g:_dispatch_opts, a:file)
endf

let g:dispatchlist = []

" Vimscript stuff (mnemonic: Shift-2 is @)
command! -count=1 WTF call lh#exception#say_what(<count>)
nmap ;2m :let g:_cmdrecfile=expand("%")<CR>
nmap ;2g :e <C-r>=g:_cmdrecfile<CR><CR>
nmap ;23 gcc"myil:<C-r>m<CR>gcc
nmap ;22 "myil:<C-r>m<CR>
nmap ;2l :Messages<CR>G<C-w>p
nmap ;2w :WTF<CR>
nmap ;2s :source %<CR>
nmap <silent> ;2ww :exec '1WTF'<CR>
nmap <silent> ;2w2 :exec '2WTF'<CR>
nmap <silent> ;2w3 :exec '3WTF'<CR>
nmap ;2? :nmap ;2<CR>


" filco map
imap <Insert>v<Right> fun! <C-o>mz() abort<C-o>oendf<C-o>'z<Right>
imap <Insert>vf fun! <C-o>mz() abort<C-o>oendf<C-o>'z<Right>
imap <Insert>vi if <C-o>mz<C-o>oendif<C-o>'z<Right>

" expand current file
cmap <C-R>5 <C-R>=expand("%:p")<CR>

" important changed since TS

" nnoremap q; q:
" nnoremap q<Space> q
" nnoremap q<Return> @@
" nnoremap ;q @
" xnoremap ;q @
" xnoremap q<Space> q
" xnoremap q<Return> @@

" Only for the duration.. .(Mappigns){{{
nmap <F10>G :Grepper -dir repo,file<Space>
imap <Insert>a ${[@]}<Left><Left><Left><Left>
imap <Insert>z "$"<Left>
inoremap <Insert>i if [[ <C-o>mz ]]; then<CR>fi<C-o>`z<Right>
imap <Insert>D _declare_dirvar() { local _dir="${BASH_SOURCE[0]}"; _dir="${_dir%/*}"; local varname="${1:-dir}"; local count="${2:-1}"; while [[ "$count" -gt 0 ]]; do _dir="${_dir%/*}"; let count-- <bar><bar> :; done; eval "$varname"'="$_dir"'; }

let _rangerexecmd="/media/shared/ts-default/modules-all/ranger/ranger/ranger.py"
nmap <F10>rr :exe printf('term ++curwin %s', g:_rangerexecmd)<CR>
"}}}

fun! g:OldFunFastScriptid() abort "{{{
    return ":fun! s:__sid()\nreturn str2nr(matchlist(expand('<sfile>'), '<SNR>\\(\\d\\+\\)_.*')[1])\nendf\nlet s:scriptid = s:__sid()\nlet s:scriptfile = expand('<sfile>:p')"
endf
execute g:OldFunFastScriptid()
 "}}}
" set non-default packpath -- e.g. for drop-script{{{
if ! has("win32")
    if expand("<sfile>:p") != expand("~/.vim")
        let g:nonstandardvimdir=expand("<sfile>:p:h")
        execute printf("set packpath+=%s", g:nonstandardvimdir)
        execute printf("set runtimepath+=%s", g:nonstandardvimdir)
    endif
endif
"}}}

" later stdlib candidates
" idee: change something, then... substitute in operator scope or incrementally with undo/redo magic

fun! _Where_TS() abort "{{{
    let tsbash_bin = trim(system("which ts-bash"))
    if v:shell_error
        return ""
    else
        return fnamemodify(tsbash_bin, ":p:h:h")
    endif
endf "}}}


"terminal = bottom window{{{
tmap <C-w>,R :<C-w>:sp<CR><C-w>:TS<CR><C-w>p<C-w>:bwipeout!<CR><C-w>p
tmap <C-w>,r exec bash<CR>
xmap ;t "zy<C-w>b<C-w>"z<CR><C-w>p
nmap ;til vil;t
nmap ;tii <C-w>bi<C-w>p
nmap ;T <C-w>b<Up><CR><C-w>p
nmap 2;T <C-w>b<Up><Up><CR><C-w>p
nmap ;R <C-w>b<C-w>,r<Up><Up><CR><C-w>p
nmap ;C <C-w>b<C-c><C-w>p
nmap ;<C-m> <C-w>b<C-m><C-w>p
nmap <F9>? :nmap <lt>F9><CR>
nmap <F9>B <C-w>b<C-w>N,/simon@\S*:/.*\$<CR>NNzt

"terminal searchLastStacktraceEl (bash)
" tnoremap <C-w>,e <C-w>Ngg/\(\[TEST\]\\<bar>\s*✘\?\)\s*\[\zs.\{-}\ze\].*$<CR>G:set hlsearch<CR>

fun! _FileAndLineMatch(linefragment) abort "{{{
    echo "LINE: ".a:linefragment
    let pathAndDotMatch=matchlist(a:linefragment, '^\([.\][.A-Za-z0-9/_-]\+\)\(\(:\|.\{,5}line \)\(\d\+\)\)\?.*$')
    if ! empty(pathAndDotMatch)
        let path = pathAndDotMatch[1]
        let lineno = pathAndDotMatch[4]
        echo path
        echo lineno
        if empty(glob(path))
            if path[0] == "."
                if empty(glob(getcwd(-1)."/".path))
                    if empty(glob(getcwd()."/".path))
                        echom printf('%s is no existing path', getcwd()."/".path)
                        return []
                    else
                        return [getcwd()."/".path, lineno]
                    endif
                else
                    return [getcwd(-1)."/".path, lineno]
                endif
            else
                echom printf('%s is no existing path', path)
                return []
            endif
        else
            return [path, lineno]
        endif
    else
        return []
    endif
endf "}}}
fun! _GoToFileAndLine(fileAndLine) abort "{{{
    echom a:fileAndLine
    if expand("%:p") != a:fileAndLine[0]
        execute printf('e %s', fnameescape(a:fileAndLine[0]))
    endif
    if len(a:fileAndLine) > 1 && match(a:fileAndLine[1], '\d\+') > -1
        exec a:fileAndLine[1]
    endif
endf "}}}

" jump to bash errors
" these are from the terminal n-mode
nmap <F9>NN <C-w>b<C-w>N<C-w>p
nmap <F9>NI <C-w>bi<C-w>p
nmap <F9>gf mz:sp<CR><C-W>k<C-w>xF<C-w>p<C-w>p<C-w>=
nmap <F9>GF mz:sp<CR><C-W>k<C-w>xF<C-w>pi<C-w>p<C-w>=
nmap <F9>pgf !9pgf
nmap !9pgf "zy$mzi<C-w>:let g:_lastLoc=_FileAndLineMatch(getreg("z"))<CR><C-w>:echom "HI"<CR><C-w>p:if ! empty(g:_lastLoc) <bar> call _GoToFileAndLine(g:_lastLoc) <bar> endif<CR>

nmap !9SearchQlistStart> :let @/='\c\(>>>\<bar>uncaught exception\<bar>Traceback\<bar>\[ERROR]\<bar>simon@\S*:.*\$\)'<CR>
" the next pattern is basically, a slash prepended by SOL or \<
nmap !9SearchQlistFileStart> :let @/='\v([^A-Za-z0-9]<bar>^)\zs(\/<bar>\.+\/)'<CR>

tnoremap <C-w>N <C-w>Nzb
nmap <F9>gg <C-w>b<C-w>N!9SearchQlistStart>GkN!9SearchQlistFileStart>n<F9>pgf
nmap <F9>gG <C-w>b<C-w>N!9SearchQlistStart>GkN!9SearchQlistFileStart>n
nmap <F9>gn <C-w>b<C-w>N'z!9SearchQlistFileStart>n<F9>pgf
nmap <F9>gN <C-w>b<C-w>N'z!9SearchQlistFileStart>N<F9>pgf
nmap <F9>zf 0f)f{mza<Space><Esc>'z%$a<Space><Esc>V'zzf
nmap <F10>zf <Esc>'<mz$a<Space><Esc>'>$a<Space><Esc>V'zzf

" uut
nmap <F9>m :let g:_tsdev_uut=expand("%:p")<CR>
nmap <F9><C-m> <C-w>:let @z=g:_tsdev_uut<CR><C-w>b<C-c><C-w>"z<CR><C-w>p
nmap <F9>` <C-w>:let @z=expand("%:p")<CR><C-w>b<C-c><C-w>"z<CR><C-w>p
" }}}
" YouCompleteMe{{{
silent! packadd! YouCompleteMe
let g:ycm_extra_conf_vim_data = []

let g:ycm_log_level='debug'
let g:ycm_python_binary_path='python'

" let g:ycm_global_ycm_extra_conf = g:Layer("rich").relto_file("python/ycm_global_conf.py")

let g:ycm_cache_omnifunc = 1
let g:ycm_min_num_of_chars_for_completion = 2
let g:ycm_auto_trigger = 1
let g:ycm_max_num_identifier_candidates = 30
let g:ycm_complete_in_comments = 1
let g:ycm_collect_identifiers_from_comments_and_strings = 1
let g:ycm_collect_identifiers_from_tags_files = 0 "They say this may be slow
let g:ycm_seed_identifiers_with_syntax = 1 
let g:ycm_filepath_completion_use_working_dir = 1 "filepath compl rel. to cwd or to file

" Preview window behavior
let g:ycm_autoclose_preview_window_after_completion = 0 " after popup
let g:ycm_autoclose_preview_window_after_insertion = 1 " after insert mode
let pumheight=25

command! -bar YCMI let g:ycm_autoclose_preview_window_after_insertion = ! g:ycm_autoclose_preview_window_after_insertion <bar> echo 'g:ycm_autoclose_preview_window_after_insertion toggled to: '.g:ycm_autoclose_preview_window_after_insertion
command! -bar YCMC let g:ycm_autoclose_preview_window_after_completion= ! g:ycm_autoclose_preview_window_after_completion <bar> echo 'g:ycm_autoclose_preview_window_after_completion toggled to: '.g:ycm_autoclose_preview_window_after_completion

let g:ycm_goto_buffer_command = 'same-buffer' 
let g:ycm_key_invoke_completion = '<C-Space>' 
let g:ycm_key_list_stop_completion = ['<cr>']
let g:ycm_key_list_select_completion = ['<Down>', '<C-j>']
let g:ycm_key_list_previous_completion = ['<Up>', '<C-k>'] 
    " inoremap <expr> <C-j> pumvisible() ? '<DOWN>' : '<C-j>'
    " inoremap <expr> <C-k> pumvisible() ? '<UP>' : '<C-k>' 

nnoremap <F10>__ycm__gg :YcmCompleter GoTo<CR>
nnoremap <F10>__ycm__GG :YcmCompleter GoToImprecise<CR>
nnoremap <F10>__ycm__gt :YcmCompleter GoToType<CR>

nnoremap <F10>__ycm__gd :YcmCompleter GoToDeclaration<CR>
nnoremap <F10>__ycm__gD :YcmCompleter GoToDefinition<CR>

nnoremap <F10>__ycm__gi :YcmCompleter GoToImplementationElseDeclaration<CR>
nnoremap <F10>__ycm__gI :YcmCompleter GoToImplementation<CR>

nnoremap <F10>__ycm__r :YcmCompleter GoToReferences<CR>

nnoremap <F10>__ycm__T :YcmCompleter GetTypeImprecise<CR>
nnoremap <F10>__ycm__t :YcmCompleter GetType<CR>

nnoremap <F10>__ycm__D :YcmCompleter GetDocImprecise<CR>
nnoremap <F10>__ycm__d :YcmCompleter GetDoc<CR>

nnoremap <F10>__ycm__F :YcmCompleter FixIt<CR>
nnoremap <F10>__ycm__fix :YcmCompleter FixIt<CR>
nnoremap <F10>R :YcmCompleter RefactorRename<CR>
nnoremap <F10>__ycm__q :q<CR>

nnoremap <F10>__ycm__? :nmap <lt>F10>__ycm__<CR>

nmap <Leader><Space> <F10>__ycm__
"}}}

" __ EASYMOTION{{{

" hi EasyMotionTarget2First cterm=bold ctermbg=none ctermfg=blue
" hi EasyMotionTarget2Second cterm=bold ctermbg=none ctermfg=blue
" augroup easymotion_colors
"     au!
"     au ColorScheme * hi EasyMotionTarget2First cterm=bold ctermbg=none ctermfg=blue
"     au ColorScheme * hi EasyMotionTarget2Second cterm=bold ctermbg=none ctermfg=blue
"     " au VimEnter * hi link EasyMotionTarget2First  ErrorMsg
"     " au VimEnter * hi link EasyMotionTarget2Second ErrorMsg
" augroup END

let g:EasyMotion_startofline=1
let g:EasyMotion_do_shade=0
let g:EasyMotion_enter_jump_first = 1
let g:EasyMotion_use_upper = 1
let g:EasyMotion_use_upper = 1
let g:EasyMotion_keys = 'ASDFGHJKLQWERTYUIOPZXCVBNM'
hi link EasyMotionMoveHL Search
hi link EasyMotionIncSearch Search
let g:EasyMotion_move_highlight = 1

"""""""""""""""""""""""""""""
"  normal VIM motion stuff  "
"""""""""""""""""""""""""""""
" TODO candidate for statemachine stuff to unify

" TODO: ,swp does something....


nmap <Leader>s         <Plug>(easymotion-s2)
nmap <Leader>S <Plug>(easymotion-sn)
xmap <Leader>s         <Plug>(easymotion-s2)
xmap <Leader>S <Plug>(easymotion-sn)
omap <Leader>s <Plug>(easymotion-s2)
omap <Leader>S <Plug>(easymotion-sn)
" omap <Leader>z <Plug>(easymotion-sn)

" Bidirectional easymotions, shifted = whole buf 

nmap  <Leader>t <Plug>(easymotion-bd-tl)
omap  <Leader>t <Plug>(easymotion-bd-tl)
xmap  <Leader>t <Plug>(easymotion-bd-tl)
nmap  <Leader>f <Plug>(easymotion-bd-fl)
omap  <Leader>f <Plug>(easymotion-bd-fl)
xmap  <Leader>f <Plug>(easymotion-bd-fl)
"TODO: make uniform EM mappings{{{
" nmap  <Leader>T <Plug>(easymotion-bd-t)
" omap  <Leader>T <Plug>(easymotion-bd-t)
" map  <Leader>f <Plug>(easymotion-bd-fl)
" omap  <Leader>f <Plug>(easymotion-bd-fl)
" map  <Leader>F <Plug>(easymotion-bd-f)
" omap  <Leader>F <Plug>(easymotion-bd-f)
" map  <Leader>w <Plug>(easymotion-bd-wl)
" omap  <Leader>w <Plug>(easymotion-bd-wl)
" map  <Leader>W <Plug>(easymotion-bd-w)
" omap  <Leader>W <Plug>(easymotion-bd-w)
" map  <Leader>e <Plug>(easymotion-bd-el)
" omap  <Leader>e <Plug>(easymotion-bd-el)
" map  <Leader>E <Plug>(easymotion-bd-e)
" omap  <Leader>E <Plug>(easymotion-bd-e)
" map  <Leader>ge <Plug>(easymotion-bd-el)
" omap  <Leader>e <Plug>(easymotion-bd-el)
" map  <Leader>E <Plug>(easymotion-bd-e)
" omap  <Leader>E <Plug>(easymotion-bd-e)
"}}}
" half as fast PgUp/down events
nnoremap <PageUp> <C-u>
nnoremap <PageDown> <C-d>

nnoremap z<PageUp> zb
nnoremap z<PageDown> zt
xnoremap z<PageUp> <Esc>'>zbgv
xnoremap z<PageDown> <Esc>'<ztgv

" Linemovements: with repos and without

" xmap <Insert> <Plug>(easymotion-sol-bd-jk)
" omap <Insert> <Plug>(easymotion-sol-bd-jk)
" nmap <Insert> <Plug>(easymotion-sol-bd-jk)
xmap <Up> <Plug>(easymotion-sol-k)
omap <Up> <Plug>(easymotion-sol-k)
nmap <Up> <Plug>(easymotion-sol-k)
xmap <Down> <Plug>(easymotion-sol-j)
omap <Down> <Plug>(easymotion-sol-j)
nmap <Down> <Plug>(easymotion-sol-j)

" xmap <Leader><Insert> <Esc>zz:call feedkeys("gv\<Plug>(easymotion-sol-bd-jk)")<CR>
" nmap <Leader><Insert> zz:call feedkeys("\<Plug>(easymotion-sol-bd-jk)")<CR>
xmap z<Up> <Esc>zb:call feedkeys("gv\<Plug>(easymotion-sol-k)")<CR>
nmap z<Up> zb:call feedkeys("\<Plug>(easymotion-sol-k)")<CR>
xmap z<Down> <Esc>zt:call feedkeys("gv\<Plug>(easymotion-sol-j)")<CR>
nmap z<Down> zt:call feedkeys("\<Plug>(easymotion-sol-j)")<CR>

set hlsearch " DO NOT DISABLE
let g:incsearch#auto_nohlsearch = 1
omap n  <Plug>(incsearch-nohl-n)
xmap n  <Plug>(incsearch-nohl-n)
nmap n  <Plug>(incsearch-nohl-n)

omap N  <Plug>(incsearch-nohl-N)
xmap N  <Plug>(incsearch-nohl-N)
nmap N  <Plug>(incsearch-nohl-N)

" Incsearch: replacing default search
nmap ? m`<Plug>(incsearch-nohl)<Plug>(incsearch-easymotion-stay)
omap ? m`<Plug>(incsearch-nohl)<Plug>(incsearch-easymotion-stay)
xmap ? m`<Plug>(incsearch-nohl)<Plug>(incsearch-easymotion-stay)
nmap / m`<Plug>(incsearch-nohl)<Plug>(incsearch-stay)
omap / m`<Plug>(incsearch-nohl)<Plug>(incsearch-stay)
xmap / m`<Plug>(incsearch-nohl)<Plug>(incsearch-stay)
" incsearch + easymotion
" 
" nmap <Leader><Leader>/ :call feedkeys("\<lt>Plug>(incsearch-easymotion-stay)\<lt>Up>")<CR>

" this is always the vanilla search
nnoremap <Leader>/ /

" Workaround:
" TODO: works, but maybe get incsearch working? Workarounds for not using the incsearch commandsline
" this invokes vanilla search, see mapping above

" This can be maaped to by something that wants to have highlight but vanish on movement
nmap <F10>__hl :set hlsearch<CR><Plug>(incsearch-nohl0)
" nmap <silent> <F10>__hl :keepj exec "normal m`\<Plug>(incsearch-nohl-n)``"<CR>

"}}}

" Quickfix {{{

nmap <Leader>c<Up> :cope<CR>

nmap <silent> <Leader>cf :call QFFirstLast(getqflist(), 'cope <bar> call execute(num."cc")', 0, funcref("g:QFFilter_IsLocationUnderCwd", [getcwd()]))<CR>
nmap <silent> <Leader>cl :call QFFirstLast(getqflist(), 'cope <bar> call execute(num."cc")', 1, funcref("g:QFFilter_IsLocationUnderCwd", [getcwd()]))<CR>
nmap <silent> <Leader>c<Home> :call QFFirstLast(getqflist(), 'cope <bar> call execute(num."cc")', 0, funcref("g:QFFilter_IsLocation", [getcwd()]))<CR>
nmap <silent> <Leader>c<End> :call QFFirstLast(getqflist(), 'cope <bar> call execute(num."cc")', 1, funcref("g:QFFilter_IsLocationUnderCwd", [getcwd()]))<CR>

nmap <silent> <Leader>cc :cc<CR>
nmap <silent> <Leader>cv <Leader>cp:cc<CR>

" go to top or bottom of list
nmap <silent> <Leader>cG :set lazyredraw<CR><Leader>j:exec printf("cc %s", getqflist({'size':1}).size)<CR><Leader>X:set nolazyredraw<CR>
nmap <silent> <Leader>cgg :set lazyredraw<CR><Leader>j:1cc<CR><Leader>X:set nolazyredraw<CR>
nmap <silent> <Leader>c<Home> <Leader>cgg
nmap <silent> <Leader>c<End> <Leader>cG

nmap <silent> <S-up> :set lazyredraw<CR><Leader>j<Leader>ck<Leader>X:set nolazyredraw<CR>
nmap <silent> <S-down> :set lazyredraw<CR><Leader>j<Leader>cj<Leader>X:set nolazyredraw<CR>
nmap <silent> <C-Up> ,cpk<c-m>
nmap <silent> <C-Down> ,cpj<c-m>

nmap <Leader>crr :call qf#switch(1,1,0)<bar>CResize<bar>exec "normal ggG" <bar> call qf#switch(1,0,0)<CR>
nmap <Leader>arr :call qf#switch(2,1,1)<bar>CResize <bar>exec "normal ggG" <bar> wincmd p<CR>

nmap <Leader>c: :call :<C-u>call RegisterQfPos()<CR><Plug>(qf_qf_toggle)
nmap <Leader>c; :call :<C-u>call RegisterQfPos()<CR><Plug>(qf_qf_toggle_stay)
nmap <Leader>a: :call :<C-u>call RegisterQfPos()<CR><Plug>(qf_loc_toggle)
nmap <Leader>a; :call :<C-u>call RegisterQfPos()<CR><Plug>(qf_loc_toggle_stay)

nmap <silent> <Leader>cp :<C-u>call RegisterQfPos()<CR>:<C-u>call qf#switch(1, 1, 0)<CR>
" use only the precise loc list
nmap <silent> <Leader>ap :<C-u>call RegisterQfPos()<CR>:<C-u>call qf#switch(2, 1, 1)<CR>
" use any loc list if the precise one is not found
nmap <silent> <Leader>aP :<C-u>call RegisterQfPos()<CR>:<C-u>call qf#switch(2, 1, 0)<CR>

nmap <Leader>ced <Plug>Qflistsplit
nmap <Leader>aed <Plug>Loclistsplit

noremap <Leader>aaj :ALENext<CR>
nnoremap <Leader>aak :ALEPrevious<CR>
nmap <Leader>cj <Plug>(qf_qf_next)
nmap <Leader>ck <Plug>(qf_qf_previous)
nmap <Leader>aj <Plug>(qf_loc_next)
nmap <Leader>ak <Plug>(qf_loc_previous)

command! -bar -count=1 Cfnext execute _Cfnext(<count>, 'qf')
command! -bar -count=1 Cfprev execute _Cfnext(<count>, 'qf', 1)
command! -bar -count=1 Lfnext execute _Cfnext(<count>, 'loc')
command! -bar -count=1 Lfprev execute _Cfnext(<count>, 'loc', 1)

fun! QFFilter_IsLocation(element) abort
    return a:element["lnum"] > 0
endf

fun! QFFilter_IsLocationUnderCwd(dir, element) abort
    if a:element["lnum"] <= 0 || a:element["bufnr"] == 0
        return 0
    endif
    if ! filereadable(bufname(a:element["bufnr"]))
        return 0
    endif
    let resolvedEl = resolve(fnamemodify(bufname(a:element["bufnr"]), ":p"))
    let resolvedDir = resolve(fnamemodify(a:dir, ":p"))
    let idx=stridx(resolvedEl, resolvedDir)
    if idx == 0
        return 1
    endif
    return 0
endf

fun! QFFirstLast(list, cmd, ...) abort
    let list=a:list
    let listcmd=a:cmd
    let from_bottom = get(a:, 1, 0)
    let Filterfun = get(a:, 2, funcref("g:QFFilter_IsLocation"))

    let excmd=''
    let num=1
    if from_bottom
        let num=len(list)
        call reverse(list)
    endif
    for item in list
        if Filterfun(item)
            exec listcmd
            return item
        endif
        if from_bottom
            let num = num - 1
        else
            let num = num + 1
        endif
    endfor
    echo "no item found that satisfies ".string(Filterfun)
    return {}
endf

function! _Cfnext(count, list, ...) abort
  let reverse = a:0 && a:1 
  let func = 'get' . a:list . 'list'
  let params = a:list == 'loc' ? [0] : []
  let cmd = a:list == 'loc' ? 'll' : 'cc'

  let items = call(func, params)
  if len(items) == 0
    return 'echoerr ' . string('E42: No Errors')
  endif

  call map(items, 'extend(v:val, {"idx": v:key + 1})')
  if reverse
    call reverse(items)
  endif

  let [bufnr, cmp] = [bufnr('%'), reverse ? 1 : -1]
  let context = [line('.'), col('.')]
  if v:version > 800 || has('patch-8.0.1112')
    let current = call(func, extend(copy(params), [{'idx':1}])).idx
  else
    redir => capture | execute cmd | redir END
    let current = str2nr(matchstr(capture, '(\zs\d\+\ze of \d\+)'))
  endif
  call add(context, current)

  call filter(items, 'v:val.bufnr == bufnr && _CfCmp(context, [v:val.lnum, v:val.col, v:val.idx]) == cmp')

  let idx = get(get(items, 0, {}), 'idx', 'E553: No more items')

  if type(idx) == type(0)
    return cmd . idx
  else
     return 'echoerr' . string(idx)
  endif
endfunction
function! _CfCmp(a, b)
  for i in range(len(a:a))
    if a:a[i] < a:b[i]
      return -1
    elseif a:a[i] > a:b[i]
      return 1
    endif
  endfor
  return 0
endfunction

let g:kickfix_zebra = 0

"""""""""""""""""""""""
"  debugging with QF  "
"""""""""""""""""""""""

" selfmade qf height ctrl
if !exists('g:qf_wh')
    let g:qf_wh = 15
endif
if !exists('g:msgLastEnd')
    let msgLastEnd = -1
endif

""""""""""""""""""""""""""
"  the convenience maps  "
""""""""""""""""""""""""""

command! -nargs=0 QSort call s:SortUniqQFList()
command! -nargs=1 RejectExt RejectName .<args>$
command! -nargs=1 KeepExt KeepName .<args>$
command! -nargs=1 KeepName call g:OldFunWithVar('g:qf_bufname_or_text', 1, 'Keep '.<q-args>)
command! -nargs=1 KeepCont call g:OldFunWithVar('g:qf_bufname_or_text', 2, 'Keep '.<q-args>)
command! -nargs=1 KeepBoth call g:OldFunWithVar('g:qf_bufname_or_text', 0, 'Keep '.<q-args>)
command! -nargs=1 RejectName call g:OldFunWithVar('g:qf_bufname_or_text', 1, 'Reject '.<q-args>)
command! -nargs=1 RejectCont call g:OldFunWithVar('g:qf_bufname_or_text', 2, 'Reject '.<q-args>)
command! -nargs=1 RejectBoth call g:OldFunWithVar('g:qf_bufname_or_text', 0, 'Reject '.<q-args>)
command! -bar -nargs=0 CResize call g:QFResizeGlobal()

command! -nargs=0 QCd let g:qflistbase = getcwd() . '/.qf' | echo printf('Quickfix register dir is now %s', g:qflistbase)
command! -nargs=0 QShow exec 'e '.g:qflistbase.'/'


fun! RegisterQfMaps() abort
    nmap <silent><buffer> <Leader>m :.cc <bar> call g:OldFunFlashCurrentLine(1, 400) <bar> wincmd p<CR>
    nmap <silent><buffer> J j:.cc <bar> call g:OldFunFlashCurrentLine(2, 150) <bar> wincmd p<CR>
    nmap <silent><buffer> K k:.cc <bar> call g:OldFunFlashCurrentLine(2, 150) <bar> wincmd p<CR>

    nmap <silent> <buffer> o :<C-u>let loc_item = line('.') <bar> call qf#switch(1, 0, 0) <bar> sp <bar> exec loc_item.'cc'<CR>
    nmap <silent> <buffer> a :<C-u>let loc_item = line('.') <bar> call qf#switch(1, 0, 0) <bar> vs <bar> exec loc_item.'cc'<CR>
    nmap <silent> <buffer> O :<C-u>let loc_item = line('.') <bar> call qf#switch(1, 0, 0) <bar> sp <bar> exec loc_item.'cc' <bar> call qf#switch(1, 0, 0)<CR>
    nmap <silent> <buffer> A :<C-u>let loc_item = line('.') <bar> call qf#switch(1, 0, 0) <bar> vs <bar> exec loc_item.'cc' <bar> call qf#switch(1, 0, 0)<CR>

    " nmap <silent> <buffer> <Leader><cr> :<C-u>let loc_item = line('.') <bar> call qf#switch(1, 0, 0) <bar> exec loc_item.'cc'<CR>
    nmap <silent> <buffer> <C-m> :cc <C-R>=line(".")<CR><CR>
    " nmap <silent> <buffer> <Leader><C-m> :cc <C-R>=line(".")<CR><CR>

    nmap <buffer> <Leader><Leader><Space> :<C-u>call RegisterQfPos()<CR>
    nmap <silent> <buffer> <Leader>x :<C-u>call RegisterQfPos()<CR>:<C-u>call qf#switch(1, 0, 0) <bar> cclose <CR>
    nmap <silent> <buffer> <Leader><Leader>x :let g:qf_lastPos = {} <bar> call qf#switch(1, 0, 0) <bar> cclose <CR>

    nmap <silent> <buffer> <Leader>c; <Leader>x
    " nmap <buffer> <C-w>p :<C-u>call qf#switch(1, 0, 0)<CR>

    nmap <buffer> <silent> u :silent! colder<CR>
    nmap <buffer> <silent> <C-r> :silent! cnewer<CR>

    nnoremap <silent> <buffer> dae :call RegisterQfPos() <bar> :cexpr []<CR>

endf
fun! RegisterLocMaps() abort
    nmap <silent><buffer> <Leader>m :.ll <bar> call g:OldFunFlashCurrentLine(1, 400) <bar> wincmd p<CR>
    nmap <silent><buffer> J j:.ll <bar> call g:OldFunFlashCurrentLine(2, 150) <bar> wincmd p<CR>
    nmap <silent><buffer> K k:.ll <bar> call g:OldFunFlashCurrentLine(2, 150) <bar> wincmd p<CR>

    nmap <silent> <buffer> o :<C-u>let loc_item = line('.') <bar> call qf#switch(2, 0, 0) <bar> sp <bar> exec loc_item.'ll'<CR>
    nmap <silent> <buffer> a :<C-u>let loc_item = line('.') <bar> call qf#switch(2, 0, 0) <bar> vs <bar> exec loc_item.'ll'<CR>
    nmap <silent> <buffer> O :<C-u>let loc_item = line('.') <bar> call qf#switch(2, 0, 0) <bar> sp <bar> exec loc_item.'ll' <bar> wincmd p <bar> call qf#switch(2, 0, 0)<CR>
    nmap <silent> <buffer> A :<C-u>let loc_item = line('.') <bar> call qf#switch(2, 0, 0) <bar> vs <bar> exec loc_item.'ll' <bar> wincmd p <bar> call qf#switch(2, 0, 0)<CR>
    
    " if it goes into a different buffer than that of the loclist... TODO: detect that

    nmap <buffer> <C-m> :<C-u>let loc_item = line('.') <bar> call qf#switch(2, 0, 0) <bar> exec loc_item.'ll'<CR>
    nmap <buffer> <Leader><C-m> :<C-u>let loc_item = line('.') <bar> call qf#switch(2, 0, 0) <bar> exec loc_item.'ll'<CR>

    " nmap <buffer> <C-w>p <Plug>(qf_loc_switch) " location lists in pairs..
    nmap <buffer> <Leader><Leader><Space> :<C-u>call RegisterQfPos()<CR>
    nmap <silent> <buffer> <Leader>x :<C-u>call RegisterQfPos()<CR>:lclose<CR>
    nmap <silent> <buffer> <Leader><Leader>x :let g:loc_lastPos = {} <bar> call qf#switch(2, 0, 0) <bar> lclose <CR>


    nmap <silent> <buffer> <Leader>a; <Leader>x
    " nmap <buffer> <C-w>p :<C-u>call qf#switch(2, 0, 0)<CR>

    nmap <buffer> <silent> u :silent! lolder<CR>
    nmap <buffer> <silent> <C-r> :silent! lnewer<CR>

    nnoremap <silent> <buffer> dae :call RegisterQfPos() <bar> lexpr []<CR>
endf
fun! RegisterGeneralMaps() abort
    " nmap <buffer> <C-w>H :<C-u>call g:QfAdaptWinMovement('H', QfWinState())<CR>
    " nmap <buffer> <C-w>J :<C-u>call g:QfAdaptWinMovement('J', QfWinState())<CR>
    " nmap <buffer> <C-w>K :<C-u>call g:QfAdaptWinMovement('K', QfWinState())<CR>
    " nmap <buffer> <C-w>L :<C-u>call g:QfAdaptWinMovement('L', QfWinState())<CR>
    nmap <buffer> <C-w><Space> :call RegisterQfPos()<CR>
    nnoremap <buffer> <Leader>S :QSort<CR>
    nnoremap <buffer> <Leader>ke 0f<bar>T."zyt<bar>:KeepExt <C-r>z<CR>
    nnoremap <buffer> <Leader>re 0f<bar>F.l"zyt<bar>:RejectExt <C-r>z<CR>
    nnoremap <buffer> <Leader>rn 0"zyt<bar>:RejectName \V<C-r>z<CR>
    xnoremap <buffer> <Leader>rn "zy:<C-u>RejectName \V<C-r>z<CR>
    xnoremap <buffer> <Leader>R "zy:<C-u>Reject \V<C-r>z<CR>
    xnoremap <buffer> <Leader>K "zy:<C-u>Keep \V<C-r>z<CR>
endf


"""""""""""""""""""""""""""""""
"  Plugin settings, volatile  "
"""""""""""""""""""""""""""""""


" Plugin: qf plugin settings
let g:qf_max_height = 20 " should be overruled by vim-qf_resize if qf.vim is not set to autoresize
let g:qf_window_bottom = 1 " should be overruled by vim-qf_resize if qf.vim is not set to autoresize
let g:qf_loclist_window_bottom = 0 " should be overruled by vim-qf_resize if qf.vim is not set to autoresize

" TODO: these settings interfere with my toggle and register commands wrt. focus
let g:qf_auto_open_quickfix = 1
let g:qf_auto_open_loclist = 0
let g:qf_auto_resize = 0
let g:qf_auto_quit = 0
let g:qf_nowrap = 1

"" Plugin: qfenter


" Plugin: vim-qf_resize (blueyed) (uncommented for all defaults...)
" let g:qf_resize_min_height = 3 " can be a buffer setting, "experimental internal defaults"
let g:qf_resize_max_height = 20
" let g:qf_resize_max_ratio = 0.15
" let g:qf_resize_on_win_close = 1 " Resize/handle all qf windows when a window gets closed. Default: 1.

"" Plugin: QFEnter
let g:qfenter_enable_autoquickfix = 0
let g:qfenter_keymap = {}
let g:qfenter_keymap.open = ['<Space><cr>']
let g:qfenter_keymap.vopen = ['<Space>a']
let g:qfenter_keymap.hopen = ['<Space>o']
let g:qfenter_keymap.topen = ['<Space>t']
"" all supported commands: open, vopen, hopen, topen, cnext, vcnext, hcnext, tcnext, cprev, vcprev, hcprev, tcprev, 


"""""""""""""""""""""
"  various helpers  "
"""""""""""""""""""""
function! s:CompareQuickfixEntries(i1, i2)
  if bufname(a:i1.bufnr) == bufname(a:i2.bufnr)
    return a:i1.lnum == a:i2.lnum ? 0 : (a:i1.lnum < a:i2.lnum ? -1 : 1)
  else
    return bufname(a:i1.bufnr) < bufname(a:i2.bufnr) ? -1 : 1
  endif
endfunction
function! s:SortUniqQFList()
  let sortedList = sort(getqflist(), 's:CompareQuickfixEntries')
  let uniqedList = []
  let last = ''
  for item in sortedList
    let this = bufname(item.bufnr) . "\t" . item.lnum
    if this !=# last
      call add(uniqedList, item)
      let last = this
    endif
  endfor
  call setqflist(uniqedList)
endfunction

"""""""""""""""""""""""
"  moving qf windows  "
"""""""""""""""""""""""

" moving the windows and have them stay there
if !exists('g:qf_lastPos')
    let g:qf_lastPos = {}
endif
if !exists('g:loc_lastPos')
    let g:loc_lastPos = {}
endif
fun! QfPositioningHook() abort
    let type = qf#type(winnr())
    call lh#assert#true(type > 0)
    if type == 1
        if !empty(g:qf_lastPos)
            call g:qf_lastPos.qfinit_from_this(type)
        else
            call s:qfinit_fresh(type)
        endif
    endif
    if type == 2
        if !empty(g:loc_lastPos)
            call g:loc_lastPos.qfinit_from_this(type)
        else
            call s:qfinit_fresh(type)
        endif
    endif
endf
fun! QfGetLastStateForCurrent() abort
    let type = qf#type(winnr())
    call lh#assert#true(type > 0)
    if type == 1
        if empty(g:qf_lastPos)
            return QfWinState()
        endif
        return g:qf_LastPos
    elseif type == 2
        if empty(g:loc_lastPos)
            return QfWinState()
        endif
        return g:loc_lastPos
    endif
endf
fun! QfWinState(...) abort
    let s = g:OldFunWin_get(get(a:, 1, winnr()))
    "TODO: bad monkey patching! (older me: yes, indeed... >_<)
    call lh#object#inject_methods(s, s:scriptid, 'qfinit_from_this')
    return s
endf
fun! RegisterQfPos() abort
    return 0
    let type = qf#type(winnr())
    
    "TODOitclean: now, I am assuming we can do this by just looking at the current win
    if type == 0
        " call s:Verbose('not registering QfPos because this is not such a window')
        return
    endif
    if type > 0
        if type == 1
            let g:qf_lastPos = QfWinState()
        elseif  type == 2
            let g:loc_lastPos = QfWinState()
        endif 
    else
        " call s:Verbose('not in a window of that type in RegisterQfPos(%1)', type)
    endif
endf

" This gets called for movements we want to do something about
fun! g:QfAdaptWinMovement(movement, currentState) abort
    return 0
    call lh#assert#not_empty(a:currentState)
    
    if match(a:movement, '\v^[HJKL]$' >= 0)
        exec "wincmd ".a:movement
        " call s:Verbose('current state: %1', a:currentState)
        let hjklPrev = a:currentState.getHJKL()
        if match(a:movement, '\v^[HL]$') >= 0
            if !empty(hjklPrev)
                let complement = g:OldFunHJKLComplement(a:movement)
                if hjklPrev == complement
                    exec "vertical resize ".a:currentState.width
                    return
                endif
            endif
        else
            CResize
        endif
    endif

    call RegisterQfPos()
endf

fun! QfContentChanged() abort
    call lh#assert#true(qf#type(winnr()) > 0)
    
" TODO: implement that
    if match(QfWinState().getHJKL(), '[HL]') == -1
        CResize
    endif
endf

" Type is 1 for quickfix and 2 for loclist
fun! s:qfinit_fresh(type) abort
    if a:type == 1
        call ExecNormalWincmd('K')
        CResize
    elseif a:type == 2
        call ExecNormalWincmd('J')
        CResize " resize when default vertical-open behavior
    endif
endf
" initialization behavior of qf expressed as a class method on WinInfo, the last registered or default state of the window
" newest_movement as optional arg; currently only wincmd HJKL is processed (keep same width etc)
fun! s:qfinit_from_this(type, ...) abort dict
    if a:type > 0
        let hjkl = self.getHJKL()
        if ! empty(hjkl)
            exec "wincmd " . hjkl
            if match(hjkl, '\v[JK]') >= 0
                CResize
            endif
            if match(hjkl, '\v[HL]') >= 0
                exec "vertical resize " . self.width
            endif
        else
            CResize
            " if not hjkl, then leave it to the default behavior of CResize (which is also defined here, upon work of others...)
        endif
    elseif a:type == 2
        " nothing
    endif
endf


""""""""""""""""""""""""""""
"  autocommand definition  "
""""""""""""""""""""""""""""

fun! QfRegisterMappings() abort
    if qf#IsQfWindow(winnr())
        call RegisterQfMaps()
    endif

    if qf#IsLocWindow(winnr())
        call RegisterLocMaps()
    endif
    call RegisterGeneralMaps()
endf
fun! OnQfFiletype() abort
    call QfRegisterMappings()
    " call QfPositioningHook()
endf
augroup QfPosSimlei
    autocmd!
    autocmd FileType qf call OnQfFiletype()
    " autocmd! * <buffer>
    " exec ''
augroup end

fun! g:QFResizeGlobal() abort
    
    " let w1 = winnr()
    " let w2 = winnr('#')
    " echo qf#getWinInfos([1,2])
    " call qf#OnEach([1,2], { w -> w.vertResize(1, 1, 2, 0)})
    " call qf#OnEach([1,2], { w -> w.vertResize(1, g:qf_wh, 2, 0)})
    " exec w2.'wincmd w'
    " exec w1.'wincmd w'

    if qf#type(winnr()) > 0
        call g:OldFunWin_get().vertResize(1, g:qf_wh, 2, 0)
    endif
    " if qf#IsQfWindowOpen() 
    "     for winnum in range(1, winnr('$'))
    "         let height = 1
    "         if qf#IsQfWindow(winnum)
    "             let height = getwininfo(win_getid(winnum))[0]['height']
    "         endif
    "     endfor
    "     let switchBack = 0
    "     if qf#IsQfWindow(winnr())
    "         let switchBack = 1
    "         exec "normal \<Plug>(qf_qf_switch)"
    "     endif
    "     if ! g:OldFunWin_get().isFullHeight()
    "         QfResizeWindows " blueyed impl.
    "     endif
    "     if switchBack == 1
    "     QFResizeGlobal
    "         exec "normal \<Plug>(qf_qf_switch)"
    "     endif

    "     " Legacy: with vim-qf stuff
    "     " let max_height = get(g:, 'qf_max_height', 10) < 1 ? 10 : get(g:, 'qf_max_height', 10) 
    "     " if height <= max_height || 1 " TODO: always resize... get it to work that qf doesnt maximize nor reopens vertically
    "     "     if qf#IsQfWindow(winnr())
    "     "         let switchBack = 0
    "     "         " call feedkeys("\<Plug>(qf_qf_switch)", 'x') 
    "     "         exec "normal \<Plug>(qf_qf_switch)"
    "     "     else
    "     "         let switchBack = 1
    "     "     endif
    "     "     execute get(g:, "qf_auto_resize", 1) ? 'cclose|' . min([ max_height, len(getqflist()) ]) . 'cwindow' : 'cwindow'
    "     "     if switchBack == 1
    "     "         exec "normal \<Plug>(qf_qf_switch)"
    "     "     endif
    "     " endif
    " endif
endf

let g:currentQFListCanon = 'default'

"""""""""""""""""""""""""""""""""
"  QFRegisters and named lists  "
"""""""""""""""""""""""""""""""""

if ! exists('g:qflistbase')
    let g:qflistbase = getcwd() . '/.qf'
endif

" flags: 'forceAdd', 'P', 'changeCanon'
fun! g:PutQF(spec, ...) abort
    let [f, canon, isUp] = a:spec
    let modeOfPut = 'replace' " append, prepend
    let success = 0

    if index(a:000, 'P') != -1
        let modeOfPut = 'prepend'
    else
        if index(a:000, 'forceAdd') != -1 || isUp
            let modeOfPut = 'append'
        else
            let modeOfPut = 'replace'
        endif
    endif

    if filereadable(f)
        if modeOfPut == 'replace'
            exec 'Qfl '.f
            let success = 1
        elseif modeOfPut == 'append'
            exec 'Qfla '.f
            let success = 1
        elseif modeOfPut == 'prepend'
            exec 'QflA '.f
        endif
    else
        let namedlists = qf#namedlist#GetLists()
        if index(namedlists, canon) != -1
            call xolox#misc#msg#warn('Using named list ' . canon . ' - probably not saved!')
            if modeOfPut == 'replace'
                exec 'LoadList '.canon
                let success = 1
            elseif modeOfPut == 'append'
                exec 'LoadListAdd '.canon
                let success = 1
            elseif modeOfPut == 'prepend'
                call xolox#misc#msg#warn('Prepending a list to another has not yet been implemented!')
            endif
        else
            call xolox#misc#msg#warn(printf('No file ''%s'' and no named list ''%s''exist', f, canon))
        endif
    endif
    if success
        call xolox#misc#msg#info('put list with mode ' . modeOfPut . ' and flags ' . string(a:000) . ' into listreg ' . canon)
        if index(a:000, 'changeCanon')
            let g:currentQFListCanon = canon
            " call xolox#misc#msg#info('the current quickfix register is ' . canon)
        endif
    endif
endf
" flags: changeCanon
fun! g:YankQF(spec, ...) abort
    let [f, canon, isUp] = a:spec
    let success = 0
    if ! filewritable(f)
        call mkdir(fnamemodify(f, ':p:h'), 'p')
    endif
    if isUp
        call xolox#misc#msg#warn('Can''t currently append to a list by yanking; use SaveListAdd and "put" it afterwards')
    else
        exec 'Qfw ' . f
        exec 'SaveList ' . canon
        let success = 1
    endif
    
    if success
        call xolox#misc#msg#info('yanked list with flags ' . string(a:000) . ' to listreg ' . canon)
        if index(a:000, 'changeCanon')
            let g:currentQFListCanon = canon
            " call xolox#misc#msg#info('the current quickfix register is ' . canon)
        endif
    endif
endf
fun! g:QFFileAndMod(char) abort
    let uppat = '\v\C[A-Z]'
    let lowpat = '\v\C[a-z]'
    let alphapat = '\v[a-zA-Z]'
    let isDefault = (a:char ==# '"' || a:char ==# '+' || a:char == '*')
    let isalpha = match(a:char, alphapat) != -1
    let isUp = match(a:char, uppat) != -1
    let isLow = match(a:char, lowpat) != -1
    if isDefault
        return [g:qflistbase.'/'.'default'.'.qflist', 'default', isUp]
    endif
    if isalpha
        let canon = tolower(a:char)
        return [g:qflistbase.'/'.canon.'.qflist', canon, isUp]
    else
        throw "no alpha character for g:QFFileAndMod: ". a:char
    endif
endf
fun! g:QFFile(char) abort
    return g:QFFileAndMod(a:char)[0]
endf

command! -nargs=1 QYank call YankQF(QFFileAndMod(<f-args>))
"" Proxy cmd for implementation. Current: kickfix native writing
command! -nargs=1 Qfw call g:OldFunKillBufIfExists(<f-args>) | w! <args>
command! -nargs=1 Qfl QLoad <args>
" append
command! -nargs=1 Qfla call g:QflaImpl(<f-args>)
" prepend
command! -nargs=1 QflA call g:QflAImpl(<f-args>)
" command! -nargs=1 EnsureQf if qf#type(winnr()) != 1 | call qf#switch(1,0,0) | endif | <args>

" qf.vim powered append-paste style
fun! g:QflaImpl(file) abort
    SaveList buf1
    exec "QLoad ".a:file
    call qf#switch(1, 0, 0)
    SaveList buf2
    LoadList buf1
    LoadListAdd buf2
endf
" qf.vim and kickfix powered prepend-paste style
fun! g:QflAImpl(file) abort
    SaveList buf1
    exec "QLoad ".a:file
    call qf#switch(1, 0, 0)
    LoadListAdd buf1
endf
fun! QfMergePWithOlder() abort
    colder
    SaveList buf1
    cnewer
    SaveList buf2
    LoadList buf1
    LoadListAdd buf2
endf
fun! QfMergeWithOlder() abort
    colder
    SaveList buf1
    cnewer
    LoadListAdd buf1
endf

"""""""""""""""
"  Graveyard  "
"""""""""""""""


"" Plugin: QFEdit

" let g:editqf_no_mappings = 1
" nmap <Leader>cn <Plug>QFAddNote
" cmap <Leader>an <Plug>LocAddNote

" let g:editqf_saveqf_filename  = "quickfix.list"
" let g:editqf_saveloc_filename = "location.list"
" let g:editqf_jump_to_error = 0
" let g:editqf_store_absolute_filename = 1
"}}}

" vsearch {{{
"
" regex escaping and unescaping using visual selection
xmap <F3>Rex :<C-u>let @z=g:OldFunUnEscapeRegex(g:OldFunUnquoteEscapedRegex(g:OldFunVisual_getText(1)))<CR>gvd"zp
xmap <F3>/rex <Plug>(incsearch-nohl):<C-u>call setreg('/', g:OldFunUnEscapeRegex(g:OldFunUnquoteEscapedRegex(g:OldFunVisual_getText(1))))<CR>:call histadd('search', getreg('/'))<CR><F10>__hl
xmap <F3>/Rex :<C-u>call setreg('/', g:OldFunVisual_getText(1))<CR>:call histadd('search', getreg('/'))<CR><F10>__hl


" Very precious stepwise substitution mapping, relying on column-based pattern to start at cursor, cleaning it up afterwards, working nice with highlights etc
nmap <F3>n m`:s/\%><C-r>=col(".")-1<CR>c<C-r>=g:OldFunCleanColFromPattern(getreg("/"))<CR>/~/&<CR>:call setreg("/", g:OldFunCleanColFromPattern(getreg("/")))<CR>``:set hlsearch<CR>n<Plug>incsearch-nohl-n

" substitute forward (line based)
nmap <F3>s$ :.,$&gc<CR>
nmap <F3>S$ :.,$&g<CR>
nmap <F3>s^ :.,0&gc<CR>
nmap <F3>S^ :.,0&g<CR>

xnoremap <silent> <F3>f :<C-U>call <SID>VSetSearch('/')<CR>/<C-R>/<CR><C-o>
xnoremap <silent> * :<C-U>call <SID>VSetSearch('/')<CR>/<C-R>/<CR><C-o>
nmap <Plug>VLToggle :let g:VeryLiteral = !g:VeryLiteral
  \\| echo "VeryLiteral " . (g:VeryLiteral ? "On" : "Off")<CR>
nmap <F11>vl <Plug>VLToggle 

inoremap <silent> <C-R>/ <C-R>=Del_word_delims()<CR>
cnoremap <C-R>/ <C-R>=Del_word_delims()<CR>

" set gdefault
nnoremap <Leader>g& :%s//~/&c<CR>
command! -nargs=* SP call g:Simleime_fetch(<q-args>."\n")

" single s: identical replacement, double: no replacement, triple: unnamed reg. replacement
xnoremap <F3>s" :s/\V<C-r>"/<C-r>"/<Left>
xnoremap <F3>sw "zy:s/\V<C-r>z/<C-r>z/<Left>
xnoremap <F3>ss" :s/\V<C-r>"//<Left>
xnoremap <F3>ssw "zy:s/\V<C-r>z//<Left>
xnoremap <F3>sss" :s/\V<C-r>"/<C-r>"/<Left>
xnoremap <F3>sssw "zy:s/\V<C-r>z/<C-r>0/<Left>

nnoremap <F3>s" :s/\V<C-r>"/<C-r>"/<Left>
nnoremap <F3>sw "zyiw:s/\V<C-r>z/<C-r>z/<Left>
nnoremap <F3>sW "zyiW:s/\V<C-r>z/<C-r>z/<Left>
nnoremap <F3>ss" :s/\V<C-r>"//<Left>
nnoremap <F3>ssw "zyiw:s/\V<C-r>z//<Left>
nnoremap <F3>ssW "zyiW:s/\V<C-r>z//<Left>
nnoremap <F3>sssw "zyiw:s/\V<C-r>z/<C-r>"/<Left>
nnoremap <F3>sssW "zyiW:s/\V<C-r>z/<C-r>0/<Left>

" yank/paste the next match
nnoremap <F3>/y m`ygn``p<C-R>0
nnoremap <F3>/p m`ygn``p<C-R>0
inoremap <F3>/p <Esc>ygngi<C-R>0

" converts pattern into linewise
cmap <F3>l <Home>\_^.*<End>.*\_$

nnoremap <F3>/y :execute 'CopyMatches '.v:register<CR>
nnoremap <F3>/s :CopyMatches -<CR>
nnoremap <F3>/S :Scratch!<CR>:wincmd p<CR>:CopyMatches -<CR>
nmap <F3>ft :noautocmd vimgrepadd //j **/*.<Left><Left><Left><Left><Left><Left><Left><Left>
nmap <F3>ba :silent! noautocmd bufdo! vimgrepadd //j %<Left><Left><Left><Left>
nmap <F3>bb :noautocmd vimgrepadd //j %<Left><Left><Left><Left>
noremap! <F3>cl <Home>cexpr [] <bar><Space>
noremap! <F3>cl <Home>cexpr [] <bar><Space>

" input and command line stuff for regexes
noremap! <F3>. \_.
noremap! <F3>m \n
noremap! <F3>M \n\s*
noremap! <F3><Home> \_^
noremap! <F3><End> \_$
noremap! <F3>* \{-1,}<Left>

" Plugin to copy matches (search hits which may be multiline).
" Version 2012-05-03 from http://vim.wikia.com/wiki/VimTip478
"
" :CopyMatches      copy matches to clipboard (each match has newline added)
" :CopyMatches x    copy matches to register x
" :CopyMatches X    append matches to register x
" :CopyMatches -    display matches in a scratch buffer (does not copy)
" :CopyMatches pat  (after any of above options) use 'pat' as search pattern
" :CopyMatches!     (with any of above options) insert line numbers
" Same options work with the :CopyLines command (which copies whole lines).

" Jump to first scratch window visible in current tab, or create it.
" This is useful to accumulate results from successive operations.
" Global function that can be called from other scripts.
function! GoScratch()
  normal gs 
  " plugin takes care of that
  return
  " let done = 0
  " for i in range(1, winnr('$'))
  "   execute i . 'wincmd w'
  "   if &buftype == 'nofile'
  "     let done = 1
  "     break
  "   endif
  " endfor
  " if !done
  "   new
  "   setlocal buftype=nofile bufhidden=hide noswapfile
  " endif
endfunction

" Append match, with line number as prefix if wanted.
function! s:Matcher(hits, match, linenums, subline)
  if !empty(a:match)
    let prefix = a:linenums ? printf('%3d  ', a:subline) : ''
    call add(a:hits, prefix . a:match)
  endif
  return a:match
endfunction

" Append line numbers for lines in match to given list.
function! s:MatchLineNums(numlist, match)
  let newlinecount = len(substitute(a:match, '\n\@!.', '', 'g'))
  if a:match =~ "\n$"
    let newlinecount -= 1  " do not copy next line after newline
  endif
  call extend(a:numlist, range(line('.'), line('.') + newlinecount))
  return a:match
endfunction

" Return list of matches for given pattern in given range.
" If 'wholelines' is 1, whole lines containing a match are returned.
" This works with multiline matches.
" Work on a copy of buffer so unforeseen problems don't change it.
" Global function that can be called from other scripts.
function! GetMatches(line1, line2, pattern, wholelines, linenums)
  let savelz = &lazyredraw
  set lazyredraw
  let lines = getline(1, line('$'))
  new
  setlocal buftype=nofile bufhidden=delete noswapfile
  silent put =lines
  1d
  let hits = []
  let sub = a:line1 . ',' . a:line2 . 's/' . escape(a:pattern, '/')
  if a:wholelines
    let numlist = []  " numbers of lines containing a match
    let rep = '/\=s:MatchLineNums(numlist, submatch(0))/e'
  else
    let rep = '/\=s:Matcher(hits, submatch(0), a:linenums, line("."))/e'
  endif
  silent execute sub . rep . (&gdefault ? '' : 'g')
  call OnThisWinFromPrev('wincmd q')
  if a:wholelines
    let last = 0  " number of last copied line, to skip duplicates
    for lnum in numlist
      if lnum > last
        let last = lnum
        let prefix = a:linenums ? printf('%3d  ', lnum) : ''
        call add(hits, prefix . getline(lnum))
      endif
    endfor
  endif
  let &lazyredraw = savelz
  return hits
endfunction

" Copy search matches to a register or a scratch buffer.
" If 'wholelines' is 1, whole lines containing a match are returned.
" Works with multiline matches. Works with a range (default is whole file).
" Search pattern is given in argument, or is the last-used search pattern.
function! s:CopyMatches(bang, line1, line2, args, wholelines)
  let l = matchlist(a:args, '^\%(\([a-zA-Z"*+-]\)\%($\|\s\+\)\)\?\(.*\)')
  let reg = empty(l[1]) ? '+' : l[1]
  let pattern = empty(l[2]) ? @/ : l[2]
  let hits = GetMatches(a:line1, a:line2, pattern, a:wholelines, a:bang)
  let msg = 'No non-empty matches'
  if !empty(hits)
    if reg == '-'
      call GoScratch()
      normal! G0m'
      silent put =hits
      " Jump to first line of hits and scroll to middle.
      ''+1normal! zz
    else
      execute 'let @' . reg . ' = join(hits, "\n") . "\n"'
    endif
    let msg = 'Number of matches: ' . len(hits)
  endif
  redraw  " so message is seen
  echo msg
endfunction
command! -bang -nargs=? -range=% CopyMatches call s:CopyMatches(<bang>0, <line1>, <line2>, <q-args>, 0)
command! -bang -nargs=? -range=% CopyLines call s:CopyMatches(<bang>0, <line1>, <line2>, <q-args>, 1)

" =========== VeryLiteral visual search functions

if !exists('g:VeryLiteral')
  let g:VeryLiteral = 0
endif
function! s:VSetSearch(cmd)
  let old_reg = getreg(g:defaultreg)
  let old_regtype = getregtype('"')
  normal! gvy
  if @@ =~? '^[0-9a-z,_]*$' || @@ =~? '^[0-9a-z ,_]*$' && g:VeryLiteral
    let @/ = @@
  else
    let pat = escape(@@, a:cmd.'\')
    if g:VeryLiteral
      let pat = substitute(pat, '\n', '\\n', 'g')
    else
      let pat = substitute(pat, '^\_s\+', '\\s\\+', '')
      let pat = substitute(pat, '\_s\+$', '\\s\\*', '')
      let pat = substitute(pat, '\_s\+', '\\_s\\+', 'g')
    endif
    let @/ = '\V'.pat
  endif
  normal! gV
  call setreg(g:defaultreg, old_reg, old_regtype)
endfunction

function! Del_word_delims()
   let reg = getreg("/")
   " After *                i^r/ will give me pattern instead of \<pattern\>
   let res = substitute(reg, '^\\<\(.*\)\\>$', '\1', '' )
   if res != reg
      return res
   endif
   " After * on a selection i^r/ will give me pattern instead of \Vpattern
   let res = substitute(reg, '^\\V'          , ''  , '' )
   let res = substitute(res, '\\\\'          , '\\', 'g')
   let res = substitute(res, '\\n'           , '\n', 'g')
   return res
endfunction
" END call Src('rc/vsearch.vim') }}}

" __ DROP{{{

tmap <C-w>,w <C-w>:set winfixwidth<CR>
tmap <C-w>,h <C-w>:set winfixheight<CR>
nmap <C-w>,w <C-w>:set winfixwidth<CR>
nmap <C-w>,h <C-w>:set winfixheight<CR>

" Detabbing
command! Detab %s/\t/    /g


"}}}

" __ SIMPLE STUFF{{{

let g:auto_save = 1

command! Q qa!
"}}}
" __ MAPPINGS{{{

nmap <F10>rcv :source ~/.vim/vimrc<CR>
nmap <F10>rce :e $MYVIMRC<CR>
nmap <F10>rcb :e ~/.bashrc

xmap K "zy'>"zpgv
xmap J "zy'<"zPgv

nmap ,J <C-w>j:q<CR>
nmap ,K <C-w>k:q<CR>
nmap ,H <C-w>h:q<CR>
nmap ,L <C-w>l:q<CR>
nmap ,j :sp<CR><C-w>j
nmap ,k :sp<CR>
nmap ,h :vs<CR>
nmap ,l :vs<CR><C-w>l
nmap ,x :q<CR>

nmap <F10>s :Obsession! ~/.vimsession<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left>
nmap <F10>S :source ~/*.vimsession


"}}}
" __ STANDARDMAPS{{{

nnoremap <F5><F5> :checktime<CR>
nmap <silent> g" :Regtrim<CR>

" TODO: alt-l " inoremap <silent> l <Esc>:call cursor(line('.'), col("'^"))<CR>

" C-r maps, I had problems with this once{{{
nmap <C-m> <CR>
omap <C-m> <CR>
xmap <C-m> <CR>
imap <C-m> <CR>
cmap <C-m> <CR>
smap <C-m> <Tab>
"}}}
" > and < for default , and ;{{{
nnoremap > ;
nnoremap < ,
xnoremap > ;
xnoremap < ,
"}}}
" remapping backtick and single quote for marks{{{
nnoremap ' `
nnoremap ` '
onoremap ' `
onoremap ` '
"}}}
"Command line related{{{
cnoremap <F10>< '<,'>
"}}}
"Macros{{{

"}}}
" tab navigatrion from terminal{{{
tmap <C-PageUp> <C-w>:tabp<CR>
tmap <C-PageDown> <C-w>:tabn<CR>
"}}}


xmap <Home> ^
nmap <Home> ^
omap <Home> ^
imap <Home> <C-o>^
xmap <End> $h

" Tab indent/dedent/justifying{{{
nnoremap <C-t>k >
xnoremap <C-t>k >gv
nnoremap <C-t>j <
xnoremap <C-t>j <gv
nmap <C-t>l =
xmap <C-t>l =
"paste autoindent
nmap <C-t>p =gb
"}}}


imap <Insert>o <C-o>o
imap <Insert>O <C-o>O
imap <Insert>go <F10>o
imap <Insert>gO <F10>O
map! <Insert>e <space>=<space>
map! <Insert><Up> <Insert>e


nnoremap ;w :setl wrap!<CR>
nnoremap <silent><expr> ;h (&hls && v:hlsearch ? ':nohls' : ':set hls')."\n"

" Inline file{{{
" TODO: make operator
xmap <F10>if "zy<Esc>"xyil:Commentary<CR>A {{{<CR><Esc>mzjmx'z:read <C-r>z<CR>'x
xmap <F10>iF <F10>ifi<CR><Up>END <C-o>"xp<End> }}}<Esc>:Commentary<CR>
"}}}
"}}}
" __ DIRVISH{{{

fun! DirvishSortPass() abort
    normal! $"xyl
    if @x == "/"
        if ! empty(@z)
            normal! "Zdd
        else
            normal! "zdd
        endif
    endif
endf
fun! DirvishSort() abort
    let @z=""
    g:.:call DirvishSortPass()
    if ! empty(@z)
        normal! gg"zP
    endif
    g:.:normal! $F/ld0
endf


" fun! _Dirvish_LCD() abort
"     if ! exists("w:dirvish_pre_lcd")
"         let w:dirvish_pre_lcd = getcwd()
"     endif
" endf
" fun! _Dirvish_LCD_back() abort
"     exec print("%s", w:dirvish_pre_lcd)

" endf

augroup dirvish_config
  autocmd!

    autocmd FileType dirvish nnoremap <silent><buffer>
    \   gh :silent keeppatterns g@\v/\.[^\/]+/?$@d _<cr>
    \|  nnoremap <silent><buffer> t :call dirvish#open('tabedit', 0)<CR>
    \|  nmap <buffer> r R
    \|  nmap <buffer> <Leader>cd :cd %<CR>R:pwd<CR>
    \|  nmap <buffer> <Leader>ed :e %
    \|  nmap <buffer> <Leader>md :Mkdir %
    \|  nmap <buffer> <Leader>~ :e $HOME/<CR>
    \|  nmap <buffer> <Leader>// :e /<CR>
    \|  nmap <buffer> <Leader><cr> :Viewer <C-R><C-a><CR>
    \|  nmap <buffer> <Leader><CR> :Viewer <C-R><C-a><CR>
    \|  nmap <buffer> <Leader><C-g> :Grepper -dir file<CR>
    \|  nnoremap <buffer> q q
    \|  nnoremap <F10><Space> :TS -cwd=<C-r>=expand("%:p:h")<CR><CR>
    \|  nnoremap <Leader>gd :e <C-r>=getcwd(-1)<CR><CR>

    autocmd VimEnter * if exists('#FileExplorer') | exe 'au! FileExplorer *' | endif
augroup END

let g:dirvish_relative_paths=0

" execute shdo command window
nmap <Leader><Leader>x Z!
"}}}
" __ Scratch{{{

let g:scratch_autohide = 0
let g:scratch_insert_autohide = 0
" let g:scratch_filetype = 'sh'
let g:scratch_height = 10
let g:scratch_top = 1
let g:scratch_horizontal = 1 " TODO: toggle

let g:scratch_persistence_file = '.scratch'
let g:scratch_persistence_always = 1
" if empty('g:scratch_persistence_file')
"     let g:scratch_persistence_file = ''
" endif

let g:scratch_no_mappings = 1
nnoremap <Leader>gs; :ScratchPreview<CR>
nnoremap <Leader>gss :Scratch<CR>
nnoremap <F11>sc :let g:scratch_autohide=!g:scratch_autohide <bar> echo 'Scratch autohide: '.g:scratch_autohide<CR>:ScratchPreview<CR>:ScratchPreview<CR><C-w>p

nmap <Leader>gs :Scratch<CR><C-w>p
nmap gs :Scratch<CR>
nmap gS :Scratch!<CR>
xmap <Leader>gs <plug>(scratch-selection-reuse)<C-w>p
xmap gs <plug>(scratch-selection-reuse)
xmap gS <plug>(scratch-selection-clear)
"}}}
" __ TABS{{{

set clipboard^=unnamed,unnamedplus
let g:defaultreg = '+'
set clipboard=unnamedplus

filetype plugin indent on
" show existing tab with 4 spaces width
set tabstop=4
" when indenting with '>', use 4 spaces width
set shiftwidth=4
" On pressing tab, insert 4 spaces
set expandtab
"}}}
" __ easyclip{{{

let g:EasyClipShareYanks = 1 " TODO: reenable easyclip yank sharing as soon as issue is resolved.
let g:EasyClipUsePasteDefaults = 0
let g:EasyClipUsePasteToggleDefaults = 0
let g:EasyClipUseCutDefaults = 0
nnoremap <Insert>p :IPaste<CR>
inoremap <Insert>p <C-o>:IPaste<CR>
nnoremap <Del> "_x
nmap Y y$
nmap x <Plug>MoveMotionPlug
xmap x <Plug>MoveMotionXPlug
nmap xx <Plug>MoveMotionLinePlug
nmap X <Plug>MoveMotionEndOfLinePlug

"}}}
" __ TARGETS{{{

" https://github.com/wellle/targets.vim/blob/master/cheatsheet.md

let g:targets_nl = 'nN'
let g:targets_aiAI = 'aIAi'
" let g:targets_aiAI = 'akAI'
" let g:targets_mapped_aiAI = 'aiAI'

" Never seek backwards:
let g:targets_seekRanges = 'cc cr cb cB lc ac Ac lr rr lb ar ab lB Ar aB Ab AB rb rB bb bB BB'


augroup targets_ext
    au!
    autocmd User targets#mappings#user call targets#mappings#extend({
        \ 'd': {'pair': [{'o':'(', 'c':')'}, {'o':'[', 'c':']'}, {'o':'{', 'c':'}'}]}
        \ })
        " \ 'f': {'quote': [{'d':"'"}, {'d':'"'}, {'d':'`'}]},
augroup end
"     \ 's': { 'separator': [{'d':','}, {'d':'.'}, {'d':';'}, {'d':':'}, {'d':'+'}, {'d':'-'},
"     \                      {'d':'='}, {'d':'~'}, {'d':'_'}, {'d':'*'}, {'d':'#'}, {'d':'/'},
"     \                      {'d':'\'}, {'d':'|'}, {'d':'&'}, {'d':'$'}] },
"     \ '@': {
"     \     'separator': [{'d':','}, {'d':'.'}, {'d':';'}, {'d':':'}, {'d':'+'}, {'d':'-'},
"     \                   {'d':'='}, {'d':'~'}, {'d':'_'}, {'d':'*'}, {'d':'#'}, {'d':'/'},
"     \                   {'d':'\'}, {'d':'|'}, {'d':'&'}, {'d':'$'}],
"     \     'pair':      [{'o':'(', 'c':')'}, {'o':'[', 'c':']'}, {'o':'{', 'c':'}'}, {'o':'<', 'c':'>'}],
"     \     'quote':     [{'d':"'"}, {'d':'"'}, {'d':'`'}],
"     \     'tag':       [{}],
"     \     },
"     \ })
" only if not inside target
" let g:targets_jumpRanges = 'cr cb cB lc ac Ac lr rr ll lb ar ab lB Ar aB Ab AB rb al rB Al bb aa bB Aa BB AA'
"

"}}}
" __ TEXTOBJECTS{{{

" switching "inclusive" for backward motion
omap <BS> v

" ia, aa (textobj_parameter)
let g:vim_textobj_parameter_mapping = 'a'

" last textobject repeat
omap <silent> ,. :<C-u>exe "normal! v`]o`["<CR>
xmap <silent> ,. `]o`[
" last visual selection
omap <Leader>v :normal! gv<CR>
nmap <Leader>v gv
" paste text object
omap <leader><leader>v :normal vgb<CR>
nmap <leader><leader>v vgb

nmap <Insert><Insert> <Plug>(operator-replace)
"}}}
" __ FZF{{{

if ! empty('g:_fzf_path_added')
    let g:_fzf_path_added=1
    let $PATH=expand("$PATH").":".expand("~/.vim/pack/standalone/start/fzf-master/bin")
endif

imap <Insert>L <plug>(fzf-complete-line)
nnoremap <silent> ;;e :Files<CR>
nnoremap ;;b :Buffers<CR>
nnoremap ;;l :BLines<CR>
nnoremap ;;L :Lines<CR>
nnoremap ;;t :BTags<CR>
nnoremap ;;T :Tags<CR>
nnoremap ;;c :Commands<CR>
nnoremap ;;m :Maps<CR>
nnoremap ;;s :Snippets<CR>
nnoremap ;;h :Helptags<CR>
nnoremap ;;y :Filetypes<CR>
"}}}
" __ FOLDING{{{

command! -nargs=0 Marker call ApplyMarkerFolding()
fun! ApplyMarkerFolding() abort
    set fdm=marker
    FastFoldUpdate
    exec "normal zx"
    FastFoldUpdate!
endf

" Plugin: Fastfold
" regarding simpylFold, auto-on-save interrupts vim-schlepp...
let g:fastfold_savehook = 0
let g:fastfold_fold_command_suffixes =  ['x','X']
let g:fastfold_fold_movement_commands = []

nmap z? :FastFoldUpdate!<CR>
nmap z<Home> zR
nmap z<End> zM
" Update fold mapping with revealing the current code, all else folded
nmap zuZ :FastFoldUpdate<CR>zM:sleep 200m<CR>zr:sleep 200m<CR>zvzz
nmap zuz :FastFoldUpdate<CR>
let g:searchFoldMayResetToGlobal = 0
nmap zuu <Plug>SearchFoldRestorezuz

" Default Searchfold
let g:searchfold_do_maps = 0
nmap <Leader>z   <Plug>SearchFoldNormal
"}}}
" __ BASIC SETTINGS{{{

set timeoutlen=2000
set textwidth=0

set history=5000
set viminfo^=/5000

" This has to be the last viminfo entry as per documentation of the 'n' option!
" TODO: refactoring where does the viminfo file get set? better leave it
" global, for now, eh...
" TODO: cfg

set smartcase
set ignorecase
set modeline
set modelines=8

filetype plugin indent on
set nobackup
set fileformats=unix,dos,mac
set noswapfile
set splitbelow
set splitright
set ttyfast
set smartindent
set showcmd
set backspace=indent,eol,start
set showtabline=2
set hidden
"" Encoding
set encoding=utf-8
set fileencodings=utf-8
" set bomb
set ttyfast

"" Tabs. May be overriten by autocmd rules
set expandtab
set tabstop=4
set softtabstop=0
set shiftwidth=4
set expandtab
set list listchars=tab:→\ ,trail:·
"}}}
" __ APPEARANCE{{{

set laststatus=2
"" Disable the blinking cursor.
set gcr=a:blinkon0
set scrolloff=3
" set textwidth=79
set wildmenu
" set wildmode=longest,list


" IndentLine
let g:indentLine_enabled = 1
let g:indentLine_concealcursor = 0
let g:indentLine_char = '┆'
let g:indentLine_faster = 0 "TODO: lol. 'may bring little issue with it' when 1

set number
" show active line only for the active window 
augroup CursorLine
    au!
    au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
    au WinLeave * setlocal nocursorline
augroup END

noh

" Color Scheme

" COLORS
" set termguicolors
let g:CSApprox_loaded = 1

if $COLORTERM == 'gnome-terminal'
    set term=gnome-256color
else
    if $TERM == 'xterm'
    set term=xterm-256color
    endif
endif
let g:solarized_termcolors=256


" needed?
set t_Co=256
if !exists("g:syntax_on")
    syntax enable
endif

" DEFAULT THEME
    " set background=light
    " colorscheme default " not bad actually in light variant

    " Background transparent hack
    " hi Normal guibg=NONE ctermbg=NONE

set background=light
colorscheme PaperColor " solarized8
"}}}
" __ EASYMOTION{{{

let g:EasyMotion_startofline=1
let g:EasyMotion_do_shade=0
let g:EasyMotion_enter_jump_first = 1
let g:EasyMotion_use_upper = 1
let g:EasyMotion_use_upper = 1
let g:EasyMotion_keys = 'ASDFGHJKLQWERTYUIOPZXCVBNM'
hi link EasyMotionMoveHL Search
hi link EasyMotionIncSearch Search
let g:EasyMotion_move_highlight = 1

"""""""""""""""""""""""""""""
"  normal VIM motion stuff  "
"""""""""""""""""""""""""""""
" TODO candidate for statemachine stuff to unify

" TODO: ,swp does something....


nmap <Leader>s         <Plug>(easymotion-s2)
nmap <Leader>S <Plug>(easymotion-sn)
xmap <Leader>s         <Plug>(easymotion-s2)
xmap <Leader>S <Plug>(easymotion-sn)
omap <Leader>s <Plug>(easymotion-s2)
omap <Leader>S <Plug>(easymotion-sn)
" omap <Leader>z <Plug>(easymotion-sn)

" Bidirectional easymotions, shifted = whole buf 

nmap  <Leader>t <Plug>(easymotion-bd-tl)
omap  <Leader>t <Plug>(easymotion-bd-tl)
xmap  <Leader>t <Plug>(easymotion-bd-tl)

"TODO: make uniform EM mappings
" nmap  <Leader>T <Plug>(easymotion-bd-t)
" omap  <Leader>T <Plug>(easymotion-bd-t)
" map  <Leader>f <Plug>(easymotion-bd-fl)
" omap  <Leader>f <Plug>(easymotion-bd-fl)
" map  <Leader>F <Plug>(easymotion-bd-f)
" omap  <Leader>F <Plug>(easymotion-bd-f)
" map  <Leader>w <Plug>(easymotion-bd-wl)
" omap  <Leader>w <Plug>(easymotion-bd-wl)
" map  <Leader>W <Plug>(easymotion-bd-w)
" omap  <Leader>W <Plug>(easymotion-bd-w)
" map  <Leader>e <Plug>(easymotion-bd-el)
" omap  <Leader>e <Plug>(easymotion-bd-el)
" map  <Leader>E <Plug>(easymotion-bd-e)
" omap  <Leader>E <Plug>(easymotion-bd-e)
" map  <Leader>ge <Plug>(easymotion-bd-el)
" omap  <Leader>e <Plug>(easymotion-bd-el)
" map  <Leader>E <Plug>(easymotion-bd-e)
" omap  <Leader>E <Plug>(easymotion-bd-e)


" half as fast PgUp/down events
nnoremap <PageUp> <C-u>
nnoremap <PageDown> <C-d>

nnoremap z<PageUp> zb
nnoremap z<PageDown> zt
xnoremap z<PageUp> <Esc>'>zbgv
xnoremap z<PageDown> <Esc>'<ztgv

" Linemovements: with repos and without

" xmap <Insert> <Plug>(easymotion-sol-bd-jk)
" omap <Insert> <Plug>(easymotion-sol-bd-jk)
" nmap <Insert> <Plug>(easymotion-sol-bd-jk)
xmap <Up> <Plug>(easymotion-sol-k)
omap <Up> <Plug>(easymotion-sol-k)
nmap <Up> <Plug>(easymotion-sol-k)
xmap <Down> <Plug>(easymotion-sol-j)
omap <Down> <Plug>(easymotion-sol-j)
nmap <Down> <Plug>(easymotion-sol-j)

" xmap <Leader><Insert> <Esc>zz:call feedkeys("gv\<Plug>(easymotion-sol-bd-jk)")<CR>
" nmap <Leader><Insert> zz:call feedkeys("\<Plug>(easymotion-sol-bd-jk)")<CR>
xmap ;;<Up> <Esc>zb:call feedkeys("gv\<Plug>(easymotion-sol-k)")<CR>
nmap ;;<Up> zb:call feedkeys("\<Plug>(easymotion-sol-k)")<CR>
xmap ;;<Down> <Esc>zt:call feedkeys("gv\<Plug>(easymotion-sol-j)")<CR>
nmap ;;<Down> zt:call feedkeys("\<Plug>(easymotion-sol-j)")<CR>


" 
" vmap <Leader><Home> <Plug>(easymotion-sol-bd-jk)
" omap <Leader><Home> <Plug>(easymotion-sol-bd-jk)
" nmap <Leader><Home> <Plug>(easymotion-sol-bd-jk)


set hlsearch " DO NOT DISABLE
let g:incsearch#auto_nohlsearch = 1
omap n  <Plug>(incsearch-nohl-n)
xmap n  <Plug>(incsearch-nohl-n)
nmap n  <Plug>(incsearch-nohl-n)

omap N  <Plug>(incsearch-nohl-N)
xmap N  <Plug>(incsearch-nohl-N)
nmap N  <Plug>(incsearch-nohl-N)

" incsearch + easymotion
" 
" omap <Leader>/ m`<Plug>(incsearch-easymotion-stay)
" xmap <Leader>/ m`<Plug>(incsearch-easymotion-stay)
" nmap <Leader>/ m`<Plug>(incsearch-easymotion-stay)

" Workaround:
" TODO: works, but maybe get incsearch working? Workarounds for not using the incsearch commandsline
" this invokes vanilla search, see mapping above
nnoremap <F10>__search /
" This can be maaped to by something that wants to have highlight but vanish on movement
nmap <F10>__hl :set hlsearch<CR><Plug>(incsearch-nohl0)
" nmap <silent> <F10>__hl :keepj exec "normal m`\<Plug>(incsearch-nohl-n)``"<CR>

"}}}
" __ SURROUND{{{

" Surround
let g:surround_no_insert_mappings=1

nmap <C-g> ys
xmap <C-g> <Plug>VSurround
imap <C-g> <Plug>Isurround
omap <C-g> :normal gvhol<CR>

imap <C-g>( <C-g>)
imap <C-g>[ <C-g>]
imap <C-g>{ <C-g>}
imap <C-g><Space> <C-g><Space><Space>

cnoremap <C-g>' ''<Left>
cnoremap <C-g>" ""<Left>
cnoremap <C-g>) ()<Left>
cnoremap <C-g>] []<Left>
cnoremap <C-g>} {}<Left>
cnoremap <C-g>> <lt>><Left>
tnoremap <C-g>' ''<Left>
tnoremap <C-g>" ""<Left>
tnoremap <C-g>) ()<Left>
tnoremap <C-g>] []<Left>
tnoremap <C-g>} {}<Left>
imap <Insert> <nop>

map! <Insert><Space> <Space><Space><Left>
map! <Insert><Insert> ()<Left>
map! <Insert><Home> []<Left>
map! <Insert><PageUp> {}<Left>
map! <Insert><PageDown> <lt>><Left>
map! <Insert>' ''<Left>
map! <Insert><Bs> ""<Left>
map! <Insert><Del> <Del><Bs>
smap <Insert> <Del><Insert>
"}}}
" __ WINMOVEMENT{{{

nmap <C-w>P :b#<CR>
tmap <C-w>P <C-w>:b#<CR>

nnoremap <Leader><Leader><Leader>l :call g:MoveToNextTab()<CR>
nnoremap <Leader><Leader><Leader>h :call g:MoveToPrevTab()<CR>
nmap <Leader><Leader><Leader>L :sp<CR>:call g:MoveToNextTab()<CR>
nmap <Leader><Leader><Leader>H :sp<CR>:call g:MoveToPrevTab()<CR>

"""""""""""""""""""""""""""""""""""""""""""
"  fast splitting and moving and closing  "
"""""""""""""""""""""""""""""""""""""""""""
nmap <Leader>x :q<CR>
nmap <silent> <Leader>X :q!<CR>


" undo :q
let g:undoquit_mapping = '<C-w>u'
let g:tradewinds_no_maps = 1

" window movement
" swapping

nmap <Leader><Leader>j <C-w>j<C-w>:call g:WinBufSwap()<CR>
nmap <Leader><Leader>k <C-w>k<C-w>:call g:WinBufSwap()<CR>
nmap <Leader><Leader>l <C-w>l<C-w>:call g:WinBufSwap()<CR>
nmap <Leader><Leader>h <C-w>h<C-w>:call g:WinBufSwap()<CR>
" soft move (tradewinds plugin)
nmap <leader><Leader>H <plug>(tradewinds-h)
nmap <leader><Leader>J <plug>(tradewinds-j)
nmap <leader><Leader>K <plug>(tradewinds-k)
nmap <leader><Leader>L <plug>(tradewinds-l)
" simply splitting the same buffer in the 4 directions (2 dir + stay or move)
nmap <Leader>j :sp<CR>
nmap <Leader>k :sp<CR><C-w>k
nmap <Leader>l :vs<CR>
nmap <Leader>h :vs<CR><C-w>h
" -- and deleting in 4 directions
nmap <Leader>H <C-w>h:call OnThisWinFromPrev('wincmd q')<CR>
nmap <Leader>J <C-w>j:call OnThisWinFromPrev('wincmd q')<CR>
nmap <Leader>K <C-w>k:call OnThisWinFromPrev('wincmd q')<CR>
nmap <Leader>L <C-w>l:call OnThisWinFromPrev('wincmd q')<CR>

nmap <Leader>n :enew<CR>

" TODO: elsewhere
nmap <F10>d? :echo 'pwd: '.getcwd().' <bar> -1wd: ' . getcwd(-1)<CR>
nmap <F10>d! :ResetCWD<CR>:pwd<CR>

" Resizing:

nmap <silent> <C-w><Up> :12CmdResizeUp<CR>
nmap <silent> <C-w><Down> :12CmdResizeDown<CR>
nmap <silent> <C-w><Left> :12CmdResizeLeft<CR>
nmap <silent> <C-w><Right> :12CmdResizeRight<CR>
nmap <silent> <C-w><C-Up> :12CmdResizeUp<CR>
nmap <silent> <C-w><C-Down> :12CmdResizeDown<CR>
nmap <silent> <C-w><C-Left> :12CmdResizeLeft<CR>
nmap <silent> <C-w><C-r> :12CmdResizeLeft<CR>
nmap <silent> <C-w><C-Right> :12CmdResizeRight<CR>
tmap <silent> <C-w><Up> <C-w>:12CmdResizeUp<CR>
tmap <silent> <C-w><Down> <C-w>:12CmdResizeDown<CR>
tmap <silent> <C-w><Left> <C-w>:12CmdResizeLeft<CR>
tmap <silent> <C-w><Right> <C-w>:12CmdResizeRight<CR>
tmap <silent> <C-w><C-Up> <C-w>:12CmdResizeUp<CR>
tmap <silent> <C-w><C-Down> <C-w>:12CmdResizeDown<CR>
tmap <silent> <C-w><C-Left> <C-w>:12CmdResizeLeft<CR>
tmap <silent> <C-w><C-r> <C-w>:12CmdResizeLeft<CR>
tmap <silent> <C-w><C-Right> <C-w>:12CmdResizeRight<CR>

if !exists('g:shrinkInit')
    let g:shrinkInit = 15
endif
command! -nargs=1 PreserveWin call WithWinPreservedEval(<q-args>)

" Ordered list of commands to resize
let g:resizespec = [ 
            \ ['main', 'call GetNormalWincmd("_")'], 
            \ ['qf', 'CResize'],
            \ ['regular', 'Shrink']
            \]
" Resizing_Indexes:how the idxes are determined:
fun! ResizeRoutineIdx(winnr) abort
    let info = g:OldFunWin_get(a:winnr)
    let mark = 'notouch'
    if info.isTerm()
        return mark
    endif
   
    let mark = 'qf'
    if info.qftype() > 0 
        return mark
    endif

    if g:mainWin.winid == info.winid
        return 'main'
    endif

    return 'regular'
endfun


nmap  <C-w>;  <Plug>(choosewin)
tmap <C-w>; <C-w>:ChooseWin<CR>
let g:choosewin_overlay_enable = 0


"""""""""""""""""""""""
"  support functions  "
"""""""""""""""""""""""


fun! GetNormalWincmd(cmd, ...) abort
    let mycount=get(a:, 1, '')
    let fmt = "normal! %2\<C-w>%1"
    return lh#fmt#printf(fmt, a:cmd, mycount)
endf
fun! ExecNormalWincmd(cmd, ...) abort
    exec call('GetNormalWincmd', [a:cmd] + a:000)
endf
" TODO: rather ...Exec // make both variants?
fun! WithWinPreservedEval(cmd) abort
    let wdot = g:OldFunWin_get()
    let whash = g:OldFunWin_get(winnr('#'))
    try
        exec a:cmd
    finally
        " let wdotnow = g:OldFunWin_get()
        " let whashnow = g:OldFunWin_get(winnr('#'))
        " if wdot.winid != wdotnow.winid || whash.winid != whashnow.winid
        "     wdotnow
        " endif
        call whash.jump()
        call wdot.jump()
    endtry

endf
fun! OnThisWinFromPrev(execstring) abort
    let curwin = winnr()
    wincmd p
        let pwin = winnr()
    let pwinid = win_getid(pwin)
    exec curwin.'wincmd w'
    exec a:execstring
    let nowpwin = win_id2win(pwinid)
    exec printf('%swincmd w', nowpwin)
endf


function! g:WinBufSwap()
  let thiswin = winnr()
  let thisbuf = bufnr("%")
  let lastwin = winnr("#")
  let lastbuf = winbufnr(lastwin)

  exec  lastwin . " wincmd w" ."|".
      \ "buffer ". thisbuf ."|".
      \ thiswin ." wincmd w" ."|".
      \ "buffer ". lastbuf
endfunction
function! g:MoveToPrevTab()
  "there is only one window
  if tabpagenr('$') == 1 && winnr('$') == 1
    return
  endif
  "preparing new window
  let l:tab_nr = tabpagenr('$')
  let l:cur_buf = bufnr('%')
  if tabpagenr() != 1
    close!
    if l:tab_nr == tabpagenr('$')
      tabprev
    endif
    sp
  else
    close!
    exe "0tabnew"
  endif
  "opening current buffer in new window
  exe "b".l:cur_buf
endfunc
function! g:MoveToNextTab()
  "there is only one window
  if tabpagenr('$') == 1 && winnr('$') == 1
    return
  endif
  "preparing new window
  let l:tab_nr = tabpagenr('$')
  let l:cur_buf = bufnr('%')
  if tabpagenr() < tab_nr
    close!
    if l:tab_nr == tabpagenr('$')
      tabnext
    endif
    sp
  else
    close!
    tabnew
  endif
  "opening current buffer in new window
  exe "b".l:cur_buf
endfunc
"}}}
" __ TERMINAL_API{{{

" TODO: general purpose command to set jumpmark
command! -bar -nargs=0 Markj exec "normal! m`"

" TODO: refactor: move somewhere
set cpoptions-=a

" :read !... replacement; t: tempfile, s: scratch buffer, without: current buffer
command! -nargs=1               Rt      Markj | exec "e ".tempname() | call _ReadImpl(<f-args>, 'normal ggdd')
command! -nargs=1               Rs      Markj | enew | setlocal buftype=nofile | setlocal bufhidden=hide | setlocal noswapfile | call _ReadImpl(<f-args>, 'normal ggdd', 'let linenoSelStart=1', 'let select=0')
command! -nargs=1               R       Markj | call _ReadImpl(<f-args>, 'let select=1')

" $SHELL terminal
command! -bang -nargs=+         TS                     call _Term_Impl_FromCmd(expand("$SHELL"), {"bang":<bang>0}, <f-args>)

" Vidir
command! -nargs=0               Vid                    Term! vidir
command! -nargs=0 -range        RVid    <line1>,<line2>RTerm! vidir -

" Term interaction
command! -bang -nargs=+         Term                   call _Term_Impl_FromCmd(<q-args>, {"bang":<bang>0}, <f-args>)
command! -bang -range -nargs=+  RTerm   <line1>,<line2>call _RTerm_Impl_FromCmd(<q-args>, {"bang":<bang>0}, <f-args>)

command! -bang -nargs=+         TermS                  call _Term_Impl_FromCmd(_Shellcall(<q-args>), {"bang":<bang>0})
command! -bang -range -nargs=+  RTermS  <line1>,<line2>call _RTerm_Impl_FromCmd(_Shellcall(<q-args>), {"bang":<bang>0})

" clone a finished terminal buffer
command! -nargs=? TClone call _TCloneImpl(<f-args>)

" TODO: commands to make a finished terminal buffer stay
" setlocal nomodifiable | setlocal buftype=nofile | setlocal readonly | setlocal nobuflisted | setlocal bufhidden= | setlocal noswapfile

" !TODO: when returning to a window from closed terminal buffer, restore alt buffer (when it would inevitably erase it b/c the terminal buffer will be deleted).
" This more and more takes the form of a "tethered to the calling buffer" type of command
" could be useful for parsing a loclist from errors for quick tests, or clist for more global use cases

" Read command implementation
fun! _ReadImpl(command, ...) abort
    let linenoBefore=line('.')
    let linenoSelStart=linenoBefore
    let linenoSelEnd=linenoBefore

    let afterCmds=a:000
    let select=0

    exec 'read !'.a:command
    let linenoAfter=line('.')
    if linenoAfter != linenoBefore
        let linenoSelStart=linenoBefore+1
        let linenoSelEnd=linenoAfter
    endif

    for cmd in afterCmds
        exec cmd
    endfor

    if select
        call cursor(linenoSelEnd, 1)
        normal! V
        call cursor(linenoSelStart, 1)
    endif
endf
" TClone Implementation
fun! _TCloneImpl(...) abort
    let cmds= a:0 == 0 ? ['enew'] : a:000
    let altbuf=bufnr('#')
    let tmpfile = tempname()
    exec printf('w! %s', tmpfile)
    exec altbuf.'b'
    for cmd in cmds
        exec cmd
    endfor
    exec printf('r %s', tmpfile)
    1d_
endf
" Term Command Implementations
fun! _ParseCmdArgs(args) abort
    let result={}
    let result.positional=[]
    for arg in a:args
        if stridx(arg, "-") == 0
            let arg=arg[1:]
            if stridx(arg, "=") > -1
                let until=stridx(arg, "=")-1
                let start=stridx(arg, "=")+1
                let key=arg[0:until]
                let val=arg[start:]
                let result[key]=val
            else
                let result[arg]=1
            endif
        else
            let result.positional = result.positional + [arg]
        endif
    endfor
    return result
endf
fun! _Term_Impl_FromCmd(qargs, opts, ...) abort
    let opts_extended=copy(a:opts)
    echom string(_ParseCmdArgs(a:000))
    call extend(opts_extended, _ParseCmdArgs(a:000))
    return _Term_Impl(a:qargs, opts_extended)
endf
fun! _RTerm_Impl_FromCmd(qargs, opts, ...) abort
    let opts_extended=copy(a:opts)
    call extend(opts_extended, _ParseCmdArgs(a:000))
    return _RTerm_Impl(a:qargs, opts_extended)
endf
fun! _Term_Impl(qargs, opts) abort
    let optbuilder = {}
    let callbackbuilder = []

    if has_key(a:opts, 'cwd')
        call extend(optbuilder, {"cwd": a:opts.cwd})
    endif
    if get(a:opts, "bang", 0)
        call add(callbackbuilder, 'call _TermAction_Postexit()')
    endif
    return call ('TermInteractAdhoc', [a:qargs, optbuilder] + callbackbuilder)
endf
fun! _RTerm_Impl(qargs, opts) abort range
    let optbuilder = {}
    let callbackbuilder = []
    call extend(optbuilder,  _TermInteractRangeIOOpts(a:firstline, a:lastline, winbufnr(winnr())) )

    if has_key(a:opts, 'cwd')
        call extend(optbuilder, {"cwd": a:opts.cwd})
    endif
    if get(a:opts, "bang", 0)
        call add(callbackbuilder, 'call _TermAction_Postexit()')
    endif
    return call ('TermInteractAdhoc', [a:qargs, optbuilder] + callbackbuilder)
endf

" Terminal interaction with optional callbacks
" TODO: isolate concurrent calls! Only 1 at a time is now valid.
fun! TermInteractAdhoc(call, options, ...) abort range
    normal! m`

    let postcmds=[]
    call add(postcmds, 'map <buffer> <F10>c :TCloned<CR>')
    let g:_termcmd_callback = postcmds + a:000

    let opts=empty(a:options)? {} : a:options
    let mergedopts = extend(
                \ {
                \ "curwin": 1,
                \ "cwd" : getcwd(), 
                \ 
                \   'exit_cb':'_TermInteractExitCb',
                \   "close_cb": "_TermInteractCloseCb",
                \ }, opts)

    call term_start(a:call, mergedopts)
endf

" Callbacks from vim
fun! _TermInteractExitCb(job,exitstatus) abort
    let g:_termcmd_exit=[a:job, a:exitstatus]
endf
fun! _TermInteractCloseCb(channel) abort
    let g:_termcmd_closed_channel=a:channel
    if ! empty(g:_termcmd_callback)
        for cmd in g:_termcmd_callback
            execute cmd
        endfor
    endif
endf

" line range from buffer: (line1:'<, line2:'>, bufnr: winbufnr(winnr()))
fun! _TermInteractRangeIOOpts(...) abort
    let line1=get(a:, 1, line("'<"))
    let line2=get(a:, 2, line("'>"))
    let bufnr=get(a:, 3, winbufnr(winnr()))
    return {
                \ "in_io": "buffer"
                \ , "in_top":line1
                \ , "in_bot":line2
                \ , "in_buf":winbufnr(winnr())
                \ }
endf

" constructs a tempfile with the command and feeds it to bash
fun! _Shellcall(shellcmd)
    let tmpfile=tempname()
    call writefile([a:shellcmd], tmpfile)
    return [expand("$SHELL"), tmpfile]
endf

" hand-tuned commands to return from finished terminal buffer to alternate buffer; Dirvish accommodations
" TODO: only works correctly when process terminates and window would keep
" open. not with :bdelete and the like!
fun! _TermAction_Postexit() abort
    " if g:_terminteract_noclose
    "     return
    " endif
    " if 
        
    " endif
" setlocal nomodifiable | setlocal buftype=nofile | setlocal readonly | setlocal nobuflisted | setlocal bufhidden= | setlocal noswapfile
    exec "normal! \<C-o>"
    silent! call feedkeys("\<Esc>")

    if getbufvar('%', '&filetype') ==# 'dirvish'
        Dirvish %
    endif
    redraw!
endf
"}}}
" __ TERMINAL{{{

nmap <F10><Space> :TS -cwd=<C-r>=fnameescape(getcwd())<CR><CR>
nmap <F10><F10><Space> :TS -cwd=<C-r>=fnameescape(expand("%:p:h"))<CR><CR>

tmap <C-w><C-n><C-n> <C-w>:let @x=@+<CR><C-w>:let @z="pwd <bar> xcl -i"<CR><C-w>"z<CR><C-w>:TS<CR><C-w>:let @z="cd ".@+<CR><C-w>:let @+=@x<CR>
tmap <C-w><C-n><C-p> <C-w>"z

tmap <Plug>(easymotion-prefix) <Nop>

au BufRead,BufNewFile *.rc set filetype=sh

augroup TerminalStuff
    au! 
    au TerminalOpen * if &buftype == 'terminal' | setlocal nonumber
augroup END
"}}}
" Font Functions{{{

function! g:Font_GetCurrentFonts() abort
    if(exists('g:_Font_Current'))
        return g:_Font_Current
    else
        throw "parsing fonts from guifont not yet implemented"
    endif
endf
function! g:Font_SetCurrentFonts(fontspecs) abort
    let g:_Font_Current=a:fontspecs
    let generated_spec = g:Font_MakeGuifontString(a:fontspecs)
    " let &guifont=generated_spec
    execute printf('set guifont=%s', generated_spec)
endf
function! g:Font_MakeGuifontString(fontspecs) abort
    let guifontrepr=""
    for spec in a:fontspecs
        let fontname_escaped=substitute(spec["name"], ' ', '\\ ', 'g')
        if ! empty(guifontrepr)
            let guifontrepr .= ","
        endif
        if(has("x11"))
            let guifontrepr .= printf('%s\ %s', fontname_escaped, spec["height"])
        else
            let guifontrepr .= printf('%s\ h%s', fontname_escaped, spec["height"])
        endif
    endfor
    return guifontrepr
endf
function! g:Font_AddToHeights(fontspecs, summand) abort
    let result=[]
    for spec in a:fontspecs
        let newfont=copy(spec)
        let newfont["name"] = spec["name"]
        let newfont["height"] = spec["height"] + a:summand
        let result = result + [newfont]
    endfor
    return result
endf

command! -narg=0 ZoomIn    :call g:Font_ZoomIn()
command! -narg=0 ZoomOut   :call g:Font_ZoomOut()
function! g:Font_ZoomIn() abort
    let zoomed = g:Font_AddToHeights(g:Font_GetCurrentFonts(), 1)
    call g:Font_SetCurrentFonts(zoomed)
endfunction
" guifont size - 1
function! g:Font_ZoomOut() abort
    let zoomed = g:Font_AddToHeights(g:Font_GetCurrentFonts(), -1)
    call g:Font_SetCurrentFonts(zoomed)
endfunction

if has("gui")
    map <C-F11> :ZoomOut<CR>
    map <S-F11> :ZoomIn<CR>
endif
"}}}
" Font Settings {{{
if ! exists("g:_hassetfont") 
    if has("win32")
        call Font_SetCurrentFonts([{"name":"Cascadia Code", "height":"11"}])
    else
        call Font_SetCurrentFonts([{"name":"Ubuntu Mono", "height":"11"}])
    endif
    let g:_hassetfont=1
endif

" }}}
"GVim related{{{
set guioptions-=l
set guioptions-=L
set guioptions-=r
set guioptions-=R
set guioptions-=b
set guioptions-=e
set guioptions-=m
set guioptions-=T
set guioptions-=b
set guioptions-=l
set guioptions+=c
"}}}

" OldF stuff, extracted and rewritten as global functions with prefix OldFun{{{

fun! OldFunOutputSplitWindow(...) 
  " this function output the result of the Ex command into a split scratch buffer
  let cmd = join(a:000, ' ')
  let temp_reg = @"
  redir @"
  silent! execute cmd
  redir END
  let output = copy(@")
  let @" = temp_reg
  if empty(output)
    echoerr "no output"
  else
    new
    setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted
    put! =output
  endif
endfunction

" Consumer

fun! OldFunFdmModeline(...) 
    if a:0 > 0
        exec lh#fmt#printf('set foldmethod=%1', a:1)
    endif
" Append modeline after last line in buffer.
" Use substitute() instead of printf() to handle '%%s' modeline in LaTeX
" files.
  let l:modeline = printf(" vim: fdm=%s", &foldmethod)
  let l:modeline = substitute(&commentstring, "%s", l:modeline, "")
  call append(line("$"), l:modeline)
endfunction

" I/O and helpers
fun! OldFunPrt(...) abort 
    return call('lh#fmt#printf', a:000)
endf
fun! OldFunLHStr(...) abort 
    if a:0 == 0
        return ''
    endif
    if a:0 == 1
        return lh#object#to_string(a:1)
    endif
    return lh#object#to_string(a:000)
endf
fun! OldFunNop(...) abort 
endf

fun! OldFunGetStack(handle) abort 
    if ! has_key(g:stacks, a:handle)
        let g:stacks[a:handle] = lh#stack#new()
    endif
    return g:stacks[a:handle]
endf
if ! exists('g:stacks')
    let g:stacks = {}
endif

fun! OldFunInputChar() 
    let c = getchar()
    return type(c) == type(0) ? nr2char(c) : c
endfunction
fun! OldFunIdxSet(list, idx, newVal) abort 
    let l:new = copy(a:list)
    let l:new[a:idx] = a:newVal
    return l:new
endf
fun! OldFunWithVar(varname, newval, fwdcmd) abort 
    if exists(a:varname)
        let l:prevVal = eval(a:varname)
    endif
    exe 'let '.a:varname.' = a:newval'
    try
        exe a:fwdcmd
    finally
        if exists('l:prevVal')
            exe 'let '.a:varname.' = '.string(l:prevVal)
        else
            exe 'unlet '.a:varname
        endif
    endtry
endf

" Registers
fun! OldFunStripreg(reg) 
    call setreg(a:reg, trim(getreg(a:reg)))
endf
fun! OldFunExpandreg(...) 
" for use in commands with <q-reg> as argument.
    let l:arg = get(a:, 1, '<unset>')
    
    if l:arg != '<unset>' && l:arg != ''
        return l:arg
    else
        return g:defaultreg
    endif
endf

" Patterns and search

fun! OldFunCleanColFromPattern(prevPattern) abort 
    let l:cleaned = substitute(a:prevPattern, '\V\^\\%>\[0-9]\+c', '', '')
    return l:cleaned 
endf

fun! OldFunEscapeRegex(r) 
    return "'" . substitute(a:r, "\\V'", "''", 'g') . "'"
endf
fun! OldFunUnEscapeRegex(r) 
    return substitute(a:r, '\V''''', '''', 'g')
endf
fun! OldFunUnquoteEscapedRegex(r) 
    return substitute(a:r, '\V\^''\(\.\*\)''\$', '\1', '')
endf

" Buffers
fun! OldFunKillBufIfExists(file) abort 
    let bufnr = bufnr(a:file)
    while bufnr > -1 && bufexists(bufnr)
        exec printf('bw! %s', bufnr)
    endwhile
endf

" Operator, Motion and Range
" - Easymotion
fun! OldFunGetEMLineNr() abort 
" retval == 0 -> success
" retval == 1 -> cancelled
" see snippet emline
    call inputsave()
    let prev = getpos('.')
    let retval = EasyMotion#Sol(0, '2')
    let retpos = getpos('.')
    call setpos('.', prev)
    call inputrestore()
    return [retval, retpos[1]]
endf
fun! OldFunSelectEMRange() abort 
    let [retv, line1] = g:GetEMLineNr()
    if retv == 0
        let [retv, line2] = g:OldFunGetEMLineNr()
        if retv == 0
            call g:OldFunVisual_applyPos(g:OldFunVisual_makePos(line1, line2), 1)
        else
            echo 'aborted SelectEMRange'
            call feedkeys("\<ESC>")
        endif
    else
        echo 'aborted! SelectEMRange'
        call feedkeys("\<ESC>")
    endif
endf

" - Visual
fun! OldFunVisual_GetPos() abort 
    return [getpos("'<"), getpos("'>")]
endf
fun! OldFunVisual_applyPos(posArray, ...) abort 
    let [a:pos1, a:pos2] = a:posArray
    let a:doReselect = get(a:, 1, 0)
    call setpos("'<", a:pos1)
    call setpos("'>", a:pos2)
    let apparentMode = g:OldFunVisual_apparentmode(a:posArray)
    let vmode = visualmode()
    if vmode !=# apparentMode
        let lazyrd_old = &lazyredraw
        let &lazyredraw = 1
        let savepos = getpos('.')
        keepj normal gv
        call feedkeys(apparentMode)
        call feedkeys('', 'x')
        call setpos('.', savepos)
        let &lazyredraw = lazyrd_old
    endif
    if a:doReselect == 1
        normal gv
        let vmode = mode()
        if vmode !=# apparentMode
            call feedkeys(apparentMode)
        endif
    endif
endf
fun! OldFunVisual_apparentmode(posArray) 
    if a:posArray[1][2] == 2147483647 && a:posArray[0][2] != 1
    endif
    let apparent = a:posArray[1][2] == 2147483647 && a:posArray[0][2] == 1 ? 'V' : 'v'
    return apparent
endf
fun! OldFunVisual_to2x2(visPosPairArray) 
    return g:OldFunVisual_makePos(a:visPosPairArray[0][1], a:visPosPairArray[1][1], a:visPosPairArray[0][2], a:visPosPairArray[1][2])
endf
fun! OldFunVisual_makePos(line1, line2, ...) 
    let a:col1 = get(a:, 1, 1)
    let a:col2 = get(a:, 2, 2147483647)
    let a:apparentMode = get(a:, 3, a:col2 == 2147483647 && a:col1 == 1 ? 'V' : 'v')

    let l1 = a:line1
    let l2 = a:line2
    let c1 = a:col1
    let c2 = a:col2
    " sanity checks
    if l1 < 1
        let l1 = 1
    endif
    if l2 < 1
        let l2 = 1
    endif
    if l1 > line('$')
    endif
    if l2 > line('$')
    endif
    if c1 < 1
        let c1 = 1
    endif
    if c2 < 1
        let c2 = 1
    endif
    if c1 > col([l1, '$']) && c1 != 2147483647
        let c1 = 1
    endif
    if c2 > col([l2, '$']) && c2 != 2147483647
    endif
    if a:apparentMode ==# 'V'
        " V is selected only when the parameters strictly match see above
        return [[0, l1, 1, 0], [0, l2, 2147483647, 0]]
    else
        " here would be wiggle room and mayne a mode overriding param e.g. when col1 was specified != 1 but not col2
        " currently we count this case as character mode
        return [[0, l1, c1, 0], [0, l2, c2, 0]]
    endif
endf
fun! OldFunVisual_getText(...) 
    let a:includeFinalCR = get(a:, 1, 1)
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    let result = join(lines, "\n")
    if column_end >= col([line_end, '$']) && a:includeFinalCR
        let result = result . "\n"
    endif
    return result 
endfunction

" - Deletion
fun! OldFunCaptureDeletion(...) abort 
" default arg is the current vis selection
" returns a Deletion object
" if specified as list, length of 4 or 5 indicates single pos like pos(..) returns
"                           -- the members need all not be also lists
"                       length of 2 where the members are not lists, indicates [linenr, colnr] 
"                       length of 2 where the members are also lists indicates a range like [pos(...), pos(...)]
" if specified as a string, the argument is fed to pos(), i.e. '.', "'z", ...
" if specified as a int, the argument is taken as the column in the current line
" =====
" returns [parsed_spec(2x4 pos(..) format), projectedcurpos, startpos==endpos]
        let spec = get(a:, 1, g:OldFunVisual_GetPos())
        if type(spec) == 3
            let memberlists = type(spec[0]) == 3
            if memberlists
                call assert_true(len(spec) == 2)
                let parsedspec = spec
            else
                if len(spec) == 2
                    let parsedspec = [[0]+spec[0]+[0], [0]+spec[1]+[0]]
                elseif len(spec) == 4 or len(spec) == 5
                    let parsedspec = [spec[0:3], spec[0:3]]
                else 
                    throw "ProjectPosDelete: not a valid spec: ".string(spec)
                endif
            endif
        elseif type(spec) == 1
            let pos = getpos(spec)
            let parsedspec = [pos, pos]
        elseif type(spec) == 0
            let pos = [0, line('.'), spec, 0]
            let parsedspec = [pos, pos]
        endif

        let [startpos, endpos] = parsedspec
        let startline = startpos[1]
        let endline = endpos[1]
        let startlineEnd = col([startline, '$'])
        let endlineEnd = col([endline, '$']) 
        let startcol = min([col([startline, '$']), startpos[2]])
        let endcol = min([col([endline, '$']), endpos[2]])
        let nextlineChars = strchars(getline(endline+1))

        " Pushback of the START of the selection, imminent because end of line selected
        let charsLeftAtEOL = endcol < endlineEnd -1 " CR may not be included!
        let pushbackImminent = ! charsLeftAtEOL
        let atCR = endlineEnd <= endcol " will delete the \n
        
        return g:OldFunDeletion(parsedspec, startpos, endpos, startline, endline, startlineEnd, endlineEnd, startcol, endcol, nextlineChars, charsLeftAtEOL, pushbackImminent, atCR)
endf
" -- Class Deletion
fun! OldFunDeletion(capturedRange, startpos, endpos, startline, endline, startlineEnd, endlineEnd, startcol, endcol, nextlineChars, charsLeftAtEol, pushbackImminent, atCR) abort 
let s = lh#object#make_top_type({
        \ 'capturedRange': a:capturedRange, 
        \ 'startpos': a:startpos, 
        \ 'endpos': a:endpos, 
        \ 'startline': a:startline, 
        \ 'endline': a:endline, 
        \ 'startlineEnd': a:startlineEnd, 
        \ 'endlineEnd': a:endlineEnd, 
        \ 'startcol': a:startcol, 
        \ 'endcol': a:endcol, 
        \ 'nextlineChars': a:nextlineChars, 
        \ 'charsLeftAtEol': a:charsLeftAtEol, 
        \ 'pushbackImminent': a:pushbackImminent, 
        \ 'atCR': a:atCR
        \ })

    function! s.willFeed() dict abort
        return (self.atCR && self.nextlineChars > 0)
    endfunction

    function! s.posAfter() dict abort

        if self.pushbackImminent
            if self.willFeed()
                let resultcol = self.startcol " wont be pushed back because something will feed the line
            else
                if self.startcol == 1 " cant be pushed back
                    let resultcol = self.startcol
                else
                    let resultcol = self.startcol-1
                endif
            endif
        else
            let resultcol = self.startcol
        endif
        let resultline = self.startline
        return [0, resultline, resultcol, 0]
    endfunction

    function! s.whichPasteThen() dict abort
        let projection = self.posAfter()
        if self.startcol == projection[2]
            return 'P'
        else
            return 'p'
        endif
    endfunction
    
    return s
endfunction

" - Operator
fun! OldFunGetPresentOperatorData(...) abort 
    "TODO: sanity check arguments
    return g:OldFunOperatorData(call('g:OldFunParseOpfunData', a:000))
endfunction
fun! OldFunOperatorData(asList) abort 
let s = lh#object#make_top_type({
        \ '_asList': a:asList, 
        \ 'content': a:asList[0], 
        \ 'posrange': a:asList[1], 
        \ 'markerrange': a:asList[2], 
        \ 'type': a:asList[3], 
        \ 'distantpos': a:asList[4]
        \ })
    fun! s.flash(...) dict abort
        let arglist = self.posrange+a:000
        call call('g:OldFunFlashVisual', arglist)
    endfunction
    return s
endfunction
fun! OldFunParseOpfunData(type) abort 
" returns [stringcontent, [[pos1x4],[pos2x4]], [mark1Str, mark2Str], a:type, [distantPos1x4, distantPosIdx(0 or 1 <> '<, '>)]] // type=visual/line/whatever a:type contains
    "type can be line, char, block, visual" -- with visual, gv get us the right selection. user can then check for trailing newline herself...

    
    if a:type == 'visual'
        let evalpos = g:OldFunVisual_GetPos()
        let signs = ["'<","'>"]
        let l:content = g:OldFunVisual_getText(1)
    else
        let vispos = g:OldFunVisual_GetPos()
        let pos = getpos(".")

        call lh#log#this('parseopfunData where: ')
        let opos = getpos("'[")
        call lh#log#this('opos1: '.string(getpos("'[")))
        
        if a:type == 'line'
            silent keepj exe "normal! '[V']\<esc>"
        else
            silent keepj exe "normal! `[v`]\<esc>"
        endif
        let opos = getpos("'[")
        call lh#log#this('opos2: '.string(getpos("'[")))
        let evalpos = g:OldFunVisual_GetPos()
        call lh#log#this('stdm evalpog:OldFun %1', evalpos)
        
        let signs = ["'[","']"]
        silent keepj norm 
        let l:content = g:OldFunVisual_getText(1)

        keepj call g:OldFunVisual_applyPos(vispos)
        keepj call setpos(".", pos)
    endif
    
    let [p1, p2] = evalpos
    let distantpos = p2
    let distantidx = 1
    let curpos = getpos('.')
    let distantpos = p2
    let distantidx = 1
    if abs(p1[1]-curpos[1]) > abs(p1[1]-curpos[1]) || abs(p1[2]-curpos[2]) > abs(p2[2]-curpos[2])
        let distantpos = p1
        let distantidx = 0
    endif
    return [l:content, evalpos, signs, a:type, [distantpos, distantidx]]
endf



"TODO: sunday PasteLineToCmdOpfun; need to select furthest from cursor which opdata should contain
fun! OldFunPasteLineToCmdOpfun(type) abort 
    let opdata = g:OldFunOperatorData(g:OldFunParseOpfunData(a:type))
endfunction
fun! OldFunTakeOp(type) abort 
    let opdata = g:OldFunOperatorData(g:OldFunParseOpfunData(a:type))
    call g:OldFunFlashVisual(opdata.posrange[0], opdata.posrange[1], 2, 100)
    let g:_moveop_payload = g:OldFunRange_makecmd(opdata.markerrange, "%st%%s")
    call feedkeys(":\<C-\>eg:OldFun.CmdlineGoToPlaceholder(g:_moveop_payload, '%s')\<CR>")
endfunction
fun! OldFunMoveOp(type) abort 
    let opdata = g:OldFunOperatorData(g:OldFunParseOpfunData(a:type))
    call g:OldFunFlashVisual(opdata.posrange[0], opdata.posrange[1], 2, 100)
    let g:_moveop_payload = g:OldFunRange_makecmd(opdata.markerrange, "%sm%%s", "`", "+1")
    call feedkeys(":\<C-\>eg:OldFun.CmdlineGoToPlaceholder(g:_moveop_payload, '%s')\<CR>")
endfunction
fun! OldFunCmdlineGoToPlaceholder(cmdline, placeholder) abort 
    " C-\= mode function to be evaluated to set the command line
    " TODO: what if placeholder is not found? -> set pos to end
    " TODO: refactor calls to this to a dedicated cmd
    let idx = stridx(a:cmdline, a:placeholder)
    call setcmdpos(idx+1)
    return substitute(a:cmdline, '\V'.a:placeholder, '', '')
endf
fun! OldFunRange_makecmd(markerrange, command, ...) abort 
    " supply a range (TODO: from opdata; refactor this)
    " command is a printf format string to be evaluated by thisfunction, with the range being the argument
    " example: '%smark z'
    " optiong:OldFun markname ('a', '`'), and markpos('+1' or '+0' or '-0' or '-3'), need both be specified, to drop a mark relative to the oprange bounds
    let [a:markstart, a:markend] = a:markerrange
    let a:markname = get(a:, 1, '')
    let a:markpos = get(a:, 2, '<empty>')
    let a:selectafter = get(a:, 3, 0)
    "todo: support pos arrays?

    let coreCmd = printf(a:command, printf('%s,%s', a:markstart, a:markend))

    let markSthCmd = ''
    if !empty(a:markname)
        let relmark=a:markend
        if a:markpos[0] == '-'
            let relmark=a:markstart
        endif
        let markSthCmd = call('printf', ['%s%sk%s | '] + [relmark, a:markpos, a:markname])
    endif

    let selectafterCmd = ''
    if a:selectafter && 0
        "TODO: selectafter could be quite useful!
    endif

    return markSthCmd . coreCmd . selectafterCmd
endf
fun! g:CmdlineGoToPlaceholder(cmdline, placeholder) abort 
    " C-\= mode function to be evaluated to set the command line
    " TODO: what if placeholder is not found? -> set pos to end
    " TODO: refactor calls to this to a dedicated cmd
    let idx = stridx(a:cmdline, a:placeholder)
    call setcmdpos(idx+1)
    return substitute(a:cmdline, '\V'.a:placeholder, '', '')
endf





""""""""""""""""""""""""""""""
"  range command groundwork  "
""""""""""""""""""""""""""""""

" supply a range (TODO: from opdata; refactor this)
" command is a printf format string to be evaluated by thisfunction, with the range being the argument
" example: '%smark z'
" optiong:OldFun markname ('a', '`'), and markpos('+1' or '+0' or '-0' or '-3'), need both be specified, to drop a mark relative to the oprange bounds
fun! OldFunRange_makecmd(markerrange, command, ...) abort 
    let [a:markstart, a:markend] = a:markerrange
    let a:markname = get(a:, 1, '')
    let a:markpos = get(a:, 2, '<empty>')
    let a:selectafter = get(a:, 3, 0)
    "todo: support pos arrays?

    let coreCmd = printf(a:command, printf('%s,%s', a:markstart, a:markend))

    let markSthCmd = ''
    if !empty(a:markname)
        let relmark=a:markend
        if a:markpos[0] == '-'
            let relmark=a:markstart
        endif
        let markSthCmd = call('printf', ['%s%sk%s | '] + [relmark, a:markpos, a:markname])
    endif

    let selectafterCmd = ''
    if a:selectafter && 0
        "TODO: selectafter could be quite useful!
    endif

    return markSthCmd . coreCmd . selectafterCmd
endf

" Visuals

fun! OldFun_blinkwin(nr) abort
    let win = g:OldFun.Win_get(a:nr)
    if win.exists()
        call win.jump()
        let localRelnr = &relativenumber
        let &relativenumber = !localRelnr
        call g:OldFun.FlashCurrentLine()
        let &relativenumber = localRelnr
    else
        throw printf("window %s doesnt exist", a:nr)
    endif
endf

fun! OldFunBlinkWin(nr) abort 
    call WithWinPreservedEval(printf("call %s(%s)", g:OldFunmod.script.snrName("_blinkwin"), a:nr))
endf


fun! OldFunFlashLines(linenr1, linenr2, ...) abort 
    let selection = g:OldFunVisual_makePos(a:linenr1, a:linenr2)
    call call('g:OldFunFlashVisual', selection+a:000)
endf
fun! OldFunFlashLine(linenr1, ...) abort 
    call call('g:OldFunFlashLines', [a:linenr1, a:linenr1] + a:000)
endf
fun! OldFunFlashCurrentLine(...) abort 
    call call('g:OldFunFlashLine', [line('.')] + a:000)
endf
fun! OldFunFlashVisual(pos1, pos2, ...) abort 
    
    let l:times = get(a:, 1, 1)
    let l:duration = get(a:, 2, 200)
    let l:gvpos = g:OldFunVisual_GetPos()
    let l:curpos = getcurpos()
    
    for i in range(l:times)
        if i > 0
            exec "sleep ".(l:duration/3)."m"
        endif
        call g:OldFunVisual_applyPos([a:pos1, a:pos2], 1)
        redraw
        exec "sleep ".l:duration."m"
        keepj normal 
        redraw
    endfor
    call g:OldFunVisual_applyPos(l:gvpos)
    call setpos(".", l:curpos)
endf
fun! OldFunFlashMarkerRange(m1, m2, ...) 
    let p1 = getpos("'".a:m1)
    let p2 = getpos("'".a:m2)
    call call('g:OldFunFlashLines', [p1[1], p2[1]] + a:000)
endf

" Windows

fun! OldFunWin_get(...) abort 
    return g:OldFunWin_getId(win_getid(get(a:, 1, winnr())))
endf
fun! OldFunWin_getId(...) abort 
    let winid = get(a:, 1, win_getid())
    if winid > 0 && win_id2tabwin(winid) != [0,0]
        return g:OldFunWinInfo(getwininfo(winid)[0])
    else
        throw 'No window info for winid ' . winid
    endif
endf

" bufnr height loclist quickfix terminal tabnr variables width winbar wincol winid winnr winrow
fun! OldFunWinInfo(infoDict) abort 
let s = lh#object#make_top_type(copy(a:infoDict))

    function! s.updated() dict abort
        return g:OldFunWin_get(self.nrNow())
    endfunction
    
    function! s.updatedjump() dict abort
        return self.jump(self.nrNow())
    endfunction

    " no recalculating nothing
    function! s.jump() dict abort
        call win_gotoid(self.winid)
    endfunction

    " means "exists in tab page"
    function! s.exists() dict abort
        return win_id2win(self.winid) > 0
    endfunction
    " means "exists in tab page"
    function! s.existsSomewhere() dict abort
        return win_id2tabwin(self.winid)
    endfunction

    function! s.nrNow() dict abort
        let updated = win_id2win(self.winid)
        return updated
    endfunction

    function! s.isTerm() dict abort
        return self.terminal == 1
    endfunction
    function! s.qftype() dict abort
        return qf#type(self.winnr)
    endfunction
    function! s.isFullHeight() dict abort
        return abs(self.height + &cmdheight + 1 - &lines) <= 1 " somehow the 1 buffer is necessary
    endfunction
    function! s.isFullWidth() dict abort
        return self.width == &columns
    endfunction
    function! s.isRightmost() dict abort
        return self.width + self.wincol >= &columns
    endfunction
    function! s.isLeftmost() dict abort
        return self.wincol == 1
    endfunction
    function! s.isTopmost() dict abort
        return self.winrow <=2
    endfunction
    function! s.isBottommost() dict abort
        return self.winrow + self.height + &cmdheight >= &lines -1 " TODO: the -1 buffer is not necessary with my setup
    endfunction

    " if split situation corresponds to wincmdHJK or L, return the char, else return empty string.
    " returns empty also on a fullscreen window (it would be the only window in that tab)
    function! s.getHJKL() dict abort
        if self.isFullWidth() && self.isFullHeight()
            return ''
        endif
        if self.isFullWidth()
            if self.isBottommost()
                return 'J'
            endif
            if self.isTopmost()
                return 'K'
            endif
        endif
        if self.isFullHeight()
            if self.isLeftmost()
                return 'H'
            endif
            if self.isRightmost()
                return 'L'
            endif
        endif
        return ''
    endfunction
    function! s.getLines() dict abort
        return getbufline(self.bufnr, 1, '$')
    endfunction
    function! s.getLineNum() dict abort
        if winnr() == self.nrNow()
            return line('$')
        endif
        return len(self.getLines())
    endfunction
    let s.projectVertResize = function('g:OldFunProjectVertResize')
    let s.vertResize = function('g:OldFunVertResize')

    return s
endfunction

fun! OldFunProjectVertResize(minLegal, maxLegal, blanklines, minimize) dict abort 
    let [min, max, blanklines, minimize] = [a:minLegal, a:maxLegal, a:blanklines, a:minimize]
    let lines = self.getLineNum()
    " boring, will always go to legal min (blanklines dont overrule)
    if minimize
        return min([min, max])
    else
        let max = min([ lines+blanklines, max ])
        return max([min, max])
    endif 
endfunction
fun! OldFunVertResize(minLegal, maxLegal, blanklines, minimize) abort dict 
    if !self.isFullHeight()
        let [min, max, blanklines, minimize] = [a:minLegal, a:maxLegal, a:blanklines, a:minimize]
        let projection = self.projectVertResize(min, max, blanklines, minimize)
        if winnr() != self.winnr
            let changecmd = lh#fmt#printf('%1wincmd w', self.winnr)
            exec changecmd
            exec 'resize '.projection
            wincmd p
        endif
        exec 'resize '.projection
    else
        " do nothing in this case
    endif
    
endf

fun! OldFunHJKLComplement(hjkl) abort 
    call lh#assert#true(match(a:hjkl, '\v\C^[HJKL]$') >= 0)
    if a:hjkl == 'H'
        return 'L'
    elseif a:hjkl == 'J'
        return 'K'
    elseif a:hjkl == 'K'
        return 'J'
    elseif a:hjkl == 'L'
        return 'H'
    endif
endf

fun! OldFunfunid(name) abort 
    return "<SNR>".g:OldFunscriptid."_".a:name
endf
"}}}
" vim: fdm=marker

