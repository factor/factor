! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors combinators classes math layouts
compiler.cfg.instructions
compiler.cfg.instructions.syntax
compiler.cfg.value-numbering.graph
compiler.cfg.value-numbering.expressions ;
IN: compiler.cfg.value-numbering.simplify

! Return value of f means we didn't simplify.
GENERIC: simplify* ( expr -- vn/expr/f )

: simplify-box-float ( in -- vn/expr/f )
    dup op>> \ ##unbox-float = [ in>> ] [ drop f ] if ;

: simplify-unbox-float ( in -- vn/expr/f )
    dup op>> \ ##box-float = [ in>> ] [ drop f ] if ;

M: unary-expr simplify*
    #! Note the copy propagation: a copy always simplifies to
    #! its source VN.
    [ in>> vn>expr ] [ op>> ] bi {
        { \ ##copy [ ] }
        { \ ##copy-float [ ] }
        { \ ##box-float [ simplify-box-float ] }
        { \ ##unbox-float [ simplify-unbox-float ] }
        [ 2drop f ]
    } case ;

M: expr simplify* drop f ;

: simplify ( expr -- vn )
    dup simplify* {
        { [ dup not ] [ drop expr>vn ] }
        { [ dup expr? ] [ expr>vn nip ] }
        { [ dup integer? ] [ nip ] }
    } cond ;

GENERIC: number-values ( insn -- )

M: ##flushable number-values [ >expr simplify ] [ dst>> ] bi set-vn ;
M: insn number-values drop ;
