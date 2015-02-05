USING: accessors classes.tuple compiler.tree kernel namespaces sequences
stack-checker.backend stack-checker.known-words stack-checker.recursive-state
stack-checker.state stack-checker.values stack-checker.visitor tools.test
words ;
IN: stack-checker.known-words.tests

! Because node is an identity-tuple
: node-seqs-eq? ( seq1 seq2 -- ? )
    [ [ tuple-slots ] map concat ] bi@ = ;

{ t } [
    0 \ <value> set-global [
        V{ } clone stack-visitor set
        \ swap "shuffle" word-prop infer-shuffle
    ] with-infer nip V{
        T{ #introduce { out-d { 1 2 } } }
        T{ #shuffle
           { mapping { { 3 2 } { 4 1 } } }
           { in-d V{ 1 2 } }
           { out-d V{ 3 4 } }
        }
        T{ #return { in-d V{ 3 4 } } }
    } node-seqs-eq?
] unit-test

: foo ( x -- )
    drop ;

{ t } [
    0 \ <value> set-global [
        V{ } clone stack-visitor set
        1234
        T{ literal-tuple
           { value [ foo ] }
           { recursion T{ recursive-state } }
        } infer-call*
    ] with-infer nip V{
        T{ #shuffle
           { mapping { } }
           { in-d { 1234 } }
           { out-d { } }
        }
        T{ #introduce { out-d { 1 } } }
        T{ #call { word foo } { in-d V{ 1 } } { out-d { } } }
        T{ #return { in-d V{ } } }
    } node-seqs-eq?
] unit-test
