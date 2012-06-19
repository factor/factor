! Copyright (C) 2009 Bruno Deferrari
! See http://factorcode.org/license.txt for BSD license.
USING: io io.streams.memory serialize kernel ;
IN: tokyo.utils

: memory>object ( memory -- object )
    [ deserialize ] with-memory-reader ;
