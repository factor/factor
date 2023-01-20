! Copyright (C) 2009 Elie Chaftari.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays assocs help.markup help.syntax math sequences
strings ;
IN: pop3

HELP: <pop3-account>
{ $values

    { "pop3-account" pop3-account }
}
{ $description "creates a " { $link pop3-account } " object with defaults for the port and timeout slots." } ;

HELP: account
{ $values

    { "pop3-account" pop3-account }
}
{ $description "You only need to call " { $link connect } " after calling this word to reconnect to the latest accessed POP3 account." }
{ $examples
    { $code
    "account connect"
    ""
    }
} ;

HELP: >user
{ $values
    { "name" "userID of the account" }
}
{ $description "Sends the userID of the account on the POP3 server (this could be the full e-mail address)" $nl
"This must be the first command after " { $link connect } " if username and password have not been set with " { $link <pop3-account> } "."
} ;

HELP: >pwd
{ $values
    { "password" "password for the userID" }
}
{ $description "Sends the clear-text password for the userID. The password may be case sensitive. This must be the next command after " { $link >user } "." } ;

HELP: capa
{ $values

    { "array" array }
}
{ $description "Queries the mail server capabilities, as described in RFC 2449. It is advised to check for command support before calling the appropriate words (e.g. TOP UIDL)." } ;

HELP: connect
{ $values
    { "pop3-account" pop3-account }
}
{ $description "Opens a network connection to the pop3 mail server with the settings given in the pop3-account slots." }
{ $examples
    { $code "USING: accessors pop3 ;"
    "<pop3-account>"
    "    \"pop.yourisp.com\" >>host"
    "    \"username@yourisp.com\" >>user"
    "    \"pass123\" >>pwd"
    "connect"
    ""
    }
} ;

HELP: consolidate
{ $values

    { "seq" sequence }
}
{ $description "Builds a sequence of email tuples, iterating over each email top and consolidating its headers with its number, uidl, and size." } ;

HELP: delete
{ $values
    { "message#" fixnum }
}
{ $description "This marks message number message# for deletion from the server. This is the way to get rid of a problem causing message. It is not actually deleted until the " { $link close } " word is issued. If you lose the connection to the mail server before calling the " { $link close } " word, the server should not delete any messages. Example: 3 delete" } ;

HELP: headers
{ $values

    { "assoc" assoc }
}
{ $description "Gathers and associates the From:, Subject:, and To: headers of each message." } ;

HELP: list
{ $values

    { "assoc" assoc }
}
{ $description "Lists each message with its number and size in bytes" } ;

HELP: pop3-account
{ $class-description "A POP3 account on a POP3 server. It has the following slots:"
    { $slots
        { "#" "The ephemeral ordinal number of the message." }
        { "host" "The name or IP address of the remote host to which a POP3 connection is required." }
        { "port" "The POP3 server port (defaults to 110)." }
        { "timeout" "Maximum time in minutes to wait for a response from the POP3 server (defaults to 1 minutes)." }
        { "user" "The userID of the account on the POP3 server." }
        { "pwd" { "The clear-text password for the userID." } }
        { "stream" { "The duplex input/output stream wrapping the POP3 session." } }
        { "capa" { "A list of the mail server capabilities." } }
        { "count" { "Number of messages in the mailbox." } }
        { "list" { "A list of every message with its number and size in bytes" } }
        { "uidls" { "The UIDL (Unique IDentification Listing) of every message in the mailbox together with its ordinal number." } }
        { "messages" { "A sequence of email tuples in the mailbox containing each email's headers, number, uidl, and size." } }
    }
"The " { $slot "host" } " is required; the rest are either set by default or optional." $nl
"The " { $slot "user" } " and " { $slot "pwd" } " must either be set before using " { $link connect } " or immediately after it with the " { $link >user } " and " { $link >pwd } " words."
} ;

HELP: message
{ $class-description "An e-mail message having the following slots:"
    { $slots
        { "#" "The ephemeral ordinal number of the message." }
        { "uidl" "The POP3 UIDL (Unique IDentification Listing) of the message." }
        { "headers" "The From:, Subject:, and To: headers of the message." }
        { "from" "The sender of the message. An e-mail address." }
        { "to" "The recipients of the message." }
        { "subject" { "The subject of the message." } }
        { "size" { "The size of the message in octets." } }
    }
} ;

HELP: close
{ $description "Deletes any messages marked for deletion, and then logs you off of the mail server. This is the last command to use." } ;

HELP: retrieve
{ $values
    { "message#" fixnum }
    { "seq" sequence }
}
{ $description "Sends message number message# to you. You should prepare for some base64 decoding. You probably want to do this with a mailer." } ;

HELP: reset
{ $description "Resets the status of the remote POP3 server. This includes resetting the status of all messages to not be deleted." } ;

HELP: count
{ $values

    { "n" fixnum }
}
{ $description "Gets the number of messages in the mailbox." } ;

HELP: top
{ $values
    { "message#" fixnum } { "#lines" fixnum }
    { "seq" sequence }
}
{ $description "Lists the header for message# and the first #lines of the message text. For example, 1 0 top would list just the headers for message 1, where as 1 5 top would list the headers and first 5 lines of the message text." } ;

HELP: uidl
{ $values
    { "message#" fixnum }
    { "uidl" string }
}
{ $description "Gets the POP3 UIDL (Unique IDentification Listing) of the given message#." } ;

HELP: uidls
{ $values

    { "assoc" assoc }
}
{ $description "Gets the POP3 UIDL (Unique IDentification Listing) of every specific message in the mailbox together with its ordinal number. UIDL provides a mechanism that avoids numbering issues between POP3 sessions by assigning a permanent and unique ID for each message." } ;

ARTICLE: "pop3" "POP3 client library"
"The " { $vocab-link "pop3" } " vocab implements a client interface to the POP3 protocol, enabling a Factor application to talk to POP3 servers. It allows interactive sessions similar to telnet ones to do maintenance on your mailbox on a POP3 mail server; to look at, and possibly delete, any problem causing message (e.g. too large, improperly formatted, etc.)." $nl
"Word names do not necessarily map directly to POP3 commands defined in RFC1081 or RFC1939, although most commands are supported." $nl
"This article assumes that you are familiar with the POP3 protocol."
$nl
"Connecting to the mail server:"
{ $subsections connect }
"You need to construct a pop3-account tuple first, setting at least the host slot."
{ $subsections <pop3-account> }
{ $examples
    { $code "USING: accessors pop3 ;"
    "<pop3-account>"
    "    \"pop.yourisp.com\" >>host"
    "    \"username@yourisp.com\" >>user"
    "    \"pass123\" >>pwd"
    "connect"
    ""
    }
}
$nl
"If you do not supply the username or password, you will need to call the " { $link >user } " and " { $link >pwd } " vocabs in this order after the " { $link connect } " vocab."
{ $examples
    { $code "USING: accessors pop3 ;"
    "<pop3-account>"
    "    \"pop.yourisp.com\" >>host"
    "connect"
    ""
    "\"username@yourisp.com\" >user"
    "\"pass123\" >pwd"
    ""
    }
}
$nl
{ $notes "Subsequent calls to the " { $link pop3-account } " thus created can be done by calling the " { $link account } " word. If you needed to reconnect to the same POP3 account after having called " { $link close } ", you only need to call " { $link account } " followed by " { $link connect } "." }
$nl
"Querying the mail server:"
$nl
"For its capabilities:"
{ $subsections capa }
{ $examples
    { $code
    "capa ."
    "{ \"CAPA\" \"TOP\" \"UIDL\" }"
    ""
    }
}
$nl
"For the message count:"
{ $subsections count }
{ $examples
    { $code
    "count ."
    "2"
    ""
    }
}
$nl
"For each message's size:"
{ $subsections list }
{ $examples
    { $code
    "list ."
    "H{ { 1 \"1006\" } { 2 \"747\" } }"
    ""
    }
}
$nl
"For a specific message raw header, appropriate headers, or number of lines:"
{ $subsections top }
{ $examples
    { $code
    "1 0 top ."
    "<the raw-source of the message header is retrieved>"
    ""
    }
    { $code
    "1 5 top ."
    "<the raw-source of the message header and its first 5 lines are retrieved>"
    ""
    }
    { $code
    "1 0 top headers ."
    "H{"
    "    { \"From:\" \"from@mail.com\" }"
    "    { \"Subject:\" \"Re:\" }"
    "    { \"To:\" \"username@host.com\" }"
    "}"
    ""
    }
}
$nl
"To consolidate all the messages of this account into a single association:"
{ $subsections consolidate }
{ $examples
    { $code
    "consolidate ."
"{
        T{ message
            { # 1 }
            { uidl \"000000d547ac2fc2\" }
            { from \"from.first@mail.com\" }
            { to \"username@host.com\" }
            { subject \"First subject\" }
            { size \"1006\" }
        }
        T{ message
            { # 2 }
            { uidl \"000000d647ac2fc2\" }
            { from \"from.second@mail.com\" }
            { to \"username@host.com\" }
            { subject \"Second subject\" }
            { size \"747\" }
        }
}"
    ""
    }
}
$nl
"You may want to delete message #2 but want to make sure you are deleting the right one. You can check that message #2 has the uidl from the example above."
{ $subsections uidl }
{ $examples
    { $code
    "2 uidl ."
    "\"000000d647ac2fc2\""
    ""
    }
}
$nl
"Now with your mind at rest, you can delete message #2. The message is marked for deletion."
{ $subsections delete }
{ $examples
    { $code
    "2 delete"
    ""
    }
}
$nl
"The messages marked for deletion are actually deleted only when " { $link close } " is called. This should be the last command you issue."
{ $subsections close }
{ $examples
    { $code
    "close"
    ""
    }
}
{ $notes "If you change your mind at any point, you can call " { $link reset } " to reset the status of all messages to not be deleted." } ;

ABOUT: "pop3"
