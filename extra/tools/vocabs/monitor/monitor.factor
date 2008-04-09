! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: threads io.files io.monitors init kernel
vocabs vocabs.loader tools.vocabs namespaces continuations
sequences splitting assocs ;
IN: tools.vocabs.monitor

: vocab-dir>vocab-name ( path -- vocab )
    left-trim-separators right-trim-separators
    { { CHAR: / CHAR: . } { CHAR: \\ CHAR: . } } substitute ;

: path>vocab-name ( path -- vocab )
    dup ".factor" tail? [ parent-directory ] when
    dup [ vocab-dir>vocab-name ] when ;

: changed-vocab ( vocab -- )
    dup vocab
    [ dup changed-vocabs get-global set-at ] [ drop ] if ;

: monitor-thread ( path monitor -- )
    #! On OS X, monitors give us the full path, so we chop it
    #! off if its there.
    next-change drop swap ?head drop
    path>vocab-name changed-vocab reset-cache ;

: start-monitor-thread ( root -- )
    #! Silently ignore errors during monitor creation since
    #! monitors are not supported on all platforms.
    (normalize-path) dup t <monitor> [ monitor-thread t ] 2curry
    "Vocabulary monitor" spawn-server drop ;

: start-monitor-threads ( -- )
    [
        vocab-roots get [ start-monitor-thread ] each
        H{ } clone changed-vocabs set-global
        vocabs [ changed-vocab ] each
    ] ignore-errors ;

[ start-monitor-threads ] "tools.vocabs.monitor" add-init-hook
