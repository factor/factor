! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs command-line concurrency.messaging
continuations init io.backend io.files io.monitors io.pathnames
kernel namespaces sequences sets splitting threads
tr vocabs vocabs.loader vocabs.refresh vocabs.cache ;
IN: vocabs.refresh.monitor

TR: convert-separators "/\\" ".." ;

: vocab-dir>vocab-name ( path -- vocab )
    trim-head-separators
    trim-tail-separators
    convert-separators ;

: path>vocab-name ( path -- vocab )
    dup ".factor" tail? [ parent-directory ] when ;

: chop-vocab-root ( path -- path' )
    "resource:" prepend-path normalize-path
    dup vocab-roots get
    [ normalize-path ] map
    [ head? ] with find nip
    ?head drop ;

: path>vocab ( path -- vocab )
    chop-vocab-root path>vocab-name vocab-dir>vocab-name ;

: monitor-loop ( -- )
    #! On OS X, monitors give us the full path, so we chop it
    #! off if its there.
    receive path>> path>vocab changed-vocab
    reset-cache
    monitor-loop ;

: add-monitor-for-path ( path -- )
    dup exists? [ t my-mailbox (monitor) ] when drop ;

: monitor-thread ( -- )
    [
        [
            vocab-roots get prune [ add-monitor-for-path ] each

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
    "-no-monitors" (command-line) member?
    [ start-monitor-thread ] unless
] "vocabs.refresh.monitor" add-init-hook
