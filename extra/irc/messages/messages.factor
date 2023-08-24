! Copyright (C) 2009 Bruno Deferrari
! See https://factorcode.org/license.txt for BSD license.
USING: accessors ascii combinators.short-circuit
irc.messages.base kernel math sequences splitting ;
IN: irc.messages

! connection
IRC: pass        "PASS"    password ;
IRC: nick        "NICK"    : nickname ;
IRC: user        "USER"    user mode _ : realname ;
IRC: oper        "OPER"    name password ;
IRC: mode        "MODE"    name mode parameter ;
IRC: service     "SERVICE" nickname _ distribution type _ : info ;
IRC: quit        "QUIT"    : comment ;
IRC: squit       "SQUIT"   server : comment ;
! channel operations
IRC: join        "JOIN"    : channel ;
IRC: part        "PART"    channel : comment ;
IRC: topic       "TOPIC"   channel : topic ;
IRC: names       "NAMES"   channel ;
IRC: list        "LIST"    channel ;
IRC: invite      "INVITE"  nickname channel ;
IRC: kick        "KICK"    channel user : comment ;
! chating
IRC: privmsg     "PRIVMSG" target : text ;
IRC: notice      "NOTICE"  target : text ;
! server queries
IRC: motd        "MOTD"    target ;
IRC: lusers      "LUSERS"  mask target ;
IRC: version     "VERSION" target ;
IRC: stats       "STATS"   query target ;
IRC: links       "LINKS"   server mask ;
IRC: time        "TIME"    target ;
IRC: connect     "CONNECT" server port remote-server ;
IRC: trace       "TRACE"   target ;
IRC: admin       "ADMIN"   target ;
IRC: info        "INFO"    target ;
! service queries
IRC: servlist    "SERVLIST" mask type ;
IRC: squery      "SQUERY"  service-name : text ;
! user queries
IRC: who         "WHO"     mask operator ;
IRC: whois       "WHOIS"   target mask ;
IRC: whowas      "WHOWAS"  nickname count target ;
! misc
IRC: kill        "KILL"    nickname : comment ;
IRC: ping        "PING"    server1 server2 ;
IRC: pong        "PONG"    server1 server2 ;
IRC: error       "ERROR"   : message ;
! numeric replies
IRC: rpl-welcome         "001" nickname : comment ;
IRC: rpl-whois-user      "311" nicnamek user host _ : real-name ;
IRC: rpl-channel-modes   "324" channel mode params ;
IRC: rpl-notopic         "331" channel : topic ;
IRC: rpl-topic           "332" channel : topic ;
IRC: rpl-inviting        "341" channel nickname ;
IRC: rpl-names           "353" nickname _ channel : nicks ;
IRC: rpl-names-end       "366" nickname channel : comment ;
! error replies
IRC: rpl-nickname-in-use "433" _ name ;
IRC: rpl-nick-collision  "436" nickname : comment ;

PREDICATE: channel-mode < mode name>> first "#&" member? ;
PREDICATE: participant-mode < channel-mode parameter>> ;
PREDICATE: ctcp < privmsg
    trailing>> { [ length 1 > ] [ first 1 = ] [ last 1 = ] } 1&& ;
PREDICATE: action < ctcp trailing>> rest "ACTION" head? ;

M: rpl-names post-process-irc-message ( rpl-names -- )
    [ [ ascii:blank? ] trim split-words ] change-nicks drop ;

M: ctcp post-process-irc-message ( ctcp -- )
    [ rest but-last ] change-text drop ;

M: action post-process-irc-message ( action -- )
    [ 7 tail ] change-text call-next-method ;
