
nnoremap <silent><buffer> gh :silent keeppatterns g@\v/\.[^\/]+/?$@d _<cr>
nnoremap <silent><buffer> t :call dirvish#open('tabedit', 0)<CR>
nmap <buffer> r R
nmap <buffer> <Leader>cd :cd %<CR>R:pwd<CR>
nmap <buffer> <Leader>ed :e %
nmap <buffer> <Leader>md :Mkdir %
nmap <buffer> <Leader>~ :e $HOME/<CR>
nmap <buffer> <Leader>// :e /<CR>
nmap <buffer> <Leader><cr> :Viewer <C-R><C-l><CR>
nmap <buffer> <Leader><Leader><cr> :Executor <C-R><C-l><CR>
nmap <buffer> <Leader><C-g> :Grepper -dir file<CR>
nnoremap <F10><Space> :TS -cwd=<C-r>=expand("%:p:h")<CR><CR>
nnoremap <Leader>gd :e <C-r>=getcwd(-1)<CR><CR>
nmap <F10>G :Grepper -dir file
setlocal buflisted

