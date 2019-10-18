! Copyright (C) 2003, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: tools
USING: kernel math memory io namespaces ;

: benchmark ( quot -- gctime runtime )
    millis >r gc-time >r call gc-time r> - millis r> - ;

: time ( quot -- )
    benchmark
    [ # " ms run / " % # " ms GC time" % ] "" make print flush ;
