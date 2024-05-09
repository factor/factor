! Copyright (C) 2024 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: combinators command-line command-loop
concurrency.mailboxes io io.encodings.utf8 io.sockets kernel
literals math.parser namespaces prettyprint random sequences
splitting stomp threads unicode ;

IN: stomp.cli

INITIALIZED-SYMBOL: stomp-host [ "localhost" ]
INITIALIZED-SYMBOL: stomp-port [ 61613 ]

CONSTANT: stomp-mailbox $[ <mailbox> ]

: put-frame ( frame -- )
    stomp-mailbox mailbox-put ;

CONSTANT: COMMANDS {
    T{ command
        { name "abort" }
        { quot [ stomp-abort put-frame ] }
        { help "Roll back a transaction in progress." } }
    T{ command
        { name "ack" }
        { quot [ stomp-ack put-frame ] }
        { help "Acknowledge success of a message using client acknowledgment." } }
    T{ command
        { name "begin" }
        { quot [ stomp-begin put-frame ] }
        { help "Start a transaction." } }
    T{ command
        { name "commit" }
        { quot [ stomp-begin put-frame ] }
        { help "Commit a transaction in progress." } }
    T{ command
        { name "debug" }
        { quot [ >lower { "on" "true" "yes" } member? stomp-debug? set-global ] }
        { help "Enable or disable message debug statements." } }
    T{ command
        { name "nack" }
        { quot [ stomp-nack put-frame ] }
        { help "Acknowledge failure of a message using client acknowledgment." } }
    T{ command
        { name "receipts" }
        { quot [ >lower { "on" "true" "yes" } member? stomp-receipts? set-global ] }
        { help "Enable or disable message receipts." } }
    T{ command
        { name "send" }
        { quot [ " " split1 stomp-send put-frame ] }
        { help "Send a message to a destination in the messaging system." } }
    T{ command
        { name "sendfile" }
        { quot [ " " split1 stomp-sendfile put-frame ] }
        { help "Send a file to a destination in the messaging system." } }
    T{ command
        { name "subscribe" }
        { quot [ stomp-subscribe put-frame ] }
        { help "Subscribe to a destination." } }
    T{ command
        { name "unsubscribe" }
        { quot [ stomp-unsubscribe put-frame ] }
        { help "Unsubscribe from a destination." } }
}

! XXX: wait for connected to start before run-command-loop
! XXX: when disconnected, exit with a message
! XXX: print incoming and outgoing messages nicely

TUPLE: stomp-command-loop < command-loop ;

M: stomp-command-loop run-command-loop
    [
        stomp-host get resolve-host [ ipv4? ] filter random
        stomp-port get with-port utf8 [
            stomp-mailbox [ [ nl . flush ] with-global ] stomp-loop
        ] with-client
    ] in-thread call-next-method ;

: stomp-options ( args -- )
    [
        unclip >lower {
            { [ dup { "-h" "--host" } member? ] [ unclip stomp-host set-global ] }
            { [ dup { "-p" "--port" } member? ] [ unclip string>number stomp-port set-global ] }
            { [ dup { "-u" "--username" } member? ] [ unclip stomp-username set-global ] }
            { [ dup { "-w" "--password" } member? ] [ unclip stomp-password set-global ] }
        } case stomp-options
    ] unless-empty ;

: stomp-main ( -- )
    command-line get stomp-options
    "Welcome to STOMP!" "STOMP>"
    stomp-command-loop new-command-loop
    COMMANDS [ over add-command ] each
    run-command-loop ;

MAIN: stomp-main

