! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: threads io.files io.monitors init kernel
vocabs vocabs.loader tools.vocabs namespaces continuations
sequences splitting assocs command-line ;
IN: tools.vocabs.monitor

: vocab-dir>vocab-name ( path -- vocab )
    left-trim-separators right-trim-separators
    { { CHAR: / CHAR: . } { CHAR: \\ CHAR: . } } substitute ;

: path>vocab-name ( path -- vocab )
    dup ".factor" tail? [ parent-directory ] when ;

: chop-vocab-root ( path -- path' )
    "resource:" prepend-path (normalize-path)
    dup vocab-roots get
    [ (normalize-path) ] map
    [ head? ] with find nip
    ?head drop ;

: path>vocab ( path -- vocab )
    chop-vocab-root path>vocab-name vocab-dir>vocab-name ;

: monitor-loop ( monitor -- )
    #! On OS X, monitors give us the full path, so we chop it
    #! off if its there.
    dup next-change drop path>vocab changed-vocab
    reset-cache
    monitor-loop ;

: monitor-thread ( -- )
    [
        [
            "" resource-path t <monitor>
            
            H{ } clone changed-vocabs set-global
            vocabs [ changed-vocab ] each
            
            monitor-loop
        ] with-monitors
    ] ignore-errors ;

: start-monitor-thread ( -- )
    #! Silently ignore errors during monitor creation since
    #! monitors are not supported on all platforms.
    [ monitor-thread ] "Vocabulary monitor" spawn drop ;

[
    "-no-monitors" cli-args member? [
        start-monitor-thread
    ] unless
] "tools.vocabs.monitor" add-init-hook
