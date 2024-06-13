! Copyright (C) 2004, 2011 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs byte-arrays classes
classes.builtin classes.private classes.tuple
classes.tuple.private combinators combinators.short-circuit
combinators.smart command-line compiler.codegen.relocation
compiler.units endian generic generic.single.private grouping
hashtables hashtables.private io io.encodings.binary io.files
io.pathnames kernel kernel.private layouts locals.types make
math math.bitwise math.order namespaces namespaces.private
parser parser.notes prettyprint quotations sequences
sequences.private source-files splitting strings system vectors
vocabs words ;
IN: bootstrap.image

: arch-name ( os cpu -- arch )
    [ [ windows? ] [ ppc? ] bi* or ] 2check
    [ [ drop unix ] dip ] unless
    [ name>> ] bi@ "-" glue ;

: my-arch-name ( -- arch )
    os cpu arch-name ;

: boot-image-name ( arch -- string )
    "boot." ".image" surround ;

: my-boot-image-name ( -- string )
    my-arch-name boot-image-name ;

CONSTANT: image-names
    {
        "windows-x86.32" "unix-x86.32"
        "windows-x86.64" "unix-x86.64"
        "windows-arm.64" "unix-arm.64"
    }

<PRIVATE

! Object cache; we only consider numbers equal if they have the
! same type
TUPLE: eql-wrapper { obj read-only } ;

C: <eql-wrapper> eql-wrapper

M: eql-wrapper hashcode* obj>> hashcode* ;

GENERIC: (eql?) ( obj1 obj2 -- ? )

: eql? ( obj1 obj2 -- ? )
    { [ [ class-of ] same? ] [ (eql?) ] } 2&& ;

M: fixnum (eql?) eq? ;

M: bignum (eql?) { bignum bignum } declare = ;

M: float (eql?) fp-bitwise= ;

M: sequence (eql?)
    [ [ length ] same? ] 2check
    [ [ eql? ] 2all? ] [ 2drop f ] if ;

M: object (eql?) = ;

M: eql-wrapper equal?
    over eql-wrapper? [ [ obj>> ] bi@ eql? ] [ 2drop f ] if ;

TUPLE: eq-wrapper { obj read-only } ;

C: <eq-wrapper> eq-wrapper

M: eq-wrapper equal?
    over eq-wrapper? [ [ obj>> ] bi@ eq? ] [ 2drop f ] if ;

M: eq-wrapper hashcode*
    nip obj>> identity-hashcode ;

SYMBOL: objects

: cache-eql-object ( obj quot -- value )
    [ <eql-wrapper> objects get ] dip '[ obj>> @ ] cache ; inline

: cache-eq-object ( obj quot -- value )
    [ <eq-wrapper> objects get ] dip '[ obj>> @ ] cache ; inline

: lookup-object ( obj -- n/f )
    <eq-wrapper> objects get at ;

: put-object ( n obj -- )
    <eq-wrapper> objects get set-at ;

! Constants need to be synced with
!   vm/image.hpp
CONSTANT: image-magic 0x0f0e0d0c
CONSTANT: image-version 4

CONSTANT: data-base 1024

CONSTANT: header-size 10

CONSTANT: data-heap-size-offset 3

SYMBOL: sub-primitives

SYMBOL: special-objects

:: jit-conditional ( test-quot false-quot -- )
    [ 0 test-quot call ] B{ } make length :> len
    building get length extra-offset get + len +
    [ extra-offset set false-quot call ] B{ } make
    [ length test-quot call ] [ % ] bi ; inline

: make-jit ( quot -- parameters literals code )
    [
        0 extra-offset set
        init-relocation
        call( -- )
        parameter-table get >array
        literal-table get >array
        relocation-table get >byte-array
    ] B{ } make 2array ;

: make-jit-no-params ( quot -- code )
    make-jit 2nip ;

: jit-define ( quot n -- )
    [ make-jit-no-params ] dip special-objects get set-at ;

: define-sub-primitive ( quot word -- )
    [ make-jit 3array ] dip sub-primitives get set-at ;

: define-sub-primitives ( assoc -- )
    [ swap define-sub-primitive ] assoc-each ;

: define-combinator-primitive ( quot non-tail-quot tail-quot word -- )
    [
        [
            [ make-jit ]
            [ make-jit-no-params ]
            [ make-jit-no-params ]
            tri*
        ] output>array
    ] dip
    sub-primitives get set-at ;

SYMBOL: bootstrapping-image

! Image output format
SYMBOL: big-endian

SYMBOL: architecture

: emit ( cell -- ) bootstrapping-image get push ;

: emit-64 ( cell -- )
    bootstrap-cell 8 = [
        emit
    ] [
        d>w/w big-endian get [ swap ] unless emit emit
    ] if ;

: emit-seq ( seq -- ) bootstrapping-image get push-all ;

: fixup ( value offset -- ) bootstrapping-image get set-nth ;

: heap-size ( -- size )
    bootstrapping-image get length header-size - special-object-count -
    bootstrap-cells ;

: here ( -- size ) heap-size data-base + ;

: here-as ( tag -- pointer ) here bitor ;

: (align-here) ( alignment -- )
    [ here neg ] dip rem
    [ bootstrap-cell /i [ 0 emit ] times ] unless-zero ;

: align-here ( -- )
    data-alignment get (align-here) ;

: emit-fixnum ( n -- ) tag-fixnum emit ;

: emit-header ( n -- ) tag-header emit ;

: emit-object ( class quot -- addr )
    [ type-number ] dip over here-as
    [ swap emit-header call align-here ] dip ; inline

! Read any object for emitting.
GENERIC: prepare-object ( obj -- ptr )

! Image header

: emit-image-header ( -- )
    image-magic emit
    image-version emit
    data-base emit ! relocation base at end of header
    0 emit ! size of data heap set later
    0 emit ! reloc base of code heap is 0
    0 emit ! size of code heap is 0
    0 emit ! reserved
    0 emit ! reserved
    0 emit ! reserved
    0 emit ! reserved
    special-object-count [ f prepare-object emit ] times ;

! Bignums

: bignum-bits ( -- n ) bootstrap-cell-bits 2 - ;

: bignum-radix ( -- n ) bignum-bits 2^ 1 - ;

: bignum>sequence ( n -- seq )
    ! n is positive or zero.
    [ dup 0 > ]
    [ [ bignum-bits neg shift ] [ bignum-radix bitand ] bi ]
    produce nip ;

: emit-bignum ( n -- )
    dup dup 0 < [ neg ] when bignum>sequence
    [ nip length 1 + emit-fixnum ]
    [ drop 0 < 1 0 ? emit ]
    [ nip emit-seq ]
    2tri ;

M: bignum prepare-object
    [
        bignum [ emit-bignum ] emit-object
    ] cache-eql-object ;

! Fixnums

M: fixnum prepare-object
    ! When generating a 32-bit image on a 64-bit system,
    ! some fixnums should be bignums.
    dup
    bootstrap-most-negative-fixnum
    bootstrap-most-positive-fixnum between?
    [ tag-fixnum ] [ >bignum prepare-object ] if ;

TUPLE: fake-bignum n ;

C: <fake-bignum> fake-bignum

M: fake-bignum prepare-object n>> tag-fixnum ;

! Floats

M: float prepare-object
    [
        float [
            8 (align-here) double>bits emit-64
        ] emit-object
    ] cache-eql-object ;

! Special objects

! Padded with fixnums for 8-byte alignment
M: f prepare-object drop \ f type-number ;

! Words

: word-sub-primitive ( word -- obj )
    [ target-word ] with-global sub-primitives get at ;

: emit-word ( word -- )
    [
        [ subwords [ emit-word ] each ]
        [
            [
                {
                    [ hashcode <fake-bignum> ]
                    [ name>> ]
                    [ vocabulary>> ]
                    [ def>> ]
                    [ props>> ]
                    [ pic-def>> ]
                    [ pic-tail-def>> ]
                    [ word-sub-primitive ]
                    [ drop 0 ] ! entry point
                } cleave
            ] output>array [ prepare-object ] map!
        ] bi
        \ word [ emit-seq ] emit-object
    ] keep put-object ;

ERROR: not-in-image vocabulary word ;

: transfer-word ( word -- word )
    [ target-word ] keep or ;

: fixup-word ( word -- offset )
    transfer-word
    [ lookup-object ] [ [ vocabulary>> ] [ name>> ] bi not-in-image ] ?unless ;

: fixup-words ( -- )
    bootstrapping-image get [ dup word? [ fixup-word ] when ] map! drop ;

M: word prepare-object ;

! Wrappers

M: wrapper prepare-object
    [ wrapped>> prepare-object wrapper [ emit ] emit-object ] cache-eql-object ;

! Strings
: native> ( object -- object )
    big-endian get [ [ be> ] map ] [ [ le> ] map ] if ;

: emit-bytes ( seq -- )
    bootstrap-cell <groups> native> emit-seq ;

: pad-bytes ( seq -- newseq )
    dup length bootstrap-cell align 0 pad-tail ;

: extended-part ( str -- str' )
    dup [ 128 < ] all? [ drop f ] [
        [ -7 shift 1 bitxor ] { } map-as
        big-endian get
        [ [ 2 >be ] { } map-as ]
        [ [ 2 >le ] { } map-as ] if
        B{ } join
    ] if ;

: ascii-part ( str -- str' )
    [
        [ 128 mod ] [ 128 >= ] bi
        [ 128 bitor ] when
    ] B{ } map-as ;

: emit-string ( string -- ptr )
    [ length ] [ extended-part prepare-object ] [ ] tri
    string [
        [ emit-fixnum ]
        [ emit ]
        [ f prepare-object emit ascii-part pad-bytes emit-bytes ]
        tri*
    ] emit-object ;

M: string prepare-object
    ! We pool strings so that each string is only written once
    ! to the image
    [ emit-string ] cache-eql-object ;

: assert-empty ( seq -- )
    length 0 assert= ;

: emit-dummy-array ( obj type -- ptr )
    [ assert-empty ] [
        [ 0 emit-fixnum ] emit-object
    ] bi* ;

M: byte-array prepare-object
    [
        byte-array [
            dup length emit-fixnum
            bootstrap-cell 4 = [ 0 emit 0 emit ] when
            pad-bytes emit-bytes
        ] emit-object
    ] cache-eq-object ;

! Tuples
ERROR: tuple-removed class ;

: require-tuple-layout ( word -- layout )
    [ tuple-layout ] [ tuple-removed ] ?unless ;

: (emit-tuple) ( tuple -- pointer )
    [ tuple-slots ]
    [ class-of transfer-word require-tuple-layout ] bi prefix [ prepare-object ] map
    tuple [ emit-seq ] emit-object ;

: emit-tuple ( tuple -- pointer )
    dup class-of name>> "tombstone" =
    [ [ (emit-tuple) ] cache-eql-object ]
    [ [ (emit-tuple) ] cache-eq-object ]
    if ;

M: tuple prepare-object emit-tuple ;

M: tombstone prepare-object
    state>> "+tombstone+" "+empty+" ?
    "hashtables.private" lookup-word def>> first
    [ emit-tuple ] cache-eql-object ;

! Arrays
: emit-array ( array -- offset )
    [ prepare-object ] map array [ [ length emit-fixnum ] [ emit-seq ] bi ] emit-object ;

M: array prepare-object [ emit-array ] cache-eq-object ;

! This is a hack. We need to detect arrays which are tuple
! layout arrays so that they can be internalized, but making
! them a built-in type is not worth it.
PREDICATE: tuple-layout-array < array
    dup length 5 >= [
        {
            [ first-unsafe tuple-class? ]
            [ second-unsafe fixnum? ]
            [ third-unsafe fixnum? ]
        } 1&&
    ] [ drop f ] if ;

M: tuple-layout-array prepare-object
    [
        [ dup integer? [ <fake-bignum> ] when ] map
        emit-array
    ] cache-eql-object ;

! Quotations

M: quotation prepare-object
    [
        array>> prepare-object
        quotation [
            emit ! array
            f prepare-object emit ! cached-effect
            f prepare-object emit ! cache-counter
            0 emit ! entry point
        ] emit-object
    ] cache-eql-object ;

! End of the image

: emit-words ( -- )
    all-words [ emit-word ] each ;

: emit-singletons ( -- )
    t OBJ-CANONICAL-TRUE special-objects get set-at
    0 >bignum OBJ-BIGNUM-ZERO special-objects get set-at
    1 >bignum OBJ-BIGNUM-POS-ONE special-objects get set-at
    -1 >bignum OBJ-BIGNUM-NEG-ONE special-objects get set-at ;

: create-global-hashtable ( -- global-hashtable )
    {
        dictionary source-files builtins
        update-map implementors-map
    } [ [ bootstrap-word ] [ get global-box boa ] bi ] H{ } map>assoc
    {
        class<=-cache class-not-cache classes-intersect-cache
        class-and-cache class-or-cache next-method-quot-cache
    } [ H{ } clone global-box boa ] H{ } map>assoc assoc-union
    global-hashtable boa ;

: emit-global ( -- )
    create-global-hashtable
    OBJ-GLOBAL special-objects get set-at ;

: emit-jit-data ( -- )
    {
        { JIT-IF-WORD if }
        { JIT-PRIMITIVE-WORD do-primitive }
        { JIT-DIP-WORD dip }
        { JIT-2DIP-WORD 2dip }
        { JIT-3DIP-WORD 3dip }
        { PIC-MISS-WORD inline-cache-miss }
        { PIC-MISS-TAIL-WORD inline-cache-miss-tail }
        { MEGA-LOOKUP-WORD mega-cache-lookup }
        { MEGA-MISS-WORD mega-cache-miss }
        { JIT-DECLARE-WORD declare }
        { C-TO-FACTOR-WORD c-to-factor }
        { LAZY-JIT-COMPILE-WORD lazy-jit-compile }
        { UNWIND-NATIVE-FRAMES-WORD unwind-native-frames }
        { GET-FPU-STATE-WORD fpu-state }
        { SET-FPU-STATE-WORD set-fpu-state }
        { SIGNAL-HANDLER-WORD signal-handler }
        { LEAF-SIGNAL-HANDLER-WORD leaf-signal-handler }
    }
    \ OBJ-UNDEFINED undefined-def 2array suffix [
        swap execute( -- x ) special-objects get set-at
    ] assoc-each ;

: emit-special-object ( obj idx -- )
    [ prepare-object ] [ header-size + ] bi* fixup ;

: emit-special-objects ( -- )
    special-objects get [ swap emit-special-object ] assoc-each ;

: emit-locals ( -- )
    bootstrapping-image get [ dup local? [ emit-word ] [ drop ] if ] each ;

: fixup-header ( -- )
    heap-size data-heap-size-offset fixup ;

: build-generics ( -- )
    [
        all-words
        [ generic? ] filter
        [ make-generic ] each
    ] with-compilation-unit ;

: build-image ( -- image )
    600,000 <vector> bootstrapping-image set
    60,000 <hashtable> objects set
    emit-image-header
    "Building generic words..." print flush
    build-generics
    "Serializing words..." print flush
    emit-words
    "Serializing locals..." print flush
    emit-locals
    "Serializing JIT data..." print flush
    emit-jit-data
! special-objects get ...
! nl
! "sub-primitives" print
! sub-primitives get ...
! \ c-to-factor of
! 43 special-objects get set-at

    "Serializing global namespace..." print flush
    emit-global
    "Serializing singletons..." print flush
    emit-singletons
    "Serializing special object table..." print flush
    emit-special-objects
    "Performing word fixups..." print flush
    fixup-words
    "Performing header fixups..." print flush
    fixup-header
    "Image length: " write bootstrapping-image get length .
    "Object cache size: " write objects get assoc-size .
    \ last-word global delete-at
    bootstrapping-image get ;

! Image output

: (write-image) ( image -- )
    bootstrap-cell output-stream get
    big-endian get
    [ '[ _ >be _ stream-write ] each ]
    [ '[ _ >le _ stream-write ] each ] if ;

: write-image ( image -- )
    "Writing image to " write
    architecture get boot-image-name resource-path
    [ write "..." print flush ]
    [ binary [ (write-image) ] with-file-writer ] bi ;

PRIVATE>

: make-image ( arch -- )
    architecture associate H{
        { parser-quiet? f }
        { auto-use? f }
    } assoc-union! [
        H{ } clone special-objects set
        "resource:basis/bootstrap/stage1.factor" run-file
        build-image
        write-image
    ] with-variables ;

: make-images ( -- )
    image-names [ make-image ] each ;

: make-my-image ( -- )
    my-arch-name make-image ;

: make-image-main ( -- )
    command-line get [
        make-my-image
    ] [
        [ "boot." ?head drop ".image" ?tail drop make-image ] each
    ] if-empty ;

MAIN: make-image-main
