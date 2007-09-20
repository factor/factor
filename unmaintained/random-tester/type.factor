USING: arrays errors generic hashtables io kernel lazy-lists math
memory modules namespaces null-stream prettyprint random-tester2
quotations sequences strings
tools vectors words ;
IN: random-tester

: inert ;
TUPLE: inert-object ;

: inputs ( -- seq )
    {
        0 -1 -1000000000000000000000000 2
        inert
        -29/2
        1000000000000000000000000000000/1111111111111111111111111111111111
        3/4
            -1000000000000000000000000/111111111111111111
        -3.14 1/0. 0.0 -1/0. 3.14 0/0.
        20102101010100110110
        C{ 1 -1 }
        W{ 55 }
        { }
        f  t
        ""
        "asdf"
        [ ]
        ! DLL" libm.dylib"
        ! ALIEN: 1
        T{ inert-object f }
    }
    [
        H{ { 1 2 } { "asdf" "foo" } } clone ,
        H{ } clone ,
        V{ 1 0 65536 } clone ,
        V{ } clone ,
        SBUF" " clone ,
        B{ } clone ,
        ?{ } clone ,
    ] { } make append ;

TUPLE: success quot inputs outputs input-types output-types ;

SYMBOL: err
SYMBOL: last-time
SYMBOL: quot
SYMBOL: output
SYMBOL: input
SYMBOL: silent
t silent set-global

: test-quot ( input quot -- success/f )
    ! 2dup swap . . flush
    ! dup [ hash+ ] = [ 2dup . . flush ] when
    err off
    quot set input set
    silent get [
        quot get last-time get = [
            quot get
            dup . flush
            last-time set
        ] unless
    ] unless
    [
        clear
        input get >vector set-datastack quot get
        [ [ [ call ] { } make drop ] with-null-stream ]
        [ err on ] recover
        datastack clone output set
    ] with-saved-datastack
    err get [
        f
    ] [
        quot get input get output get
        2dup [ [ type ] map ] 2apply <success>
    ] if ;
    
: test-inputs ( word -- seq )
    [
        [ word-input-count inputs swap ] keep
        1quotation [
            test-quot [ , ] when*
        ] curry each-permutation
    ] { } make ;
    
: >types ( quot -- seq )
    map concat prune natural-sort ;

: >output-types ( seq -- seq )
    #! input seq is the result of test-inputs
    [ success-output-types ] >types ;

: >input-types ( seq -- seq )
    #! input seq is the result of test-inputs
    [ success-input-types ] >types ;
  
TUPLE: typed quot inputs outputs ;

: successes>typed ( seq -- typed )
    dup empty? [
        drop f { } clone { } clone <typed>
    ] [
        [ first success-quot ] keep
        [ >input-types ] keep >output-types <typed>
    ] if ;

: word>type-check ( word -- tuple )
    [
        dup test-inputs
        successes>typed ,
    ] curry [ with-saved-datastack ] { } make first ;

: type>name ( n -- string )
    dup integer? [
        {
            "fixnum"
            "bignum"
            "word"
            "obj"
            "ratio"
            "float"
            "complex"
            "wrapper"
            "array"
            "boolean"
            "hashtable"
            "vector"
            "string"
            "sbuf"
            "quotation"
            "dll"
            "alien"
            "tuple"
        } nth
    ] when ;
    
: replace-subseqs ( seq new old -- seq )
    [
        swapd split1 [ append swap add ] [ nip ] if*
    ] 2each ;

: type-array>name ( seq -- seq )
    {
        { "object" { 0 1 2 4 5 6 7 8 9 10 11 12 13 14 15 16 17 } }
        { "seq3" { 0 1 8 9 11 12 13 14 } }
        { "seq2" { 0 8 9 11 12 13 14 } }
        { "seq" { 8 9 11 12 13 14 } }
        { "number" { 0 1 4 5 6 } }
        { "real" { 0 1 4 5 } }
        { "rational" { 0 1 4 } }
        { "integer" { 0 1 } }
        { "float/complex" { 5 6 } }
        { "word/f" { 2 9 } }
    } flip first2 replace-subseqs [ type>name ] map ;

: buggy?
    [ word>type-check ] catch [
        drop f
    ] [
        2array [ [ type-array>name ] map ] map
        [ [ length 1 = ] all? ] all? not
    ] if ;

: variable-stack-effect?
    [ word>type-check ] catch nip ;

: find-words ( quot -- seq )
    \ safe-words get
    [
        word-input-count 3 <=
    ] subset swap subset ;

: find-safe ( -- seq ) [ buggy? not ] find-words ;

: find-buggy ( -- seq ) [ buggy? ] find-words ;

: test-word ( output input word -- ? )
    1quotation test-quot dup [
        success-outputs sequence=
    ] [
        nip
    ] if ;

: word-finder ( inputs outputs -- seq )
    swap safe-words
    [ >r 2dup r> test-word ] subset 2nip ;

: (enumeration-test)
    [
        [ stack-effect effect-in length ] catch [ 4 < ] unless
    ] subset [ [ test-inputs successes>typed , ] each ] { } make ;

! full-gc finds corrupted memory faster

: enumeration-test ( -- seq )
    [
        \ safe-words get
        f silent set
        (enumeration-test)
    ] with-scope ;
    
: array>all-quots ( seq n -- seq )
    [
        [ 1+ [ >quotation , ] each-permutation ] each-with
    ] { } make ;

: array>all ( seq n -- seq )
    dupd array>all-quots append ;

: quot-finder ( inputs outputs -- seq )
    swap safe-words 2 array>all
    [
        3 [ >quotation >r 2dup r> [ test-quot ] keep
        swap [ , ] [ drop ] if ] each-permutation
    ] { } make ;

: word-frequency ( -- alist )
    all-words [ dup usage length 2array ] map sort-values ;

