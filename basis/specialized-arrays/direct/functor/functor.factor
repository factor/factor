! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: functors sequences sequences.private kernel words classes
math alien alien.c-types byte-arrays accessors
specialized-arrays parser
prettyprint.backend prettyprint.custom prettyprint.sections ;
IN: specialized-arrays.direct.functor

<PRIVATE

: pprint-direct-array ( direct-array tag -- )
    <block
    pprint-word
    [ underlying>> ] [ length>> ] bi [ pprint* ] bi@
    block> ;

PRIVATE>

FUNCTOR: define-direct-array ( T -- )

A'      IS ${T}-array
S       IS ${T}-sequence
>A'     IS >${T}-array
<A'>    IS <${A'}>
A'{     IS ${A'}{

A       DEFINES-CLASS direct-${T}-array
<A>     DEFINES <${A}>
A'@      DEFINES ${A'}@

NTH     [ T dup c-type-getter-boxer array-accessor ]
SET-NTH [ T dup c-setter array-accessor ]

WHERE

TUPLE: A
{ underlying c-ptr read-only }
{ length fixnum read-only } ;

: <A> ( alien len -- direct-array ) A boa ; inline
M: A length length>> ; inline
M: A nth-unsafe underlying>> NTH call ; inline
M: A set-nth-unsafe underlying>> SET-NTH call ; inline
M: A like drop dup A instance? [ >A' ] unless ; inline
M: A new-sequence drop <A'> ; inline

M: A byte-length length>> T heap-size * ; inline

SYNTAX: A'@ 
    scan-object scan-object <A> parsed ;

M: A pprint-delims drop \ A'{ \ } ;

M: A >pprint-sequence ;

M: A pprint*
    [ pprint-object ]
    [ \ A'@ pprint-direct-array ]
    pprint-c-object ;

INSTANCE: A sequence
INSTANCE: A S

T c-type
    \ A >>direct-array-class
    \ <A> >>direct-array-constructor
    drop

;FUNCTOR
