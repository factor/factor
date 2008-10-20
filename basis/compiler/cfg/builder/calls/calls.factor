! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: qualified kernel words sequences layouts namespaces
accessors fry arrays byte-arrays locals math combinators alien
classes.algebra cpu.architecture compiler.tree.propagation.info
compiler.cfg.registers
compiler.cfg.instructions
compiler.cfg.builder.hats
compiler.cfg.builder.stacks ;
QUALIFIED: compiler.intrinsics
QUALIFIED: kernel.private
QUALIFIED: slots.private
QUALIFIED: math.private
QUALIFIED: alien.accessors
IN: compiler.cfg.builder.calls

{
    kernel.private:tag
    math.private:fixnum+fast
    math.private:fixnum-fast
    math.private:fixnum-bitand
    math.private:fixnum-bitor 
    math.private:fixnum-bitxor
    math.private:fixnum-shift-fast
    math.private:fixnum-bitnot
    math.private:fixnum*fast
    math.private:fixnum< 
    math.private:fixnum<=
    math.private:fixnum>=
    math.private:fixnum>
    math.private:bignum>fixnum
    math.private:fixnum>bignum
    eq?
    compiler.intrinsics:(slot)
    compiler.intrinsics:(set-slot)
    compiler.intrinsics:(tuple)
    compiler.intrinsics:(array)
    compiler.intrinsics:(byte-array)
    compiler.intrinsics:(complex)
    compiler.intrinsics:(ratio)
    compiler.intrinsics:(wrapper)
    compiler.intrinsics:(write-barrier)
    alien.accessors:alien-unsigned-1
    alien.accessors:set-alien-unsigned-1
    alien.accessors:alien-signed-1
    alien.accessors:set-alien-signed-1
    alien.accessors:alien-unsigned-2
    alien.accessors:set-alien-unsigned-2
    alien.accessors:alien-signed-2
    alien.accessors:set-alien-signed-2
    alien.accessors:alien-cell
    alien.accessors:set-alien-cell
} [ t "intrinsic" set-word-prop ] each

: enable-alien-4-intrinsics ( -- )
    {
        alien.accessors:alien-unsigned-4
        alien.accessors:set-alien-unsigned-4
        alien.accessors:alien-signed-4
        alien.accessors:set-alien-signed-4
    } [ t "intrinsic" set-word-prop ] each ;

: enable-float-intrinsics ( -- )
    {
        math.private:float+
        math.private:float-
        math.private:float*
        math.private:float/f
        math.private:fixnum>float
        math.private:float>fixnum
        alien.accessors:alien-float
        alien.accessors:set-alien-float
        alien.accessors:alien-double
        alien.accessors:set-alien-double
    } [ t "intrinsic" set-word-prop ] each ;

: ##tag-fixnum ( dst src -- ) tag-bits get ##shl-imm ;

: ^^tag-fixnum ( src -- dst ) ^^i1 ##tag-fixnum ;

: ##untag-fixnum ( dst src -- ) tag-bits get ##sar-imm ;

: ^^untag-fixnum ( src -- dst ) ^^i1 ##untag-fixnum ;

: emit-tag ( -- )
    phantom-pop tag-mask get ^^and-imm ^^tag-fixnum phantom-push ;

: ^^offset>slot ( vreg -- vreg' ) cell 4 = [ 1 ^^shr-imm ] when ;

: (emit-slot) ( infos -- dst )
    [ 2phantom-pop ] [ third literal>> ] bi*
    ^^slot ;

: (emit-slot-imm) ( infos -- dst )
    1 phantom-drop
    [ phantom-pop ^^offset>slot ]
    [ [ second literal>> ] [ third literal>> ] bi ] bi*
    ^^slot-imm ;

: value-info-small-tagged? ( value-info -- ? )
    dup literal?>> [ literal>> small-tagged? ] [ drop f ] if ;

: emit-slot ( node -- )
    node-input-infos
    dup second value-info-small-tagged?
    [ (emit-slot-imm) ] [ (emit-slot) ] if
    phantom-push ;

: (emit-set-slot) ( infos -- )
    [ 3phantom-pop ] [ fourth literal>> ] bi*
    ##set-slot ;

: (emit-set-slot-imm) ( infos -- )
    1 phantom-drop
    [ 2phantom-pop ^^offset>slot ]
    [ [ third literal>> ] [ fourth literal>> ] bi ] bi*
    ##set-slot-imm ;

: emit-set-slot ( node -- )
    1 phantom-drop
    node-input-infos
    dup third value-info-small-tagged?
    [ (emit-set-slot-imm) ] [ (emit-set-slot) ] if ;

: (emit-fixnum-imm-op) ( infos insn -- dst )
    1 phantom-drop
    [ phantom-pop ] [ second literal>> tag-fixnum ] [ ] tri*
    call ; inline

: (emit-fixnum-op) ( insn -- dst )
    [ 2phantom-pop ] dip call ; inline

:: emit-fixnum-op ( node insn imm-insn -- )
    [let | infos [ node node-input-infos ] |
        infos second value-info-small-tagged?
        [ infos imm-insn (emit-fixnum-imm-op) ]
        [ insn (emit-fixnum-op) ]
        if
    ] ; inline

: emit-primitive ( node -- )
    word>> ##simple-stack-frame ##call ;

: emit-fixnum-shift-fast ( node -- )
    dup node-input-infos dup second value-info-small-tagged? [
        nip
        [ 1 phantom-drop phantom-pop ] dip
        second literal>> dup sgn {
            { -1 [ neg tag-bits get + ^^sar-imm ^^tag-fixnum ] }
            {  0 [ drop ] }
            {  1 [ ^^shl-imm ] }
        } case
        phantom-push
    ] [ drop emit-primitive ] if ;

: emit-fixnum-bitnot ( -- )
    phantom-pop ^^not tag-mask get ^^xor-imm phantom-push ;

: (emit-fixnum*fast) ( -- dst )
    2phantom-pop ^^untag-fixnum ^^mul ;

: (emit-fixnum*fast-imm) ( infos -- dst )
    1 phantom-drop
    [ phantom-pop ] [ second literal>> ] bi* ^^mul-imm ;

: emit-fixnum*fast ( node -- )
    node-input-infos
    dup second value-info-small-tagged?
    [ (emit-fixnum*fast-imm) ] [ drop (emit-fixnum*fast) ] if
    phantom-push ;

: emit-fixnum-comparison ( node cc -- )
    [ '[ _ ##boolean ] ] [ '[ _ ##boolean-imm ] ] bi
    emit-fixnum-op ;

: emit-bignum>fixnum ( -- )
    phantom-pop ^^bignum>integer ^^tag-fixnum phantom-push ;

: emit-fixnum>bignum ( -- )
    phantom-pop ^^untag-fixnum ^^integer>bignum phantom-push ;

: emit-float-op ( insn -- )
    [ 2phantom-pop [ ^^unbox-float ] bi@ ] dip call ^^box-float ; inline

: emit-float-comparison ( cc -- )
    '[ _ ##boolean ] emit-float-op ;

: emit-float>fixnum ( -- )
    phantom-pop ^^unbox-float ^^float>integer ^^tag-fixnum phantom-push ;

: emit-fixnum>float ( -- )
    phantom-pop ^^untag-fixnum ^^integer>float ^^box-float phantom-push ;

: pop-literal ( node -- n )
    1 phantom-drop dup in-d>> first node-value-info literal>> ; 

: emit-allot ( size type tag -- )
    ^^allot [ fresh-object ] [ phantom-push ] bi ;

: emit-write-barrier ( -- )
    phantom-pop dup fresh-object? [ drop ] [ ^^write-barrier ] if ;

: (prepare-alien-accessor-imm) ( class offset -- offset-vreg )
    1 phantom-drop [ phantom-pop swap ^^unbox-c-ptr ] dip ^^add-imm ;

: (prepare-alien-accessor) ( class -- offset-vreg )
    [ 2phantom-pop ^^untag-fixnum swap ] dip ^^unbox-c-ptr ^^add ;

: prepare-alien-accessor ( infos -- offset-vreg )
    <reversed> [ second class>> ] [ first ] bi
    dup value-info-small-tagged? [
        1 phantom-drop
        literal>> (prepare-alien-accessor-imm)
    ] [ drop (prepare-alien-accessor) ] if ;

:: inline-alien ( node quot test -- )
    [let | infos [ node node-input-infos ] |
        infos test call
        [ infos prepare-alien-accessor quot call ]
        [ node emit-primitive ]
        if
    ] ; inline

: inline-alien-getter? ( infos -- ? )
    [ first class>> c-ptr class<= ]
    [ second class>> fixnum class<= ]
    bi and ;

: inline-alien-getter ( node quot -- )
    '[ @ phantom-push ]
    [ inline-alien-getter? ] inline-alien ; inline

: inline-alien-setter? ( infos class -- ? )
    '[ first class>> _ class<= ]
    [ second class>> c-ptr class<= ]
    [ third class>> fixnum class<= ]
    tri and and ;

: inline-alien-integer-setter ( node quot -- )
    '[ phantom-pop ^^untag-fixnum @ ]
    [ fixnum inline-alien-setter? ]
    inline-alien ; inline

: inline-alien-cell-setter ( node quot -- )
    [ dup node-input-infos first class>> ] dip
    '[ phantom-pop _ ^^unbox-c-ptr @ ]
    [ pinned-c-ptr inline-alien-setter? ]
    inline-alien ; inline

: inline-alien-float-setter ( node quot -- )
    '[ phantom-pop ^^unbox-float @ ]
    [ float inline-alien-setter? ]
    inline-alien ; inline

: emit-alien-unsigned-getter ( node n -- )
    '[
        _ {
            { 1 [ ^^alien-unsigned-1 ] }
            { 2 [ ^^alien-unsigned-2 ] }
            { 4 [ ^^alien-unsigned-4 ] }
        } case ^^tag-fixnum
    ] inline-alien-getter ;

: emit-alien-signed-getter ( node n -- )
    '[
        _ {
            { 1 [ ^^alien-signed-1 ] }
            { 2 [ ^^alien-signed-2 ] }
            { 4 [ ^^alien-signed-4 ] }
        } case ^^tag-fixnum
    ] inline-alien-getter ;

: emit-alien-integer-setter ( node n -- )
    '[
        _ {
            { 1 [ ##set-alien-integer-1 ] }
            { 2 [ ##set-alien-integer-2 ] }
            { 4 [ ##set-alien-integer-4 ] }
        } case
    ] inline-alien-integer-setter ;

: emit-alien-cell-getter ( node -- )
    [ ^^alien-cell ^^box-alien ] inline-alien-getter ;

: emit-alien-cell-setter ( node -- )
    [ ##set-alien-cell ] inline-alien-cell-setter ;

: emit-alien-float-getter ( node reg-class -- )
    '[
        _ {
            { single-float-regs [ ^^alien-float ] }
            { double-float-regs [ ^^alien-double ] }
        } case ^^box-float
    ] inline-alien-getter ;

: emit-alien-float-setter ( node reg-class -- )
    '[
        _ {
            { single-float-regs [ ##set-alien-float ] }
            { double-float-regs [ ##set-alien-double ] }
        } case
    ] inline-alien-float-setter ;

: emit-intrinsic ( node word -- )
    {
        { \ kernel.private:tag [ drop emit-tag ] }
        { \ math.private:fixnum+fast [ [ ^^add ] [ ^^add-imm ] emit-fixnum-op ] }
        { \ math.private:fixnum-fast [ [ ^^sub ] [ ^^sub-imm ] emit-fixnum-op ] }
        { \ math.private:fixnum-bitand [ [ ^^and ] [ ^^and-imm ] emit-fixnum-op ] }
        { \ math.private:fixnum-bitor [ [ ^^or ] [ ^^or-imm ] emit-fixnum-op ] }
        { \ math.private:fixnum-bitxor [ [ ^^xor ] [ ^^xor-imm ] emit-fixnum-op ] }
        { \ math.private:fixnum-shift-fast [ emit-fixnum-shift-fast ] }
        { \ math.private:fixnum-bitnot [ drop emit-fixnum-bitnot ] }
        { \ math.private:fixnum*fast [ emit-fixnum*fast ] }
        { \ math.private:fixnum< [ cc< emit-fixnum-comparison ] }
        { \ math.private:fixnum<= [ cc<= emit-fixnum-comparison ] }
        { \ math.private:fixnum>= [ cc>= emit-fixnum-comparison ] }
        { \ math.private:fixnum> [ cc> emit-fixnum-comparison ] }
        { \ eq? [ cc= emit-fixnum-comparison ] }
        { \ math.private:bignum>fixnum [ drop emit-bignum>fixnum ] }
        { \ math.private:fixnum>bignum [ drop emit-fixnum>bignum ] }
        { \ math.private:float+ [ drop [ ^^add-float ] emit-float-op ] }
        { \ math.private:float- [ drop [ ^^sub-float ] emit-float-op ] }
        { \ math.private:float* [ drop [ ^^mul-float ] emit-float-op ] }
        { \ math.private:float/f [ drop [ ^^div-float ] emit-float-op ] }
        { \ math.private:float< [ drop cc< emit-float-comparison ] }
        { \ math.private:float<= [ drop cc<= emit-float-comparison ] }
        { \ math.private:float>= [ drop cc>= emit-float-comparison ] }
        { \ math.private:float> [ drop cc> emit-float-comparison ] }
        { \ math.private:float= [ drop cc> emit-float-comparison ] }
        { \ math.private:float>fixnum [ drop emit-float>fixnum ] }
        { \ math.private:fixnum>float [ drop emit-fixnum>float ] }
        { \ compiler.intrinsics:(slot) [ emit-slot ] }
        { \ compiler.intrinsics:(set-slot) [ emit-set-slot ] }
        { \ compiler.intrinsics:(tuple) [ pop-literal 2 + cells tuple tuple emit-allot ] }
        { \ compiler.intrinsics:(array) [ pop-literal 2 + cells array object emit-allot ] }
        { \ compiler.intrinsics:(byte-array) [ pop-literal 2 cells + byte-array object emit-allot ] }
        { \ compiler.intrinsics:(complex) [ drop 3 cells complex complex emit-allot ] }
        { \ compiler.intrinsics:(ratio) [ drop 3 cells ratio ratio emit-allot ] }
        { \ compiler.intrinsics:(wrapper) [ drop 2 cells wrapper object emit-allot ] }
        { \ compiler.intrinsics:(write-barrier) [ drop emit-write-barrier ] }
        { \ alien.accessors:alien-unsigned-1 [ 1 emit-alien-unsigned-getter ] }
        { \ alien.accessors:set-alien-unsigned-1 [ 1 emit-alien-integer-setter ] }
        { \ alien.accessors:alien-signed-1 [ 1 emit-alien-signed-getter ] }
        { \ alien.accessors:set-alien-signed-1 [ 1 emit-alien-integer-setter ] }
        { \ alien.accessors:alien-unsigned-2 [ 2 emit-alien-unsigned-getter ] }
        { \ alien.accessors:set-alien-unsigned-2 [ 2 emit-alien-integer-setter ] }
        { \ alien.accessors:alien-signed-2 [ 2 emit-alien-signed-getter ] }
        { \ alien.accessors:set-alien-signed-2 [ 2 emit-alien-integer-setter ] }
        { \ alien.accessors:alien-unsigned-4 [ 4 emit-alien-unsigned-getter ] }
        { \ alien.accessors:set-alien-unsigned-4 [ 4 emit-alien-integer-setter ] }
        { \ alien.accessors:alien-signed-4 [ 4 emit-alien-signed-getter ] }
        { \ alien.accessors:set-alien-signed-4 [ 4 emit-alien-integer-setter ] }
        { \ alien.accessors:alien-cell [ emit-alien-cell-getter ] }
        { \ alien.accessors:set-alien-cell [ emit-alien-cell-setter ] }
        { \ alien.accessors:alien-float [ single-float-regs emit-alien-float-getter ] }
        { \ alien.accessors:set-alien-float [ single-float-regs emit-alien-float-setter ] }
        { \ alien.accessors:alien-double [ double-float-regs emit-alien-float-getter ] }
        { \ alien.accessors:set-alien-double [ double-float-regs emit-alien-float-setter ] }
    } case ;
