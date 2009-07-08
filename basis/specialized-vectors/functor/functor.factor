! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: functors sequences sequences.private growable
prettyprint.custom kernel words classes math parser ;
QUALIFIED: vectors.functor
IN: specialized-vectors.functor

FUNCTOR: define-vector ( T -- )

V   DEFINES-CLASS ${T}-vector

A   IS      ${T}-array
<A> IS      <${A}>

>V  DEFERS >${V}
V{  DEFINES ${V}{

WHERE

V A <A> vectors.functor:define-vector

M: V contract 2drop ;

M: V pprint-delims drop \ V{ \ } ;

M: V >pprint-sequence ;

M: V pprint* pprint-object ;

SYNTAX: V{ \ } [ >V ] parse-literal ;

INSTANCE: V growable

;FUNCTOR
