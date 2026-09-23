USING: accessors alien.c-types alien.data arrays assocs
combinators.short-circuit compiler.cfg.build-stack-frame
compiler.cfg.stack-frame compiler.errors compiler.units continuations
definitions grouping kernel layouts memory namespaces quotations ranges
sequences specialized-arrays stack-checker tools.test words ;
SPECIALIZED-ARRAY: char
IN: compiler.tests.large-stack-frames

: frame-barrier ( -- ) ;

: capture-inner ( -- callstack ) get-callstack frame-barrier ;

: capture-outer ( -- callstack ) capture-inner frame-barrier ;

: large-frame-word ( size quot -- word )
    [ char swap 2array 1array ] dip
    [ [ drop 65 ] map! ] prepend \ with-scoped-allocation 3array >quotation
    [ dup infer define-temp ] with-compilation-unit ;

: call-large-frame ( word -- obj ) execute( -- obj ) frame-barrier ;

: large-frame-sizes ( -- seq ) 4032 4112 16 <range> 65536 suffix ;

: large-frame-compile-error ( -- error/f )
    max-stack-frame-size [ drop ] large-frame-word
    [ [ execute( -- ) f ] [ nip ] recover ]
    [ [ forget ] with-compilation-unit ] bi ;

{ t t } [
    compiler-errors get-global assoc-size
    large-frame-compile-error
    { [ not-compiled? ] [ error>> stack-frame-too-large? ] } 1&&
    swap compiler-errors get-global assoc-size =
] unit-test

64-bit? [
    { t } [
        large-frame-sizes [
            [ drop capture-outer ] large-frame-word call-large-frame
            callstack>array 3 group [ first ] map
            \ call-large-frame swap member?
        ] all?
    ] unit-test

    { t } [
        large-frame-sizes [
            [ compact-gc first ] large-frame-word call-large-frame 65 =
        ] all?
    ] unit-test
] when
