" if exists('g:loaded_run_nvim') | finish | endif " prevent loading file twice
" 
" let s:save_cpo = &cpo " save user coptions
" set cpo&vim " reset them to defaults
" 
" " command to run our plugin
" command! Run lua require'run'.run()
" 
" let &cpo = s:save_cpo " and restore after
" unlet s:save_cpo
" 
" let g:loaded_run_nvim = 1

lua require("run").init()
