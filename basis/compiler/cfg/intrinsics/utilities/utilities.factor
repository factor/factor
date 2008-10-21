! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math layouts cpu.architecture ;
IN: compiler.cfg.intrinsics.utilities

: value-info-small-tagged? ( value-info -- ? )
    literal>> dup fixnum? [ tag-fixnum small-enough? ] [ drop f ] if ;
