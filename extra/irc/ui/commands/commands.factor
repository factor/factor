! Copyright (C) 2008 William Schlieper
! See http://factorcode.org/license.txt for BSD license.

USING: kernel irc.client irc.messages irc.ui

IN: irc.ui.commands

: say ( string -- )
    [ client get profile>> nickname>> <own-message> print-irc ]
    [ listener get write-message ] bi ;

: quote ( string -- )
    drop ; ! THIS WILL CHANGE
