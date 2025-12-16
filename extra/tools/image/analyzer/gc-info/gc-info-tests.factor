USING: accessors alien.c-types alien.syntax arrays assocs bit-arrays
classes.struct combinators.short-circuit compiler compiler.cfg
compiler.cfg.debugger compiler.cfg.instructions
compiler.cfg.linearization compiler.codegen.gc-maps compiler.units fry
generic grouping io io.encodings.binary io.streams.byte-array kernel
math namespaces random sequences system tools.image.analyzer.gc-info
tools.image.analyzer.utils tools.test vm vocabs words ;
IN: tools.image.analyzer.gc-info.tests
QUALIFIED: cpu.x86.features.private
QUALIFIED: crypto.aes.utils
QUALIFIED: effects
QUALIFIED: gtk2-samples.opengl
QUALIFIED: opencl

: normal? ( word -- ? )
    { [ generic? ] [ primitive? ] [ inline? ] [ no-compile? ] } 1|| not ;

: word>gc-info ( word -- gc-info )
    word>byte-array binary <byte-reader> <backwards-reader> [
        gc-info read-struct-safe
    ] with-input-stream ;

: cfg>gc-maps ( cfg -- gc-maps )
    cfg>insns [ gc-map-insn? ] filter [ gc-map>> ] map
    [ gc-map-needed? ] filter ;

: tally-gc-maps ( gc-maps -- seq/f )
    [ f ] [
        [ [ gc-root-offsets ] map largest-spill-slot ]
        [ [ derived-root-offsets ] map [ keys ] map largest-spill-slot ]
        [ length ] tri 3array
    ] if-empty ;

! Like word>gc-info but uses the compiler
: word>gc-info-expected ( word -- seq/f )
    test-regs first [ cfg set ] [ cfg>gc-maps tally-gc-maps ] bi ;

! Handle f f as input. Deferred words don't have any gc-info. See #1394.
: same-gc-info? ( compiler-gc-info/f gc-info/f -- ? )
    2dup = [
        2drop t
    ] [
        [ struct-slot-values = ]
        [ [ not ] dip return-address-count>> 0 = and ] 2bi or
    ] if ;

: base-pointer-groups-expected ( word -- seq )
    test-regs first cfg>gc-maps [ derived-root-offsets { } like ] { } map-as ;

: base-pointer-groups-decoded ( word -- seq )
    word>gc-maps [
        second second [ swap 2array ] map-index
        [ -1 = ] reject-values
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

! word>gc-maps
{ f } [
    \ effects:<effect> word>gc-maps empty?
] unit-test

cpu x86.64? [
    os windows? [
        ! The difference is because Windows stack references are
        ! longer because of the home space.
        {
            { 156 { ?{ f f f f f t t t t } { } } }
        }
    ] [
        {
            { 155 { ?{ f t t t t } { } } }
        }
    ] if
    [
        \ effects:<effect> word>gc-maps first
    ] unit-test
] when

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

! Originally from llvm.types, but llvm moved to unmaintained
TYPEDEF: void* LLVMTypeRef
TYPEDEF: void* LLVMTypeHandleRef
FUNCTION: LLVMTypeRef LLVMResolveTypeHandle ( LLVMTypeHandleRef TypeHandle )
FUNCTION: LLVMTypeHandleRef LLVMCreateTypeHandle ( LLVMTypeRef PotentiallyAbstractTy )
FUNCTION: void LLVMRefineType ( LLVMTypeRef AbstractTy, LLVMTypeRef ConcreteTy )
FUNCTION: void LLVMDisposeTypeHandle ( LLVMTypeHandleRef TypeHandle )

: resolve-types ( typeref typeref -- typeref )
    over LLVMCreateTypeHandle [ LLVMRefineType ] dip
    [ LLVMResolveTypeHandle ] keep LLVMDisposeTypeHandle ;

! base-pointer-groups
{ t } [
\ resolve-types
    [ base-pointer-groups-expected ] [ base-pointer-groups-decoded ] bi =
] unit-test

! Tough words #1227
{ t } [
    \ resolve-types
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

! #1436
{ t } [
    \ gtk-samples.opengl:opengl-main
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

{ t } [
    \ opencl:cl-queue-kernel deterministic-gc-info?
] unit-test



! TODO: try on 32 bit \ feedback-format:
