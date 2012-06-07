" |:source| the updated scripts automatically.
" Version: 1.1
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

let s:save_cpo = &cpo
set cpo&vim

function! auto_source#register(file, ...)
  let auto = a:0 && a:1
  let file = s:normalize_path(a:file)
  if file ==# s:self_file || !filereadable(file) ||
  \  (auto && !s:check(file))
    return 0
  endif
  let s:files[file] = getftime(file)
  return 1
endfunction

function! auto_source#unregister(file)
  let file = s:normalize_path(a:file)
  if has_key(s:files, file)
    call remove(s:files, file)
    return 1
  endif
  return 0
endfunction

function! auto_source#list()
  return keys(s:files)
endfunction

function! auto_source#check()
  return keys(filter(copy(s:files), 'getftime(v:key) != v:val'))
endfunction

function! auto_source#source(...)
  let silent = a:0 && a:1
  for file in auto_source#check()
    if !filereadable(file)
      call auto_source#unregister(file)
      continue
    endif
    let s:files[file] = getftime(file)
    if g:auto_source#unlet_loaded && file =~# '/plugin/'
      unlet! g:loaded_{fnamemodify(file, ':r:s?.*/plugin/??:gs?\W?_?')}
    endif
    source `=file`
    if !silent
      echomsg 'auto_source: sourced: ' . file
    endif
  endfor
endfunction

function! auto_source#_command(files, bang)
  if a:bang
    if empty(a:files)
      call auto_source#source()
    else
      for file in a:files
        if auto_source#unregister(file)
          echomsg 'auto_source: unregistered: ' . file
        endif
      endfor
    endif
  else
    if empty(a:files)
      echo join(sort(auto_source#list()), "\n")
    else
      for file in a:files
        if auto_source#register(file)
          echomsg 'auto_source: registered: ' . file
        endif
      endfor
    endif
  endif
endfunction

function! s:normalize_path(path)
  return fnamemodify(resolve(a:path), ':p:gs?\\\+?/?')
endfunction

function! s:check(file)
  return s:match(a:file, g:auto_source#include, 1) &&
  \     !s:match(a:file, g:auto_source#exclude, 0)
endfunction

function! s:match(str, pat, empty)
  if empty(a:pat)
    return a:empty
  endif
  for pat in s:to_list(a:pat)
    if a:str =~# pat
      return 1
    endif
  endfor
  return 0
endfunction

function! s:to_list(expr)
  return type(a:expr) == type([]) ? a:expr : [a:expr]
endfunction

function! s:set_default(var, val)
  if !exists(a:var)
    let {a:var} = a:val
  endif
endfunction

let s:files = {}
let s:self_file = s:normalize_path(expand('<sfile>'))

call s:set_default('g:auto_source#include', '')
call s:set_default('g:auto_source#exclude', '')
call s:set_default('g:auto_source#silent', 0)
call s:set_default('g:auto_source#unlet_loaded', 1)

let &cpo = s:save_cpo
