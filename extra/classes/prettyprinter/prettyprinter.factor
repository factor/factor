! Copyright (C) 2023 Jean-Marc Lugrin.
! See https://factorcode.org/license.txt for BSD license.

! Print a class heierarchy in the listener
! or to a file: "TESTDUMP.TXT" utf8 [ gadget hierarchy. ] with-file-writer


USING:  classes hashtables ui.gadgets assocs kernel sequences prettyprint  vectors 
math io formatting strings sorting accessors io.styles vocabs ;

IN: classes.prettyprinter

ERROR: not-a-class-error ;

<PRIVATE

CONSTANT: in-col 40

: add-child  ( c h  -- )
    over ! ( c h -- c h c )
    superclass-of  ! ( c h c -- c h s )
    swap at* ! (c h s -- c s h -- c v ? ) vector for superclass but if f ignore
        [ swap suffix! drop ]  ! ( c v -- )
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
    ! 2 * CHAR: . <string>  write ! leader
    [ "| " ] replicate "" concat-as write  
    ! 1 CHAR: \x20 <string> write
;

: print-class ( c i -- ) 
    2dup print-leader print-class-name ! ( c i -- c i )
    2 * over name>> length + ! Current column  c ci -- 
    dup in-col < [ in-col swap - CHAR: \x20 <string>  write  ] [ drop  ] if
    print-in 
    nl 
;

: print-superclasses ( c -- )
    superclass-of dup
    [ " < " write
        [ print-class-name ] 
        [ print-superclasses ] bi 
    ]
    [ drop ]
    if
;

: print-root-class ( c -- ) 
    [ print-class-name ]
    [ print-superclasses ] bi
    nl
;

 :: print-children ( h c i -- )
    i 0 = [ c print-root-class ] [ c i print-class  ] if
    c h at
    [ h swap i 1 + print-children ] each
 ;

PRIVATE>

: class-hierarchy ( -- hash )
    ! Hastable class -> empty mutable vector
    classes  [ drop V{ } clone ] zip-with >hashtable
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
