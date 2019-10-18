USING: compiler errors inference interpreter io kernel math
memory namespaces prettyprint random-tester sequences tools
words arrays definitions generic graphs hashtables byte-arrays ;
IN: random-tester2

SYMBOL: wordbank
: w1
    {
        die
        set-walker-hook exit

        xref-words

        times repeat (repeat)
        supremum infimum assoc norm-sq
        product sum curry remove-all member? subseq?

        (next-power-of-2) (^) d>w/w w>h/h millis
        (random) ^n integer, first-bignum
        most-positive-fixnum ^ init-random next-power-of-2
        most-negative-fixnum

        clear-hash build-graph

        >r r>

        set-callstack set-word set-word-prop
        set-catchstack set-namestack set-retainstack
        set-continuation-retain continuation-catch
        set-continuation-name catchstack retainstack
        set-no-math-method-generic
        set-no-math-method-right
        set-check-method-class
        set-check-create-name
        set-pathname-string
        set-check-create-vocab
        <check-create> check-create?
        reset-generic forget-class
        create forget-word forget-vocab forget forget-tuple
        remove-word-prop empty-method
        continue-with <continuation>

        define-compound define make-generic
        define-method define-predicate-class
        define-tuple-class define-temp define-tuple-slots
        define-writer define-predicate define-generic
        ?make-generic define-reader define-slot define-slots
        define-typecheck define-slot-word define-union-class
        define-generic* with-methods define-constructor
        predicate-word condition-continuation define-symbol

        ndrop

        set-word-def set-word-name
        set-word-props set-word-primitive

        stdio
        close readln read1 read read-until
        stream-read stream-readln stream-read1 lines (lines)
        contents stream-copy stream-flush
        lines-loop
        stream-format set-line-reader-cr

        double>bits float>bits >bignum

        intern-slots class-predicates delete (delete) prune memq?
        normalize norm vneg vmax vmin v- v+ [v-]

        bin> oct> le> be> hex> string>number

        gensym random counter <byte-array>
        <word> <client-stream> <server> <client>
        <duplex-stream> <file-writer> <file-reader> ! <file-r/w>
        init-namespaces unxref-word set-global set off on
        nest
        set-restart-obj
        +@ inc dec

        changed-words changed-word

        callstack namespace namestack global vocabularies

        path+ parent-dir

        .s . 

        with-datastack <quotation>
        (delegates) simple-slot , # % split-next,
        <continuation> continue-with set-delegate

        closure
        
        tabular-output simple-slots set-axis

        join concat group
        hash+
    }
    { "arrays" "errors" "generic" "graphs" "hashtables" "io"
    "kernel" "math" "namespaces"
    "queues" "strings" "sequences" "vectors" "words" }
    [ words ] map concat diff ;

w1 wordbank set-global

: databank
    {
        ! V{ } H{ } V{ 3 } { 3 } { } "" "asdf"
        pi 1/0. -1/0. 0/0. [ ]
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

: pick-one [ length random ] keep nth ;

: fooify-test
    "syms" get pick-one
    2000 random >quotation
    over set-word-def
    100 random zero? [ code-gc ] when
    compile fooify-test ;

