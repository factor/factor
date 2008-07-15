! Copyright (C) 2008 William Schlieper
! See http://factorcode.org/license.txt for BSD license.

USING: kernel vocabs.loader sequences strings irc.messages ;

IN: irc.ui.commandparser

"irc.ui.commands" require

: command ( string -- command )
    dup empty? [ drop "say" ] when
    dup "irc.ui.commands" lookup
    [ "quote" "irc.ui.commands" lookup ] unless* ;

: parse-message ( string -- )
    "/" head? [ " " split1 swap command execute ] when ;
