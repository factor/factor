! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs alien alien.c-types arrays
cpu.x86.assembler cpu.x86.assembler.private cpu.architecture
kernel kernel.private math memory namespaces make sequences
words system layouts combinators math.order fry locals
compiler.constants compiler.cfg.registers
compiler.cfg.instructions compiler.codegen
compiler.codegen.fixup ;
IN: cpu.x86.architecture

HOOK: temp-reg-1 cpu ( -- reg )
HOOK: temp-reg-2 cpu ( -- reg )

M: x86 %load-immediate MOV ;

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

: align-stack ( n -- n' )
    os macosx? cpu x86.64? or [ 16 align ] when ;

M: x86 stack-frame-size ( stack-frame -- i )
    [ spill-counts>> [ swap reg-size * ] { } assoc>map sum ]
    [ params>> ]
    [ return>> ]
    tri + +
    3 cells +
    align-stack ;

M: x86 %call ( label -- ) CALL ;
M: x86 %jump-label ( label -- ) JMP ;
M: x86 %return ( -- ) 0 RET ;

: code-alignment ( -- n )
    building get length dup cell align swap - ;

: align-code ( n -- )
    0 <repetition> % ;

M:: x86 %dispatch ( src temp -- )
    ! Load jump table base. We use a temporary register
    ! since on AMD64 we have to load a 64-bit immediate. On
    ! x86, this is redundant.
    ! Add jump table base
    temp HEX: ffffffff MOV rc-absolute-cell rel-here
    src temp ADD
    src HEX: 7f [+] JMP
    ! Fix up the displacement above
    code-alignment dup bootstrap-cell 8 = 15 9 ? +
    building get dup pop* push
    align-code ;

M: x86 %dispatch-label ( word -- )
    0 cell, rc-absolute-cell rel-word ;

:: (%slot) ( obj slot tag temp -- op )
    temp slot obj [+] LEA
    temp tag neg [+] ; inline

:: (%slot-imm) ( obj slot tag -- op )
    obj slot cells tag - [+] ; inline

M: x86 %slot ( dst obj slot tag temp -- ) (%slot) MOV ;
M: x86 %slot-imm ( dst obj slot tag -- ) (%slot-imm) MOV ;
M: x86 %set-slot ( src obj slot tag temp -- ) (%slot) swap MOV ;
M: x86 %set-slot-imm ( src obj slot tag -- ) (%slot-imm) swap MOV ;

: ?MOV ( dst src -- )
    2dup = [ 2drop ] [ MOV ] if ; inline

: 1operand ( dst src -- dst' )
    dupd ?MOV ; inline

: 2operand ( dst src1 src2 -- dst src )
    [ 1operand ] dip ; inline

M: x86 %add     [+] LEA ;
M: x86 %add-imm [+] LEA ;
M: x86 %sub     2operand SUB ;
M: x86 %sub-imm neg [+] LEA ;
M: x86 %mul     2operand IMUL2 ;
M: x86 %mul-imm 2operand IMUL2 ;
M: x86 %and     2operand AND ;
M: x86 %and-imm 2operand AND ;
M: x86 %or      2operand OR ;
M: x86 %or-imm  2operand OR ;
M: x86 %xor     2operand XOR ;
M: x86 %xor-imm 2operand XOR ;
M: x86 %shl-imm 2operand SHL ;
M: x86 %shr-imm 2operand SHR ;
M: x86 %sar-imm 2operand SAR ;
M: x86 %not     1operand NOT ;

: bignum@ ( reg n -- op )
    cells bignum tag-number - [+] ; inline

M:: x86 %integer>bignum ( dst src temp -- )
    #! on entry, inreg is a signed 32-bit quantity
    #! exits with tagged ptr to bignum in outreg
    #! 1 cell header, 1 cell length, 1 cell sign, + digits
    #! length is the # of digits + sign
    [
        { "end" "nonzero" "positive" } [ define-label ] each
        src 0 CMP ! is it zero?
        "nonzero" get JNE
        ! Use cached zero value
        dst 0 >bignum %load-indirect
        "end" get JMP
        "nonzero" resolve-label
        ! Allocate a bignum
        dst 4 cells bignum bignum temp %allot
        ! Write length
        dst 1 bignum@ 2 tag-fixnum MOV
        ! Test sign
        src 0 CMP
        "positive" get JGE
        dst 2 bignum@ 1 MOV ! negative sign
        src NEG
        dst 3 bignum@ src MOV
        src NEG ! we don't want to clobber src
        "end" get JMP
        "positive" resolve-label
        dst 2 bignum@ 0 MOV ! positive sign
        dst 3 bignum@ src MOV
        "end" resolve-label
    ] with-scope ;

M:: x86 %bignum>integer ( dst src -- )
    [
        "nonzero" define-label
        "positive" define-label
        "end" define-label
        dst src 1 bignum@ MOV
         ! if the length is 1, its just the sign and nothing else,
         ! so output 0
        dst 1 tag-fixnum CMP
        "nonzero" get JNE
        dst 0 MOV
        "end" get JMP
        "nonzero" resolve-label
        ! load the value
        dst src 3 bignum@ MOV
        ! is the sign negative?
        src 2 bignum@ 0 CMP
        "positive" get JE
        dst -1 IMUL2
        "positive" resolve-label
        dst 3 SHL
        "end" resolve-label
    ] with-scope ;

M: x86 %add-float 2operand ADDSD ;
M: x86 %sub-float 2operand SUBSD ;
M: x86 %mul-float 2operand MULSD ;
M: x86 %div-float 2operand DIVSD ;

M: x86 %integer>float CVTTSD2SI ;
M: x86 %float>integer CVTSI2SD ;

M: x86 %copy ( dst src -- ) MOV ;

M: x86 %copy-float MOVSD ;

M: x86 %unbox-float ( dst src -- )
    float-offset [+] MOVSD ;

M:: x86 %unbox-any-c-ptr ( dst src dst temp -- )
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
    dst 16 float float temp %allot
    dst 8 float tag-number - [+] src MOVSD ;

: alien@ ( reg n -- op ) cells object tag-number - [+] ;

M:: x86 %box-alien ( dst src temp -- )
    [
        { "end" "f" } [ define-label ] each
        src 0 CMP
        "f" get JE
        dst 4 cells alien object temp %allot
        dst 1 alien@ \ f tag-number MOV
        dst 2 alien@ \ f tag-number MOV
        ! Store src in alien-offset slot
        dst 3 alien@ src MOV
        "end" get JMP
        "f" resolve-label
        dst \ f tag-number MOV
        "end" resolve-label
    ] with-scope ;

: small-reg-4 ( reg -- reg' )
    H{
        { EAX EAX }
        { ECX ECX }
        { EDX EDX }
        { EBX EBX }
        { ESP ESP }
        { EBP EBP }
        { ESI ESP }
        { EDI EDI }

        { RAX EAX }
        { RCX ECX }
        { RDX EDX }
        { RBX EBX }
        { RSP ESP }
        { RBP EBP }
        { RSI ESP }
        { RDI EDI }
    } at ; inline

: small-reg-2 ( reg -- reg' )
    small-reg-4 H{
        { EAX AX }
        { ECX CX }
        { EDX DX }
        { EBX BX }
        { ESP SP }
        { EBP BP }
        { ESI SI }
        { EDI DI }
    } at ; inline

: small-reg-1 ( reg -- reg' )
    small-reg-4 {
        { EAX AL }
        { ECX CL }
        { EDX DL }
        { EBX BL }
    } at ; inline

: small-reg ( reg size -- reg' )
    {
        { 1 small-reg-1 }
        { 2 small-reg-2 }
        { 4 small-reg-4 }
    } case ;

: small-regs ( -- regs ) { EAX ECX EDX EBX } ; inline

: small-reg-that-isn't ( exclude -- reg' )
    small-reg-4 small-regs [ eq? not ] with find nip ;

: with-save/restore ( reg quot -- )
    [ drop PUSH ] [ call ] [ drop POP ] 2tri ; inline

:: with-small-register ( dst src quot: ( dst src -- ) -- )
    #! If the destination register overlaps a small register, we
    #! call the quot with that. Otherwise, we find a small
    #! register that is not equal to src, and call quot, saving
    #! and restoring the small register.
    dst small-regs memq? [ src quot call ] [
        src small-reg-that-isn't
        [ src quot call ]
        with-save/restore
    ] if ; inline

: %alien-integer-getter ( dst src size quot -- )
    '[ [ _ small-reg ] dip @ ] with-small-register ; inline

: %alien-unsigned-getter ( dst src size -- )
    [ MOVZX ] %alien-integer-getter ; inline

M: x86 %alien-unsigned-1 1 %alien-unsigned-getter ;
M: x86 %alien-unsigned-2 2 %alien-unsigned-getter ;
M: x86 %alien-unsigned-4 4 %alien-unsigned-getter ;

: %alien-signed-getter ( dst src size -- )
    [ MOVSX ] %alien-integer-getter ; inline

M: x86 %alien-signed-1 1 %alien-signed-getter ;
M: x86 %alien-signed-2 2 %alien-signed-getter ;
M: x86 %alien-signed-4 4 %alien-signed-getter ;

M: x86 %alien-cell [] MOV ;
M: x86 %alien-float dupd [] MOVSS dup CVTSS2SD ;
M: x86 %alien-double [] MOVSD ;

:: %alien-integer-setter ( ptr value size -- )
    value ptr [| new-value ptr |
        new-value value ?MOV
        ptr [] new-value size small-reg MOV
    ] with-small-register ; inline

M: x86 %set-alien-integer-1 1 %alien-integer-setter ;
M: x86 %set-alien-integer-2 2 %alien-integer-setter ;
M: x86 %set-alien-integer-4 4 %alien-integer-setter ;
M: x86 %set-alien-cell [ [] ] dip MOV ;
M: x86 %set-alien-float dup dup CVTSD2SS [ [] ] dip MOVSS ;
M: x86 %set-alien-double [ [] ] dip MOVSD ;

: load-zone-ptr ( reg -- )
    #! Load pointer to start of zone array
    0 MOV "nursery" f rc-absolute-cell rel-dlsym ;

: load-allot-ptr ( nursery-ptr allot-ptr -- )
    [ drop load-zone-ptr ] [ swap cell [+] MOV ] 2bi ;

: inc-allot-ptr ( nursery-ptr n -- )
    [ cell [+] ] dip 8 align ADD ;

: store-header ( temp type -- )
    [ [] ] [ type-number tag-fixnum ] bi* MOV ;

: store-tagged ( dst tag -- )
    tag-number OR ;

M:: x86 %allot ( dst size type tag nursery-ptr -- )
    nursery-ptr dst load-allot-ptr
    dst type store-header
    dst tag store-tagged
    nursery-ptr size inc-allot-ptr ;

HOOK: %alien-global cpu ( symbol dll register -- )

M:: x86 %write-barrier ( src card# table -- )
    #! Mark the card pointed to by vreg.
    ! Mark the card
    card# src MOV
    card# card-bits SHR
    "cards_offset" f table %alien-global
    table card# [+] card-mark <byte> MOV

    ! Mark the card deck
    card# deck-bits card-bits - SHR
    "decks_offset" f table %alien-global
    table card# [+] card-mark <byte> MOV ;

M: x86 %gc ( -- )
    "end" define-label
    temp-reg-1 load-zone-ptr
    temp-reg-2 temp-reg-1 cell [+] MOV
    temp-reg-2 1024 ADD
    temp-reg-1 temp-reg-1 3 cells [+] MOV
    temp-reg-2 temp-reg-1 CMP
    "end" get JLE
    %prepare-alien-invoke
    "minor_gc" f %alien-invoke
    "end" resolve-label ;

HOOK: stack-reg cpu ( -- reg )

: decr-stack-reg ( n -- )
    dup 0 = [ drop ] [ stack-reg swap SUB ] if ;

M: x86 %prologue ( n -- )
    temp-reg-1 0 MOV rc-absolute-cell rel-this
    dup PUSH
    temp-reg-1 PUSH
    stack-reg swap 3 cells - SUB ;

: incr-stack-reg ( n -- )
    dup 0 = [ drop ] [ stack-reg swap ADD ] if ;

M: x86 %epilogue ( n -- ) cell - incr-stack-reg ;

M: x86 %compare-branch ( label cc src1 src2 -- )
    CMP {
        { cc< [ JL ] }
        { cc<= [ JLE ] }
        { cc> [ JG ] }
        { cc>= [ JGE ] }
        { cc= [ JE ] }
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
    } case ;

: stack@ ( n -- op ) stack-reg swap [+] ;

: spill-integer-base ( stack-frame -- n )
    [ params>> ] [ return>> ] bi + ;

: spill-integer@ ( n -- op )
    cells
    stack-frame get spill-integer-base
    + stack@ ;

: spill-float-base ( stack-frame -- n )
    [ spill-counts>> int-regs swap at int-regs reg-size * ]
    [ params>> ]
    [ return>> ]
    tri + + ;

: spill-float@ ( n -- op )
    double-float-regs reg-size *
    stack-frame get spill-float-base
    + stack@ ;

M: x86 %spill-integer ( src n -- ) spill-integer@ swap MOV ;
M: x86 %reload-integer ( dst n -- ) spill-integer@ MOV ;

M: x86 %spill-float spill-float@ swap MOVSD ;
M: x86 %reload-float spill-float@ MOVSD ;

M: int-regs %save-param-reg drop >r stack@ r> MOV ;
M: int-regs %load-param-reg drop swap stack@ MOV ;

GENERIC: MOVSS/D ( dst src reg-class -- )

M: single-float-regs MOVSS/D drop MOVSS ;
M: double-float-regs MOVSS/D drop MOVSD ;

M: float-regs %save-param-reg >r >r stack@ r> r> MOVSS/D ;
M: float-regs %load-param-reg >r swap stack@ r> MOVSS/D ;

GENERIC: push-return-reg ( reg-class -- )
GENERIC: load-return-reg ( n reg-class -- )
GENERIC: store-return-reg ( n reg-class -- )

M: x86 %prepare-alien-invoke
    #! Save Factor stack pointers in case the C code calls a
    #! callback which does a GC, which must reliably trace
    #! all roots.
    "stack_chain" f temp-reg-1 %alien-global
    temp-reg-1 [] stack-reg MOV
    temp-reg-1 [] cell SUB
    temp-reg-1 2 cells [+] ds-reg MOV
    temp-reg-1 3 cells [+] rs-reg MOV ;

M: x86 fp-shadows-int? ( -- ? ) f ;

M: x86 value-structs? t ;

M: x86 small-enough? ( n -- ? )
    HEX: -80000000 HEX: 7fffffff between? ;

: next-stack@ ( n -- operand )
    #! nth parameter from the next stack frame. Used to box
    #! input values to callbacks; the callback has its own
    #! stack frame set up, and we want to read the frame
    #! set up by the caller.
    stack-frame get total-size>> + stack@ ;
