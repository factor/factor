! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors debugger io kernel math prettyprint sequences
system unix.signals ;
IN: debugger.unix

: signal-name. ( n -- )
    signal-name [ " (" ")" surround write ] when* ;

M: unix signal-error. ( obj -- )
    "Unix signal #" write
    third [ pprint ] [ signal-name. ] bi nl ;
