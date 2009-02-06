! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.complex.functor sequences kernel ;
IN: alien.complex

<< { "float" "double" } [ dup "complex-" prepend define-complex-type ] each >>