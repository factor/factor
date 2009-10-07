! Copyright (C) 2009 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: kernel fry accessors sequences assocs sets namespaces
arrays combinators combinators.short-circuit math make locals
deques dlists layouts byte-arrays cpu.architecture
compiler.utilities
compiler.constants
compiler.cfg
compiler.cfg.rpo
compiler.cfg.hats
compiler.cfg.registers
compiler.cfg.instructions
compiler.cfg.def-use
compiler.cfg.utilities
compiler.cfg.loop-detection
compiler.cfg.renaming.functor
compiler.cfg.representations.preferred ;
IN: compiler.cfg.representations

! Virtual register representation selection.

ERROR: bad-conversion dst src dst-rep src-rep ;

GENERIC: emit-box ( dst src rep -- )
GENERIC: emit-unbox ( dst src rep -- )

M:: float-rep emit-box ( dst src rep -- )
    double-rep next-vreg-rep :> temp
    temp src ##single>double-float
    dst temp double-rep emit-box ;

M:: float-rep emit-unbox ( dst src rep -- )
    double-rep next-vreg-rep :> temp
    temp src double-rep emit-unbox
    dst temp ##double>single-float ;

M: double-rep emit-box
    drop
    [ drop 16 float int-rep next-vreg-rep ##allot ]
    [ float-offset swap ##set-alien-double ]
    2bi ;

M: double-rep emit-unbox
    drop float-offset ##alien-double ;

M:: vector-rep emit-box ( dst src rep -- )
    int-rep next-vreg-rep :> temp
    dst 16 2 cells + byte-array int-rep next-vreg-rep ##allot
    temp 16 tag-fixnum ##load-immediate
    temp dst 1 byte-array tag-number ##set-slot-imm
    dst byte-array-offset src rep ##set-alien-vector ;

M: vector-rep emit-unbox
    [ byte-array-offset ] dip ##alien-vector ;

M:: scalar-rep emit-box ( dst src rep -- )
    int-rep next-vreg-rep :> temp
    temp src rep ##scalar>integer
    dst temp tag-bits get ##shl-imm ;

M:: scalar-rep emit-unbox ( dst src rep -- )
    int-rep next-vreg-rep :> temp
    temp src tag-bits get ##sar-imm
    dst temp rep ##integer>scalar ;

: emit-conversion ( dst src dst-rep src-rep -- )
    {
        { [ 2dup eq? ] [ drop ##copy ] }
        { [ dup int-rep eq? ] [ drop emit-unbox ] }
        { [ over int-rep eq? ] [ nip emit-box ] }
        [
            2dup 2array {
                { { double-rep float-rep } [ 2drop ##single>double-float ] }
                { { float-rep double-rep } [ 2drop ##double>single-float ] }
                ! Punning SIMD vector types? Naughty naughty! But
                ! it is allowed... otherwise bail out.
                [
                    drop 2dup [ reg-class-of ] bi@ eq?
                    [ drop ##copy ] [ bad-conversion ] if
                ]
            } case
        ]
    } cond ;

<PRIVATE

! For every vreg, compute possible representations.
SYMBOL: possibilities

: possible ( vreg -- reps ) possibilities get at ;

: compute-possibilities ( cfg -- )
    H{ } clone [ '[ swap _ conjoin-at ] with-vreg-reps ] keep
    [ keys ] assoc-map possibilities set ;

! Compute vregs which must remain tagged for their lifetime.
SYMBOL: always-boxed

:: (compute-always-boxed) ( vreg rep assoc -- )
    rep int-rep eq? [
        int-rep vreg assoc set-at
    ] when ;

: compute-always-boxed ( cfg -- assoc )
    H{ } clone [
        '[
            [
                dup [ ##load-reference? ] [ ##load-constant? ] bi or
                [ drop ] [ [ _ (compute-always-boxed) ] each-def-rep ] if
            ] each-non-phi
        ] each-basic-block
    ] keep ;

! For every vreg, compute the cost of keeping it in every possible
! representation.

! Cost map maps vreg to representation to cost.
SYMBOL: costs

: init-costs ( -- )
    possibilities get [ [ 0 ] H{ } map>assoc ] assoc-map costs set ;

: increase-cost ( rep vreg -- )
    ! Increase cost of keeping vreg in rep, making a choice of rep less
    ! likely.
    [ basic-block get loop-nesting-at ] 2dip costs get at at+ ;

: maybe-increase-cost ( possible vreg preferred -- )
    pick eq? [ 2drop ] [ increase-cost ] if ;

: representation-cost ( vreg preferred -- )
    ! 'preferred' is a representation that the instruction can accept with no cost.
    ! So, for each representation that's not preferred, increase the cost of keeping
    ! the vreg in that representation.
    [ drop possible ]
    [ '[ _ _ maybe-increase-cost ] ]
    2bi each ;

: compute-costs ( cfg -- costs )
    init-costs [ representation-cost ] with-vreg-reps costs get ;

! For every vreg, compute preferred representation, that minimizes costs.
: minimize-costs ( costs -- representations )
    [ >alist alist-min first ] assoc-map ;

: compute-representations ( cfg -- )
    [ compute-costs minimize-costs ]
    [ compute-always-boxed ]
    bi assoc-union
    representations set ;

! Insert conversions. This introduces new temporaries, so we need
! to rename opearands too.

! Mapping from vreg,rep pairs to vregs
SYMBOL: alternatives

:: emit-def-conversion ( dst preferred required -- new-dst' )
    ! If an instruction defines a register with representation 'required',
    ! but the register has preferred representation 'preferred', then
    ! we rename the instruction's definition to a new register, which
    ! becomes the input of a conversion instruction.
    dst required next-vreg-rep [ preferred required emit-conversion ] keep ;

:: emit-use-conversion ( src preferred required -- new-src' )
    ! If an instruction uses a register with representation 'required',
    ! but the register has preferred representation 'preferred', then
    ! we rename the instruction's input to a new register, which
    ! becomes the output of a conversion instruction.
    preferred required eq? [ src ] [
        src required alternatives get [
            required next-vreg-rep :> new-src
            [ new-src ] 2dip preferred emit-conversion
            new-src
        ] 2cache
    ] if ;

SYMBOLS: renaming-set needs-renaming? ;

: init-renaming-set ( -- )
    needs-renaming? off
    V{ } clone renaming-set set ;

: no-renaming ( vreg -- )
    dup 2array renaming-set get push ;

: record-renaming ( from to -- )
    2array renaming-set get push needs-renaming? on ;

:: (compute-renaming-set) ( vreg required quot: ( vreg preferred required -- ) -- )
    vreg rep-of :> preferred
    preferred required eq?
    [ vreg no-renaming ]
    [ vreg vreg preferred required quot call record-renaming ] if ; inline

: compute-renaming-set ( insn -- )
    ! temp vregs don't need conversions since they're always in their
    ! preferred representation
    init-renaming-set
    [ [ [ emit-use-conversion ] (compute-renaming-set) ] each-use-rep ]
    [ , ]
    [ [ [ emit-def-conversion ] (compute-renaming-set) ] each-def-rep ]
    tri ;

: converted-value ( vreg -- vreg' )
    renaming-set get pop first2 [ assert= ] dip ;

RENAMING: convert [ converted-value ] [ converted-value ] [ ]

: perform-renaming ( insn -- )
    needs-renaming? get [
        renaming-set get reverse-here
        [ convert-insn-uses ] [ convert-insn-defs ] bi
        renaming-set get length 0 assert=
    ] [ drop ] if ;

GENERIC: conversions-for-insn ( insn -- )

SYMBOL: phi-mappings

! compiler.cfg.cssa inserts conversions which convert phi inputs into
!  the representation of the output. However, we still have to do some
!  processing here, because if the only node that uses the output of
!  the phi instruction is another phi instruction then this phi node's
! output won't have a representation assigned.
M: ##phi conversions-for-insn
    [ , ] [ [ inputs>> values ] [ dst>> ] bi phi-mappings get set-at ] bi ;

! When a literal zeroes/ones vector is unboxed, we replace the ##load-reference
! with a ##zero-vector or ##fill-vector instruction since this is more efficient.
: convert-to-zero-vector? ( insn -- ? )
    {
        [ dst>> rep-of vector-rep? ]
        [ obj>> B{ 0 0 0 0  0 0 0 0  0 0 0 0  0 0 0 0 } = ]
    } 1&& ;
: convert-to-fill-vector? ( insn -- ? )
    {
        [ dst>> rep-of vector-rep? ]
        [ obj>> B{ 255 255 255 255  255 255 255 255  255 255 255 255  255 255 255 } = ]
    } 1&& ;

: (convert-to-zero/fill-vector) ( insn -- dst rep )
    dst>> dup rep-of ; inline

: conversions-for-load-insn ( insn -- ?insn )
    {
        {
            [ dup convert-to-zero-vector? ]
            [ (convert-to-zero/fill-vector) ##zero-vector f ]
        }
        {
            [ dup convert-to-fill-vector? ]
            [ (convert-to-zero/fill-vector) ##fill-vector f ]
        }
        [ ]
    } cond ;

M: ##load-reference conversions-for-insn
    conversions-for-load-insn [ call-next-method ] when* ;

M: ##load-constant conversions-for-insn
    conversions-for-load-insn [ call-next-method ] when* ;

M: vreg-insn conversions-for-insn
    [ compute-renaming-set ] [ perform-renaming ] bi ;

M: insn conversions-for-insn , ;

: conversions-for-block ( bb -- )
    dup kill-block? [ drop ] [
        [
            [
                H{ } clone alternatives set
                [ conversions-for-insn ] each
            ] V{ } make
        ] change-instructions drop
    ] if ;

! If the output of a phi instruction is only used as the input to another
! phi instruction, then we want to use the same representation for both
! if possible.
SYMBOL: work-list

: add-to-work-list ( vregs -- )
    work-list get push-all-front ;

: rep-assigned ( vregs -- vregs' )
    representations get '[ _ key? ] filter ;

: rep-not-assigned ( vregs -- vregs' )
    representations get '[ _ key? not ] filter ;

: add-ready-phis ( -- )
    phi-mappings get keys rep-assigned add-to-work-list ;

: process-phi-mapping ( dst -- )
    ! If dst = phi(src1,src2,...) and dst's representation has been
    ! determined, assign that representation to each one of src1,...
    ! that does not have a representation yet, and process those, too.
    dup phi-mappings get at* [
        [ rep-of ] [ rep-not-assigned ] bi*
        [ [ set-rep-of ] with each ] [ add-to-work-list ] bi
    ] [ 2drop ] if ;

: remaining-phi-mappings ( -- )
    phi-mappings get keys rep-not-assigned
    [ [ int-rep ] dip set-rep-of ] each ;

: process-phi-mappings ( -- )
    <hashed-dlist> work-list set
    add-ready-phis
    work-list get [ process-phi-mapping ] slurp-deque
    remaining-phi-mappings ;

: insert-conversions ( cfg -- )
    H{ } clone phi-mappings set
    [ conversions-for-block ] each-basic-block
    process-phi-mappings ;

PRIVATE>

: select-representations ( cfg -- cfg' )
    needs-loops

    {
        [ compute-possibilities ]
        [ compute-representations ]
        [ insert-conversions ]
        [ ]
    } cleave
    representations get cfg get (>>reps) ;
