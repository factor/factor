! Copyright (C) 2024 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: command-line.parser command-loop concurrency.mailboxes io
io.encodings.utf8 io.sockets kernel literals math namespaces
prettyprint random sequences splitting stomp threads unicode ;

IN: stomp.cli

SYMBOL: stomp-host
SYMBOL: stomp-port

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

CONSTANT: OPTIONS {
    T{ option
        { name "--host" }
        { help "set the hostname" }
        { variable stomp-host }
        { default "127.0.0.1" }
    }
    T{ option
        { name "--port" }
        { help "set the port" }
        { type integer }
        { variable stomp-port }
        { default 61613 }
    }
    T{ option
        { name "--username" }
        { help "set the username" }
        { variable stomp-username }
    }
    T{ option
        { name "--password" }
        { help "set the password" }
        { variable stomp-password }
    }
}

! XXX: wait for connected to start before run-command-loop
! XXX: when disconnected, exit with a message
! XXX: print incoming and outgoing messages nicely

: start-stomp-client ( -- )
    [
        stomp-host get resolve-host [ ipv4? ] filter random
        stomp-port get with-port utf8 [
            stomp-mailbox [ [ nl . flush ] with-global ] stomp-loop
        ] with-client
    ] in-thread ;

: stomp-main ( -- )
    OPTIONS [
        "Welcome to STOMP!" "STOMP>" <command-loop>
        COMMANDS [ over add-command ] each
        start-stomp-client run-command-loop
    ] with-options ;

MAIN: stomp-main
