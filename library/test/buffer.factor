IN: temporary USING: test kernel kernel-internals ;

: with-buffer ( size quot -- )
    >r <buffer> r> keep buffer-free ;

: buffer-test1 ( -- buffer )
    "quux" swap [ buffer-append ] keep ;

: buffer-test2 ( -- buffer )
    6 [
        "abcdef" swap [ buffer-append ] keep [ 3 swap buffer-consume ] keep
        buffer-contents
    ] with-buffer ;

[ 8 ] [ 12 [ buffer-test1 buffer-capacity ] with-buffer ] unit-test
[ "def" ] [ buffer-test2 ] unit-test 
