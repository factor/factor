! Copyright (C) 2009 Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: mirrors specialized-arrays math.vectors ;
IN: specialized-arrays.mirrors

INSTANCE: specialized-array enumerated-sequence
INSTANCE: simd-128          enumerated-sequence
INSTANCE: simd-256          enumerated-sequence
