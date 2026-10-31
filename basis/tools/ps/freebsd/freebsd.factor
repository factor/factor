! Copyright (C) 2026 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays io io.encodings.utf8 io.launcher kernel
math.parser sequences splitting system tools.ps unicode ;
IN: tools.ps.freebsd

: parse-ps-line ( line -- pair )
    [ blank? ] trim-head [ blank? ] split1-when
    [ string>number ] [ [ blank? ] trim-head ] bi* 2array ;

M: freebsd ps
    { "/bin/ps" "-axww" "-o" "pid=" "-o" "command=" }
    utf8 [ read-lines [ parse-ps-line ] map ] with-process-reader ;
