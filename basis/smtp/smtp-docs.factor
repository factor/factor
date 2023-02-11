! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax io.encodings.utf8 io.sockets
quotations strings ;
IN: smtp

HELP: smtp-config
{ $class-description "An SMTP configuration object, with the following slots:"
    { $slots
        { "domain" { "Name of the machine sending the email, or " { $link host-name } " if empty." } }
        { "server" { "An " { $link <inet> } " of the SMTP server." } }
        { "tls?" { "Secure socket after connecting to server, server must support " { $snippet "STARTTLS" } } }
        { "read-timeout" { "Length of time after which we give up waiting for a response." } }
        { "auth" { "Either " { $link no-auth } " or an instance of " { $link plain-auth } " or " { $link login-auth } } }
    }
} ;

HELP: default-smtp-config
{ $values { "smtp-config" smtp-config } }
{ $description "Creates a new " { $link smtp-config } " with defaults of a one minute " { $snippet "read-timeout" } ", " { $link no-auth } " for authentication, and " { $snippet "localhost" } " port " { $snippet "25" } " as the server." } ;

{ smtp-config default-smtp-config } related-words

HELP: no-auth
{ $class-description "If the " { $snippet "auth" } " slot is set to this value, no authentication will be performed." } ;

HELP: plain-auth
{ $class-description "If the " { $snippet "auth" } " slot is set to this value, plain authentication will be performed, with the username and password stored in the " { $slot "username" } " and " { $slot "password" } " slots of the tuple sent to the server as plain-text." }
{ $notes "This authentication method is no longer supported by Outlook mail servers." } ;

HELP: <plain-auth>
{ $values { "username" string } { "password" string } { "plain-auth" plain-auth } }
{ $description "Creates a new " { $link plain-auth } " instance." } ;

HELP: login-auth
{ $class-description "If the " { $snippet "auth" } " slot is set to this value, LOGIN authentication will be performed, with the username and password stored in the " { $slot "username" } " and " { $slot "password" } " slots of the tuple sent to the server as plain-text." } ;

HELP: <login-auth>
{ $values { "username" string } { "password" string } { "login-auth" login-auth } }
{ $description "Creates a new " { $link login-auth } " instance." } ;

{ no-auth plain-auth login-auth } related-words

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
    { $slots
        { "from" "The sender of the e-mail. An e-mail address." }
        { "to" "The recipients of the e-mail. A sequence of e-mail addresses." }
        { "cc" "Carbon-copy. A sequence of e-mail addresses." }
        { "bcc" "Blind carbon-copy. A sequence of e-mail addresses." }
        { "subject" "The subject of the e-mail. A string." }
        { "content-type" { "The MIME type of the body. A string, default is " { $snippet "text/plain" } "." } }
        { "encoding" { "An encoding to send the body as. Default is " { $link utf8 } "." } }
        { "body" " The body of the e-mail. A string." }
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
"First, we set the login and password to a " { $link <login-auth> } " tuple with our login. Next, we set the gmail server address with an " { $link <inet> } " object. Finally, we tell the SMTP library to use a secure connection."
{ $notes
    "Observed on 2016-03-02: Gmail has restrictions for what they consider \"less secure apps\" (these include the factor smtp client)."
    { $list
        { "If the account does not use 2-step verification, Gmail requires explicitly allowing access to less secure apps. Visit " { $url "https://www.google.com/settings/security/lesssecureapps" } " to turn it on. More info: " { $url "https://support.google.com/accounts/answer/6010255?hl=en" } "." }
        { "If the account does use 2-step verification, Gmail requires the use of application-specific passwords. Visit " { $url "https://security.google.com/settings/security/apppasswords" } " to create a password for use with Factor. More info: " { $url "https://support.google.com/accounts/answer/185833?hl=en" } "." }
    }
}
{ $examples
{ $code
    "USING: smtp namespaces io.sockets ;"
    ""
    "default-smtp-config
    \"smtp.gmail.com\" 587 <inet> >>server
    t >>tls?
    \"my.gmail.address@gmail.com\" \"qwertyuiasdfghjk\" <login-auth> >>auth
    \\ smtp-config set-global"
}
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
    login-auth
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
