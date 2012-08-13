! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel namespaces memoize init sequences vocabs
vocabs.hierarchy vocabs.loader vocabs.metadata vocabs.refresh ;
IN: vocabs.cache

: reset-cache ( vocab -- )
    vocab-name root-cache get-global delete-at
    \ vocab-file-contents reset-memoized
    \ all-vocabs-recursive reset-memoized
    \ all-authors reset-memoized
    \ all-tags reset-memoized ;

SINGLETON: cache-observer

M: cache-observer vocab-changed drop reset-cache ;

[
    f changed-vocabs set-global
    cache-observer add-vocab-observer
] "vocabs.cache" add-startup-hook
