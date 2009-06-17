! Copyright (C) 2009 Bruno Deferrari
! See http://factorcode.org/license.txt for BSD license.
USING: io io.streams.memory serialize kernel ;
IN: tokyo.utils

: with-memory-reader ( memory quot -- )
    [ <memory-stream> ] dip with-input-stream* ; inline

: memory>object ( memory -- object )
    [ deserialize ] with-memory-reader ;
