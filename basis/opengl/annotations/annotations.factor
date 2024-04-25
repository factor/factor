! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors ascii calendar combinators.short-circuit
compiler.units kernel namespaces opengl sequences
tools.annotations.private vocabs words ;
IN: opengl.annotations

TUPLE: gl-error-log
    { function word initial: t }
    { error gl-error-tuple }
    { timestamp timestamp } ;

gl-error-log [ V{ } clone ] initialize

: <gl-error-log> ( function code -- gl-error-log )
    dupd <gl-error> now gl-error-log boa ;

: log-gl-error ( function -- )
    gl-error-code [ <gl-error-log> gl-error-log get push ] [ drop ] if* ;

: clear-gl-error-log ( -- )
    V{ } clone gl-error-log set ;

: gl-function? ( word -- ? )
    name>> { [ "glGetError" = not ] [ "gl" head? ] [ third LETTER? ] } 1&& ;

: gl-functions ( -- words )
    "opengl.gl" lookup-vocab vocab-words [ gl-function? ] filter ;

: annotate-gl-functions ( quot -- )
    [
        [ gl-functions ] dip [ dupd curry (annotate) ] curry each
    ] with-compilation-unit ;

: reset-gl-functions ( -- )
    [ gl-functions [ (reset) ] each ] with-compilation-unit ;

: throw-gl-errors ( -- )
    [ '[ @ _ (gl-error) ] ] annotate-gl-functions ;

: log-gl-errors ( -- )
    [ '[ @ _ log-gl-error ] ] annotate-gl-functions ;
