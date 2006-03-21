! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: sequences
USING: generic kernel lists namespaces strings ;

GENERIC: flatten* ( obj -- )

M: object flatten* , ;

M: sequence flatten* [ flatten* ] each ;

M: string flatten* , ;

M: sbuf flatten* , ;

M: cons flatten* uncons >r flatten* r> flatten* ;

M: wrapper flatten* wrapped flatten* ;

: flatten ( obj -- seq ) [ flatten* ] { } make ;
