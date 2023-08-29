" Vim filetype plugin file
" Language: Factor
" Maintainer: Tim Allen <screwtape@froup.com>
" Last Change: 2011 Apr 05

" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

" Code formatting settings loosely adapted from:
" http://concatenative.org/wiki/view/Factor/Coding%20Style

" Tabs are not allowed in Factor source files; use four spaces
" instead.
setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4

" Try to limit lines to 64 characters.
setlocal textwidth=64 colorcolumn=+1
hi ColorColumn ctermbg=darkgrey guibg=#1e2528

" Teach Vim what comments look like.
setlocal comments+=b:!,b:#!

" Make all of these characters part of a word (useful for
" skipping over words with w, e, and b)
setlocal iskeyword=33-126,128-255

" Insert closing brackets and quotes, spaces, stack effects ...
" examples ("|" is the position of the cursor):
" |if + [ → [|] if
" [|] + <Space> → [ | ]
" [|] + <CR> → [
"     |
" ]
" (|) + <Space> → ( |-- )
" [|] + = → [=|=]
" [|] + <BS> → |
if exists("g:EnableFactorAutopairs") &&
      \g:EnableFactorAutopairs == 1

  function s:RemoveTrailingSpaces()
    let save_view = winsaveview()
    %s/ \+$//e
    call winrestview(save_view)
  endfunction

  au BufWrite <buffer> :call s:RemoveTrailingSpaces()

  function s:Insert(before, after)
    return a:before .. a:after ..
          \repeat("\<C-G>U\<Left>", strlen(a:after))
  endfunction

  function s:PadAfter()
    return getline('.')[col('.') - 1] != ' ' ?
          \s:Insert('', ' ') : ''
  endfunction

  function s:Context()
    return strpart(getline('.'), col('.') - 2, 2)
  endfunction

  function s:WiderContext()
    return strpart(getline('.'), col('.') - 3, 4)
  endfunction

  function s:OpenParenthesis()
    return (s:Context() != '()' ? s:PadAfter() : '') ..
          \s:Insert('(', ')')
  endfunction

  function s:OpenBracket()
    let context = s:Context()
    return (
          \context != '==' && context != '[]' ? s:PadAfter() : ''
          \) .. s:Insert('[', ']')
  endfunction

  function s:OpenBrace()
    return s:PadAfter() .. s:Insert('{', '}')
  endfunction

  function s:Equal()
    let context = s:Context()
    if context == '[]' || context == '=='
      return s:Insert('=', '=')
    else
      return s:Insert('=', '')
    endif
  endfunction

  function s:Quote()
    return s:Context() == '""' ? '' :
          \(s:PadAfter() .. s:Insert('"', '"'))
  endfunction

  function s:Return()
    let context = s:Context()
    let widercontext = s:WiderContext()
    if context == '[]' || context == '{}' ||
          \widercontext == '[  ]' || widercontext == '{  }'
      return "\<CR>\<C-O>O"
    else
      return "\<CR>"
    endif
  endfunction

  function s:Backspace()
    let context = s:Context()
    let widercontext = s:WiderContext()
    if widercontext == '[  ]' || widercontext == '(  )' ||
          \widercontext == '{  }' || context == '""' ||
          \context == '==' || context == '()' ||
          \context == '[]' || context == '{}'
      return "\<Del>\<BS>"
    else
      return "\<BS>"
    endif
  endfunction

  function s:Space()
    let context = s:Context()
    if context == '[]' || context == '{}' ||
          \s:WiderContext() == '(())' ||
          \strpart(getline('.'), col('.') - 5, 5) == ':> ()'
      return s:Insert(' ', ' ')
    elseif context == '()'
      return s:Insert(' ', '-- ')
    else
      return s:Insert(' ', '')
    endif
  endfunction

  inoremap <buffer> <expr> (       <SID>OpenParenthesis()
  inoremap <buffer> <expr> [       <SID>OpenBracket()
  inoremap <buffer> <expr> {       <SID>OpenBrace()
  inoremap <buffer> <expr> =       <SID>Equal()
  inoremap <buffer> <expr> "       <SID>Quote()
  inoremap <buffer> <expr> <CR>    <SID>Return()
  inoremap <buffer> <expr> <BS>    <SID>Backspace()
  inoremap <buffer> <expr> <Space> <SID>Space()

endif

" vim:sw=2:et:
