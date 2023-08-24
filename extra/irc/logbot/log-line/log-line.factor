! Copyright (C) 2009 Bruno Deferrari.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors irc.messages irc.messages.base kernel make
combinators sequences ;
IN: irc.logbot.log-line

: dot-or-parens ( string -- string )
    [ "." ] [ " (" prepend ")." append ] if-empty ;

GENERIC: >log-line ( object -- line )

M: irc-message >log-line line>> ;

M: ctcp >log-line
    [ "CTCP: " % dup sender>> % " " % text>> % ] "" make ;

M: action >log-line
    [ "* " % dup sender>> % " " % text>> % ] "" make ;

M: privmsg >log-line
    [ "<" % dup sender>> % "> " % text>> % ] "" make ;

: prefix% ( string -- )
    " [" % % "]" % ;

M: irc.messages:join >log-line
    [
        [ "* " % sender>> % ]
        [ prefix>> prefix% " has joined the channel." % ] bi
    ] "" make ;

M: part >log-line
    [
        [ "* " % sender>> % ]
        [ prefix>> prefix% " has left the channel" % ]
        [ comment>> dot-or-parens % ] tri
    ] "" make ;

M: quit >log-line
    [
        [ "* " % sender>> % ]
        [ prefix>> prefix% " has quit" % ]
        [ comment>> dot-or-parens % ] tri
    ] "" make ;

M: kick >log-line
    [
        {
            [ "* " % sender>> % ]
            [ " has kicked " % user>> % ]
            [ " from the channel" % comment>> dot-or-parens % ]
         } cleave
    ] "" make ;

M: participant-mode >log-line
    [
        {
            [ "* " % sender>> % ]
            [ " has set mode " % mode>> % ]
            [ " to " % parameter>> % ]
        } cleave
    ] "" make ;

M: nick >log-line
    [ "* " % dup sender>> % " is now known as " % nickname>> % ] "" make ;

M: topic >log-line
    [ "* " % dup sender>> % " has set the topic for " % dup channel>> %
      ": \"" % topic>> % "\"" % ] "" make ;
