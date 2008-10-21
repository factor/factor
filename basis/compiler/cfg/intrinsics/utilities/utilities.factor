! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math layouts cpu.architecture
compiler.cfg.instructions ;
IN: compiler.cfg.intrinsics.utilities

: value-info-small-tagged? ( value-info -- ? )
    literal>> dup fixnum? [ tag-fixnum small-enough? ] [ drop f ] if ;

: emit-primitive ( node -- )
    word>> ##simple-stack-frame ##call ;
