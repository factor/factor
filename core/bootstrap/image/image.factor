! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays bit-arrays byte-arrays generic assocs
hashtables assocs hashtables.private io kernel kernel.private
math namespaces parser prettyprint sequences sequences.private
strings sbufs vectors words quotations assocs system layouts
splitting growable math.functions classes tuples words.private
io.binary io.files vocabs vocabs.loader source-files
definitions debugger float-arrays quotations.private
combinators.private combinators ;
IN: bootstrap.image

<PRIVATE

! Constants

: image-magic HEX: 0f0e0d0c ; inline
: image-version 4 ; inline

: char bootstrap-cell 2/ ; inline

: data-base 1024 ; inline

: userenv-size 40 ; inline

: header-size 10 ; inline

: data-heap-size-offset 3 ; inline
: t-offset              6 ; inline
: 0-offset              7 ; inline
: 1-offset              8 ; inline
: -1-offset             9 ; inline

: array-start 2 bootstrap-cells object tag-number - ;
: scan@ array-start 4 - ;
: wrapper@ bootstrap-cell object tag-number - ;
: word-xt@ 8 bootstrap-cells object tag-number - ;
: quot-array@ bootstrap-cell object tag-number - ;
: quot-xt@ 2 bootstrap-cells object tag-number - ;

! The image being constructed; a vector of word-size integers
SYMBOL: image

! Object cache
SYMBOL: objects

! Image output format
SYMBOL: big-endian

! Bootstrap architecture name
SYMBOL: architecture

! Bootstrap global namesapce
SYMBOL: bootstrap-global

! Boot quotation, set in stage1.factor
SYMBOL: bootstrap-boot-quot

! JIT parameters
SYMBOL: jit-code-format
SYMBOL: jit-setup
SYMBOL: jit-prolog
SYMBOL: jit-word-primitive-jump
SYMBOL: jit-word-primitive-call
SYMBOL: jit-word-jump
SYMBOL: jit-word-call
SYMBOL: jit-push-wrapper
SYMBOL: jit-push-literal
SYMBOL: jit-if-word
SYMBOL: jit-if-jump
SYMBOL: jit-if-call
SYMBOL: jit-dispatch-word
SYMBOL: jit-dispatch
SYMBOL: jit-epilog
SYMBOL: jit-return

: userenv-offset ( symbol -- n )
    {
        { bootstrap-boot-quot 20 }
        { bootstrap-global 21 }
        { jit-code-format 22 }
        { jit-setup 23 }
        { jit-prolog 24 }
        { jit-word-primitive-jump 25 }
        { jit-word-primitive-call 26 }
        { jit-word-jump 27 }
        { jit-word-call 28 }
        { jit-push-wrapper 29 }
        { jit-push-literal 30 }
        { jit-if-word 31 }
        { jit-if-jump 32 }
        { jit-if-call 33 }
        { jit-dispatch-word 34 }
        { jit-dispatch 35 }
        { jit-epilog 36 }
        { jit-return 37 }
    } at header-size + ;

: emit ( cell -- ) image get push ;

: emit-64 ( cell -- )
    bootstrap-cell 8 = [
        emit
    ] [
        d>w/w big-endian get [ swap ] unless emit emit
    ] if ;

: emit-seq ( seq -- ) image get push-all ;

: fixup ( value offset -- ) image get set-nth ;

: heap-size ( -- size )
    image get length header-size - userenv-size -
    bootstrap-cells ;

: here ( -- size ) heap-size data-base + ;

: here-as ( tag -- pointer ) here swap bitor ;

: align-here ( -- )
    here 8 mod 4 = [ 0 emit ] when ;

: emit-fixnum ( n -- ) tag-bits get shift emit ;

: emit-object ( header tag quot -- addr )
    swap here-as >r swap tag-header emit call align-here r> ;
    inline

! Write an object to the image.
GENERIC: ' ( obj -- ptr )

! Image header

: emit-header ( -- )
    image-magic emit
    image-version emit
    data-base emit ! relocation base at end of header
    0 emit ! size of data heap set later
    0 emit ! reloc base of code heap is 0
    0 emit ! size of code heap is 0
    0 emit ! pointer to t object
    0 emit ! pointer to bignum 0
    0 emit ! pointer to bignum 1
    0 emit ! pointer to bignum -1
    userenv-size [ f ' emit ] times ;

: emit-userenv ( symbol -- )
    dup get ' swap userenv-offset fixup ;

! Bignums

: bignum-bits bootstrap-cell-bits 2 - ;

: bignum-radix bignum-bits 2^ 1- ;

: (bignum>seq) ( n -- )
    dup zero? [
        drop
    ] [
        dup bignum-radix bitand ,
        bignum-bits neg shift (bignum>seq)
    ] if ;

: bignum>seq ( n -- seq )
    #! n is positive or zero.
    [ (bignum>seq) ] { } make ;

: emit-bignum ( n -- )
    [ 0 < 1 0 ? ] keep abs bignum>seq
    dup length 1+ emit-fixnum
    swap emit emit-seq ;

M: bignum '
    bignum tag-number dup [ emit-bignum ] emit-object ;

! Fixnums

M: fixnum '
    #! When generating a 32-bit image on a 64-bit system,
    #! some fixnums should be bignums.
    dup most-negative-fixnum most-positive-fixnum between?
    [ tag-bits get shift ] [ >bignum ' ] if ;

! Floats

M: float '
    float tag-number dup [
        align-here double>bits emit-64
    ] emit-object ;

! Special objects

! Padded with fixnums for 8-byte alignment

: t, t t-offset fixup ;

M: f '
    #! f is #define F RETAG(0,F_TYPE)
    drop \ f tag-number ;

:  0,  0 >bignum '  0-offset fixup ;
:  1,  1 >bignum '  1-offset fixup ;
: -1, -1 >bignum ' -1-offset fixup ;

! Beginning of the image

: begin-image ( -- ) emit-header t, 0, 1, -1, ;

! Words

: emit-word ( word -- )
    [
        dup hashcode ' ,
        dup word-name ' ,
        dup word-vocabulary ' ,
        dup word-def ' ,
        dup word-props ' ,
        f ' ,
        0 ,
        0 ,
    ] { } make
    \ word type-number object tag-number
    [ emit-seq ] emit-object
    swap objects get set-at ;

: word-error ( word msg -- * )
    [ % dup word-vocabulary % " " % word-name % ] "" make throw ;

: transfer-word ( word -- word )
    dup target-word [ ] [ word-name no-word ] ?if ;

: fixup-word ( word -- offset )
    transfer-word dup objects get at
    [ ] [ "Not in image: " word-error ] ?if ;

: fixup-words ( -- )
    image get [ dup word? [ fixup-word ] when ] change-each ;

M: word ' ;

! Wrappers

M: wrapper '
    wrapped ' wrapper type-number object tag-number
    [ emit ] emit-object ;

! Strings
: 16be> 0 [ swap 16 shift bitor ] reduce ;
: 16le> <reversed> 16be> ;

: emit-chars ( seq -- )
    char <groups>
    big-endian get [ [ 16be> ] map ] [ [ 16le> ] map ] if
    emit-seq ;

: pack-string ( string -- newstr )
    dup length 1+ char align 0 pad-right ;

: emit-string ( string -- ptr )
    string type-number object tag-number [
        dup length emit-fixnum
        f ' emit
        pack-string emit-chars
    ] emit-object ;

M: string '
    #! We pool strings so that each string is only written once
    #! to the image
    objects get [ emit-string ] cache ;

: assert-empty ( seq -- )
    length 0 assert= ;

: emit-dummy-array ( obj type -- ptr )
    swap assert-empty
    type-number object tag-number
    [ 0 emit-fixnum ] emit-object ;

M: byte-array ' byte-array emit-dummy-array ;

M: bit-array ' bit-array emit-dummy-array ;

M: float-array ' float-array emit-dummy-array ;

! Arrays
: emit-array ( list type tag -- pointer )
    >r >r [ ' ] map r> r> [
        dup length emit-fixnum
        emit-seq
    ] emit-object ;

: emit-tuple ( obj -- pointer )
    objects get [
        [ tuple>array unclip transfer-word , % ] { } make
        tuple type-number dup emit-array
    ] cache ; inline

M: tuple ' emit-tuple ;

M: tombstone '
    delegate
    "((tombstone))" "((empty))" ? "hashtables.private" lookup
    word-def first emit-tuple ;

M: array '
    array type-number object tag-number emit-array ;

! Quotations

M: quotation '
    objects get [
        quotation-array '
        quotation type-number object tag-number [
            emit ! array
            0 emit ! XT
        ] emit-object
    ] cache ;

! Vectors and sbufs

M: vector '
    dup underlying ' swap length
    vector type-number object tag-number [
        emit-fixnum ! length
        emit ! array ptr
    ] emit-object ;

M: sbuf '
    dup underlying ' swap length
    sbuf type-number object tag-number [
        emit-fixnum ! length
        emit ! array ptr
    ] emit-object ;

! Hashes

M: hashtable '
    [ hash-array ' ] keep
    hashtable type-number object tag-number [
        dup hash-count emit-fixnum
        hash-deleted emit-fixnum
        emit ! array ptr
    ] emit-object ;

! Curries

M: curry '
    dup curry-quot ' swap curry-obj '
    \ curry type-number object tag-number
    [ emit emit ] emit-object ;

! End of the image

: emit-words ( -- )
    all-words [ emit-word ] each ;

: emit-global ( -- )
    [
        {
            dictionary source-files
            typemap builtins class<map update-map
        } [ dup get swap bootstrap-word set ] each
    ] H{ } make-assoc
    bootstrap-global set
    bootstrap-global emit-userenv ;

: emit-boot-quot ( -- )
    bootstrap-boot-quot emit-userenv ;

: emit-jit-data ( -- )
    \ if jit-if-word set
    \ dispatch jit-dispatch-word set
    {
        jit-code-format
        jit-setup
        jit-prolog
        jit-word-primitive-jump
        jit-word-primitive-call
        jit-word-jump
        jit-word-call
        jit-push-wrapper
        jit-push-literal
        jit-if-word
        jit-if-jump
        jit-if-call
        jit-dispatch-word
        jit-dispatch
        jit-epilog
        jit-return
    } [ emit-userenv ] each ;

: fixup-header ( -- )
    heap-size data-heap-size-offset fixup ;

: end-image ( -- )
    "Building generic words..." print flush
    all-words [ generic? ] subset [ make-generic ] each
    "Serializing words..." print flush
    emit-words
    "Serializing JIT data..." print flush
    emit-jit-data
    "Serializing global namespace..." print flush
    emit-global
    "Serializing boot quotation..." print flush
    emit-boot-quot
    "Performing word fixups..." print flush
    fixup-words
    "Performing header fixups..." print flush
    fixup-header
    "Image length: " write image get length .
    "Object cache size: " write objects get assoc-size .
    \ word global delete-at ;

! Image output

: (write-image) ( image -- )
    bootstrap-cell big-endian get [
        [ >be write ] curry each
    ] [
        [ >le write ] curry each
    ] if ;

: image-name
    "boot." architecture get ".image" 3append resource-path ;

: write-image ( image filename -- )
    "Writing image to " write dup write "..." print flush
    <file-writer> [ (write-image) ] with-stream ;

: prepare-profile ( arch -- )
    "resource:core/bootstrap/layouts/layouts.factor" run-file
    "resource:core/cpu/" swap {
        { "x86.32" "x86/32" }
        { "x86.64" "x86/64" }
        { "linux-ppc" "ppc/linux" }
        { "macosx-ppc" "ppc/macosx" }
        { "arm" "arm" }
    } at "/bootstrap.factor" 3append ?resource-path run-file ;

: prepare-image ( arch -- )
    dup architecture set prepare-profile
    bootstrapping? on
    load-help? off
    800000 <vector> image set 20000 <hashtable> objects set ;

PRIVATE>

: make-image ( architecture -- )
    [
        parse-hook off
        prepare-image
        begin-image
        "resource:/core/bootstrap/stage1.factor" run-file
        end-image
        image get image-name write-image
    ] with-scope ;

: make-images ( -- )
    {
        "x86.32" "x86.64" "linux-ppc" "macosx-ppc" "arm"
    } [ make-image ] each ;
