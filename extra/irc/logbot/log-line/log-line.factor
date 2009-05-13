! Copyright (C) 2009 Bruno Deferrari.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors irc.messages irc.messages.base kernel make ;
EXCLUDE: sequences => join ;
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

M: join >log-line
    [ "* " % sender>> % " has joined the channel." % ] "" make ;

M: part >log-line
    [ "* " % dup sender>> % " has left the channel" %
      comment>> dot-or-parens % ] "" make ;

M: quit >log-line
    [ "* " % dup sender>> % " has quit" %
      comment>> dot-or-parens % ] "" make ;

M: kick >log-line
    [ "* " % dup sender>> % " has kicked " % dup user>> %
      " from the channel" % comment>> dot-or-parens % ] "" make ;

M: participant-mode >log-line
    [ "* " % dup sender>> % " has set mode " % dup mode>> %
      " to " % parameter>> % ] "" make ;

M: nick >log-line
    [ "* " % dup sender>> % " is now known as " % nickname>> % ] "" make ;

M: topic >log-line
    [ "* " % dup sender>> % " has set the topic for " % dup channel>> %
      ": \"" % topic>> % "\"" % ] "" make ;
