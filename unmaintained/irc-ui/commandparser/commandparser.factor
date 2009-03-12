! Copyright (C) 2008 William Schlieper
! See http://factorcode.org/license.txt for BSD license.

USING: kernel vocabs.loader sequences strings splitting words irc.messages ;

IN: irc.ui.commandparser

: command ( string string -- string command )
    [ "say" ] when-empty
    dup "irc.ui.commands" lookup
    [ nip ]
    [ " " append prepend "quote" "irc.ui.commands" lookup ] if* ;

: parse-message ( string -- )
    "/" ?head [ " " split1 swap command ] [ "say" command ] if execute ;
