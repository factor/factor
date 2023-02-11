! Copyright (c) 2009 Samuel Tardieu.
! See See https://factorcode.org/license.txt for BSD license.
USING: backtrack math tools.test ;

cut-amb
{ 1 } [ { 1 2 } amb ] unit-test
{ V{ { 1 2 } } } [ [ { 1 2 } ] bag-of ] unit-test
{ V{ 1 2 } } [ [ { 1 2 } amb ] bag-of ] unit-test
[ cut-amb { } amb ] must-fail
[ fail ] must-fail
{ V{ 1 10 2 20 } } [ [ { 1 2 } amb { 1 10 } amb * ] bag-of ] unit-test
{ V{ 7 -1 } } [ [ 3 4 { + - } amb-execute ] bag-of ] unit-test
{ "foo" t } [ [ "foo" t ] [ "bar" ] if-amb ] unit-test
{ "bar" f } [ [ "foo" f ] [ "bar" ] if-amb ] unit-test
{ "bar" f } [ [ "foo" fail ] [ "bar" ] if-amb ] unit-test
