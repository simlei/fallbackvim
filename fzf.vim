let s:oo = {}

let s:oo.wrap_vimcfg=function("fzf#wrap")
let s:oo.wrap_filepreview=function("fzf#vim#with_preview")

" basic call infrastructure{{{
" ignores sink and sink* arguments! they must be implemented on the return
" value or callback value

fun! s:fzf_parse_varargs_into_opts(existing, ...) abort
    let result = copy(a:existing)
    for Arg in a:000
        if type(Arg) == type({})
            call extend(result, Arg)
        elseif type(Arg) == type(function("has"))
            call Arg(result)
        else
            throw "options argument not recognized: ".string(Arg)
        endif
    endfor
    return result
endf

fun! s:fzfrunSync(Callback, ...) abort
    let options = call('s:fzf_parse_varargs_into_opts', [{}] + a:000 )
    let options["sink*"] = funcref("s:fzfrunCallback", [a:Callback])
    if has("gui")
        call a:Callback(lh#option#unset())
        throw "cannot run sync in GUI"
        " let s:fzfSelectorResult = {}
        " call call('fzf#run', runargs)
        " return s:fzfSelectorResult
    endif
    call call('fzf#run', [options])
endf

" operates under the assumption that in gvim, EVERY fzf#run invocation is async, and in vim, EVERY fzf#run invocation is sync.
" TODO: launcher or something else could be set so this doesnt hold true
fun! s:fzfrunAsync(Callback, ...) abort
    let options = call('s:fzf_parse_varargs_into_opts', [{}] + a:000 )
    let options["sink*"] = funcref("s:fzfrunCallback", [a:Callback])
    if ! has("gui")
        call a:Callback(lh#option#unset())
        throw "cannot go async without gui right now"
    endif
    call call('fzf#run', [options])
endf
"TODO: these can contain stuff on the first lines related to the accept etc
"args but are not considered right now for empty/notempty
"TODO: lib: The library fixes this and should attach here!
fun! s:fzfrunCallback(Callback, result)
    let res = filter(copy(a:result), { i,x -> ! empty(x)})
    if(empty(res))
        call a:Callback(lh#option#unset())
    else
        call a:Callback(res)
    endif
endf
"}}}

fun! SelectOne(Callback, source, ...) abort
    let wrappers = [s:oo.wrap_vimcfg]
    " TODO: can I remove that options key?
    let opts =  {
                \ 'source':  a:source, 
                \ 'options': "",
                \ 'down':    '40%'
                \ }
    for Wrapper in wrappers
        let opts = Wrapper(opts)
    endfor

    let OneCallback = funcref(funcref("s:fzf_SelectOne_Filter"), [a:Callback])
    if has("gui")
        call call("s:fzfrunAsync", [OneCallback, opts] + a:000)
    else
        call call("s:fzfrunSync", [OneCallback, opts] + a:000)
    endif
endf
fun! SelectMulti(Callback, source, ...) abort
    let wrappers = [s:oo.wrap_vimcfg]
    " TODO: can I remove that options key?
    let opts =  {
                \ 'source':  a:source, 
                \ 'options': "--multi",
                \ 'down':    '40%'
                \ }
    for Wrapper in wrappers
        let opts = Wrapper(opts)
    endfor

    let MultiCallback = funcref(funcref("s:fzf_SelectMulti_Filter"), [a:Callback])
    if has("gui")
        call call("s:fzfrunAsync", [MultiCallback, opts] + a:000)
    else
        call call("s:fzfrunSync", [MultiCallback, opts] + a:000)
    endif
endf
fun! s:fzf_SelectOne_Filter(Callback, result) abort
    if lh#option#is_unset(a:result)
        call a:Callback("")
    else
        call a:Callback(a:result[0])
    endif
endf

fun! s:fzf_SelectMulti_Filter(Callback, result) abort
    if lh#option#is_unset(a:result)
        call a:Callback([])
    else
        call a:Callback(a:result)
    endif
endf

fun! g:Echo(expr) abort
    return execute("echo printf('%s', a:expr)", "")
endf
fun! g:Echom(expr) abort
    return execute("echom printf('%s', a:expr)", "")
endf
fun! g:LetTo(varname, value) abort
    return lh#let#to(a:varname, a:value)
endf

" call SelectOne(funcref("Echom"), ["123", "456"])

" vim: fdm=marker
