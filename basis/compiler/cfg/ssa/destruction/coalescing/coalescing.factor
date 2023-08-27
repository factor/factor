USING: accessors arrays assocs compiler.cfg.def-use
compiler.cfg.instructions compiler.cfg.linearization
compiler.cfg.registers compiler.cfg.ssa.destruction.leaders
compiler.cfg.ssa.interference compiler.utilities
cpu.architecture fry kernel make namespaces sequences sets
sorting ;
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

: initial-leaders ( insns -- leaders )
    [ [ defs-vregs ] [ temp-vregs ] bi append ] map concat unique ;

: initial-class-elements ( -- class-elements )
    defs get [ [ dup dup value-of ] dip <vreg-info> 1array ] assoc-map ;

: init-coalescing ( insns -- )
    initial-leaders leader-map namespaces:set
    initial-class-elements class-element-map namespaces:set ;

GENERIC: coalesce-now ( insn -- )

M: insn coalesce-now drop ;

M: ##tagged>integer coalesce-now
    [ dst>> ] [ src>> ] bi t try-eliminate-copy ;

M: ##phi coalesce-now
    [ dst>> ] [ inputs>> values ] bi zip-scalar
    sort t try-eliminate-copies ;

GENERIC: coalesce-later ( insn -- )

M: insn coalesce-later drop ;

M: alien-call-insn coalesce-later drop ;

M: vreg-insn coalesce-later
    [ defs-vregs ] [ uses-vregs ] bi zip ?first [ , ] when* ;

M: ##copy coalesce-later
    [ dst>> ] [ src>> ] bi 2array , ;

M: ##parallel-copy coalesce-later
    values>> % ;

: eliminatable-copy? ( vreg1 vreg2 -- ? )
    [ rep-of ] bi@ [ [ reg-class-of ] same? ] [ [ rep-size ] same? ] 2bi and ;

: coalesce-cfg ( cfg -- )
    cfg>insns-rpo dup init-coalescing
    [ [ [ coalesce-now ] [ coalesce-later ] bi ] each ] { } make
    [ first2 eliminatable-copy? ] filter f try-eliminate-copies ;
