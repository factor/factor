USING: compiler errors inference interpreter io
kernel math memory namespaces prettyprint random-tester
sequences tools words ;
USING: arrays definitions generic graphs hashtables ;
IN: random-tester2

SYMBOL: wordbank
: w1
    {
        die
        set-walker-hook exit

        xref-words

        times repeat (repeat)
        supremum infimum assoc rassoc norm-sq
        product sum curry remove-all member?

        (next-power-of-2) (^) d>w/w w>h/h millis
        (random-int) ^n integer, first-bignum
        most-positive-fixnum ^ init-random next-power-of-2
        most-negative-fixnum

        clear-hash build-graph

        be>

        >r r>

        set-callstack set-word set-word-prop
        set-catchstack set-namestack set-retainstack
        set-continuation-retain continuation-catch
        set-continuation-name catchstack retainstack
        set-no-math-method-generic
        set-no-math-method-right
        set-check-method-class
        set-check-create-name
        set-nested-style-stream-style
        set-pathname-string
        set-check-create-vocab
        <check-create>
        reset-generic forget-class
        create forget-word forget-vocab forget forget-tuple
        check-create?
        remove-word-prop empty-method
        continue-with <continuation>

        define-compound define make-generic
        define-tuple define-temp define-tuple-slots
        define-writer define-predicate define-generic
        ?make-generic define-reader define-slot define-slots
        define-typecheck define-slot-word define-union
        define-generic* with-methods define-constructor
        predicate-word condition-continuation define-symbol

        ndrop

        set-word-def set-word-name
        set-word-props set-word-primitive

        close readln read1 read (lines) with-server
        stream-read
        stream-readln stream-read1 lines contents stream-copy
        stream-flush (readln)

        word-xt.

        stdio

        group

        .s

        double>bits float>bits >bignum

        intern-slots class-predicates delete (delete) prune memq?
        normalize norm vneg vmax vmin v- v+ [v-]

        bin> oct> le> be> hex> concat string>number

        gensym random-int counter <byte-array>
        <word> <client-stream> <server> <client>
        <duplex-stream>
        <file-writer> <file-reader>
        init-namespaces unxref-word set-global
        set-restart-obj
        +@ inc dec

        ! 0.0 5000000 condition
        condition
        
        callstack namespace namestack global vocabularies

        file. (file.) path+ parent-dir

        <continuation> continue-with

    }
    { "arrays" "errors" "generic" "graphs" "hashtables" "io"
    "kernel" "math" "namespaces"
    "queues" "strings" "sequences" "words" "vectors" "words" }
    [ words ] map concat diff ;

w1 wordbank set-global

: databank
    {
        ! V{ } H{ } V{ 3 } { 3 } { } "" "asdf"
        pi
        1/0. -1/0. 0/0. [ ]
        f t "" 0 0.0 3.14 2 -3 -7 20 3/4 -3/4 1.2/3 3.5
        C{ 2 2 } C{ 1/0. 1/0. }
    } ;

: setup-test ( #data #code -- data... quot )
    #! variable stack effect
    >r [ databank pick-one ] times r>
    [ drop wordbank get pick-one ] map >quotation ;

SYMBOL: before
SYMBOL: after
SYMBOL: quot
SYMBOL: err
err off

: test-compiler ( data... quot -- ... )
    err off
    dup quot set
    datastack clone dup pop* before set
    [ call ] catch drop datastack clone after set
    clear
    before get [ ] each
    quot get [ compile-1 ] [ err on ] recover ;

: do-test ( data... quot -- )
    .s flush test-compiler
    err get [
        datastack after get 2dup = [
            2drop
        ] [
            [ . ] each
            "--" print
            [ . ] each quot get .
            "not =" throw
        ] if
    ] unless
    clear ;

: random-test ( #data #code -- )
    setup-test do-test ;

: run-random-tester2
    100000000000000 [ 6 3 random-test ] times ;


! A worthwhile test that has not been run extensively
1000 [ drop gensym ] map "syms" set

: pick-one [ length random-int ] keep nth ;

: fooify
    "syms" get pick-one
    2000 random-int >quotation
    over set-word-def
    100 random-int zero? [ code-gc ] when
    compile fooify ;

