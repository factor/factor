USING: threads io.files io.monitors init kernel tools.browser ;
IN: vocabs.monitor

! Use file system change monitoring to flush the tags/authors
! cache
: update-thread ( monitor -- )
    dup next-change 2drop reset-cache update-thread ;

: start-update-thread
    [
        "" resource-path t <monitor> update-thread
    ] in-thread ;

[ start-update-thread ] "tools.browser" add-init-hook
