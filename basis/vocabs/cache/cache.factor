! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs fry kernel namespaces memoize init sequences vocabs
vocabs.hierarchy vocabs.loader vocabs.metadata vocabs.refresh
words ;
IN: vocabs.cache

: reset-cache ( vocab -- )
    vocab-name
    [ root-cache get delete-at ]
    [
        \ vocab-file-lines "memoize" word-prop swap
        '[ drop first vocab-name _ = ] assoc-reject! drop
    ] bi
    \ all-disk-vocabs-recursive reset-memoized
    \ all-authors reset-memoized
    \ all-tags reset-memoized ;

SINGLETON: cache-observer

<PRIVATE

: forgot-vocab? ( vocab -- ? )
    vocab-name dictionary get key? not ;

PRIVATE>

M: cache-observer vocab-changed
    drop dup forgot-vocab? [ reset-cache ] [ drop ] if ;

[
    f changed-vocabs set-global
    cache-observer add-vocab-observer
] "vocabs.cache" add-startup-hook
