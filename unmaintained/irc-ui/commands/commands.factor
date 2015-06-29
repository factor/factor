! Copyright (C) 2008 William Schlieper
! See http://factorcode.org/license.txt for BSD license.

USING: accessors kernel sequences arrays irc.client
       irc.messages irc.ui namespaces ;

IN: irc.ui.commands

: say ( string -- )
    irc-tab get
    [ window>> client>> profile>> nickname>> <own-message> print-irc ]
    [ chat>> speak ] 2bi ;

: me ( string -- ) ! Placeholder until I make /me look different
    "ACTION " 1 prefix prepend 1 suffix say ;

: join ( string -- )
    irc-tab get window>> join-channel ;

: query ( string -- )
    irc-tab get window>> query-nick ;

: whois ( string -- )
    "WHOIS" swap { } clone swap  <irc-client-message>
    irc-tab get listener>> speak ;

: quote ( string -- )
    drop ; ! THIS WILL CHANGE
