! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs init kernel memoize namespaces sequences vocabs
vocabs.hierarchy vocabs.loader vocabs.metadata vocabs.refresh
words ;
IN: vocabs.cache

: reset-vocab-cache ( vocab -- )
    vocab-name
    [ root-cache get delete-at ]
    [
        \ vocab-file-lines "memoize" word-prop swap
        '[ drop first vocab-name _ = ] assoc-reject! drop
    ] bi ;

: reset-disk-cache ( -- )
    \ all-disk-vocabs-recursive reset-memoized
    \ all-authors reset-memoized
    \ all-tags reset-memoized ;

: reset-cache ( vocab -- )
    reset-vocab-cache reset-disk-cache ;

SINGLETON: cache-observer

<PRIVATE

: forgot-vocab? ( vocab -- ? )
    vocab-name dictionary get key? not ;

PRIVATE>

M: cache-observer vocab-changed
    drop dup forgot-vocab? [ reset-vocab-cache ] [ drop ] if
    reset-disk-cache ;

STARTUP-HOOK: [
    f changed-vocabs set-global
    cache-observer add-vocab-observer
]
