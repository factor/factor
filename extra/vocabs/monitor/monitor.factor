USING: threads io.files io.monitors init kernel tools.browser
continuations ;
IN: vocabs.monitor

! Use file system change monitoring to flush the tags/authors
! cache
: update-thread ( monitor -- )
    dup next-change 2drop reset-cache update-thread ;

: start-update-thread
    #! Silently ignore errors during monitor creation since
    #! monitors are not supported on all platforms.
    [
        [ "" resource-path t <monitor> ] [ drop f ] recover
        [ update-thread ] when*
    ] in-thread ;

[ start-update-thread ] "tools.browser" add-init-hook
