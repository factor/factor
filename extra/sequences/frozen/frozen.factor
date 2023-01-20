! Copyright (C) 2009 John Benediktsson
! See https://factorcode.org/license.txt for BSD license
USING: accessors sequences ;
IN: sequences.frozen

TUPLE: frozen { seq read-only } ;

C: <frozen> frozen

M: frozen virtual@ seq>> ;

M: frozen virtual-exemplar seq>> ;

M: frozen length seq>> length ;

INSTANCE: frozen virtual-sequence

INSTANCE: frozen immutable-sequence
