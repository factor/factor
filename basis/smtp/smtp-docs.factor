! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel quotations help.syntax help.markup
io.sockets strings calendar ;
IN: smtp

HELP: smtp-server
{ $description "Holds an " { $link inet } " object with the address of an SMTP server." } ;

HELP: smtp-read-timeout
{ $description "Holds an " { $link duration } " object that specifies how long to wait for a response from the SMTP server." } ;

HELP: with-smtp-connection
{ $values { "quot" quotation } }
{ $description "Connects to an SMTP server stored in " { $link smtp-server } " and calls the quotation." } ;

HELP: <email>
{ $values { "email" email } }
{ $description "Creates an empty " { $link email } " object." } ;

HELP: send-email
{ $values { "email" email } }
{ $description "Sends an " { $link email } " object to an STMP server stored in the " { $link smtp-server } " variable.  The required slots are " { $snippet "from" } " and " { $snippet "to" } "." }

{ $examples
    { $unchecked-example "USING: accessors smtp ;"
    "<email>"
    "    \"groucho@marx.bros\" >>from"
    "    { \"chico@marx.bros\" \"harpo@marx.bros\" } >>to"
    "    { \"gummo@marx.bros\" } >>cc"
    "    { \"zeppo@marx.bros\" } >>bcc"
    "    \"Pickup line\" >>subject"
    "    \"If I said you had a beautiful body, would you hold it against me?\" >>body"
    "send-email"
    ""
    }
} ;

ARTICLE: "smtp" "SMTP Client Library"
"Start by creating a new email object:"
{ $subsection <email> }
"Set the " { $snippet "from" } " slot to a " { $link string } "." $nl
"Set the recipient fields, " { $snippet "to" } ", " { $snippet "cc" } ", and " { $snippet "bcc" } ", to arrays of strings."
"Set the " { $snippet "subject" } " to a " { $link string } "." $nl
"Set the " { $snippet "body" } " to a " { $link string } "." $nl ;
