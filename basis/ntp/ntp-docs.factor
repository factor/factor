! Copyright (C) 2010 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: help.syntax help.markup ntp ntp.private strings ;

IN: ntp

HELP: <ntp>
{ $values { "host" string } { "ntp" ntp } }
{ $description
    "Requests the time from the specified NTP time server."
} ;
