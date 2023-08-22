! Copyright (C) 2008 Bruno Deferrari, Doug Coleman, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors concurrency.mailboxes irc.client.base
irc.client.internals kernel ;
IN: irc.client

: connect-irc ( irc-client -- )
    [ (connect-irc) (do-login) spawn-irc ] with-irc ;

: attach-chat ( irc-chat irc-client -- ) [ (attach-chat) ] with-irc ;
: detach-chat ( irc-chat -- ) dup client>> [ remove-chat ] with-irc ;
: speak ( message irc-chat -- ) dup client>> [ (speak) ] with-irc ;
: hear ( irc-chat -- message ) in-messages>> mailbox-get ;
: terminate-irc ( irc-client -- ) [ (terminate-irc) ] with-irc ;
