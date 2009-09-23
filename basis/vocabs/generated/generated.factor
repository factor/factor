! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: compiler.units fry kernel vocabs vocabs.parser ;
IN: vocabs.generated

: generate-vocab ( vocab-name quot -- vocab )
    [ dup vocab [ ] ] dip '[
        [
            [
                 _ with-current-vocab
            ] with-compilation-unit
        ] keep
    ] ?if ; inline
