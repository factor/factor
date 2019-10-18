! Copyright (C) 2003, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math memory io namespaces system
math.parser ;
IN: tools.time

: benchmark ( quot -- gctime runtime )
    millis >r gc-time >r call gc-time r> - millis r> - ;
    inline

: time ( quot -- )
    benchmark
    [ # " ms run / " % # " ms GC time" % ] "" make print flush ;
    inline
