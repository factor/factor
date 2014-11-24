USING: accessors arrays assocs bit-arrays classes.struct combinators
combinators.short-circuit compiler compiler.cfg.debugger
compiler.cfg.instructions compiler.cfg.stack-frame compiler.cfg.utilities
compiler.codegen.gc-maps generic kernel math namespaces random sequences
sequences.generalizations slots.syntax tools.gc-decode tools.test vm vocabs
words compiler.cfg.linearization ;
QUALIFIED: effects
QUALIFIED: llvm.types
IN: tools.gc-decode.tests

! byte-array>bit-array
{
    ?{
        t t t t f t t t
        t f f f f f f f
    }
} [
    B{ 239 1 } byte-array>bit-array
] unit-test

{ ?{ t t t t t t t t } } [ B{ 255 } byte-array>bit-array ] unit-test

! scrub-bits
{ t } [
    \ effects:<effect> word>gc-info scrub-bits
    {
        ?{ t t t f t t t t } ! 64-bit
        ?{ t t t f f f f f t t t t } ! 32-bit
    } member?
] unit-test

{
    { }
} [
    \ decode-gc-maps word>gc-info scrub-bits
] unit-test

! decode-gc-maps
{ f } [
    \ effects:<effect> decode-gc-maps empty?
] unit-test

{ f } [
    \ + decode-gc-maps empty?
] unit-test

! read-gc-maps
{ { } } [
    \ decode-gc-maps decode-gc-maps
] unit-test

: cfg>gc-maps ( cfg -- gc-maps )
    cfg>insns [ gc-map-insn? ] filter [ gc-map>> ] map
    [ gc-map-needed? ] filter ;

: tally-gc-maps ( gc-maps -- seq/f )
    [ f ] [ {
        [ [ scrub-d>> length ] map supremum ]
        [ [ scrub-r>> length ] map supremum ]
        [ [ check-d>> length ] map supremum ]
        [ [ check-r>> length ] map supremum ]
        [ [ gc-root-offsets ] map largest-spill-slot ]
        [ [ derived-root-offsets ] map [ keys ] map largest-spill-slot ]
        [ length ]
    } cleave 7 narray ] if-empty ;

! Like word>gc-info but uses the compiler
: word>gc-info-expected ( word -- seq/f )
    test-regs first dup stack-frame>> stack-frame
    [ cfg>gc-maps tally-gc-maps ] with-variable ;

: same-gc-info? ( compiler-gc-info gc-info -- ? )
    [ struct-slot-values = ]
    [ [ not ] dip return-address-count>> 0 = and ] 2bi or ;

! One of the few words that has derived roots.
{ t } [
    \ llvm.types:resolve-types
    [ word>gc-info-expected ] [ word>gc-info ] bi same-gc-info?
] unit-test

! Do it also for a bunch of random words
: normal? ( word -- ? )
    { [ generic? ] [ primitive? ] [ inline? ] [ no-compile? ] } 1|| not ;

{ t } [
    all-words [ normal? ] filter 20 sample
    [ [ word>gc-info-expected ] [ word>gc-info ] bi same-gc-info? ] all?
] unit-test

: base-pointer-groups-expected ( word -- seq )
    test-regs first dup stack-frame>> stack-frame [
        cfg>gc-maps [ derived-root-offsets { } like ] { } map-as
    ] with-variable ;

: base-pointer-groups-decoded ( word -- seq )
    word>gc-info base-pointer-groups [
        [ swap 2array ] map-index [ nip -1 = not ] assoc-filter
    ] map ;

! base-pointer-groups
{ t } [
    \ llvm.types:resolve-types
    [ base-pointer-groups-expected ] [ base-pointer-groups-decoded ] bi =
] unit-test
