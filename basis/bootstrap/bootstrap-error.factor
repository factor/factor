USING: continuations kernel io debugger vocabs words system namespaces ;

:c
:error

"listener" lookup-vocab
[ restarts. vocab-main execute ]
[ error get die ] if*
1 exit
