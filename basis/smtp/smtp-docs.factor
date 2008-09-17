! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel quotations help.syntax help.markup
io.sockets strings calendar ;
IN: smtp

HELP: smtp-domain
{ $description "The name of the machine that is sending the email.  This variable will be filled in by the " { $link host-name } " word if not set by the user." } ;

HELP: smtp-server
{ $description "Holds an " { $link inet } " object with the address of an SMTP server." } ;

HELP: smtp-read-timeout
{ $description "Holds an " { $link duration } " object that specifies how long to wait for a response from the SMTP server." } ;

HELP: esmtp?
{ $description "Set true by default, determines whether the SMTP client is using the Extended SMTP protocol." } ;

HELP: with-smtp-connection
{ $values { "quot" quotation } }
{ $description "Connects to an SMTP server stored in " { $link smtp-server } " and calls the quotation." } ;

HELP: <email>
{ $values { "email" email } }
{ $description "Creates an empty " { $link email } " object." } ;

HELP: send-email
{ $values { "email" email } }
{ $description "Sends an " { $link email } " object to an STMP server stored in the " { $link smtp-server } " variable.  The required slots are " { $slot "from" } " and " { $slot "to" } "." }
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
"Configuring SMTP:"
{ $subsection smtp-server }
{ $subsection smtp-read-timeout }
{ $subsection smtp-domain }
{ $subsection esmtp? }
"Sending an email:"
{ $subsection send-email } ;
