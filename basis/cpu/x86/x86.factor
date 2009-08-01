! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs alien alien.c-types arrays strings
cpu.x86.assembler cpu.x86.assembler.private cpu.x86.assembler.operands
cpu.architecture kernel kernel.private math memory namespaces make
sequences words system layouts combinators math.order fry locals
compiler.constants
compiler.cfg.registers
compiler.cfg.instructions
compiler.cfg.intrinsics
compiler.cfg.comparisons
compiler.cfg.stack-frame
compiler.codegen
compiler.codegen.fixup ;
IN: cpu.x86

<< enable-fixnum-log2 >>

! Add some methods to the assembler to be more useful to the backend
M: label JMP 0 JMP rc-relative label-fixup ;
M: label JUMPcc [ 0 ] dip JUMPcc rc-relative label-fixup ;

M: x86 two-operand? t ;

HOOK: stack-reg cpu ( -- reg )

HOOK: reserved-area-size cpu ( -- n )

: stack@ ( n -- op ) stack-reg swap [+] ;

: param@ ( n -- op ) reserved-area-size + stack@ ;

: spill-integer@ ( n -- op ) spill-integer-offset param@ ;

: spill-float@ ( n -- op ) spill-float-offset param@ ;

: gc-root@ ( n -- op ) gc-root-offset param@ ;

: decr-stack-reg ( n -- )
    dup 0 = [ drop ] [ stack-reg swap SUB ] if ;

: incr-stack-reg ( n -- )
    dup 0 = [ drop ] [ stack-reg swap ADD ] if ;

: align-stack ( n -- n' )
    os macosx? cpu x86.64? or [ 16 align ] when ;

M: x86 stack-frame-size ( stack-frame -- i )
    (stack-frame-size) 3 cells reserved-area-size + + align-stack ;

HOOK: temp-reg-1 cpu ( -- reg )
HOOK: temp-reg-2 cpu ( -- reg )

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
M: x86 %not     drop NOT ;
M: x86 %log2    BSR ;

: ?MOV ( dst src -- )
    2dup = [ 2drop ] [ MOV ] if ; inline

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
        temp cell-bits 1- SAR
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

M: x86 %integer>float CVTSI2SD ;
M: x86 %float>integer CVTTSD2SI ;

M: x86 %copy ( dst src -- ) ?MOV ;

M: x86 %copy-float ( dst src -- )
    2dup = [ 2drop ] [ MOVSD ] if ;

M: x86 %unbox-float ( dst src -- )
    float-offset [+] MOVSD ;

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

M:: x86 %box-float ( dst src temp -- )
    dst 16 float temp %allot
    dst float-offset [+] src MOVSD ;

: alien@ ( reg n -- op ) cells alien tag-number - [+] ;

M:: x86 %box-alien ( dst src temp -- )
    [
        "end" define-label
        dst \ f tag-number MOV
        src 0 CMP
        "end" get JE
        dst 4 cells alien temp %allot
        dst 1 alien@ \ f tag-number MOV
        dst 2 alien@ \ f tag-number MOV
        ! Store src in alien-offset slot
        dst 3 alien@ src MOV
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
M: x86 %alien-float dupd [] MOVSS dup CVTSS2SD ;
M: x86 %alien-double [] MOVSD ;

:: %alien-integer-setter ( ptr value size -- )
    value { ptr } size [| new-value |
        new-value value ?MOV
        ptr [] new-value size n-bit-version-of MOV
    ] with-small-register ; inline

M: x86 %set-alien-integer-1 8 %alien-integer-setter ;
M: x86 %set-alien-integer-2 16 %alien-integer-setter ;
M: x86 %set-alien-integer-4 32 %alien-integer-setter ;
M: x86 %set-alien-cell [ [] ] dip MOV ;
M: x86 %set-alien-float dup dup CVTSD2SS [ [] ] dip MOVSS ;
M: x86 %set-alien-double [ [] ] dip MOVSD ;

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

: load-zone-ptr ( reg -- )
    #! Load pointer to start of zone array
    0 MOV "nursery" f rc-absolute-cell rel-dlsym ;

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
    table "cards_offset" f %alien-global
    table table [] MOV
    table card# [+] card-mark <byte> MOV

    ! Mark the card deck
    card# deck-bits card-bits - SHR
    table "decks_offset" f %alien-global
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
    %prepare-alien-invoke
    "inline_gc" f %alien-invoke ;

M: x86 %alien-global
    [ 0 MOV ] 2dip rc-absolute-cell rel-dlsym ;

M: x86 %epilogue ( n -- ) cell - incr-stack-reg ;

:: %boolean ( dst temp word -- )
    dst \ f tag-number MOV
    temp 0 MOV \ t rc-absolute-cell rel-immediate
    dst temp word execute ; inline

M: x86 %compare ( dst temp cc src1 src2 -- )
    CMP {
        { cc< [ \ CMOVL %boolean ] }
        { cc<= [ \ CMOVLE %boolean ] }
        { cc> [ \ CMOVG %boolean ] }
        { cc>= [ \ CMOVGE %boolean ] }
        { cc= [ \ CMOVE %boolean ] }
        { cc/= [ \ CMOVNE %boolean ] }
    } case ;

M: x86 %compare-imm ( dst temp cc src1 src2 -- )
    %compare ;

M: x86 %compare-float ( dst temp cc src1 src2 -- )
    UCOMISD {
        { cc< [ \ CMOVB %boolean ] }
        { cc<= [ \ CMOVBE %boolean ] }
        { cc> [ \ CMOVA %boolean ] }
        { cc>= [ \ CMOVAE %boolean ] }
        { cc= [ \ CMOVE %boolean ] }
        { cc/= [ \ CMOVNE %boolean ] }
    } case ;

M: x86 %compare-branch ( label cc src1 src2 -- )
    CMP {
        { cc< [ JL ] }
        { cc<= [ JLE ] }
        { cc> [ JG ] }
        { cc>= [ JGE ] }
        { cc= [ JE ] }
        { cc/= [ JNE ] }
    } case ;

M: x86 %compare-imm-branch ( label src1 src2 cc -- )
    %compare-branch ;

M: x86 %compare-float-branch ( label cc src1 src2 -- )
    UCOMISD {
        { cc< [ JB ] }
        { cc<= [ JBE ] }
        { cc> [ JA ] }
        { cc>= [ JAE ] }
        { cc= [ JE ] }
        { cc/= [ JNE ] }
    } case ;

M: x86 %spill-integer ( src n -- ) spill-integer@ swap MOV ;
M: x86 %reload-integer ( dst n -- ) spill-integer@ MOV ;

M: x86 %spill-float ( src n -- ) spill-float@ swap MOVSD ;
M: x86 %reload-float ( dst n -- ) spill-float@ MOVSD ;

M: x86 %loop-entry 16 code-alignment [ NOP ] times ;

M: int-regs %save-param-reg drop [ param@ ] dip MOV ;
M: int-regs %load-param-reg drop swap param@ MOV ;

GENERIC: MOVSS/D ( dst src reg-class -- )

M: single-float-regs MOVSS/D drop MOVSS ;
M: double-float-regs MOVSS/D drop MOVSD ;

M: float-regs %save-param-reg [ param@ ] 2dip MOVSS/D ;
M: float-regs %load-param-reg [ swap param@ ] dip MOVSS/D ;

GENERIC: push-return-reg ( reg-class -- )
GENERIC: load-return-reg ( n reg-class -- )
GENERIC: store-return-reg ( n reg-class -- )

M: x86 %prepare-alien-invoke
    #! Save Factor stack pointers in case the C code calls a
    #! callback which does a GC, which must reliably trace
    #! all roots.
    temp-reg-1 "stack_chain" f %alien-global
    temp-reg-1 temp-reg-1 [] MOV
    temp-reg-1 [] stack-reg MOV
    temp-reg-1 [] cell SUB
    temp-reg-1 2 cells [+] ds-reg MOV
    temp-reg-1 3 cells [+] rs-reg MOV ;

M: x86 value-struct? drop t ;

M: x86 small-enough? ( n -- ? )
    HEX: -80000000 HEX: 7fffffff between? ;

: next-stack@ ( n -- operand )
    #! nth parameter from the next stack frame. Used to box
    #! input values to callbacks; the callback has its own
    #! stack frame set up, and we want to read the frame
    #! set up by the caller.
    stack-frame get total-size>> + stack@ ;
