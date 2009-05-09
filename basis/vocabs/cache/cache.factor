! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel namespaces memoize init vocabs
vocabs.hierarchy vocabs.loader vocabs.metadata vocabs.refresh ;
IN: vocabs.cache

: reset-cache ( -- )
    root-cache get-global clear-assoc
    \ vocab-file-contents reset-memoized
    \ all-vocabs-seq reset-memoized
    \ all-authors reset-memoized
    \ all-tags reset-memoized ;

SINGLETON: cache-observer

M: cache-observer vocabs-changed drop reset-cache ;

[
    f changed-vocabs set-global
    cache-observer add-vocab-observer
] "vocabs.cache" add-init-hook