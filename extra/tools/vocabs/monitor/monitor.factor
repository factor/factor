! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: threads io.files io.monitors init kernel
vocabs.loader tools.vocabs namespaces continuations ;
IN: tools.vocabs.monitor

! Use file system change monitoring to flush the tags/authors
! cache
SYMBOL: vocab-monitor

: monitor-thread ( -- )
    vocab-monitor get-global
    next-change 2drop
    t sources-changed? set-global reset-cache ;

: start-monitor-thread
    #! Silently ignore errors during monitor creation since
    #! monitors are not supported on all platforms.
    [
        "" resource-path t <monitor> vocab-monitor set-global
        [ monitor-thread t ] "Vocabulary monitor" spawn-server drop
    ] ignore-errors ;

[ start-monitor-thread ] "tools.vocabs.monitor" add-init-hook
