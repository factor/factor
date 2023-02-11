! Copyright (C) 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test quoted-printable io.encodings.string
sequences splitting kernel io.encodings.8-bit ;
IN: quoted-printable.tests

{ "José was the
person who knew how to write the letters:
    ő and ü 
and we didn't know hów tö do thât" }
[ "Jos=E9 was the
person who knew how to write the letters:
    =F5 and =FC=20
and w=
e didn't know h=F3w t=F6 do th=E2t" quoted> latin2 decode ] unit-test

{ "Jos=E9 was the=0Aperson who knew how to write the letters:=0A    =F5 and =FC=0Aand we didn't know h=F3w t=F6 do th=E2t" }
[ "José was the
person who knew how to write the letters:
    ő and ü
and we didn't know hów tö do thât" latin2 encode >quoted ] unit-test

: message ( -- str )
    55 [ "hello" ] replicate concat ;

{ f } [ message >quoted "=\r\n" subseq-of? ] unit-test
{ 1 } [ message >quoted split-lines length ] unit-test
{ t } [ message >quoted-lines "=\r\n" subseq-of? ] unit-test
{ 4 } [ message >quoted-lines split-lines length ] unit-test
{ "===o" } [ message >quoted-lines split-lines [ last ] "" map-as ] unit-test
