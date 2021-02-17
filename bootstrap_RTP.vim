    command! -bar -nargs=1 AddRcVim  call add(vimruntime.stock_vim_init.vimrc_spec.rc, <q-args>)
    command! -bar -nargs=1 AddRcGvim call add (vimruntime.stock_vim_init.gvimrc_spec.rc, <q-args>)
    command! -bar -nargs=1 AddRcDir  AddRcVim <args>/vimrc | AddRcGvim <args>/gvimrc
    command! -bar -nargs=1 AddRcLayer  AddRcVim <args>/vimrc | AddRcGvim <args>/gvimrc | PathAddRTP <args> | PathAddPP <args>
    command! -nargs=1 -bar PathAddPP call add(g:vimruntime.stock_vim_init.prependPPList, <f-args>)
    command! -nargs=1 -bar PathAddRTP call add(g:vimruntime.stock_vim_init.prependRTPList, <f-args>)
    command! -nargs=1 -bar PathAddAfterPP call add(g:vimruntime.stock_vim_init.appendPPList, <f-args>)
    command! -nargs=1 -bar PathAddAfterRTP call add(g:vimruntime.stock_vim_init.appendRTPList, <f-args>)
    command! -nargs=1 -bar Src execute printf("source %s", _cmdPath(<f-args>))
    command! -bang -nargs=1 ReadPathE echon join(['# '.<q-args>] + split(eval(<f-args>), ","), "\n")."\n"
    command! -bang -nargs=1 ReadPath call append(line('.'), ['# '.<q-args>] + split(eval(<f-args>), ","))
    " let vimruntime.stock_vim_init.appendRTPList = []
    " let vimruntime.stock_vim_init.prependRTPList = []
    " let vimruntime.stock_vim_init.appendPPList = []
    " let vimruntime.stock_vim_init.prependPPList = []

    fun! _AdaptToBuildInSourcetree() abort
	    " detect if vim is used just after "configure; make" and change runtimepath accordingly
	    if ! empty(glob(g:_vim_instance.probable_source_rtdir))
		echom "found vim source runtime to be more precise: " . g:_vim_instance.probable_source_rtdir
		let $VIMRUNTIME=g:_vim_instance.probable_source_rtdir
		let $VIM=g:_vim_instance.probable_source_vimdir
		" echom "rtp orig:" . &rtp
		let &runtimepath = substitute(&runtimepath, '\V'.escape(g:_vim_instance.orig_VIMRUNTIME, '\'), g:_vim_instance.probable_source_rtdir, 'g')
		let &runtimepath = substitute(&runtimepath, '\V'.escape(g:_vim_instance.orig_VIM, '\'), g:_vim_instance.probable_source_vimdir, 'g')
		let &packpath = substitute(&packpath, '\V'.escape(g:_vim_instance.orig_VIMRUNTIME, '\'), g:_vim_instance.probable_source_rtdir, 'g')
		let &packpath = substitute(&packpath, '\V'.escape(g:_vim_instance.orig_VIM, '\'), g:_vim_instance.probable_source_vimdir, 'g')
		let &helpfile = substitute(&helpfile, '\V'.escape(g:_vim_instance.orig_VIMRUNTIME, '\'), g:_vim_instance.probable_source_rtdir, 'g')
		let &helpfile = substitute(&helpfile, '\V'.escape(g:_vim_instance.orig_VIM, '\'), g:_vim_instance.probable_source_vimdir, 'g')
		" echom "rtp afte:" . &rtp
	    endif
    endf

    fun! _path_rel_to(base, rel) abort
        return trim(system(printf("readlink -f %s", shellescape(a:base."/".a:rel))))
    endf

    fun! _cmdPath(...) abort
        let args=[]
        for a in a:000
            if match(a, '^[s]:') > -1
                throw "script-level variables are not supported in _cmdPath commands"
            elseif match(a, '^[glab]:') > -1
                call add(args, eval(a))
            else
                call add(args, a)
            endif
        endfor
        return join(args, "/")
    endf

    fun! _PathSettingPrepend(setting, part) abort
        " echom printf("DBG: _PathSettingPrepend('%s', '%s')", string(a:setting), string(a:part))
        if a:setting ==# "runtimepath" || a:setting ==# "rtp"
		let oldsetting = &runtimepath
		let &runtimepath=a:part.",".oldsetting
		echom printf("DBG: adding RTP: " . a:part)
	elseif a:setting ==# "packpath" || a:setting ==# "pp"
		echom printf("DBG: adding PP: " . a:part)
		let oldsetting = &packpath
		let &packpath=a:part.",".oldsetting
	else
		echoe "unknown setting: ".a:setting
        endif
    endf

    fun! _KeepPathPart(part, pathname) abort
        let p = expand(a:part)
        let matchesVIMRUNTIME = 0
        let matchesHOMEVIM = 0
        let tomatchHOMEVIM = fnamemodify(expand("$HOME")."/.vim", ':p:h')
        let tomatchVIMRUNTIME = fnamemodify(expand("$VIMRUNTIME"), ':p:h:h')
        let exists=0
        " echom "looking if ".p." matches ".tomatchHOMEVIM
        if stridx(p, tomatchHOMEVIM) == 0
            let matchesHOMEVIM=1
            " echom "matched HOMEVIM!"
        endif
        " echom "looking if ".p." matches ".tomatchVIMRUNTIME
        if stridx(p, tomatchVIMRUNTIME) == 0
            let matchesVIMRUNTIME=1
            " echom "matched VIMRUNTIME!"
        endif
        if isdirectory(p)
            let exists = 1
            " echom "exists!"
        endif
        " if stridx(p, substitute(expand("$VIMRUNTIME"), expand("$HOME"), '~', '')) == 0
        "     let matchesVIMRUNTIME=1
        " endif
        if ! matchesHOMEVIM && exists
            return 1
        else
            return 0
        endif
    endf

    fun! _VimRuntimeLog(msg, ...) abort "{{{
        " optional parameter: 1 if is fatal -- then quit
        call writefile([a:msg], vimruntime.logfile, 'a')
        if a:0 > 0 && a:1 == 1
            echoerr a:msg
            q!
        endif
    endf

if ! exists('g:_vim_instance')
    let g:_vim_instance={}
    let g:_vim_instance.cmd = v:argv[0]
    if g:_vim_instance.cmd[0] != '/'
        let g:_vim_instance.executable = resolve(systemlist("which ".g:_vim_instance.cmd)[0])
    else
        let g:_vim_instance.executable = resolve(g:_vim_instance.cmd)
    endif
    let g:_vim_instance.probable_source_vimdir = fnamemodify(g:_vim_instance.executable, ":p:h")."/.."
    let g:_vim_instance.probable_source_rtdir  = g:_vim_instance.probable_source_vimdir . "/runtime"
    let g:_vim_instance.orig_VIMRUNTIME = $VIMRUNTIME
    let g:_vim_instance.orig_VIM = $VIM

    call _AdaptToBuildInSourcetree()

    let vimruntime={}
    let vimruntime.logfile = expand('<sfile>:p:h') . '/vimruntime.log'
    let vimruntime.stock_vim_init={}
    let vimruntime.stock_vim_init.scriptfile = expand('<sfile>:p')

    " These are records of the original paths
    let vimruntime.stock_vim_init.origRTP = &runtimepath
    let vimruntime.stock_vim_init.origPP = &packpath
    " These are for vimrc/gvimrc sourcing
    let vimruntime.stock_vim_init.vimrc_spec = {}
    let vimruntime.stock_vim_init.vimrc_spec.rc = []
    let vimruntime.stock_vim_init.gvimrc_spec = {}
    let vimruntime.stock_vim_init.gvimrc_spec.rc = []
    " These are for rewriting the stock RTP
    let vimruntime.stock_vim_init.newRTPList = []
    let vimruntime.stock_vim_init.newPPList = []
    let vimruntime.stock_vim_init.appendRTPList = []
    let vimruntime.stock_vim_init.prependRTPList = []
    let vimruntime.stock_vim_init.appendPPList = []
    let vimruntime.stock_vim_init.prependPPList = []

    for p in split(vimruntime.stock_vim_init.origRTP, ",")
        if _KeepPathPart(p, 'runtimepath')
            call add(vimruntime.stock_vim_init.newRTPList, p)
        endif
    endfor
    for p in split(vimruntime.stock_vim_init.origPP, ",")
        if _KeepPathPart(p, 'packpath')
            call add(vimruntime.stock_vim_init.newPPList, p)
        endif
    endfor

endif
