! Copyright (C) 2009 Elie Chaftari.
! See https://factorcode.org/license.txt for BSD license.
USING: concurrency.promises namespaces kernel pop3 pop3.server
sequences tools.test accessors calendar ;

FROM: pop3 => count delete ;

<promise> "p" set

{ } [ "p" get mock-pop3-server ] unit-test
{ } [
        <pop3-account>
            "127.0.0.1" >>host
            "p" get 5 seconds ?promise-timeout >>port
        connect
] unit-test
{ } [ "username@host.com" >user ] unit-test
{ } [ "password" >pwd ] unit-test
{ { "CAPA" "TOP" "UIDL" } } [ capa ] unit-test
{ 2 } [ count ] unit-test
{ H{ { 1 "1006" } { 2 "747" } } } [ list ] unit-test
{
    H{
        { "From:" "from.first@mail.com" }
        { "Subject:" "First test with mock POP3 server" }
        { "To:" "username@host.com" }
    }
} [ 1 0 top drop headers ] unit-test
{
    {
        T{ message
            { # 1 }
            { uidl "000000d547ac2fc2" }
            { from "from.first@mail.com" }
            { to "username@host.com" }
            { subject "First test with mock POP3 server" }
            { size "1006" }
        }
        T{ message
            { # 2 }
            { uidl "000000d647ac2fc2" }
            { from "from.second@mail.com" }
            { to "username@host.com" }
            { subject "Second test with mock POP3 server" }
            { size "747" }
        }
    }
} [ consolidate ] unit-test
{ "000000d547ac2fc2" } [ 1 uidl ] unit-test
{ } [ 1 delete ] unit-test
{ f } [ 1 retrieve empty? ] unit-test
{ } [ reset ] unit-test
{ } [ close ] unit-test
