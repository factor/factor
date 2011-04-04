" Code formatting settings loosely adapted from:
" http://concatenative.org/wiki/view/Factor/Coding%20Style

" Tabs are not allowed in Factor source files; use four spaces instead.
setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4

" Try to limit lines to 64 characters, except for documentation, which can be
" any length.
if expand("%:t") !~ "-docs\.factor$"
    setlocal textwidth=64

    " Mark anything in column 64 or beyond as a syntax error.
    match Error /\%>63v.\+/
endif

" Teach Vim what comments look like.
setlocal comments+=b:!,b:#!
