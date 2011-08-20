! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: help.syntax help.markup ntp strings ;

IN: ntp

HELP: <ntp>
{ $values { "host" string } }
{ $description
    "Requests the time from the specified NTP time server."
} ;

