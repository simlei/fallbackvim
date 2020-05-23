let SessionLoad = 1
if &cp | set nocp | endif
let s:so_save = &so | let s:siso_save = &siso | set so=0 siso=0
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd /media/shared/ubuntu18/home/simon/.vim/pack/standalone/opt/YouCompleteMe
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
set shortmess=aoO
argglobal
%argdel
tabnew
tabrewind
edit third_party/ycmd/TESTS.md
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd w
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe 'vert 1resize ' . ((&columns * 118 + 119) / 238)
exe 'vert 2resize ' . ((&columns * 119 + 119) / 238)
argglobal
setlocal fdm=expr
setlocal fde=pandoc#folding#FoldExpr()
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
let s:l = 1 - ((0 * winheight(0) + 31) / 63)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
1
normal! 0
wincmd w
argglobal
if bufexists("third_party/ycmd/JAVA_SUPPORT.md") | buffer third_party/ycmd/JAVA_SUPPORT.md | else | edit third_party/ycmd/JAVA_SUPPORT.md | endif
setlocal fdm=manual
setlocal fde=pandoc#folding#FoldExpr()
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=3
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
24,52fold
71,83fold
53,83fold
84,104fold
105,131fold
132,154fold
155,172fold
175,181fold
182,198fold
199,204fold
205,227fold
173,227fold
4,227fold
4
normal! zo
53
normal! zo
let s:l = 131 - ((59 * winheight(0) + 31) / 63)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
131
normal! 0
lcd /media/shared/ubuntu18/home/simon/sandbox/featurelist/ct_functionlist/src
wincmd w
exe 'vert 1resize ' . ((&columns * 118 + 119) / 238)
exe 'vert 2resize ' . ((&columns * 119 + 119) / 238)
tabnext
edit /media/shared/ubuntu18/home/simon/.vim/pack/standalone/opt/YouCompleteMe/third_party/ycmd/TESTS.md
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd _ | wincmd |
split
wincmd _ | wincmd |
split
2wincmd k
wincmd w
wincmd w
wincmd w
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
wincmd =
argglobal
setlocal fdm=expr
setlocal fde=pandoc#folding#FoldExpr()
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=3
setlocal fml=1
setlocal fdn=20
setlocal fen
let s:l = 1 - ((0 * winheight(0) + 10) / 20)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
1
normal! 0
wincmd w
argglobal
if bufexists("/media/shared/ts/TSE/tsedev/project/temp-standalone-env.bash") | buffer /media/shared/ts/TSE/tsedev/project/temp-standalone-env.bash | else | edit /media/shared/ts/TSE/tsedev/project/temp-standalone-env.bash | endif
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 5 - ((4 * winheight(0) + 10) / 20)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
5
normal! 0
lcd /media/shared/ubuntu18/home/simon/sandbox/featurelist/ct_functionlist/src
wincmd w
argglobal
if bufexists("/media/shared/ts/TSE/tsedev/project/ide.vim") | buffer /media/shared/ts/TSE/tsedev/project/ide.vim | else | edit /media/shared/ts/TSE/tsedev/project/ide.vim | endif
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 1 - ((0 * winheight(0) + 10) / 21)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
1
normal! 0
wincmd w
argglobal
if bufexists("/tmp/vD4vRtY/19.sh") | buffer /tmp/vD4vRtY/19.sh | else | edit /tmp/vD4vRtY/19.sh | endif
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 1 - ((0 * winheight(0) + 7) / 15)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
1
normal! 0
lcd /media/shared/ubuntu18/home/simon/.vim/pack/standalone/opt/YouCompleteMe/project
wincmd w
4wincmd w
wincmd =
tabnext 2
badd +0 /media/shared/ubuntu18/home/simon/.vim/pack/standalone/opt/YouCompleteMe/third_party/ycmd/JAVA_SUPPORT.md
badd +1088 /media/shared/ubuntu18/home/simon/.vim/pack/standalone/opt/YouCompleteMe/README.md
badd +489 /media/shared/ubuntu18/home/simon/.vim/pack/standalone/opt/YouCompleteMe/third_party/ycmd/README.md
badd +1 /media/shared/ubuntu18/home/simon/.vim/pack/standalone/opt/YouCompleteMe/third_party/ycmd/TESTS.md
badd +0 /media/shared/ts/TSE/tsedev/project/ide.vim
badd +35 /media/shared/ubuntu18/home/simon/.vim/pack/standalone/opt/YouCompleteMe/project/ide.vim
badd +1 /media/shared/ubuntu18/home/simon/.vim/pack/standalone/opt/YouCompleteMe/project/dispatches.bash
badd +6 /media/shared/ubuntu18/home/simon/.vim/pack/standalone/opt/YouCompleteMe/project/ide
badd +0 /media/shared/ts/TSE/tsedev/project/temp-standalone-env.bash
badd +0 /tmp/vD4vRtY/19.sh
if exists('s:wipebuf') && len(win_findbuf(s:wipebuf)) == 0
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20 shortmess=filnxtToOSc
set winminheight=1 winminwidth=1
let s:sx = expand("<sfile>:p:r")."x.vim"
if file_readable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &so = s:so_save | let &siso = s:siso_save
nohlsearch
let g:this_session = v:this_session
let g:this_obsession = v:this_session
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
