! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs alien alien.c-types arrays strings
cpu.x86.assembler cpu.x86.assembler.private cpu.x86.assembler.operands
cpu.architecture kernel kernel.private math memory namespaces make
sequences words system layouts combinators math.order fry locals
compiler.constants vm byte-arrays
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

M: x86 two-operand? t ;

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

! Fastcall calling convention
HOOK: param-reg-1 cpu ( -- reg )
HOOK: param-reg-2 cpu ( -- reg )

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

:: (%slot) ( obj slot tag temp -- op )
    temp slot obj [+] LEA
    temp tag neg [+] ; inline

:: (%slot-imm) ( obj slot tag -- op )
    obj slot cells tag - [+] ; inline

M: x86 %slot ( dst obj slot tag temp -- ) (%slot) MOV ;
M: x86 %slot-imm ( dst obj slot tag -- ) (%slot-imm) MOV ;
M: x86 %set-slot ( src obj slot tag temp -- ) (%slot) swap MOV ;
M: x86 %set-slot-imm ( src obj slot tag -- ) (%slot-imm) swap MOV ;

M: x86 %add     2over eq? [ nip ADD ] [ [+] LEA ] if ;
M: x86 %add-imm 2over eq? [ nip ADD ] [ [+] LEA ] if ;
M: x86 %sub     nip SUB ;
M: x86 %sub-imm 2over eq? [ nip SUB ] [ neg [+] LEA ] if ;
M: x86 %mul     nip swap IMUL2 ;
M: x86 %mul-imm IMUL3 ;
M: x86 %and     nip AND ;
M: x86 %and-imm nip AND ;
M: x86 %or      nip OR ;
M: x86 %or-imm  nip OR ;
M: x86 %xor     nip XOR ;
M: x86 %xor-imm nip XOR ;
M: x86 %shl-imm nip SHL ;
M: x86 %shr-imm nip SHR ;
M: x86 %sar-imm nip SAR ;

M: x86 %min     nip [ CMP ] [ CMOVG ] 2bi ;
M: x86 %max     nip [ CMP ] [ CMOVL ] 2bi ;

M: x86 %not     drop NOT ;
M: x86 %log2    BSR ;

GENERIC: copy-register* ( dst src rep -- )

M: int-rep copy-register* drop MOV ;
M: tagged-rep copy-register* drop MOV ;
M: float-rep copy-register* drop MOVSS ;
M: double-rep copy-register* drop MOVSD ;
M: float-4-rep copy-register* drop MOVUPS ;
M: double-2-rep copy-register* drop MOVUPD ;
M: vector-rep copy-register* drop MOVDQU ;

: copy-register ( dst src rep -- )
    2over eq? [ 3drop ] [ copy-register* ] if ;

M: x86 %copy ( dst src rep -- ) copy-register ;

:: overflow-template ( label dst src1 src2 insn -- )
    src1 src2 insn call
    label JO ; inline

M: x86 %fixnum-add ( label dst src1 src2 -- )
    [ ADD ] overflow-template ;

M: x86 %fixnum-sub ( label dst src1 src2 -- )
    [ SUB ] overflow-template ;

M: x86 %fixnum-mul ( label dst src1 src2 -- )
    [ swap IMUL2 ] overflow-template ;

: bignum@ ( reg n -- op )
    cells bignum tag-number - [+] ; inline

M:: x86 %integer>bignum ( dst src temp -- )
    #! on entry, inreg is a signed 32-bit quantity
    #! exits with tagged ptr to bignum in outreg
    #! 1 cell header, 1 cell length, 1 cell sign, + digits
    #! length is the # of digits + sign
    [
        "end" define-label
        ! Load cached zero value
        dst 0 >bignum %load-reference
        src 0 CMP
        ! Is it zero? Then just go to the end and return this zero
        "end" get JE
        ! Allocate a bignum
        dst 4 cells bignum temp %allot
        ! Write length
        dst 1 bignum@ 2 tag-fixnum MOV
        ! Store value
        dst 3 bignum@ src MOV
        ! Compute sign
        temp src MOV
        temp cell-bits 1 - SAR
        temp 1 AND
        ! Store sign
        dst 2 bignum@ temp MOV
        ! Make negative value positive
        temp temp ADD
        temp NEG
        temp 1 ADD
        src temp IMUL2
        ! Store the bignum
        dst 3 bignum@ temp MOV
        "end" resolve-label
    ] with-scope ;

M:: x86 %bignum>integer ( dst src temp -- )
    [
        "end" define-label
        ! load length
        temp src 1 bignum@ MOV
        ! if the length is 1, its just the sign and nothing else,
        ! so output 0
        dst 0 MOV
        temp 1 tag-fixnum CMP
        "end" get JE
        ! load the value
        dst src 3 bignum@ MOV
        ! load the sign
        temp src 2 bignum@ MOV
        ! convert it into -1 or 1
        temp temp ADD
        temp NEG
        temp 1 ADD
        ! make dst signed
        temp dst IMUL2
        "end" resolve-label
    ] with-scope ;

M: x86 %add-float nip ADDSD ;
M: x86 %sub-float nip SUBSD ;
M: x86 %mul-float nip MULSD ;
M: x86 %div-float nip DIVSD ;
M: x86 %min-float nip MINSD ;
M: x86 %max-float nip MAXSD ;
M: x86 %sqrt SQRTSD ;

M: x86 %single>double-float CVTSS2SD ;
M: x86 %double>single-float CVTSD2SS ;

M: x86 %integer>float CVTSI2SD ;
M: x86 %float>integer CVTTSD2SI ;

M: x86 %unbox-float ( dst src -- )
    float-offset [+] MOVSD ;

M:: x86 %box-float ( dst src temp -- )
    dst 16 float temp %allot
    dst float-offset [+] src MOVSD ;

M:: x86 %box-vector ( dst src rep temp -- )
    dst rep rep-size 2 cells + byte-array temp %allot
    16 tag-fixnum dst 1 byte-array tag-number %set-slot-imm
    dst byte-array-offset [+]
    src rep copy-register ;

M:: x86 %unbox-vector ( dst src rep -- )
    dst src byte-array-offset [+]
    rep copy-register ;

M: x86 %broadcast-vector ( dst src rep -- )
    {
        { float-4-rep [ [ MOVSS ] [ drop dup 0 SHUFPS ] 2bi ] }
        { double-2-rep [ [ MOVSD ] [ drop dup UNPCKLPD ] 2bi ] }
    } case ;

M:: x86 %gather-vector-4 ( dst src1 src2 src3 src4 rep -- )
    rep {
        {
            float-4-rep
            [
                dst src1 MOVSS
                dst src2 UNPCKLPS
                src3 src4 UNPCKLPS
                dst src3 MOVLHPS
            ]
        }
    } case ;

M:: x86 %gather-vector-2 ( dst src1 src2 rep -- )
    rep {
        {
            double-2-rep
            [
                dst src1 MOVSD
                dst src2 UNPCKLPD
            ]
        }
    } case ;

M: x86 %add-vector ( dst src1 src2 rep -- )
    {
        { float-4-rep [ ADDPS ] }
        { double-2-rep [ ADDPD ] }
        { char-16-rep [ PADDB ] }
        { uchar-16-rep [ PADDB ] }
        { short-8-rep [ PADDW ] }
        { ushort-8-rep [ PADDW ] }
        { int-4-rep [ PADDD ] }
        { uint-4-rep [ PADDD ] }
    } case drop ;

M: x86 %sub-vector ( dst src1 src2 rep -- )
    {
        { float-4-rep [ SUBPS ] }
        { double-2-rep [ SUBPD ] }
        { char-16-rep [ PSUBB ] }
        { uchar-16-rep [ PSUBB ] }
        { short-8-rep [ PSUBW ] }
        { ushort-8-rep [ PSUBW ] }
        { int-4-rep [ PSUBD ] }
        { uint-4-rep [ PSUBD ] }
    } case drop ;

M: x86 %mul-vector ( dst src1 src2 rep -- )
    {
        { float-4-rep [ MULPS ] }
        { double-2-rep [ MULPD ] }
        { int-4-rep [ PMULLW ] }
    } case drop ;

M: x86 %div-vector ( dst src1 src2 rep -- )
    {
        { float-4-rep [ DIVPS ] }
        { double-2-rep [ DIVPD ] }
    } case drop ;

M: x86 %min-vector ( dst src1 src2 rep -- )
    {
        { float-4-rep [ MINPS ] }
        { double-2-rep [ MINPD ] }
    } case drop ;

M: x86 %max-vector ( dst src1 src2 rep -- )
    {
        { float-4-rep [ MAXPS ] }
        { double-2-rep [ MAXPD ] }
    } case drop ;

M: x86 %sqrt-vector ( dst src rep -- )
    {
        { float-4-rep [ SQRTPS ] }
        { double-2-rep [ SQRTPD ] }
    } case ;

M: x86 %horizontal-add-vector ( dst src rep -- )
    {
        { float-4-rep [ [ MOVAPS ] [ HADDPS ] [ HADDPS ] 2tri ] }
        { double-2-rep [ [ MOVAPD ] [ HADDPD ] 2bi ] }
    } case ;

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

: ?MOV ( dst src -- )
    2dup = [ 2drop ] [ MOV ] if ; inline

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
        dst new-dst ?MOV
    ] with-small-register ;

M:: x86 %set-string-nth-fast ( ch str index temp -- )
    ch { index str temp } 8 [| new-ch |
        new-ch ch ?MOV
        temp str index [+] LEA
        temp string-offset [+] new-ch 8-bit-version-of MOV
    ] with-small-register ;

:: %alien-integer-getter ( dst src size quot -- )
    dst { src } size [| new-dst |
        new-dst dup size n-bit-version-of dup src [] MOV
        quot call
        dst new-dst ?MOV
    ] with-small-register ; inline

: %alien-unsigned-getter ( dst src size -- )
    [ MOVZX ] %alien-integer-getter ; inline

M: x86 %alien-unsigned-1 8 %alien-unsigned-getter ;
M: x86 %alien-unsigned-2 16 %alien-unsigned-getter ;
M: x86 %alien-unsigned-4 32 [ 2drop ] %alien-integer-getter ;

: %alien-signed-getter ( dst src size -- )
    [ MOVSX ] %alien-integer-getter ; inline

M: x86 %alien-signed-1 8 %alien-signed-getter ;
M: x86 %alien-signed-2 16 %alien-signed-getter ;
M: x86 %alien-signed-4 32 %alien-signed-getter ;

M: x86 %alien-cell [] MOV ;
M: x86 %alien-float [] MOVSS ;
M: x86 %alien-double [] MOVSD ;
M: x86 %alien-vector [ [] ] dip copy-register ;

:: %alien-integer-setter ( ptr value size -- )
    value { ptr } size [| new-value |
        new-value value ?MOV
        ptr [] new-value size n-bit-version-of MOV
    ] with-small-register ; inline

M: x86 %set-alien-integer-1 8 %alien-integer-setter ;
M: x86 %set-alien-integer-2 16 %alien-integer-setter ;
M: x86 %set-alien-integer-4 32 %alien-integer-setter ;
M: x86 %set-alien-cell [ [] ] dip MOV ;
M: x86 %set-alien-float [ [] ] dip MOVSS ;
M: x86 %set-alien-double [ [] ] dip MOVSD ;
M: x86 %set-alien-vector [ [] ] 2dip copy-register ;

: shift-count? ( reg -- ? ) { ECX RCX } memq? ;

:: emit-shift ( dst src1 src2 quot -- )
    src2 shift-count? [
        dst CL quot call
    ] [
        dst shift-count? [
            dst src2 XCHG
            src2 CL quot call
            dst src2 XCHG
        ] [
            ECX native-version-of [
                CL src2 MOV
                drop dst CL quot call
            ] with-save/restore
        ] if
    ] if ; inline

M: x86 %shl [ SHL ] emit-shift ;
M: x86 %shr [ SHR ] emit-shift ;
M: x86 %sar [ SAR ] emit-shift ;

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

M:: x86 %call-gc ( gc-root-count -- )
    ! Pass pointer to start of GC roots as first parameter
    param-reg-1 gc-root-base param@ LEA
    ! Pass number of roots as second parameter
    param-reg-2 gc-root-count MOV
    ! Call GC
    "inline_gc" %vm-invoke-3rd-arg ; 

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

M:: x86 %spill ( src rep n -- )
    n spill@ src rep copy-register ;

M:: x86 %reload ( dst rep n -- )
    dst n spill@ rep copy-register ;

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

: enable-sse2 ( -- )
    enable-float-intrinsics
    enable-fsqrt
    enable-float-min/max
    enable-sse2-simd ;

: enable-sse3 ( -- )
    enable-sse2
    enable-sse3-simd ;

enable-min/max
enable-fixnum-log2