! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel inference.dataflow combinators sequences
namespaces math ;
IN: optimizer.control

GENERIC: detect-loops* ( node -- )

M: node detect-loops* drop ;

M: #label detect-loops* t swap set-#label-loop? ;

: not-a-loop ( #label -- )
    f swap set-#label-loop? ;

: tail-call? ( -- ? )
    node-stack get
    dup [ #label? ] find-last drop [ 1+ ] [ 0 ] if* tail
    [ node-successor #tail? ] all? ;

: detect-loop ( seen-other? label node -- seen-other? continue? )
    #! seen-other?: have we seen another label?
    {
        { [ dup #label? not ] [ 2drop t ] }
        { [ 2dup node-param eq? not ] [ 3drop t t ] }
        { [ tail-call? not ] [ not-a-loop drop f ] }
        { [ pick ] [ not-a-loop drop f ] }
        { [ t ] [ 2drop f ] }
    } cond ;

M: #call-label detect-loops*
    f swap node-param node-stack get <reversed>
    [ detect-loop ] with all? 2drop ;

: detect-loops ( node -- )
    [ detect-loops* ] each-node ;
