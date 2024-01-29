! Copyright (C) 2023 Jean-Marc Lugrin.
! See https://factorcode.org/license.txt for BSD license.

! Print a class hierarchy in the listener
! or to a file: "TESTDUMP.TXT" utf8 [ gadget hierarchy. ] with-file-writer


USING:  classes hashtables ui.gadgets assocs kernel sequences prettyprint  vectors 
math io formatting strings sorting accessors io.styles vocabs ;

IN: classes.hierarchy

ERROR: not-a-class-error ;

<PRIVATE

CONSTANT: in-col 40

: add-child  ( c h  -- )
    over 
    superclass-of  
    swap at* 
        [ swap suffix! drop ] 
        [ 2drop ] 
    if 
;

: print-class-name ( c -- )
    dup name>> swap write-object
;


: print-in ( c -- )
    vocabulary>> lookup-vocab dup name>> 
    dup ".private" tail? [ " P" ]  [ "  " ] if  write ! Mark if private
    " IN: " write 
    swap write-object 
;

: print-leader ( i -- )
    [ "| " ] replicate "" concat-as write  
;

: print-class ( c i -- ) 
    2dup print-leader print-class-name
    2 * over name>> length +  
    dup in-col < [ in-col swap - CHAR: \x20 <string>  write  ] [ drop  ] if
    print-in 
    nl 
;

: print-superclasses ( c -- )
    superclass-of 
    [ " < " write
        [ print-class-name ] 
        [ print-superclasses ] bi 
    ] when*
;

: print-root-class ( c -- ) 
    [ print-class-name ]
    [ print-superclasses ] bi
    nl
;

 :: print-children ( h c i -- )
    c i [ print-root-class ] [ print-class ] if-zero
    c h at
    [ h swap i 1 + print-children ] each
 ;

PRIVATE>

: class-hierarchy ( -- hash )
    ! Hashtable class -> empty mutable vector
    classes  [ drop V{ } clone ] H{ } zip-with-as
    ! for each child-class, add it to its parent vector
    classes [  over add-child ] each
    [ sort ] assoc-map
;

: hierarchy. ( class -- )
    dup class? [ not-a-class-error ] unless
    class-hierarchy
    ! Print from the desired root class
    swap 0 print-children 
;   
