! Copyright (c) 2024 Alex Maestas
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test quoted-printable.rfc2047 io.encodings.string
sequences splitting kernel io.encodings.8-bit ;
IN: quoted-printable.rfc2047.tests

{ "" } [ "=?US-ASCII?B??=" rfc2047> ] unit-test
{ "a b c d" } [ "=?UTF-8?Q?a_b_c_d?=" rfc2047> ] unit-test
{ "a_b c d" } [ "=?UTF-8?Q?a=5fb_c_d?=" rfc2047> ] unit-test
{ "äbcd" } [ "=?UTF-8?B?w6RiY2Q=?=" rfc2047> ] unit-test
{ "äbcd" } [ "=?UTF-8?Q?=C3=A4bcd?=" rfc2047> ] unit-test
{ "äbcd" } [ "=?iso-8859-9?B?5GJjZA==?=" rfc2047> ] unit-test
{ "äbcd" } [ "=?iso-8859-9?Q?=e4bcd?=" rfc2047> ] unit-test
[ "=?blub?Q?=41?=" rfc2047> ] [ unrecognized-charset? ] must-fail-with
