" Location:     autoload/factor.vim

" Section: Utilities

let s:path_sep_pattern = (exists('+shellslash') ? '[\\/]' : '/')..'\+'

" Remove the separator at the end of a:path.
" (Modified from vim-jp/vital.vim.)
function! s:remove_last_path_sep(path) abort
  return substitute(a:path, s:path_sep_pattern..'$', '', '')
endfunction

function! s:ensure_last_path_sep(path) abort
  return a:path =~# s:path_sep_pattern..'$' ? a:path
        \ : a:path..(!exists('+shellslash') || &shellslash ? '/' : '\')
endfunction

if !exists('g:FactorGlobEscape')
  if exists('+shellslash') && !&shellslash
    let g:FactorGlobEscape = '*[]?`{$'
  else
    let g:FactorGlobEscape = '*[]?`{$\'
  endif
endif

" (Based on tpope/vim-scriptease.)
function! s:glob(pattern, nosuf = 0, alllinks = 0) abort
  if v:version >= 704
    return glob(a:pattern, a:nosuf, 1, a:alllinks)
  else
    return split(glob(a:pattern, a:nosuf), "\n")
  endif
endfunction

" Section: File discovery & globbing

function! factor#get_vocab_roots() abort
  if exists('g:FactorVocabRoots')
    return g:FactorVocabRoots
  endif
  if !exists('g:FactorAdditionalVocabRoots')
    try
      let g:FactorAdditionalVocabRoots = map(
            \ filter(readfile(fnamemodify('~/.factor-roots', ':p')), 'v:val !=# '''''),
            \ 's:remove_last_path_sep(v:val)')
    catch /^Vim\%((\a\+)\)\=:E484/
      let g:FactorAdditionalVocabRoots = []
    endtry
  endif
  let g:FactorVocabRoots =
        \ map(g:FactorDefaultVocabRoots + g:FactorAdditionalVocabRoots, 's:remove_last_path_sep(v:val)')
  return g:FactorVocabRoots
endfunction

function! factor#expand_vocab_roots(vocab_roots)
  let sep = !exists('+shellslash') || &shellslash ? '/' : '\'
  let expanded_vocab_roots = []
  for vocab_root in a:vocab_roots
    if vocab_root =~# '^vocab:'
      let expanded_vocab_roots_len = len(expanded_vocab_roots)
      let i = 0
      while i < expanded_vocab_roots_len
        call add(expanded_vocab_roots,
              \ s:ensure_last_path_sep(expanded_vocab_roots[i])..vocab_root[6:])
        let i += 1
      endwhile
    else
      call add(expanded_vocab_roots,
            \ vocab_root =~# '^resource:' ? g:FactorResourcePath..vocab_root[9:] : vocab_root)
    endif
  endfor
  return expanded_vocab_roots
endfunction

function! factor#detect_parent_vocab_roots(vocab_roots, fname, expr, nosuf = 0, alllinks = 0) abort
  let sep = !exists('+shellslash') || &shellslash ? '/' : '\'
  let parent_vocab_roots = []
  let expanded_vocab_roots = {}
  for expanded_vocab_root in factor#expand_vocab_roots(a:vocab_roots)
    let expanded_vocab_roots[fnamemodify(expanded_vocab_root, ':p')] = 1
  endfor
  let current_path = fnamemodify(a:fname, ':p')
  while current_path !=# ''
    let current_path_glob = s:ensure_last_path_sep(escape(current_path, g:FactorGlobEscape))
    let paths = s:glob(current_path_glob..a:expr, a:nosuf, a:alllinks)
    for path in paths
      let path = fnamemodify(path, ':p')
      if get(expanded_vocab_roots, path, 0)
        call add(parent_vocab_roots, path)
      end
    endfor
    let current_path = current_path ==# '/' ? '' : fnamemodify(current_path, ':h')
  endwhile
  return parent_vocab_roots
endfunction

" (Based on tpope/vim-scriptease.)
function! factor#glob(expr, vocab = 0, trailing_dir_sep = 0, output = 0, nosuf = 0, alllinks = 0) abort
  let sep = !exists('+shellslash') || &shellslash ? '/' : '\'
  let expr = a:vocab ? 'vocab:'..substitute(a:expr, '\.', sep, 'g') : a:expr
  let found = {}
  if expr =~# '^resource:'
    for path_root in s:glob(escape(g:FactorResourcePath, g:FactorGlobEscape), 1, 1)
      let path_root = fnamemodify(path_root, ':p')
      for path in s:glob(escape(path_root, g:FactorGlobEscape)..expr[9:], a:nosuf, a:alllinks)
        if a:trailing_dir_sep == 1 | let path = fnamemodify(path, ':p') | elseif a:trailing_dir_sep == 2
          let path = s:remove_last_path_sep(fnamemodify(path, ':p'))
        endif
        let path = a:output == 0 ? 'resource:'..path[strlen(path_root):] : path
        let found[path] = 1
      endfor
    endfor
  elseif expr =~# '^vocab:'
    let expanded_vocab_roots = factor#expand_vocab_roots(factor#get_vocab_roots())
    for vocab_root in expanded_vocab_roots
      for path_root in s:glob(escape(vocab_root, g:FactorGlobEscape), 1, 1)
        let path_root = fnamemodify(path_root, ':p')
        for path in s:glob(escape(path_root, g:FactorGlobEscape)..expr[6:], a:nosuf, a:alllinks)
          if a:trailing_dir_sep == 1 | let path = fnamemodify(path, ':p') | elseif a:trailing_dir_sep == 2
            let path = s:remove_last_path_sep(fnamemodify(path, ':p'))
          endif
          let path = a:output == 0 ? 'vocab:'..path[strlen(path_root):] : a:output == 1 ? path
                \ : substitute(path[strlen(path_root):], s:path_sep_pattern, '.', 'g')
          let found[path] = 1
        endfor
      endfor
    endfor
  else
    if expr =~# '^\%[resource]\*' | let found['resource:'] = 1 | endif
    if expr =~# '^\%[vocab]\*' | let found['vocab:'] = 1 | endif
    for expr_path in s:glob(expr, 1, 1)
      let expr_path = fnamemodify(expr_path, ':p')
      for vocab_root in factor#get_vocab_roots()
        if vocab_root =~# '^resource:|^vocab:' | continue | endif
        for path_root in s:glob(escape(vocab_root, g:FactorGlobEscape), 1, 1)
          let path_root = fnamemodify(path_root, ':p')
          if expr_path[0:strlen(path_root)] !=# path_root | break | endif
          for path in s:glob(escape(path_root, g:FactorGlobEscape)..expr[strlen(path_root):], a:nosuf, a:alllinks)
            if a:trailing_dir_sep == 1 | let path = fnamemodify(path, ':p') | elseif a:trailing_dir_sep == 2
              let path = s:remove_last_path_sep(fnamemodify(path, ':p'))
            endif
            let path = a:output == 0 ? path[strlen(path_root):] : a:output == 1 ? path
                  \ : substitute(path[strlen(path_root):], s:path_sep_pattern, '.', 'g')
            let found[path] = 1
          endfor
        endfor
      endfor
    endfor
  endif
  return sort(keys(found))
endfunction

" Section: Completion

function! factor#complete_glob(arg_lead, cmd_line, cursor_pos) abort
  return factor#glob(a:arg_lead..'*', 0, 1)
endfunction

function! factor#complete_vocab_glob(arg_lead, cmd_line, cursor_pos) abort
  return factor#glob(a:arg_lead..'*.', 1, 2, 2)
endfunction

" Section: Commands

function! factor#go_to_vocab_command(count, cmd, vocab) abort
  let sep = !exists('+shellslash') || &shellslash ? '/' : '\'
  let vocab_glob = 'vocab:'..substitute(a:vocab, '\.', sep, 'g')..sep..matchstr(a:vocab, '[^.]*$')..'.factor'
  let vocab_file = get(factor#glob(vocab_glob, 0, 2, 1), a:count - 1, 0)
  if !!vocab_file
    return 'echoerr '..string('Factor: Can''t find vocabulary '..a:vocab..' in vocabulary roots')
  endif
  return a:cmd..' '..fnameescape(vocab_file)
endfunction

function! factor#make_vocab_command(count, cmd, vocab) abort
  let sep = !exists('+shellslash') || &shellslash ? '/' : '\'
  let new_vocab_root = FactorNewVocabRoot()
  let vocab_dir = get(factor#glob(new_vocab_root, 0, 1, 1), a:count - 1, 0)
  if !!vocab_dir
      return 'echoerr '..string('Factor: Can''t find new vocabulary root '..
            \ string(new_vocab_root)..' in vocabulary roots')
  endif
  let vocab_dir = fnamemodify(vocab_dir..substitute(a:vocab, '\.', sep, 'g'), ':~')
  echo vocab_dir
  let vocab_file = vocab_dir..sep..fnamemodify(vocab_dir, ':t')..'.factor'
  echo vocab_file
  call mkdir(vocab_dir, 'p')
  return a:cmd..' '..fnameescape(vocab_file)
endfunction

" vim:sw=2:et:
