! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs compiler.cfg compiler.cfg.def-use
compiler.cfg.instructions compiler.cfg.linearization compiler.cfg.liveness compiler.cfg.predecessors
compiler.cfg.registers compiler.cfg.rpo compiler.cfg.utilities
cpu.architecture deques dlists kernel locals math namespaces sequences ;
IN: compiler.cfg.register-allocation.chordal.bases

! Ordinary liveness resolves bases after SSA destruction. SSA allocation
! instead needs companion tagged phis to select the base on the same edge
! as the derived pointer, including when the bases differ between edges.
GENERIC: derived-definition? ( derived insn -- ? )

M: insn derived-definition? 2drop f ;
M: ##tagged>integer derived-definition? 2drop t ;
M: ##unbox-any-c-ptr derived-definition? 2drop t ;
M: ##copy derived-definition? swap [ src>> ] dip at >boolean ;
M: ##add-imm derived-definition? swap [ src1>> ] dip at >boolean ;
M: ##sub-imm derived-definition? swap [ src1>> ] dip at >boolean ;
M: ##sub derived-definition? swap [ src1>> ] dip at >boolean ;
M: ##add derived-definition?
    swap [ [ src1>> ] [ src2>> ] bi ] dip '[ _ at >boolean ] bi@ xor ;
M: ##phi derived-definition?
    swap [ inputs>> values ] dip '[ _ at ] any? ;

ERROR: inconsistent-ssa-derived-pointers ;

:: derived-definitions ( cfg -- derived )
    cfg cfg>insns :> instructions
    H{ } clone :> previous!
    instructions length 1 + :> remaining!
    t :> changed!
    [ changed ] [
        remaining zero? [ inconsistent-ssa-derived-pointers ] when
        remaining 1 - remaining!
        H{ } clone :> current
        instructions [| insn |
            previous insn derived-definition? [
                insn defs-vregs [ t swap current set-at ] each
            ] when
        ] each
        current previous = not changed!
        current previous!
    ] while
    previous ;

SYMBOL: phi-bases

:: false-base ( predecessor -- vreg )
    tagged-rep next-vreg-rep :> vreg
    ##load-reference new vreg >>dst f >>obj :> insn
    predecessor [ dup length 1 - insn swap rot insert-nth ] change-instructions drop
    vreg ;

:: construct-phi-base ( phi bb -- )
    phi dst>> phi-bases get at :> base
    phi inputs>> [| predecessor source |
        predecessor source lookup-base-pointer [ predecessor false-base ] unless*
    ] assoc-map :> inputs
    ##phi new base >>dst inputs >>inputs :> base-phi
    bb [ base-phi prefix ] change-instructions drop ;

:: construct-ssa-bases ( cfg -- )
    cfg compute-insns
    cfg derived-definitions :> derived
    H{ } clone phi-bases set
    cfg cfg>insns [ ##phi? ] filter [| phi |
        phi dst>> derived at [
            tagged-rep next-vreg-rep phi dst>> phi-bases get set-at
        ] when
    ] each
    phi-bases get clone base-pointers set
    cfg [| bb |
        bb instructions>> [ ##phi? ] filter [| phi |
            phi dst>> phi-bases get key? [ phi bb construct-phi-base ] when
        ] each
    ] each-basic-block ;

: compute-ssa-live-sets ( cfg -- )
    init-liveness
    phi-bases get clone base-pointers set
    dup needs-predecessors dup compute-insns
    post-order <hashed-dlist> [ push-all-front ] keep
    [ liveness-step ] slurp/replenish-deque ;
