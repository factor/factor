! Copyright (C) 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: cpu.x86.features kernel random ;

IN: random.rdrand

SINGLETON: rdrand

M: rdrand random-32* drop rdrand32 ;

: with-rdrand ( quot -- )
    [ rdrand ] dip with-random ; inline

INSTANCE: rdrand base-random
