USING: accessors arrays assocs compiler.cfg.def-use
compiler.cfg.instructions compiler.cfg.linearization
compiler.cfg.registers compiler.cfg.ssa.destruction.leaders
compiler.cfg.ssa.interference cpu.architecture fry kernel make
namespaces sequences sets sorting ;
FROM: namespaces => set ;
IN: compiler.cfg.ssa.destruction.coalescing

: zip-scalar ( scalar seq -- pairs )
    [ 2array ] with map ;

SYMBOL: class-element-map

: value-of ( vreg -- value )
    dup insn-of dup ##tagged>integer? [ nip src>> ] [ drop ] if ;

: coalesce-elements ( merged follower leader -- )
    class-element-map get [ delete-at ] [ set-at ] bi-curry bi* ;

: coalesce-vregs ( merged follower leader -- )
    2dup swap leader-map get set-at coalesce-elements ;

: vregs-interfere? ( vreg1 vreg2 -- merged/f ? )
    class-element-map get '[ _ at ] bi@ sets-interfere? ;

ERROR: vregs-shouldn't-interfere vreg1 vreg2 ;

: try-eliminate-copy ( follower leader must? -- )
    -rot leaders 2dup = [ 3drop ] [
        2dup vregs-interfere? [
            drop rot [ vregs-shouldn't-interfere ] [ 2drop ] if
        ] [ -rot coalesce-vregs drop ] if
    ] if ;

: try-eliminate-copies ( pairs must? -- )
    '[ first2 _ try-eliminate-copy ] each ;

GENERIC: coalesce-insn ( insn -- )

M: insn coalesce-insn drop ;

M: alien-call-insn coalesce-insn drop ;

M: vreg-insn coalesce-insn
    [ defs-vregs ] [ uses-vregs ] bi
    2dup [ empty? not ] both? [
        [ first ] bi@
        2dup [ rep-of reg-class-of ] bi@ eq?
        [ 2array , ] [ 2drop ] if
    ] [ 2drop ] if ;

M: ##copy coalesce-insn
    [ dst>> ] [ src>> ] bi 2array , ;

M: ##parallel-copy coalesce-insn
    values>> % ;

M: ##tagged>integer coalesce-insn
    [ dst>> ] [ src>> ] bi t try-eliminate-copy ;

M: ##phi coalesce-insn
    [ dst>> ] [ inputs>> values ] bi zip-scalar
    natural-sort t try-eliminate-copies ;

: initial-leaders ( cfg -- leaders )
    cfg>insns [ [ defs-vregs ] [ temp-vregs ] bi append ] map concat unique ;

: initial-class-elements ( -- class-elements )
    defs get [ [ dup dup value-of ] dip <vreg-info> 1array ] assoc-map ;

: init-coalescing ( cfg -- )
    initial-leaders leader-map set
    initial-class-elements class-element-map set ;

: coalesce-cfg ( cfg -- )
    dup init-coalescing
    cfg>insns-rpo [ [ coalesce-insn ] each ] V{ } make
    f try-eliminate-copies ;
