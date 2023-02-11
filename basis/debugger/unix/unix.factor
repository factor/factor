! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: debugger io kernel prettyprint sequences system
unix.signals ;
IN: debugger.unix

M: unix signal-error.
    "Unix signal #" write
    third [ pprint ] [ signal-name. ] bi nl ;
