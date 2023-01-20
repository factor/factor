! Copyright (C) 2009 Bruno Deferrari
! See https://factorcode.org/license.txt for BSD license.
USING: io.streams.memory serialize ;
IN: tokyo.utils

: memory>object ( memory -- object )
    [ deserialize ] with-memory-reader ;
