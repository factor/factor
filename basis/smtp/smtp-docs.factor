! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel quotations help.syntax help.markup
io.sockets strings calendar io.encodings.utf8 ;
IN: smtp

HELP: smtp-config
{ $class-description "An SMTP configuration object, with the following slots:"
    { $table
        { { $slot "domain" } { "Name of the machine sending the email, or " { $link host-name } " if empty." } }
        { { $slot "server" } { "An " { $link <inet> } " of the SMTP server." } }
        { { $slot "tls?" } { "Secure socket after connecting to server, server must support " { $snippet "STARTTLS" } } }
        { { $slot "read-timeout" } { "Length of time after which we give up waiting for a response." } }
        { { $slot "auth" } { "Either " { $link no-auth } " or an instance of " { $link plain-auth } } }
    }
} ;

HELP: default-smtp-config
{ $values { "smtp-config" smtp-config } }
{ $description "Creates a new " { $link smtp-config } " with defaults of a one minute " { $snippet "read-timeout" } ", " { $link no-auth } " for authentication, and " { $snippet "localhost" } " port " { $snippet "25" } " as the server." } ;

{ smtp-config default-smtp-config } related-words

HELP: no-auth
{ $class-description "If the " { $snippet "auth" } " slot is set to this value, no authentication will be performed." } ;

HELP: plain-auth
{ $class-description "If the " { $snippet "auth" } " slot is set to this value, plain authentication will be performed, with the username and password stored in the " { $slot "username" } " and " { $slot "password" } " slots of the tuple sent to the server as plain-text." } ;

HELP: <plain-auth>
{ $values { "username" string } { "password" string } { "plain-auth" plain-auth } }
{ $description "Creates a new " { $link plain-auth } " instance." } ;

HELP: with-smtp-config
{ $values { "quot" quotation } }
{ $description "Connects to an SMTP server using credentials and settings stored in " { $link smtp-config } " and calls the " { $link with-smtp-connection } " combinator." }
{ $notes "This word is used to implement " { $link send-email } " and there is probably no reason to call it directly." } ;

HELP: with-smtp-connection
{ $values { "quot" quotation } }
{ $description "Connects to an SMTP server using credentials and settings stored in " { $link smtp-config } " and calls the quotation." }
{ $notes "This word is used to implement " { $link send-email } " and there is probably no reason to call it directly." } ;

HELP: email
{ $class-description "An e-mail. E-mails have the following slots:"
    { $table
        { { $slot "from" } "The sender of the e-mail. An e-mail address." }
        { { $slot "to" } "The recipients of the e-mail. A sequence of e-mail addresses." }
        { { $slot "cc" } "Carbon-copy. A sequence of e-mail addresses." }
        { { $slot "bcc" } "Blind carbon-copy. A sequence of e-mail addresses." }
        { { $slot "subject" } "The subject of the e-mail. A string." }
        { { $slot "content-type" } { "The MIME type of the body. A string, default is " { $snippet "text/plain" } "." } }
        { { $slot "encoding" } { "An encoding to send the body as. Default is " { $link utf8 } "." } }
        { { $slot "body" } " The body of the e-mail. A string." }
    }
"The " { $slot "from" } " and " { $slot "to" } " slots are required; the rest are optional."
$nl
"An e-mail address is a string in one of the following two formats:"
{ $list
    { $snippet "joe@groff.com" }
    { $snippet "Joe Groff <joe@groff.com>" }
} } ;

HELP: <email>
{ $values { "email" email } }
{ $description "Creates an empty " { $link email } " object." } ;

HELP: send-email
{ $values { "email" email } }
{ $description "Sends an e-mail." }
{ $examples
    { $code "USING: accessors smtp ;"
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

ARTICLE: "smtp-gmail" "Setting up SMTP with gmail"
"If you plan to send all email from the same address, then setting the config variable in the global namespace is the best option. The code example below does this approach and is meant to go in your " { $link ".factor-boot-rc" } "." $nl
"First, we set the login and password to a " { $link <plain-auth> } " tuple with our login. Next, we set the gmail server address with an " { $link <inet> } " object. Finally, we tell the SMTP library to use a secure connection."
{ $notes "Gmail requires the use of application-specific passwords when accessed from anywhere but their website. Visit " { $url "https://support.google.com/accounts/answer/185833?hl=en" } " to create a password for use with Factor." }
{ $code
    "USING: smtp namespaces io.sockets ;"
    ""
    """default-smtp-config
    "smtp.gmail.com" 587 <inet> >>server
    t >>tls?
    "my.gmail.address@gmail.com" "qwertyuiasdfghjk" <plain-auth> >>auth
    \\ smtp-config set-global"""
} ;


ARTICLE: "smtp" "SMTP client library"
"The " { $vocab-link "smtp" } " vocabulary sends e-mail via an SMTP server."
$nl
"This library is configured by a globally scoped config tuple:"
{ $subsections
    smtp-config
    default-smtp-config
}
"The auth slot is set to an instance of one of the following:"
{ $subsections
    no-auth
    plain-auth
}
"Constructing an e-mail:"
{ $subsections
    email
    <email>
}
"Sending an email:"
{ $subsections send-email }
"More topics:"
{ $subsections "smtp-gmail" } ;

ABOUT: "smtp"
