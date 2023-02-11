! Copyright (C) 2012 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: ;
IN: machine-learning.transformer

GENERIC: fit-y ( y transformer -- )
GENERIC: transform-y ( y transformer -- y' )
GENERIC: inverse-transform-y ( y transformer -- y' )
