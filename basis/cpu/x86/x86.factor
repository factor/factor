! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs alien alien.c-types arrays strings
cpu.x86.assembler cpu.x86.assembler.private cpu.x86.assembler.operands
cpu.x86.features cpu.x86.features.private cpu.architecture kernel
kernel.private math memory namespaces make sequences words system
layouts combinators math.order fry locals compiler.constants
byte-arrays io macros quotations compiler compiler.units init vm
compiler.cfg.registers
compiler.cfg.instructions
compiler.cfg.intrinsics
compiler.cfg.comparisons
compiler.cfg.stack-frame
compiler.codegen.fixup ;
FROM: layouts => cell ;
FROM: math => float ;
IN: cpu.x86

! Add some methods to the assembler to be more useful to the backend
M: label JMP 0 JMP rc-relative label-fixup ;
M: label JUMPcc [ 0 ] dip JUMPcc rc-relative label-fixup ;

M: x86 vector-regs float-regs ;

HOOK: stack-reg cpu ( -- reg )

HOOK: reserved-area-size cpu ( -- n )

: stack@ ( n -- op ) stack-reg swap [+] ;

: param@ ( n -- op ) reserved-area-size + stack@ ;

: spill@ ( n -- op ) spill-offset param@ ;

: gc-root@ ( n -- op ) gc-root-offset param@ ;

: decr-stack-reg ( n -- )
    dup 0 = [ drop ] [ stack-reg swap SUB ] if ;

: incr-stack-reg ( n -- )
    dup 0 = [ drop ] [ stack-reg swap ADD ] if ;

: align-stack ( n -- n' )
    os macosx? cpu x86.64? or [ 16 align ] when ;

M: x86 stack-frame-size ( stack-frame -- i )
    (stack-frame-size) 3 cells reserved-area-size + + align-stack ;

! Must be a volatile register not used for parameter passing, for safe
! use in calls in and out of C
HOOK: temp-reg cpu ( -- reg )

HOOK: pic-tail-reg cpu ( -- reg )

M: x86 %load-immediate dup 0 = [ drop dup XOR ] [ MOV ] if ;

M: x86 %load-reference swap 0 MOV rc-absolute-cell rel-immediate ;

HOOK: ds-reg cpu ( -- reg )
HOOK: rs-reg cpu ( -- reg )

: reg-stack ( n reg -- op ) swap cells neg [+] ;

GENERIC: loc>operand ( loc -- operand )

M: ds-loc loc>operand n>> ds-reg reg-stack ;
M: rs-loc loc>operand n>> rs-reg reg-stack ;

M: x86 %peek loc>operand MOV ;
M: x86 %replace loc>operand swap MOV ;
: (%inc) ( n reg -- ) swap cells dup 0 > [ ADD ] [ neg SUB ] if ; inline
M: x86 %inc-d ( n -- ) ds-reg (%inc) ;
M: x86 %inc-r ( n -- ) rs-reg (%inc) ;

M: x86 %call ( word -- ) 0 CALL rc-relative rel-word-pic ;

: xt-tail-pic-offset ( -- n )
    #! See the comment in vm/cpu-x86.hpp
    cell 4 + 1 + ; inline

M: x86 %jump ( word -- )
    pic-tail-reg 0 MOV xt-tail-pic-offset rc-absolute-cell rel-here
    0 JMP rc-relative rel-word-pic-tail ;

M: x86 %jump-label ( label -- ) 0 JMP rc-relative label-fixup ;

M: x86 %return ( -- ) 0 RET ;

: code-alignment ( align -- n )
    [ building get length dup ] dip align swap - ;

: align-code ( n -- )
    0 <repetition> % ;

:: (%slot-imm) ( obj slot tag -- op )
    obj slot cells tag - [+] ; inline

M: x86 %slot ( dst obj slot -- ) [+] MOV ;
M: x86 %slot-imm ( dst obj slot tag -- ) (%slot-imm) MOV ;
M: x86 %set-slot ( src obj slot -- ) [+] swap MOV ;
M: x86 %set-slot-imm ( src obj slot tag -- ) (%slot-imm) swap MOV ;

:: two-operand ( dst src1 src2 rep -- dst src )
    dst src2 eq? dst src1 eq? not and [ "Cannot handle this case" throw ] when
    dst src1 rep %copy
    dst src2 ; inline

:: one-operand ( dst src rep -- dst )
    dst src rep %copy
    dst ; inline

M: x86 %add     2over eq? [ nip ADD ] [ [+] LEA ] if ;
M: x86 %add-imm 2over eq? [ nip ADD ] [ [+] LEA ] if ;
M: x86 %sub     int-rep two-operand SUB ;
M: x86 %sub-imm 2over eq? [ nip SUB ] [ neg [+] LEA ] if ;
M: x86 %mul     int-rep two-operand swap IMUL2 ;
M: x86 %mul-imm IMUL3 ;
M: x86 %and     int-rep two-operand AND ;
M: x86 %and-imm int-rep two-operand AND ;
M: x86 %or      int-rep two-operand OR ;
M: x86 %or-imm  int-rep two-operand OR ;
M: x86 %xor     int-rep two-operand XOR ;
M: x86 %xor-imm int-rep two-operand XOR ;
M: x86 %shl-imm int-rep two-operand SHL ;
M: x86 %shr-imm int-rep two-operand SHR ;
M: x86 %sar-imm int-rep two-operand SAR ;

M: x86 %min     int-rep two-operand [ CMP ] [ CMOVG ] 2bi ;
M: x86 %max     int-rep two-operand [ CMP ] [ CMOVL ] 2bi ;

M: x86 %not     int-rep one-operand NOT ;
M: x86 %neg     int-rep one-operand NEG ;
M: x86 %log2    BSR ;

GENERIC: copy-register* ( dst src rep -- )

M: int-rep copy-register* drop MOV ;
M: tagged-rep copy-register* drop MOV ;
M: float-rep copy-register* drop MOVSS ;
M: double-rep copy-register* drop MOVSD ;
M: float-4-rep copy-register* drop MOVUPS ;
M: double-2-rep copy-register* drop MOVUPD ;
M: vector-rep copy-register* drop MOVDQU ;

M: x86 %copy ( dst src rep -- )
    2over eq? [ 3drop ] [
        [ [ dup spill-slot? [ n>> spill@ ] when ] bi@ ] dip
        copy-register*
    ] if ;

M: x86 %fixnum-add ( label dst src1 src2 -- )
    int-rep two-operand ADD JO ;

M: x86 %fixnum-sub ( label dst src1 src2 -- )
    int-rep two-operand SUB JO ;

M: x86 %fixnum-mul ( label dst src1 src2 -- )
    int-rep two-operand swap IMUL2 JO ;

M: x86 %unbox-alien ( dst src -- )
    alien-offset [+] MOV ;

M:: x86 %unbox-any-c-ptr ( dst src temp -- )
    [
        { "is-byte-array" "end" "start" } [ define-label ] each
        dst 0 MOV
        temp src MOV
        ! We come back here with displaced aliens
        "start" resolve-label
        ! Is the object f?
        temp \ f tag-number CMP
        "end" get JE
        ! Is the object an alien?
        temp header-offset [+] alien type-number tag-fixnum CMP
        "is-byte-array" get JNE
        ! If so, load the offset and add it to the address
        dst temp alien-offset [+] ADD
        ! Now recurse on the underlying alien
        temp temp underlying-alien-offset [+] MOV
        "start" get JMP
        "is-byte-array" resolve-label
        ! Add byte array address to address being computed
        dst temp ADD
        ! Add an offset to start of byte array's data
        dst byte-array-offset ADD
        "end" resolve-label
    ] with-scope ;

: alien@ ( reg n -- op ) cells alien tag-number - [+] ;

:: %allot-alien ( dst displacement base temp -- )
    dst 4 cells alien temp %allot
    dst 1 alien@ base MOV ! alien
    dst 2 alien@ \ f tag-number MOV ! expired
    dst 3 alien@ displacement MOV ! displacement
    ;

M:: x86 %box-alien ( dst src temp -- )
    [
        "end" define-label
        dst \ f tag-number MOV
        src 0 CMP
        "end" get JE
        dst src \ f tag-number temp %allot-alien
        "end" resolve-label
    ] with-scope ;

M:: x86 %box-displaced-alien ( dst displacement base displacement' base' base-class -- )
    [
        "end" define-label
        "ok" define-label
        ! If displacement is zero, return the base
        dst base MOV
        displacement 0 CMP
        "end" get JE
        ! Quickly use displacement' before its needed for real, as allot temporary
        dst 4 cells alien displacement' %allot
        ! If base is already a displaced alien, unpack it
        base' base MOV
        displacement' displacement MOV
        base \ f tag-number CMP
        "ok" get JE
        base header-offset [+] alien type-number tag-fixnum CMP
        "ok" get JNE
        ! displacement += base.displacement
        displacement' base 3 alien@ ADD
        ! base = base.base
        base' base 1 alien@ MOV
        "ok" resolve-label
        dst 1 alien@ base' MOV ! alien
        dst 2 alien@ \ f tag-number MOV ! expired
        dst 3 alien@ displacement' MOV ! displacement
        "end" resolve-label
    ] with-scope ;

! The 'small-reg' mess is pretty crappy, but its only used on x86-32.
! On x86-64, all registers have 8-bit versions. However, a similar
! problem arises for shifts, where the shift count must be in CL, and
! so one day I will fix this properly by adding precoloring to the
! register allocator.

HOOK: has-small-reg? cpu ( reg size -- ? )

CONSTANT: have-byte-regs { EAX ECX EDX EBX }

M: x86.32 has-small-reg?
    {
        { 8 [ have-byte-regs memq? ] }
        { 16 [ drop t ] }
        { 32 [ drop t ] }
    } case ;

M: x86.64 has-small-reg? 2drop t ;

: small-reg-that-isn't ( exclude -- reg' )
    [ have-byte-regs ] dip
    [ native-version-of ] map
    '[ _ memq? not ] find nip ;

: with-save/restore ( reg quot -- )
    [ drop PUSH ] [ call ] [ drop POP ] 2tri ; inline

:: with-small-register ( dst exclude size quot: ( new-dst -- ) -- )
    ! If the destination register overlaps a small register with
    ! 'size' bits, we call the quot with that. Otherwise, we find a
    ! small register that is not in exclude, and call quot, saving and
    ! restoring the small register.
    dst size has-small-reg? [ dst quot call ] [
        exclude small-reg-that-isn't
        [ quot call ] with-save/restore
    ] if ; inline

M:: x86 %string-nth ( dst src index temp -- )
    ! We request a small-reg of size 8 since those of size 16 are
    ! a superset.
    "end" define-label
    dst { src index temp } 8 [| new-dst |
        ! Load the least significant 7 bits into new-dst.
        ! 8th bit indicates whether we have to load from
        ! the aux vector or not.
        temp src index [+] LEA
        new-dst 8-bit-version-of temp string-offset [+] MOV
        new-dst new-dst 8-bit-version-of MOVZX
        ! Do we have to look at the aux vector?
        new-dst HEX: 80 CMP
        "end" get JL
        ! Yes, this is a non-ASCII character. Load aux vector
        temp src string-aux-offset [+] MOV
        new-dst temp XCHG
        ! Compute index
        new-dst index ADD
        new-dst index ADD
        ! Load high 16 bits
        new-dst 16-bit-version-of new-dst byte-array-offset [+] MOV
        new-dst new-dst 16-bit-version-of MOVZX
        new-dst 7 SHL
        ! Compute code point
        new-dst temp XOR
        "end" resolve-label
        dst new-dst int-rep %copy
    ] with-small-register ;

M:: x86 %set-string-nth-fast ( ch str index temp -- )
    ch { index str temp } 8 [| new-ch |
        new-ch ch int-rep %copy
        temp str index [+] LEA
        temp string-offset [+] new-ch 8-bit-version-of MOV
    ] with-small-register ;

:: %alien-integer-getter ( dst src offset size quot -- )
    dst { src } size [| new-dst |
        new-dst dup size n-bit-version-of dup src offset [+] MOV
        quot call
        dst new-dst int-rep %copy
    ] with-small-register ; inline

: %alien-unsigned-getter ( dst src offset size -- )
    [ MOVZX ] %alien-integer-getter ; inline

: %alien-signed-getter ( dst src offset size -- )
    [ MOVSX ] %alien-integer-getter ; inline

:: %alien-integer-setter ( ptr offset value size -- )
    value { ptr } size [| new-value |
        new-value value int-rep %copy
        ptr offset [+] new-value size n-bit-version-of MOV
    ] with-small-register ; inline

M: x86 %alien-unsigned-1 8 %alien-unsigned-getter ;
M: x86 %alien-unsigned-2 16 %alien-unsigned-getter ;
M: x86 %alien-unsigned-4 32 [ 2drop ] %alien-integer-getter ;

M: x86 %alien-signed-1 8 %alien-signed-getter ;
M: x86 %alien-signed-2 16 %alien-signed-getter ;
M: x86 %alien-signed-4 32 %alien-signed-getter ;

M: x86 %alien-cell [+] MOV ;
M: x86 %alien-float [+] MOVSS ;
M: x86 %alien-double [+] MOVSD ;
M: x86 %alien-vector [ [+] ] dip %copy ;

M: x86 %set-alien-integer-1 8 %alien-integer-setter ;
M: x86 %set-alien-integer-2 16 %alien-integer-setter ;
M: x86 %set-alien-integer-4 32 %alien-integer-setter ;
M: x86 %set-alien-cell [ [+] ] dip MOV ;
M: x86 %set-alien-float [ [+] ] dip MOVSS ;
M: x86 %set-alien-double [ [+] ] dip MOVSD ;
M: x86 %set-alien-vector [ [+] ] 2dip %copy ;

: shift-count? ( reg -- ? ) { ECX RCX } memq? ;

:: emit-shift ( dst src quot -- )
    src shift-count? [
        dst CL quot call
    ] [
        dst shift-count? [
            dst src XCHG
            src CL quot call
            dst src XCHG
        ] [
            ECX native-version-of [
                CL src MOV
                drop dst CL quot call
            ] with-save/restore
        ] if
    ] if ; inline

M: x86 %shl int-rep two-operand [ SHL ] emit-shift ;
M: x86 %shr int-rep two-operand [ SHR ] emit-shift ;
M: x86 %sar int-rep two-operand [ SAR ] emit-shift ;

M: x86 %vm-field-ptr ( dst field -- )
    [ drop 0 MOV rc-absolute-cell rt-vm rel-fixup ]
    [ vm-field-offset ADD ] 2bi ;

: load-zone-ptr ( reg -- )
    #! Load pointer to start of zone array
    "nursery" %vm-field-ptr ;

: load-allot-ptr ( nursery-ptr allot-ptr -- )
    [ drop load-zone-ptr ] [ swap cell [+] MOV ] 2bi ;

: inc-allot-ptr ( nursery-ptr n -- )
    [ cell [+] ] dip 8 align ADD ;

: store-header ( temp class -- )
    [ [] ] [ type-number tag-fixnum ] bi* MOV ;

: store-tagged ( dst tag -- )
    tag-number OR ;

M:: x86 %allot ( dst size class nursery-ptr -- )
    nursery-ptr dst load-allot-ptr
    dst class store-header
    dst class store-tagged
    nursery-ptr size inc-allot-ptr ;

M:: x86 %write-barrier ( src card# table -- )
    #! Mark the card pointed to by vreg.
    ! Mark the card
    card# src MOV
    card# card-bits SHR
    table "cards_offset" %vm-field-ptr
    table table [] MOV
    table card# [+] card-mark <byte> MOV

    ! Mark the card deck
    card# deck-bits card-bits - SHR
    table "decks_offset" %vm-field-ptr
    table table [] MOV
    table card# [+] card-mark <byte> MOV ;

M:: x86 %check-nursery ( label temp1 temp2 -- )
    temp1 load-zone-ptr
    temp2 temp1 cell [+] MOV
    temp2 1024 ADD
    temp1 temp1 3 cells [+] MOV
    temp2 temp1 CMP
    label JLE ;

M: x86 %save-gc-root ( gc-root register -- ) [ gc-root@ ] dip MOV ;

M: x86 %load-gc-root ( gc-root register -- ) swap gc-root@ MOV ;

M: x86 %alien-global ( dst symbol library -- )
    [ 0 MOV ] 2dip rc-absolute-cell rel-dlsym ;    

M: x86 %epilogue ( n -- ) cell - incr-stack-reg ;

:: %boolean ( dst temp word -- )
    dst \ f tag-number MOV
    temp 0 MOV \ t rc-absolute-cell rel-immediate
    dst temp word execute ; inline

M:: x86 %compare ( dst src1 src2 cc temp -- )
    src1 src2 CMP
    cc order-cc {
        { cc<  [ dst temp \ CMOVL %boolean ] }
        { cc<= [ dst temp \ CMOVLE %boolean ] }
        { cc>  [ dst temp \ CMOVG %boolean ] }
        { cc>= [ dst temp \ CMOVGE %boolean ] }
        { cc=  [ dst temp \ CMOVE %boolean ] }
        { cc/= [ dst temp \ CMOVNE %boolean ] }
    } case ;

M: x86 %compare-imm ( dst src1 src2 cc temp -- )
    %compare ;

M:: x86 %compare-branch ( label src1 src2 cc -- )
    src1 src2 CMP
    cc order-cc {
        { cc<  [ label JL ] }
        { cc<= [ label JLE ] }
        { cc>  [ label JG ] }
        { cc>= [ label JGE ] }
        { cc=  [ label JE ] }
        { cc/= [ label JNE ] }
    } case ;

M: x86 %compare-imm-branch ( label src1 src2 cc -- )
    %compare-branch ;

M: x86 %add-float double-rep two-operand ADDSD ;
M: x86 %sub-float double-rep two-operand SUBSD ;
M: x86 %mul-float double-rep two-operand MULSD ;
M: x86 %div-float double-rep two-operand DIVSD ;
M: x86 %min-float double-rep two-operand MINSD ;
M: x86 %max-float double-rep two-operand MAXSD ;
M: x86 %sqrt SQRTSD ;

M: x86 %single>double-float CVTSS2SD ;
M: x86 %double>single-float CVTSD2SS ;

M: x86 %integer>float CVTSI2SD ;
M: x86 %float>integer CVTTSD2SI ;

: %cmov-float= ( dst src -- )
    [
        "no-move" define-label

        "no-move" get [ JNE ] [ JP ] bi
        MOV
        "no-move" resolve-label
    ] with-scope ;

: %cmov-float/= ( dst src -- )
    [
        "no-move" define-label
        "move" define-label

        "move" get JP
        "no-move" get JE
        "move" resolve-label
        MOV
        "no-move" resolve-label
    ] with-scope ;

:: (%compare-float) ( dst src1 src2 cc temp compare -- )
    cc {
        { cc<    [ src2 src1 \ compare execute( a b -- ) dst temp \ CMOVA  %boolean ] }
        { cc<=   [ src2 src1 \ compare execute( a b -- ) dst temp \ CMOVAE %boolean ] }
        { cc>    [ src1 src2 \ compare execute( a b -- ) dst temp \ CMOVA  %boolean ] }
        { cc>=   [ src1 src2 \ compare execute( a b -- ) dst temp \ CMOVAE %boolean ] }
        { cc=    [ src1 src2 \ compare execute( a b -- ) dst temp \ %cmov-float= %boolean ] }
        { cc<>   [ src1 src2 \ compare execute( a b -- ) dst temp \ CMOVNE %boolean ] }
        { cc<>=  [ src1 src2 \ compare execute( a b -- ) dst temp \ CMOVNP %boolean ] }
        { cc/<   [ src2 src1 \ compare execute( a b -- ) dst temp \ CMOVBE %boolean ] }
        { cc/<=  [ src2 src1 \ compare execute( a b -- ) dst temp \ CMOVB  %boolean ] }
        { cc/>   [ src1 src2 \ compare execute( a b -- ) dst temp \ CMOVBE %boolean ] }
        { cc/>=  [ src1 src2 \ compare execute( a b -- ) dst temp \ CMOVB  %boolean ] }
        { cc/=   [ src1 src2 \ compare execute( a b -- ) dst temp \ %cmov-float/= %boolean ] }
        { cc/<>  [ src1 src2 \ compare execute( a b -- ) dst temp \ CMOVE  %boolean ] }
        { cc/<>= [ src1 src2 \ compare execute( a b -- ) dst temp \ CMOVP  %boolean ] }
    } case ; inline

M: x86 %compare-float-ordered ( dst src1 src2 cc temp -- )
    \ COMISD (%compare-float) ;

M: x86 %compare-float-unordered ( dst src1 src2 cc temp -- )
    \ UCOMISD (%compare-float) ;

: %jump-float= ( label -- )
    [
        "no-jump" define-label
        "no-jump" get JP
        JE
        "no-jump" resolve-label
    ] with-scope ;

: %jump-float/= ( label -- )
    [ JNE ] [ JP ] bi ;

:: (%compare-float-branch) ( label src1 src2 cc compare -- )
    cc {
        { cc<    [ src2 src1 \ compare execute( a b -- ) label JA  ] }
        { cc<=   [ src2 src1 \ compare execute( a b -- ) label JAE ] }
        { cc>    [ src1 src2 \ compare execute( a b -- ) label JA  ] }
        { cc>=   [ src1 src2 \ compare execute( a b -- ) label JAE ] }
        { cc=    [ src1 src2 \ compare execute( a b -- ) label %jump-float= ] }
        { cc<>   [ src1 src2 \ compare execute( a b -- ) label JNE ] }
        { cc<>=  [ src1 src2 \ compare execute( a b -- ) label JNP ] }
        { cc/<   [ src2 src1 \ compare execute( a b -- ) label JBE ] }
        { cc/<=  [ src2 src1 \ compare execute( a b -- ) label JB  ] }
        { cc/>   [ src1 src2 \ compare execute( a b -- ) label JBE ] }
        { cc/>=  [ src1 src2 \ compare execute( a b -- ) label JB  ] }
        { cc/=   [ src1 src2 \ compare execute( a b -- ) label %jump-float/= ] }
        { cc/<>  [ src1 src2 \ compare execute( a b -- ) label JE  ] }
        { cc/<>= [ src1 src2 \ compare execute( a b -- ) label JP  ] }
    } case ;

M: x86 %compare-float-ordered-branch ( label src1 src2 cc -- )
    \ COMISD (%compare-float-branch) ;

M: x86 %compare-float-unordered-branch ( label src1 src2 cc -- )
    \ UCOMISD (%compare-float-branch) ;

MACRO: available-reps ( alist -- )
    ! Each SSE version adds new representations and supports
    ! all old ones
    unzip { } [ append ] accumulate rest swap suffix
    [ [ 1quotation ] map ] bi@ zip
    reverse [ { } ] suffix
    '[ _ cond ] ;

M: x86 %zero-vector
    {
        { double-2-rep [ dup XORPD ] }
        { float-4-rep [ dup XORPS ] }
        [ drop dup PXOR ]
    } case ;

M: x86 %zero-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M: x86 %fill-vector
    {
        { double-2-rep [ dup [ XORPD ] [ CMPEQPD ] 2bi ] }
        { float-4-rep  [ dup [ XORPS ] [ CMPEQPS ] 2bi ] }
        [ drop dup PCMPEQB ]
    } case ;

M: x86 %fill-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

: unsign-rep ( rep -- rep' )
    {
        { uint-4-rep      int-4-rep }
        { ulonglong-2-rep longlong-2-rep }
        { ushort-8-rep    short-8-rep }
        { uchar-16-rep    char-16-rep }
    } ?at drop ;

! M:: x86 %broadcast-vector ( dst src rep -- )
!     rep unsign-rep {
!         { float-4-rep [
!             dst src float-4-rep %copy
!             dst dst { 0 0 0 0 } SHUFPS
!         ] }
!         { double-2-rep [
!             dst src MOVDDUP
!         ] }
!         { longlong-2-rep [
!             dst src =
!             [ dst dst PUNPCKLQDQ ]
!             [ dst src { 0 1 0 1 } PSHUFD ]
!             if
!         ] }
!         { int-4-rep [
!             dst src { 0 0 0 0 } PSHUFD
!         ] }
!         { short-8-rep [
!             dst src { 0 0 0 0 } PSHUFLW 
!             dst dst PUNPCKLQDQ 
!         ] }
!         { char-16-rep [
!             dst src char-16-rep %copy
!             dst dst PUNPCKLBW
!             dst dst { 0 0 0 0 } PSHUFLW
!             dst dst PUNPCKLQDQ
!         ] }
!     } case ;
! 
! M: x86 %broadcast-vector-reps
!     {
!         ! Can't do this with sse1 since it will want to unbox
!         ! a double-precision float and convert to single precision
!         { sse2? { float-4-rep double-2-rep longlong-2-rep ulonglong-2-rep int-4-rep uint-4-rep short-8-rep ushort-8-rep char-16-rep uchar-16-rep } }
!     } available-reps ;

M:: x86 %gather-vector-4 ( dst src1 src2 src3 src4 rep -- )
    rep unsign-rep {
        { float-4-rep [
            dst src1 float-4-rep %copy
            dst src2 UNPCKLPS
            src3 src4 UNPCKLPS
            dst src3 MOVLHPS
        ] }
        { int-4-rep [
            dst src1 int-4-rep %copy
            dst src2 PUNPCKLDQ
            src3 src4 PUNPCKLDQ
            dst src3 PUNPCKLQDQ
        ] }
    } case ;

M: x86 %gather-vector-4-reps
    {
        ! Can't do this with sse1 since it will want to unbox
        ! double-precision floats and convert to single precision
        { sse2? { float-4-rep int-4-rep uint-4-rep } }
    } available-reps ;

M:: x86 %gather-vector-2 ( dst src1 src2 rep -- )
    rep unsign-rep {
        { double-2-rep [
            dst src1 double-2-rep %copy
            dst src2 UNPCKLPD
        ] }
        { longlong-2-rep [
            dst src1 longlong-2-rep %copy
            dst src2 PUNPCKLQDQ
        ] }
    } case ;

M: x86 %gather-vector-2-reps
    {
        { sse2? { double-2-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

: double-2-shuffle ( dst shuffle -- )
    {
        { { 0 1 } [ drop ] }
        { { 0 0 } [ dup UNPCKLPD ] }
        { { 1 1 } [ dup UNPCKHPD ] }
        [ dupd SHUFPD ]
    } case ;

: float-4-shuffle ( dst shuffle -- )
    {
        { { 0 1 2 3 } [ drop ] }
        { { 0 0 2 2 } [ dup MOVSLDUP ] }
        { { 1 1 3 3 } [ dup MOVSHDUP ] }
        { { 0 1 0 1 } [ dup MOVLHPS ] }
        { { 2 3 2 3 } [ dup MOVHLPS ] }
        { { 0 0 1 1 } [ dup UNPCKLPS ] }
        { { 2 2 3 3 } [ dup UNPCKHPS ] }
        [ dupd SHUFPS ]
    } case ;

: int-4-shuffle ( dst shuffle -- )
    {
        { { 0 1 2 3 } [ drop ] }
        { { 0 0 1 1 } [ dup PUNPCKLDQ ] }
        { { 2 2 3 3 } [ dup PUNPCKHDQ ] }
        { { 0 1 0 1 } [ dup PUNPCKLQDQ ] }
        { { 2 3 2 3 } [ dup PUNPCKHQDQ ] }
        [ dupd PSHUFD ]
    } case ;

: longlong-2-shuffle ( dst shuffle -- )
    first2 [ 2 * dup 1 + ] bi@ 4array int-4-shuffle ;

M:: x86 %shuffle-vector ( dst src shuffle rep -- )
    dst src rep %copy
    dst shuffle rep unsign-rep {
        { double-2-rep [ double-2-shuffle ] }
        { float-4-rep [ float-4-shuffle ] }
        { int-4-rep [ int-4-shuffle ] }
        { longlong-2-rep [ longlong-2-shuffle ] }
    } case ;

M: x86 %shuffle-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

:: compare-float-v-operands ( dst src1 src2 temp rep cc -- dst' src' rep cc' )
    cc { cc> cc>= cc/> cc/>= } member?
    [ dst src2 src1 rep two-operand rep cc swap-cc ]
    [ dst src1 src2 rep two-operand rep cc         ] if ;
: (%compare-float-vector) ( dst src rep double single -- )
    [ double-2-rep eq? ] 2dip if ; inline
: %compare-float-vector ( dst src1 src2 temp rep cc -- )
    compare-float-v-operands {
        { cc<    [ [ CMPLTPD    ] [ CMPLTPS    ] (%compare-float-vector) ] }
        { cc<=   [ [ CMPLEPD    ] [ CMPLEPS    ] (%compare-float-vector) ] }
        { cc=    [ [ CMPEQPD    ] [ CMPEQPS    ] (%compare-float-vector) ] }
        { cc<>=  [ [ CMPORDPD   ] [ CMPORDPS   ] (%compare-float-vector) ] }
        { cc/<   [ [ CMPNLTPD   ] [ CMPNLTPS   ] (%compare-float-vector) ] }
        { cc/<=  [ [ CMPNLEPD   ] [ CMPNLEPS   ] (%compare-float-vector) ] }
        { cc/=   [ [ CMPNEQPD   ] [ CMPNEQPS   ] (%compare-float-vector) ] }
        { cc/<>= [ [ CMPUNORDPD ] [ CMPUNORDPS ] (%compare-float-vector) ] }
    } case ;

:: compare-int-v-operands ( dst src1 src2 temp rep cc -- not-dst/f cmp-dst src' rep cc' )
    cc order-cc :> occ
    occ {
        { cc=  [ f   dst  src1 src2 rep two-operand rep cc= ] }
        { cc/= [ dst temp src1 src2 rep two-operand rep cc= ] }
        { cc<= [ dst temp src1 src2 rep two-operand rep cc> ] }
        { cc<  [ f   dst  src2 src1 rep two-operand rep cc> ] }
        { cc>  [ f   dst  src1 src2 rep two-operand rep cc> ] }
        { cc>= [ dst temp src2 src1 rep two-operand rep cc> ] }
    } case ;
:: (%compare-int-vector) ( dst src rep int64 int32 int16 int8 -- )
    rep unsign-rep :> rep'
    dst src rep' {
        { longlong-2-rep [ int64 call ] }
        { int-4-rep      [ int32 call ] }
        { short-8-rep    [ int16 call ] }
        { char-16-rep    [ int8  call ] }
    } case ; inline
:: %compare-int-vector ( dst src1 src2 temp rep cc -- )
    dst src1 src2 temp rep cc compare-int-v-operands :> cc' :> rep :> src' :> cmp-dst :> not-dst
    cmp-dst src' rep cc' {
        { cc= [ [ PCMPEQQ ] [ PCMPEQD ] [ PCMPEQW ] [ PCMPEQB ] (%compare-int-vector) ] }
        { cc> [ [ PCMPGTQ ] [ PCMPGTD ] [ PCMPGTW ] [ PCMPGTB ] (%compare-int-vector) ] }
    } case
    not-dst [ cmp-dst rep %not-vector ] when* ;

M: x86 %compare-vector ( dst src1 src2 temp rep cc -- )
    over float-vector-rep?
    [ %compare-float-vector ]
    [ %compare-int-vector ] if ;

: %compare-vector-eq-reps ( -- reps )
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep } }
        { sse4.1? { longlong-2-rep ulonglong-2-rep } }
    } available-reps ;
: %compare-vector-unord-reps ( -- reps )
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep } }
    } available-reps ;
: %compare-vector-ord-reps ( -- reps )
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep short-8-rep int-4-rep } }
        { sse4.1? { longlong-2-rep } }
    } available-reps ;

M: x86 %compare-vector-reps
    {
        { [ dup { cc= cc/= } memq? ] [ drop %compare-vector-eq-reps ] }
        { [ dup { cc<>= cc/<>= } memq? ] [ drop %compare-vector-unord-reps ] }
        [ drop %compare-vector-ord-reps ]
    } cond ;

:: %test-vector-mask ( dst temp mask vcc -- )
    vcc {
        { vcc-any    [ dst dst TEST dst temp \ CMOVNE %boolean ] }
        { vcc-none   [ dst dst TEST dst temp \ CMOVE  %boolean ] }
        { vcc-all    [ dst mask CMP dst temp \ CMOVE  %boolean ] }
        { vcc-notall [ dst mask CMP dst temp \ CMOVNE %boolean ] }
    } case ;

: %move-vector-mask ( dst src rep -- mask )
    {
        { double-2-rep [ MOVMSKPD HEX: 3 ] }
        { float-4-rep  [ MOVMSKPS HEX: f ] }
        [ drop PMOVMSKB HEX: ffff ]
    } case ;

M:: x86 %test-vector ( dst src temp rep vcc -- )
    dst src rep %move-vector-mask :> mask
    dst temp mask vcc %test-vector-mask ;

:: %test-vector-mask-branch ( label temp mask vcc -- )
    vcc {
        { vcc-any    [ temp temp TEST label JNE ] }
        { vcc-none   [ temp temp TEST label JE ] }
        { vcc-all    [ temp mask CMP label JE ] }
        { vcc-notall [ temp mask CMP label JNE ] }
    } case ;

M:: x86 %test-vector-branch ( label src temp rep vcc -- )
    temp src rep %move-vector-mask :> mask
    label temp mask vcc %test-vector-mask-branch ;

M: x86 %test-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M: x86 %add-vector ( dst src1 src2 rep -- )
    [ two-operand ] keep
    {
        { float-4-rep [ ADDPS ] }
        { double-2-rep [ ADDPD ] }
        { char-16-rep [ PADDB ] }
        { uchar-16-rep [ PADDB ] }
        { short-8-rep [ PADDW ] }
        { ushort-8-rep [ PADDW ] }
        { int-4-rep [ PADDD ] }
        { uint-4-rep [ PADDD ] }
        { longlong-2-rep [ PADDQ ] }
        { ulonglong-2-rep [ PADDQ ] }
    } case ;

M: x86 %add-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M: x86 %saturated-add-vector ( dst src1 src2 rep -- )
    [ two-operand ] keep
    {
        { char-16-rep [ PADDSB ] }
        { uchar-16-rep [ PADDUSB ] }
        { short-8-rep [ PADDSW ] }
        { ushort-8-rep [ PADDUSW ] }
    } case ;

M: x86 %saturated-add-vector-reps
    {
        { sse2? { char-16-rep uchar-16-rep short-8-rep ushort-8-rep } }
    } available-reps ;

M: x86 %add-sub-vector ( dst src1 src2 rep -- )
    [ two-operand ] keep
    {
        { float-4-rep [ ADDSUBPS ] }
        { double-2-rep [ ADDSUBPD ] }
    } case ;

M: x86 %add-sub-vector-reps
    {
        { sse3? { float-4-rep double-2-rep } }
    } available-reps ;

M: x86 %sub-vector ( dst src1 src2 rep -- )
    [ two-operand ] keep
    {
        { float-4-rep [ SUBPS ] }
        { double-2-rep [ SUBPD ] }
        { char-16-rep [ PSUBB ] }
        { uchar-16-rep [ PSUBB ] }
        { short-8-rep [ PSUBW ] }
        { ushort-8-rep [ PSUBW ] }
        { int-4-rep [ PSUBD ] }
        { uint-4-rep [ PSUBD ] }
        { longlong-2-rep [ PSUBQ ] }
        { ulonglong-2-rep [ PSUBQ ] }
    } case ;

M: x86 %sub-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M: x86 %saturated-sub-vector ( dst src1 src2 rep -- )
    [ two-operand ] keep
    {
        { char-16-rep [ PSUBSB ] }
        { uchar-16-rep [ PSUBUSB ] }
        { short-8-rep [ PSUBSW ] }
        { ushort-8-rep [ PSUBUSW ] }
    } case ;

M: x86 %saturated-sub-vector-reps
    {
        { sse2? { char-16-rep uchar-16-rep short-8-rep ushort-8-rep } }
    } available-reps ;

M: x86 %mul-vector ( dst src1 src2 rep -- )
    [ two-operand ] keep
    {
        { float-4-rep [ MULPS ] }
        { double-2-rep [ MULPD ] }
        { short-8-rep [ PMULLW ] }
        { ushort-8-rep [ PMULLW ] }
        { int-4-rep [ PMULLD ] }
        { uint-4-rep [ PMULLD ] }
    } case ;

M: x86 %mul-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep short-8-rep ushort-8-rep } }
        { sse4.1? { int-4-rep uint-4-rep } }
    } available-reps ;

M: x86 %saturated-mul-vector-reps
    ! No multiplication with saturation on x86
    { } ;

M: x86 %div-vector ( dst src1 src2 rep -- )
    [ two-operand ] keep
    {
        { float-4-rep [ DIVPS ] }
        { double-2-rep [ DIVPD ] }
    } case ;

M: x86 %div-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep } }
    } available-reps ;

M: x86 %min-vector ( dst src1 src2 rep -- )
    [ two-operand ] keep
    {
        { char-16-rep [ PMINSB ] }
        { uchar-16-rep [ PMINUB ] }
        { short-8-rep [ PMINSW ] }
        { ushort-8-rep [ PMINUW ] }
        { int-4-rep [ PMINSD ] }
        { uint-4-rep [ PMINUD ] }
        { float-4-rep [ MINPS ] }
        { double-2-rep [ MINPD ] }
    } case ;

M: x86 %min-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { uchar-16-rep short-8-rep double-2-rep short-8-rep uchar-16-rep } }
        { sse4.1? { char-16-rep ushort-8-rep int-4-rep uint-4-rep } }
    } available-reps ;

M: x86 %max-vector ( dst src1 src2 rep -- )
    [ two-operand ] keep
    {
        { char-16-rep [ PMAXSB ] }
        { uchar-16-rep [ PMAXUB ] }
        { short-8-rep [ PMAXSW ] }
        { ushort-8-rep [ PMAXUW ] }
        { int-4-rep [ PMAXSD ] }
        { uint-4-rep [ PMAXUD ] }
        { float-4-rep [ MAXPS ] }
        { double-2-rep [ MAXPD ] }
    } case ;

M: x86 %max-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { uchar-16-rep short-8-rep double-2-rep short-8-rep uchar-16-rep } }
        { sse4.1? { char-16-rep ushort-8-rep int-4-rep uint-4-rep } }
    } available-reps ;

M: x86 %dot-vector
    [ two-operand ] keep
    {
        { float-4-rep [
            sse4.1?
            [ HEX: ff DPPS ]
            [ [ MULPS ] [ drop dup float-4-rep %horizontal-add-vector ] 2bi ]
            if
        ] }
        { double-2-rep [
            sse4.1?
            [ HEX: ff DPPD ]
            [ [ MULPD ] [ drop dup double-2-rep %horizontal-add-vector ] 2bi ]
            if
        ] }
    } case ;

M: x86 %dot-vector-reps
    {
        { sse3? { float-4-rep double-2-rep } }
    } available-reps ;

M: x86 %horizontal-add-vector ( dst src rep -- )
    {
        { float-4-rep [ [ float-4-rep %copy ] [ HADDPS ] [ HADDPS ] 2tri ] }
        { double-2-rep [ [ double-2-rep %copy ] [ HADDPD ] 2bi ] }
    } case ;

M: x86 %horizontal-add-vector-reps
    {
        { sse3? { float-4-rep double-2-rep } }
    } available-reps ;

M: x86 %horizontal-shl-vector ( dst src1 src2 rep -- )
    two-operand PSLLDQ ;

M: x86 %horizontal-shl-vector-reps
    {
        { sse2? { char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M: x86 %horizontal-shr-vector ( dst src1 src2 rep -- )
    two-operand PSRLDQ ;

M: x86 %horizontal-shr-vector-reps
    {
        { sse2? { char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M: x86 %abs-vector ( dst src rep -- )
    {
        { char-16-rep [ PABSB ] }
        { short-8-rep [ PABSW ] }
        { int-4-rep [ PABSD ] }
    } case ;

M: x86 %abs-vector-reps
    {
        { ssse3? { char-16-rep short-8-rep int-4-rep } }
    } available-reps ;

M: x86 %sqrt-vector ( dst src rep -- )
    {
        { float-4-rep [ SQRTPS ] }
        { double-2-rep [ SQRTPD ] }
    } case ;

M: x86 %sqrt-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep } }
    } available-reps ;

M: x86 %and-vector ( dst src1 src2 rep -- )
    [ two-operand ] keep
    {
        { float-4-rep [ ANDPS ] }
        { double-2-rep [ ANDPD ] }
        [ drop PAND ]
    } case ;

M: x86 %and-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M: x86 %andn-vector ( dst src1 src2 rep -- )
    [ two-operand ] keep
    {
        { float-4-rep [ ANDNPS ] }
        { double-2-rep [ ANDNPD ] }
        [ drop PANDN ]
    } case ;

M: x86 %andn-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M: x86 %or-vector ( dst src1 src2 rep -- )
    [ two-operand ] keep
    {
        { float-4-rep [ ORPS ] }
        { double-2-rep [ ORPD ] }
        [ drop POR ]
    } case ;

M: x86 %or-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M: x86 %xor-vector ( dst src1 src2 rep -- )
    [ two-operand ] keep
    {
        { float-4-rep [ XORPS ] }
        { double-2-rep [ XORPD ] }
        [ drop PXOR ]
    } case ;

M: x86 %xor-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M:: x86 %not-vector ( dst src rep -- )
    dst rep %fill-vector
    dst dst src rep %xor-vector ;

M: x86 %not-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M: x86 %shl-vector ( dst src1 src2 rep -- )
    [ two-operand ] keep
    {
        { short-8-rep [ PSLLW ] }
        { ushort-8-rep [ PSLLW ] }
        { int-4-rep [ PSLLD ] }
        { uint-4-rep [ PSLLD ] }
        { longlong-2-rep [ PSLLQ ] }
        { ulonglong-2-rep [ PSLLQ ] }
    } case ;

M: x86 %shl-vector-reps
    {
        { sse2? { short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M: x86 %shr-vector ( dst src1 src2 rep -- )
    [ two-operand ] keep
    {
        { short-8-rep [ PSRAW ] }
        { ushort-8-rep [ PSRLW ] }
        { int-4-rep [ PSRAD ] }
        { uint-4-rep [ PSRLD ] }
        { ulonglong-2-rep [ PSRLQ ] }
    } case ;

M: x86 %shr-vector-reps
    {
        { sse2? { short-8-rep ushort-8-rep int-4-rep uint-4-rep ulonglong-2-rep } }
    } available-reps ;

: scalar-sized-reg ( reg rep -- reg' )
    rep-size 8 * n-bit-version-of ;

M: x86 %integer>scalar drop MOVD ;

M:: x86 %scalar>integer ( dst src rep -- )
    rep {
        { int-scalar-rep [
            dst 32-bit-version-of src MOVD
            dst dst 32-bit-version-of
            2dup eq? [ 2drop ] [ MOVSX ] if
        ] }
        { uint-scalar-rep [
            dst 32-bit-version-of src MOVD
        ] }
    } case ;

M: x86 %vector>scalar %copy ;
M: x86 %scalar>vector %copy ;

M:: x86 %spill ( src rep dst -- ) dst src rep %copy ;
M:: x86 %reload ( dst rep src -- ) dst src rep %copy ;

M: x86 %loop-entry 16 code-alignment [ NOP ] times ;

M:: x86 %save-context ( temp1 temp2 callback-allowed? -- )
    #! Save Factor stack pointers in case the C code calls a
    #! callback which does a GC, which must reliably trace
    #! all roots.
    temp1 0 MOV rc-absolute-cell rt-vm rel-fixup
    temp1 temp1 "stack_chain" vm-field-offset [+] MOV
    temp2 stack-reg cell neg [+] LEA
    temp1 [] temp2 MOV
    callback-allowed? [
        temp1 2 cells [+] ds-reg MOV
        temp1 3 cells [+] rs-reg MOV
    ] when ;

M: x86 value-struct? drop t ;

M: x86 small-enough? ( n -- ? )
    HEX: -80000000 HEX: 7fffffff between? ;

: next-stack@ ( n -- operand )
    #! nth parameter from the next stack frame. Used to box
    #! input values to callbacks; the callback has its own
    #! stack frame set up, and we want to read the frame
    #! set up by the caller.
    stack-frame get total-size>> + stack@ ;

enable-simd
enable-min/max
enable-fixnum-log2

:: install-sse2-check ( -- )
    [
        sse-version 20 < [
            "This image was built to use SSE2 but your CPU does not support it." print
            "You will need to bootstrap Factor again." print
            flush
            1 exit
        ] when
    ] "cpu.x86" add-init-hook ;

: enable-sse2 ( version -- )
    20 >= [
        enable-float-intrinsics
        enable-float-functions
        enable-float-min/max
        enable-fsqrt
        install-sse2-check
    ] when ;

: check-sse ( -- )
    [ { sse_version } compile ] with-optimizer
    "Checking for multimedia extensions: " write sse-version
    [ sse-string write " detected" print ] [ enable-sse2 ] bi ;
