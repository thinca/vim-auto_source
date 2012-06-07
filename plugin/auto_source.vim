" |:source| the updated scripts automatically.
" Version: 1.0
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

if exists('g:loaded_auto_source')
  finish
endif
let g:loaded_auto_source = 1

let s:save_cpo = &cpo
set cpo&vim

command! -bang -bar -nargs=* -complete=file
\        AutoSource call auto_source#_command([<f-args>], <bang>0)

augroup plugin-auto_source
  autocmd!
  autocmd SourcePre * call auto_source#register(expand('<afile>'), 1)
  autocmd CursorHold,FocusGained * nested
  \       call auto_source#source(g:auto_source#silent)
augroup END

function! s:register()
  redir => res
    silent scriptnames
  redir END
  for line in split(res, "\n")
    call auto_source#register(matchstr(line, '^\s*\d\+:\s*\zs.*'), 1)
  endfor
endfunction
call s:register()
delfunction s:register


let &cpo = s:save_cpo
unlet s:save_cpo
