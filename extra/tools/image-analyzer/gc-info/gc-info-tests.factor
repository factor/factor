USING: accessors arrays assocs bit-arrays classes.struct combinators
combinators.short-circuit compiler compiler.cfg.debugger
compiler.cfg.instructions compiler.cfg.linearization
compiler.cfg.stack-frame compiler.codegen.gc-maps compiler.units fry generic
grouping io io.encodings.binary io.streams.byte-array kernel math namespaces
random sequences sequences.generalizations
tools.image-analyzer.gc-info tools.image-analyzer.utils tools.test vm
vocabs words ;
IN: tools.image-analyzer.gc-info.tests
QUALIFIED: cpu.x86.features.private
QUALIFIED: crypto.aes.utils
QUALIFIED: effects
QUALIFIED: gml.coremath
QUALIFIED: llvm.types
QUALIFIED: opencl

: normal? ( word -- ? )
    { [ generic? ] [ primitive? ] [ inline? ] [ no-compile? ] } 1|| not ;

: word>gc-info ( word -- gc-info )
    word>byte-array binary <byte-reader> <backwards-reader> [
        gc-info read-struct-safe
    ] with-input-stream ;

: word>scrub-bits ( word -- bits )
    word>byte-array binary <byte-reader> <backwards-reader> [
        gc-info read-struct-safe scrub-bits
    ] with-input-stream ;

: cfg>gc-maps ( cfg -- gc-maps )
    cfg>insns [ gc-map-insn? ] filter [ gc-map>> ] map
    [ gc-map-needed? ] filter ;

: tally-gc-maps ( gc-maps -- seq/f )
    [ f ] [ {
        [ [ scrub-d>> length ] map supremum ]
        [ [ scrub-r>> length ] map supremum ]
        [ [ gc-root-offsets ] map largest-spill-slot ]
        [ [ derived-root-offsets ] map [ keys ] map largest-spill-slot ]
        [ length ]
    } cleave 5 narray ] if-empty ;

! Like word>gc-info but uses the compiler
: word>gc-info-expected ( word -- seq/f )
    test-regs first dup stack-frame>> stack-frame
    [ cfg>gc-maps tally-gc-maps ] with-variable ;

: same-gc-info? ( compiler-gc-info gc-info -- ? )
    [ struct-slot-values = ]
    [ [ not ] dip return-address-count>> 0 = and ] 2bi or ;

: base-pointer-groups-expected ( word -- seq )
    test-regs first dup stack-frame>> stack-frame [
        cfg>gc-maps [ derived-root-offsets { } like ] { } map-as
    ] with-variable ;

: base-pointer-groups-decoded ( word -- seq )
    word>gc-maps [
        second second [ swap 2array ] map-index
        [ nip -1 = ] assoc-reject
    ] map ;

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
{
    { { ?{ } ?{ } ?{ f f f f f } } }
} [
    \ word>scrub-bits word>scrub-bits
] unit-test

! decode-gc-maps
{ f } [
    \ effects:<effect> word>gc-maps empty?
] unit-test

{ f } [
    \ + word>gc-maps empty?
] unit-test

{ { } } [
    \ word>gc-maps word>gc-maps
] unit-test

! Big test
{ { } } [
    all-words [ normal? ] filter 50 sample
    [ [ word>gc-info-expected ] [ word>gc-info ] bi same-gc-info? ] reject
] unit-test

! base-pointer-groups
{ t } [
    \ llvm.types:resolve-types
    [ base-pointer-groups-expected ] [ base-pointer-groups-decoded ] bi =
] unit-test

! Tough words #1227
{ t } [
    \ llvm.types:resolve-types
    [ word>gc-info-expected ] [ word>gc-info ] bi same-gc-info?
] unit-test

{ t } [
    \ opencl:cl-queue-kernel
    [ word>gc-info-expected ] [ word>gc-info ] bi same-gc-info?
] unit-test

{ t } [
    \ crypto.aes.utils:bytes>words
    [ word>gc-info-expected ] [ word>gc-info ] bi same-gc-info?
] unit-test

{ t } [
    \ cpu.x86.features.private:(sse-version)
    [ word>gc-info-expected ] [ word>gc-info ] bi same-gc-info?
] unit-test

! Ensure deterministic gc map generation.
: recompile-word>gc-info ( word -- gc-info )
    [ 1array compile ] keep word>gc-info ;

: deterministic-gc-info? ( word -- ? )
    20 swap '[
        _ recompile-word>gc-info struct-slot-values
        dup last 0 = [ drop f ] when
    ] replicate all-equal? ;

{ t t } [
    \ opencl:cl-queue-kernel deterministic-gc-info?
    \ gml.coremath:gml-determinant deterministic-gc-info?
] unit-test
