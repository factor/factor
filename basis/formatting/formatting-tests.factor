! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license
USING: calendar kernel formatting tools.test system ;
IN: formatting.tests

[ "%s" printf ] must-infer
[ "%s" sprintf ] must-infer

[ "" ] [ "" sprintf ] unit-test
[ "asdf" ] [ "asdf" sprintf ] unit-test
[ "10" ] [ 10 "%d" sprintf ] unit-test
[ "+10" ] [ 10 "%+d" sprintf ] unit-test
[ "-10" ] [ -10 "%d" sprintf ] unit-test
[ "  -10" ] [ -10 "%5d" sprintf ] unit-test
[ "-0010" ] [ -10 "%05d" sprintf ] unit-test
[ "+0010" ] [ 10 "%+05d" sprintf ] unit-test
[ "123.456000" ] [ 123.456 "%f" sprintf ] unit-test
[ "2.44" ] [ 2.436 "%.2f" sprintf ] unit-test
[ "8.950" ] [ 8.950179003580072 "%.3f" sprintf ] unit-test
[ "123.10" ] [ 123.1 "%01.2f" sprintf ] unit-test
[ "1.2346" ] [ 1.23456789 "%.4f" sprintf ] unit-test
[ "  1.23" ] [ 1.23456789 "%6.2f" sprintf ] unit-test
[ "001100" ] [ 12 "%06b" sprintf ] unit-test
[ "==14" ] [ 12 "%'=4o" sprintf ] unit-test

{ "foo: 1 bar: 2" } [ { 1 2 3 } "foo: %d bar: %s" vsprintf ] unit-test

os windows? [
    [ "1.234000e+008" ] [ 123400000 "%e" sprintf ] unit-test
    [ "-1.234000e+008" ] [ -123400000 "%e" sprintf ] unit-test
    [ "1.234567e+008" ] [ 123456700 "%e" sprintf ] unit-test
    [ "3.625e+008" ] [ 362525200 "%.3e" sprintf ] unit-test
    [ "2.500000e-003" ] [ 0.0025 "%e" sprintf ] unit-test
    [ "2.500000E-003" ] [ 0.0025 "%E" sprintf ] unit-test
    [ "   1.0E+001" ] [ 10 "%11.1E" sprintf ] unit-test
    [ "  -1.0E+001" ] [ -10 "%11.1E" sprintf ] unit-test
    [ "  -1.0E+001" ] [ -10 "%+11.1E" sprintf ] unit-test
    [ "  +1.0E+001" ] [ 10 "%+11.1E" sprintf ] unit-test
    [ "-001.0E+001" ] [ -10 "%+011.1E" sprintf ] unit-test
    [ "+001.0E+001" ] [ 10 "%+011.1E" sprintf ] unit-test
] [
    [ "1.234000e+08" ] [ 123400000 "%e" sprintf ] unit-test
    [ "-1.234000e+08" ] [ -123400000 "%e" sprintf ] unit-test
    [ "1.234567e+08" ] [ 123456700 "%e" sprintf ] unit-test
    [ "3.625e+08" ] [ 362525200 "%.3e" sprintf ] unit-test
    [ "2.500000e-03" ] [ 0.0025 "%e" sprintf ] unit-test
    [ "2.500000E-03" ] [ 0.0025 "%E" sprintf ] unit-test
    [ "   1.0E+01" ] [ 10 "%10.1E" sprintf ] unit-test
    [ "  -1.0E+01" ] [ -10 "%10.1E" sprintf ] unit-test
    [ "  -1.0E+01" ] [ -10 "%+10.1E" sprintf ] unit-test
    [ "  +1.0E+01" ] [ 10 "%+10.1E" sprintf ] unit-test
    [ "-001.0E+01" ] [ -10 "%+010.1E" sprintf ] unit-test
    [ "+001.0E+01" ] [ 10 "%+010.1E" sprintf ] unit-test
] if

[ "ff" ] [ 0xff "%x" sprintf ] unit-test
[ "FF" ] [ 0xff "%X" sprintf ] unit-test
[ "0f" ] [ 0xf "%02x" sprintf ] unit-test
[ "0F" ] [ 0xf "%02X" sprintf ] unit-test
[ "2008-09-10" ] [ 2008 9 10 "%04d-%02d-%02d" sprintf ] unit-test
[ "Hello, World!" ] [ "Hello, World!" "%s" sprintf ] unit-test
[ "printf test" ] [ "printf test" sprintf ] unit-test
[ "char a = 'a'" ] [ CHAR: a "char %c = 'a'" sprintf ] unit-test
[ "00" ] [ 0x0 "%02x" sprintf ] unit-test
[ "ff" ] [ 0xff "%02x" sprintf ] unit-test
[ "0 message(s)" ] [ 0 "message" "%d %s(s)" sprintf ] unit-test
[ "0 message(s) with %" ] [ 0 "message" "%d %s(s) with %%" sprintf ] unit-test
[ "justif: \"left      \"" ] [ "left" "justif: \"%-10s\"" sprintf ] unit-test
[ "justif: \"     right\"" ] [ "right" "justif: \"%10s\"" sprintf ] unit-test
[ " 3: 0003 zero padded" ] [ 3 " 3: %04d zero padded" sprintf ] unit-test
[ " 3: 3    left justif" ] [ 3 " 3: %-4d left justif" sprintf ] unit-test
[ " 3:    3 right justif" ] [ 3 " 3: %4d right justif" sprintf ] unit-test
[ " -3: -003 zero padded" ] [ -3 " -3: %04d zero padded" sprintf ] unit-test
[ " -3: -3   left justif" ] [ -3 " -3: %-4d left justif" sprintf ] unit-test
[ " -3:   -3 right justif" ] [ -3 " -3: %4d right justif" sprintf ] unit-test
[ "There are 10 monkeys in the kitchen" ] [ 10 "kitchen" "There are %d monkeys in the %s" sprintf ] unit-test
[ "10" ] [ 10 "%d" sprintf ] unit-test
[ "[monkey]" ] [ "monkey" "[%s]" sprintf ] unit-test
[ "[    monkey]" ] [ "monkey" "[%10s]" sprintf ] unit-test
[ "[monkey    ]" ] [ "monkey" "[%-10s]" sprintf ] unit-test
[ "[0000monkey]" ] [ "monkey" "[%010s]" sprintf ] unit-test
[ "[####monkey]" ] [ "monkey" "[%'#10s]" sprintf ] unit-test
[ "[many monke]" ] [ "many monkeys" "[%10.10s]" sprintf ] unit-test

[ "{ 1, 2, 3 }" ] [ { 1 2 3 } "%[%s, %]" sprintf ] unit-test
[ "{ 1:2, 3:4 }" ] [ H{ { 1 2 } { 3 4 } } "%[%s: %s %]" sprintf ] unit-test


[ "%H:%M:%S" strftime ] must-infer

: testtime ( -- timestamp )
    2008 10 9 12 3 15 instant <timestamp> ;

[ t ] [ "12:03:15" testtime "%H:%M:%S" strftime = ] unit-test
[ t ] [ "12:03:15" testtime "%X" strftime = ] unit-test
[ t ] [ "10/09/2008" testtime "%m/%d/%Y" strftime = ] unit-test
[ t ] [ "10/09/2008" testtime "%x" strftime = ] unit-test
[ t ] [ "10/09/08" testtime "%m/%d/%y" strftime = ] unit-test
[ t ] [ "Thu" testtime "%a" strftime = ] unit-test
[ t ] [ "Thursday" testtime "%A" strftime = ] unit-test
[ t ] [ "Oct" testtime "%b" strftime = ] unit-test
[ t ] [ "October" testtime "%B" strftime = ] unit-test
[ t ] [ "Thu Oct 09 12:03:15 2008" testtime "%c" strftime = ] unit-test
[ t ] [ "PM" testtime "%p" strftime = ] unit-test
