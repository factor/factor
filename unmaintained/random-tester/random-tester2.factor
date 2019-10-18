USING: compiler errors inference interpreter io kernel math
memory namespaces prettyprint random-tester sequences tools
quotations words arrays definitions generic graphs
hashtables byte-arrays assocs network ;
IN: random-tester2

: dangerous-words ( -- array )
    {
        die
        set-walker-hook exit
        >r r> ndrop

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
        set-check-method-generic
        <check-create> check-create?
        reset-generic forget-class
        create forget-word forget-vocab forget
        forget-methods forget-predicate
        remove-word-prop empty-method
        continue-with <continuation>

        define-compound define make-generic
        define-method define-predicate-class
        define-tuple-class define-temp define-tuple-slots
        define-writer define-predicate define-generic
        (define-union-class)
        define-declared define-class
        define-union-class define-inline
        ?make-generic define-reader define-slot define-slots
        define-typecheck define-slot-word define-union-class
        define-simple-generic with-methods define-constructor
        predicate-word condition-continuation define-symbol
        tuple-predicate (sort-classes)

        stdio
        close readln read1 read read-until
        stream-read stream-readln stream-read1 lines
        contents stream-copy stream-flush
        lines-loop
        stream-format set-line-reader-cr
        <client-stream> <server> <client>
        <duplex-stream> <file-writer> <file-reader>
        <style-stream> style-stream default-constructor
        init-namespaces plain-writer
        
        with-datastack <quotation> datastack-underflow.
        (delegates) simple-slot , # %
        <continuation> continue-with set-delegate
        callcc0 callcc1

        :r :s :c

        (next-power-of-2) (^) d>w/w w>h/h millis
        (random) ^n integer, first-bignum
        most-positive-fixnum ^ init-random next-power-of-2
        most-negative-fixnum

        clear-assoc build-graph

        set-word-def set-word-name
        set-word-props
        set set-axis set-delegate set-global set-restart-obj



        gensym random

        double>bits float>bits >bignum

        class-predicates delete (delete) memq?
        prune join concat group at+
        normalize norm vneg vmax vmin v- v+ [v-]
        times repeat (repeat)
        supremum infimum at norm-sq
        product sum curry remove-all member? subseq?

        ! O(n) on bignums
        (add-vertex) (prune) (split) digits>integer
        substitute ?head ?tail add-vertex all? base> closure
        drop-prefix
        find-last-sep format-column head? index index*
        last-index mismatch push-new remove-vertex reset-props
        seq-quot-uses sequence= split split, split1 start
        start* string-lines string>integer tail? v.
        
        stack-picture
        
        ! allot crashes
        at+ natural-sort

        # % (delegates) +@ , . .s <continuation>
        <quotation> <word> be> bin> callstack changed-word
        changed-words continue-with counter dec
        global
        hex> inc le> namespace namestack nest oct> off
        on parent-dir path+ 
        simple-slot simple-slots string>number tabular-output
        unxref-word xref-word xref-words vocabularies
        with-datastack

        bind if-graph ! 0 >n ! GCs

        move-backward move-forward open-slice (open-slice) ! infinite loop
        (assoc-stack) ! infinite loop

        case ! 100000000000 t case ! takes a long time
    } ;

: safe-words ( -- array )
    dangerous-words {
        "arrays" "assocs" "bit-arrays" "byte-arrays"
        "errors" "generic" "graphs" "hashtables" "io"
        "kernel" "math" "namespaces" "quotations" "sbufs"
        "queues" "strings" "sequences" "vectors" "words"
    } [ words ] map concat seq-diff natural-sort ;
    
safe-words \ safe-words set-global

: databank ( -- array )
    {
        ! V{ } H{ } V{ 3 } { 3 } { } "" "asdf"
        pi 1/0. -1/0. 0/0. [ ]
        f t "" 0 0.0 3.14 2 -3 -7 20 3/4 -3/4 1.2/3 3.5
        C{ 2 2 } C{ 1/0. 1/0. }
    } ;

: setup-test ( #data #code -- data... quot )
    #! variable stack effect
    >r [ databank random ] times r>
    [ drop \ safe-words get random ] map >quotation ;

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
            "--" print [ . ] each quot get .
            "not =" throw
        ] if
    ] unless
    clear ;

: random-test* ( #data #code -- )
    setup-test do-test ;

: run-random-tester2
    100000000000000 [ 6 3 random-test* ] times ;


! A worthwhile test that has not been run extensively

1000 [ drop gensym ] map "syms" set-global

: fooify-test
    "syms" get-global random
    2000 random >quotation
    over set-word-def
    100 random zero? [ code-gc ] when
    compile fooify-test ;

