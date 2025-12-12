! Copyright (C) 2009 Anton Gorenko.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.strings gobject.ffi io.encodings.utf8 kernel ;
IN: gobject

: connect-signal-with-data ( object signal-name callback data -- )
    [ utf8 string>alien ] 2dip g_signal_connect drop ;

: connect-signal ( object signal-name callback -- )
    f connect-signal-with-data ;
