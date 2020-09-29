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

" Tabs are not allowed in Factor source files; use four spaces instead.
setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4

" Try to limit lines to 64 characters.
setlocal textwidth=64
augroup factorTextWidth
    au!
    au BufEnter <buffer> 2match Error /\%>64v.\+/
    au BufLeave <buffer> 2match none
augroup END

" Teach Vim what comments look like.
setlocal comments+=b:!,b:#!

" Make all of these characters part of a word (useful for skipping
" over words with w, e, and b)
setlocal iskeyword=33-126,128-255
