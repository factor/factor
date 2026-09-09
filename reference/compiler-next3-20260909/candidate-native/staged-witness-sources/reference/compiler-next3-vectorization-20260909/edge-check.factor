! Run after native-check definitions, before its final exit in the test launcher.
USING: accessors alien.accessors byte-arrays compiler-next3.slp.check
benchmark.scalar-mixing kernel locals math namespaces sequences ;
IN: compiler-next3.slp.edges

:: transform-buffer ( bytes offset n same-address? word -- bytes )
    n [| i |
        offset i 16 * + :> at
        same-address? at at 8 + ? :> other
        bytes at alien-unsigned-8 bytes other alien-unsigned-8
        0x13579 17 word execute( x y key increment -- a b ) :> ( a b )
        a bytes at set-alien-unsigned-8
        b bytes other set-alien-unsigned-8
    ] each-integer
    bytes ;

:: check-buffers ( -- )
    { 0 1 2 3 7 8 9 31 } [| n |
        { 0 1 7 } [| offset |
            { f t } [| same-address? |
                n 16 * offset + 8 + <byte-array> :> bytes
                n [| i |
                    i 13 * bytes offset i 16 * + set-alien-unsigned-8
                    i 29 * bytes offset i 16 * + 8 + set-alien-unsigned-8
                ] each-integer
                bytes clone offset n same-address? scalar-word get transform-buffer
                bytes clone offset n same-address? packed-word get transform-buffer assert=
            ] each
        ] each
    ] each ;
check-buffers
