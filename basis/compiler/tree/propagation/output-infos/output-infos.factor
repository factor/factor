USING: accessors combinators combinators.short-circuit compiler.tree
compiler.tree.propagation.info continuations io kernel math namespaces sequences
words ;
IN: compiler.tree.propagation.output-infos

FROM: namespaces => set ;

! * Using Stored Output Infos During Propagation
ERROR: invalid-outputs #call infos ;

: check-outputs ( #call infos -- infos )
    over out-d>> over [ length ] bi@ =
    [ nip ] [ invalid-outputs ] if ;

: null-infos? ( infos -- ? )
    [ null-info = ] any? ;

: literal-infos? ( infos -- ? )
    [ literal?>> ] any? ;

: check-consistent-effects ( #call infos -- ? )
    [ check-outputs ] [
        dup invalid-outputs? [
            2drop
            "FIXME: Inconsistent stack effect output for compiled word: " write
            word>> name>> print
            f
        ] [ rethrow ] if
    ] recover
    ;

! This is quite verbose, mainly for catching things which indicate other problems.
: check-copied-output-infos ( #call word -- ? )
    "output-infos" word-prop
    {
        { [ 2dup check-consistent-effects not ] [ 2drop f ] }
        { [ [ word>> name>> ] dip dup null-infos? ]
          [ drop "WARNING: ignoring NULL infos from " prepend write nl f ] }
        ! { [ dup literal-infos? ]
        !   [ drop "WARNING: ignoring LITERAL infos from " prepend write nl f ] }
        [ 2drop t ]
    } cond
    ;

! * Storing Inferred Output Infos

: should-store-output-infos? ( nodes -- infos/f )
    [
        { [ length 2 > ] [ but-last last ] } 1&&
        #terminate? not
    ]
    [ last dup #return?
      [ "STRANGE: last node not return, not storing outputs" print ] unless
      node-input-infos
    ]
    bi and ;

ERROR: duplicate-output-infos word infos ;

: update-output-infos ( nodes -- )
    word-being-compiled get [
        ! dup "output-infos" word-prop [ duplicate-output-infos ] when*
        swap should-store-output-infos?
        [
            [ drop ] [
                [ clone f >>literal? ] map ! This line prevents literal propagation
                "output-infos" set-word-prop
            ] if-empty
        ] [
            drop
        ] if*
    ] [ drop ] if* ;
