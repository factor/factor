! Copyright (C) 2008 William Schlieper
! See http://factorcode.org/license.txt for BSD license.

USING: accessors kernel irc.client irc.messages irc.ui namespaces ;

IN: irc.ui.commands

: say ( string -- )
    irc-tab get
    [ window>> client>> profile>> nickname>> <own-message> print-irc ]
    [ listener>> write-message ] 2bi ;

: join ( string -- )
    irc-tab get window>> join-channel ;

: query ( string -- )
    irc-tab get window>> query-nick ;

: quote ( string -- )
    drop ; ! THIS WILL CHANGE
