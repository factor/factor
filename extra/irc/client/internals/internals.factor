! Copyright (C) 2009 Bruno Deferrari
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators concurrency.mailboxes
continuations destructors io irc.client.base irc.client.chats
irc.client.participants irc.messages irc.messages.base
irc.messages.parser kernel math sequences strings threads
words.symbol ;
IN: irc.client.internals

: do-connect ( server port quot: ( host port -- stream ) attempts -- stream/f )
    dup 0 > [
        [ drop call( host port -- stream ) ]
        [ drop 15 sleep 1 - do-connect ]
        recover
    ] [ 4drop f ] if ;

: /NICK ( nick -- ) "NICK " prepend irc-print ;
: /PONG ( text -- ) "PONG " prepend irc-print ;
: /PASS ( password -- ) "PASS " prepend irc-print ;

: /LOGIN ( nick -- )
    dup /NICK
    "USER " prepend " hostname servername :irc.factor" append irc-print ;

: /CONNECT ( server port -- stream )
    irc> [ connect>> ] [ reconnect-attempts>> ] bi do-connect ;

: /JOIN ( channel password -- )
    [ " :" glue ] when* "JOIN " prepend irc-print ;

: try-connect ( -- stream/f )
    irc> profile>> [ server>> ] [ port>> ] bi /CONNECT ;

: (terminate-irc) ( -- )
    irc> dup is-running>> [
        f >>is-running
        [ stream>> dispose ] keep
        [ in-messages>> ] [ out-messages>> ] bi 2array
        [ irc-end swap mailbox-put ] each
    ] [ drop ] if ;

: (connect-irc) ( -- )
    try-connect [
        [ irc> ] dip >>stream t >>is-running
        in-messages>> [ irc-connected ] dip mailbox-put
    ] [ (terminate-irc) ] if* ;

: (do-login) ( -- )
    irc>
    [ profile>> password>> [ /PASS ] when* ]
    [ nick>> /LOGIN ]
    bi ;

GENERIC: initialize-chat ( chat -- )
M: irc-chat         initialize-chat drop ;
M: irc-channel-chat initialize-chat [ name>> ] [ password>> ] bi /JOIN ;

GENERIC: chat-put ( message obj -- )
M: irc-chat chat-put in-messages>> mailbox-put ;
M: symbol   chat-put chat> [ chat-put ] [ drop ] if* ;
M: string   chat-put chat> +server-chat+ or chat-put ;
M: sequence chat-put [ chat-put ] with each ;

: delete-chat ( name -- ) irc> chats>> delete-at ;
: unregister-chat ( name -- ) [ irc-chat-end chat-put ] [ delete-chat ] bi ;

! Server message handling

GENERIC: message-forwards ( irc-message -- seq )
M: irc-message   message-forwards drop +server-chat+ ;
M: to-one-chat   message-forwards chat> ;
M: to-all-chats  message-forwards drop chats> ;
M: to-many-chats message-forwards sender>> participant-chats ;

GENERIC: process-message ( irc-message -- )
M: object process-message drop ;
M: ping   process-message trailing>> /PONG ;
! FIXME: it shouldn't be checking for the presence of chat here...
M: irc.messages:join
    process-message [ sender>> ] [ chat> ] bi
    [ join-participant ] [ drop ] if* ;
M: part   process-message [ sender>> ] [ chat> ] bi [ part-participant ] [ drop ] if* ;
M: quit   process-message sender>> quit-participant ;
M: nick   process-message [ trailing>> ] [ sender>> ] bi rename-participant* ;
M: rpl-nickname-in-use process-message name>> "_" append /NICK ;

M: rpl-welcome process-message
    irc>
        swap nickname>> >>nick
        t >>is-ready
    chats>> values [ initialize-chat ] each ;

M: kick process-message
    [ [ user>> ] [ chat> ] bi part-participant ]
    [ dup user>> me? [ unregister-chat ] [ drop ] if ]
    bi ;

M: participant-mode process-message ( participant-mode -- )
    [ mode>> ] [ name>> ] [ parameter>> ] tri change-participant-mode ;

M: rpl-names process-message
    [ nicks>> ] [ chat> ] bi dup ?clear-participants
    '[ _ join-participant ] each ;

M: rpl-names-end process-message chat> t >>clear-participants drop ;

! Client message handling

GENERIC: handle-outgoing-irc ( irc-message -- ? )
M: irc-end     handle-outgoing-irc drop f ;
M: irc-message handle-outgoing-irc irc-message>string irc-print t ;

! Reader/Writer

: handle-reader-message ( irc-message -- ) irc> in-messages>> mailbox-put ;

: (handle-disconnect) ( -- )
    irc-disconnected irc> in-messages>> mailbox-put
    (connect-irc) (do-login) ;

: handle-disconnect ( error -- ? )
    [ irc> exceptions>> push ] when*
    irc> is-running>> [ (handle-disconnect) t ] [ f ] if ;

GENERIC: handle-input ( line/f -- ? )
M: string handle-input string>irc-message handle-reader-message t ;
M: f      handle-input handle-disconnect ;

: (reader-loop) ( -- ? )
    stream> [ |dispose stream-readln handle-input ] with-destructors ;

: reader-loop ( -- ? ) [ (reader-loop) ] [ handle-disconnect ] recover ;
: writer-loop ( -- ? ) irc> out-messages>> mailbox-get handle-outgoing-irc ;

! Processing loops

: in-multiplexer-loop ( -- ? )
    irc> in-messages>> mailbox-get {
        [ message-forwards ]
        [ process-message ]
        [ swap chat-put ]
        [ irc-end? not ]
    } cleave ;

: strings>privmsg ( name string -- privmsg )
    " :" prepend append "PRIVMSG " prepend string>irc-message ;

GENERIC: annotate-message ( chat object -- object )
M: object     annotate-message nip ;
M: to-channel annotate-message swap name>> >>channel ;
M: to-target  annotate-message swap name>> >>target ;
M: mode       annotate-message swap name>> >>name ;
M: string     annotate-message [ name>> ] dip strings>privmsg ;

: spawn-irc ( -- )
    [ reader-loop ] "irc-reader-loop" spawn-server
    [ writer-loop ] "irc-writer-loop" spawn-server
    [ in-multiplexer-loop ] "in-multiplexer-loop" spawn-server
    3drop ;

GENERIC: (attach-chat) ( irc-chat -- )

M: irc-chat (attach-chat)
    irc>
    [ [ chats>> ] [ >>client name>> swap ] 2bi set-at ]
    [ is-ready>> [ initialize-chat ] [ drop ] if ]
    2bi ;

M: irc-server-chat (attach-chat)
    irc> [ client<< ] [ chats>> +server-chat+ set-at ] 2bi ;

GENERIC: remove-chat ( irc-chat -- )
M: irc-nick-chat remove-chat name>> unregister-chat ;
M: irc-server-chat remove-chat drop +server-chat+ unregister-chat ;

M: irc-channel-chat remove-chat
    [ name>> "PART " prepend string>irc-message irc-send ]
    [ name>> unregister-chat ] bi ;

: (speak) ( message irc-chat -- ) swap annotate-message irc-send ;
