" Vim compiler file
" Compiler:	bash oo output
" Maintainer:	Simon Leischnig
" Last Change: 2019 February 19

" if exists("current_compiler")
"   finish
" endif

let current_compiler = "bashoo"

if exists(":CompilerSet") != 2
  command! -nargs=* CompilerSet setlocal <args>
endif

" CompilerSet errorformat=
"       \%E\ %#[error]\ %f:%l:\ %m,%C\ %#[error]\ %p^,%-C%.%#,%Z,
"       \%W\ %#[warn]\ %f:%l:\ %m,%C\ %#[warn]\ %p^,%-C%.%#,%Z,
"       \%-G%.%#
" CompilerSet errorformat=
"       \TRACE:\ %f:%l\ -\ %m,
"       \MESSG:\ %m,
"       \%-G%.%#

CompilerSet errorformat=
      \%s\ %f:\ line\ %l:\ %m,
      \%f:\ line\ %l:\ %m,
      \TRACE_AT:\ %f:%l:\ %m,
      \TRACE_AT:\ %f:%l:\ 

" if 0
"     CompilerSet! makeprg=vim_nc_selfcap
"     CompilerSet! makeprg=vimcap
" endif

if filereadable("Makefile")
  CompilerSet makeprg=make
endif
