! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: compiler.units continuations fry kernel vocabs vocabs.parser ;
IN: vocabs.generated

: generate-vocab ( vocab-name quot -- vocab )
    [ dup lookup-vocab [ ] ] dip '[
        [
            [
                [ _ with-current-vocab ] [ ] [ forget-vocab ] cleanup
            ] with-compilation-unit
        ] keep
    ] [ or? ] 2dip if ; inline
