USING: concurrency.threads io.files io.monitors init kernel
tools.browser ;
IN: vocabs.monitor

! Use file system change monitoring to flush the tags/authors
! cache
: (monitor-thread) ( monitor -- )
    dup next-change 2drop reset-cache (monitor-thread) ;

: monitor-thread ( -- )
    "" resource-path t <monitor> (monitor-thread) ;

: start-monitor-thread
    #! Silently ignore errors during monitor creation since
    #! monitors are not supported on all platforms.
    [ monitor-thread ] "Vocabulary monitor" spawn drop ;

[ start-monitor-thread ] "vocabs.monitor" add-init-hook
