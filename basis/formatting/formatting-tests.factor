! Copyright (C) 2008 John Benediktsson
! See https://factorcode.org/license.txt for BSD license
USING: calendar formatting kernel literals math math.functions
sequences strings system tools.test ;
IN: formatting.tests

{
    B{ 49 46 53 53 69 43 48 53 }
} [
    155000.0 B{ 0 } -1 3 B{ 69 0 } B{ 67 0 } (format-float)
] unit-test

{
    B{ 32 32 32 32 32 32 32 49 46 53 53 69 43 48 53 }
} [
    155000.0 B{ 0 } 15 3 B{ 69 0 } B{ 67 0 } (format-float)
] unit-test

! Missing locale
{ "" } [
    33.4 "" 4 4 "f" "missing" format-float
] unit-test

! Literal byte arrays are mutable, so (format-float) isn't foldable.
: trouble ( -- str ba )
    155000.0 B{ } -1 3 B{ 69 0 } [
        B{ 67 0 } (format-float) >string
    ] keep ;

{
    "1.55E+05"
    "1.550e+05"
} [
    trouble CHAR: e 0 rot set-nth trouble drop
] unit-test

[ "%s" printf ] must-infer
[ "%s" sprintf ] must-infer

{ "" } [ "" sprintf ] unit-test
{ "asdf" } [ "asdf" sprintf ] unit-test
{ "10" } [ 10 "%d" sprintf ] unit-test
{ "+10" } [ 10 "%+d" sprintf ] unit-test
{ "-10" } [ -10 "%d" sprintf ] unit-test
{ " 23" } [ 23 "% d" sprintf ] unit-test
{ "-23" } [ -23 "% d" sprintf ] unit-test
{ "  -10" } [ -10 "%5d" sprintf ] unit-test
{ "-0010" } [ -10 "%05d" sprintf ] unit-test
{ "+0010" } [ 10 "%+05d" sprintf ] unit-test
{ "123.456000" } [ 123.456 "%f" sprintf ] unit-test
{ "2.44" } [ 2.436 "%.2f" sprintf ] unit-test
{ "8.950" } [ 8.950179003580072 "%.3f" sprintf ] unit-test
{ "123.10" } [ 123.1 "%01.2f" sprintf ] unit-test
{ "1.2346" } [ 1.23456789 "%.4f" sprintf ] unit-test
{ "100000000000000000.50000" } [ 17 10^ 1/2 + "%20.5f" sprintf ] unit-test
{ "3.333333" } [ 3+1/3 "%f" sprintf ] unit-test
{ "3.666667" } [ 3+2/3 "%f" sprintf ] unit-test
{ "3.7" } [ 3+2/3 "%.1f" sprintf ] unit-test
{ "-3.7" } [ -3-2/3 "%.1f" sprintf ] unit-test
{ "-3.666667" } [ -3-2/3 "%f" sprintf ] unit-test
{ "-3.333333" } [ -3-1/3 "%f" sprintf ] unit-test
{ "3.14159265358979323846e+00" } [ 2646693125139304345 842468587426513207 / "%.20e" sprintf ] unit-test
{ "-0.500" } [ -1/2 "%.3f" sprintf ] unit-test
{ "0.010" } [ 1/100 "%.3f" sprintf ] unit-test
{ "100000000000000000000000.000000" } [ 23 10^ "%f" sprintf ] unit-test
{ "1.4" } [ 135/100 "%.1f" sprintf ] unit-test
{ "4" } [ 7/2 "%.0f" sprintf ] unit-test
{ "1" } [ 1.0 "%.0f" sprintf ] unit-test
{ "0.0e+00" } [ 0 "%.1e" sprintf ] unit-test
{ "  1.23" } [ 1.23456789 "%6.2f" sprintf ] unit-test
{ "001100" } [ 12 "%06b" sprintf ] unit-test
{ "==14" } [ 12 "%'=4o" sprintf ] unit-test
{ "foo: 1 bar: 2" } [ { 1 2 3 } "foo: %d bar: %s" vsprintf ] unit-test
{ "1.234000e+08" } [ 123400000 "%e" sprintf ] unit-test
{ "-1.234000e+08" } [ -123400000 "%e" sprintf ] unit-test
{ "1.234567e+08" } [ 123456700 "%e" sprintf ] unit-test
{ "3.625e+08" } [ 362525200 "%.3e" sprintf ] unit-test
{ "2.500000e-03" } [ 0.0025 "%e" sprintf ] unit-test
{ "2.500000E-03" } [ 0.0025 "%E" sprintf ] unit-test
{ "   1.0E+01" } [ 10 "%10.1E" sprintf ] unit-test
{ "  -1.0E+01" } [ -10 "%10.1E" sprintf ] unit-test
{ "  -1.0E+01" } [ -10 "%+10.1E" sprintf ] unit-test
{ "  +1.0E+01" } [ 10 "%+10.1E" sprintf ] unit-test
{ "-001.0E+01" } [ -10 "%+010.1E" sprintf ] unit-test
{ "+001.0E+01" } [ 10 "%+010.1E" sprintf ] unit-test
{ "+001.0E-01" } [ 0.1 "%+010.1E" sprintf ] unit-test
{ " e1" } [ 0xe1 "% x" sprintf ] unit-test
{ "+e1" } [ 0xe1 "%+x" sprintf ] unit-test
{ "-e1" } [ -0xe1 "% x" sprintf ] unit-test
{ "-e1" } [ -0xe1 "%+x" sprintf ] unit-test
{ "1.00000e+1000" } [ 1000 10^ "%.5e" sprintf ] unit-test
{ "1.00000e-1000" } [ -1000 10^ "%.5e" sprintf ] unit-test
{ t } [
    1000 10^ "%.5f" sprintf
    "1" ".00000" 1000 CHAR: 0 <string> glue =
] unit-test
{ t } [
    -1000 10^ "%.1004f" sprintf
    "0." "10000" 999 CHAR: 0 <string> glue =
] unit-test
{ "-1.00000e+1000" } [ 1000 10^ neg "%.5e" sprintf ] unit-test
{ "-1.00000e-1000" } [ -1000 10^ neg "%.5e" sprintf ] unit-test
{ t } [
    1000 10^ neg "%.5f" sprintf
    "-1" ".00000" 1000 CHAR: 0 <string> glue =
] unit-test
{ t } [
    -1000 10^ neg "%.1004f" sprintf
    "-0." "10000" 999 CHAR: 0 <string> glue =
] unit-test
{ "9007199254740991.0" } [ 53 2^ 1 - "%.1f" sprintf ] unit-test
{ "9007199254740992.0" } [ 53 2^ "%.1f" sprintf ] unit-test
{ "9007199254740993.0" } [ 53 2^ 1 + "%.1f" sprintf ] unit-test
{ "-9007199254740991.0" } [ 53 2^ 1 - neg "%.1f" sprintf ] unit-test
{ "-9007199254740992.0" } [ 53 2^ neg "%.1f" sprintf ] unit-test
{ "-9007199254740993.0" } [ 53 2^ 1 + neg "%.1f" sprintf ] unit-test
{ "987654321098765432" } [ 987654321098765432 "%d" sprintf ] unit-test
{ "987654321098765432.0" } [ 987654321098765432 "%.1f" sprintf ] unit-test
{ "987654321098765432" } [ 987654321098765432 "%.0f" sprintf ] unit-test
{ "9.8765432109876543200e+417" } [ 987654321098765432 10 400 ^ * "%.19e" sprintf ] unit-test
{ "9.876543210987654320e+417" } [ 987654321098765432 10 400 ^ * "%.18e" sprintf ] unit-test
{ "9.87654321098765432e+417" } [ 987654321098765432 10 400 ^ * "%.17e" sprintf ] unit-test
{ "9.8765432109876543e+417" } [ 987654321098765432 10 400 ^ * "%.16e" sprintf ] unit-test
{ "9.876543210987654e+417" } [ 987654321098765432 10 400 ^ * "%.15e" sprintf ] unit-test
{ "9.87654321098765e+417" } [ 987654321098765432 10 400 ^ * "%.14e" sprintf ] unit-test
{ "9.8765432109877e+417" } [ 987654321098765432 10 400 ^ * "%.13e" sprintf ] unit-test
{ "9.876543210988e+417" } [ 987654321098765432 10 400 ^ * "%.12e" sprintf ] unit-test
{ "9.87654321099e+417" } [ 987654321098765432 10 400 ^ * "%.11e" sprintf ] unit-test
{ "9.8765432110e+417" } [ 987654321098765432 10 400 ^ * "%.10e" sprintf ] unit-test
{ "9.876543211e+417" } [ 987654321098765432 10 400 ^ * "%.9e" sprintf ] unit-test
{ "9.87654321e+417" } [ 987654321098765432 10 400 ^ * "%.8e" sprintf ] unit-test
{ "9.8765432e+417" } [ 987654321098765432 10 400 ^ * "%.7e" sprintf ] unit-test
{ "9.876543e+417" } [ 987654321098765432 10 400 ^ * "%.6e" sprintf ] unit-test
{ "9.87654e+417" } [ 987654321098765432 10 400 ^ * "%.5e" sprintf ] unit-test
{ "9.8765e+417" } [ 987654321098765432 10 400 ^ * "%.4e" sprintf ] unit-test
{ "9.877e+417" } [ 987654321098765432 10 400 ^ * "%.3e" sprintf ] unit-test
{ "9.88e+417" } [ 987654321098765432 10 400 ^ * "%.2e" sprintf ] unit-test
{ "9.9e+417" } [ 987654321098765432 10 400 ^ * "%.1e" sprintf ] unit-test
! This works even on windows (even though %.0e is special on
! windows) because it doesn't use the fast formatter from the
! system
{ "1e+418" } [ 987654321098765432 10 400 ^ * "%.0e" sprintf ] unit-test
{ "9e+417" } [ 937654321098765432 10 400 ^ * "%.0e" sprintf ] unit-test
{ "1.0e+418" } [ 997654321098765432 10 400 ^ * "%.1e" sprintf ] unit-test
{ "1.00e+418" } [ 999654321098765432 10 400 ^ * "%.2e" sprintf ] unit-test

{ "ff" } [ 0xff "%x" sprintf ] unit-test
{ "FF" } [ 0xff "%X" sprintf ] unit-test
{ "0f" } [ 0xf "%02x" sprintf ] unit-test
{ "0F" } [ 0xf "%02X" sprintf ] unit-test
{ "2008-09-10" } [ 2008 9 10 "%04d-%02d-%02d" sprintf ] unit-test
{ "Hello, World!" } [ "Hello, World!" "%s" sprintf ] unit-test
{ "printf test" } [ "printf test" sprintf ] unit-test
{ "char a = 'a'" } [ CHAR: a "char %c = 'a'" sprintf ] unit-test
{ "00" } [ 0x0 "%02x" sprintf ] unit-test
{ "ff" } [ 0xff "%02x" sprintf ] unit-test
{ "0 message(s)" } [ 0 "message" "%d %s(s)" sprintf ] unit-test
{ "0 message(s) with %" } [ 0 "message" "%d %s(s) with %%" sprintf ] unit-test
{ "justif: \"left      \"" } [ "left" "justif: \"%-10s\"" sprintf ] unit-test
{ "justif: \"     right\"" } [ "right" "justif: \"%10s\"" sprintf ] unit-test
{ " 3: 0003 zero padded" } [ 3 " 3: %04d zero padded" sprintf ] unit-test
{ " 3: 3    left justif" } [ 3 " 3: %-4d left justif" sprintf ] unit-test
{ " 3:    3 right justif" } [ 3 " 3: %4d right justif" sprintf ] unit-test
{ " -3: -003 zero padded" } [ -3 " -3: %04d zero padded" sprintf ] unit-test
{ " -3: -3   left justif" } [ -3 " -3: %-4d left justif" sprintf ] unit-test
{ " -3:   -3 right justif" } [ -3 " -3: %4d right justif" sprintf ] unit-test
{ "There are 10 monkeys in the kitchen" } [ 10 "kitchen" "There are %d monkeys in the %s" sprintf ] unit-test
{ "10" } [ 10 "%d" sprintf ] unit-test
{ "[monkey]" } [ "monkey" "[%s]" sprintf ] unit-test
{ "[    monkey]" } [ "monkey" "[%10s]" sprintf ] unit-test
{ "[monkey    ]" } [ "monkey" "[%-10s]" sprintf ] unit-test
{ "[0000monkey]" } [ "monkey" "[%010s]" sprintf ] unit-test
{ "[####monkey]" } [ "monkey" "[%'#10s]" sprintf ] unit-test
{ "[many monke]" } [ "many monkeys" "[%10.10s]" sprintf ] unit-test

{ "{ 1, 2, 3 }" } [ BV{ 1 2 3 } "%[%d, %]" sprintf ] unit-test
{ "{ 1, 2, 3 }" } [ { 1 2 3 } "%[%s, %]" sprintf ] unit-test
{ "{ 1:2, 3:4 }" } [ H{ { 1 2 } { 3 4 } } "%[%s: %s %]" sprintf ] unit-test


[ "%H:%M:%S" strftime ] must-infer

: testtime ( -- timestamp )
    2008 10 9 12 3 15 instant <timestamp> ;

{ t } [ "12:03:15" testtime "%H:%M:%S" strftime = ] unit-test
{ t } [ "12:03:15" testtime "%X" strftime = ] unit-test
{ t } [ "10/09/2008" testtime "%m/%d/%Y" strftime = ] unit-test
{ t } [ "10/09/2008" testtime "%x" strftime = ] unit-test
{ t } [ "10/09/08" testtime "%m/%d/%y" strftime = ] unit-test
{ t } [ "Thu" testtime "%a" strftime = ] unit-test
{ t } [ "Thursday" testtime "%A" strftime = ] unit-test
{ t } [ "Oct" testtime "%b" strftime = ] unit-test
{ t } [ "October" testtime "%B" strftime = ] unit-test
{ t } [ "Thu Oct 09 12:03:15 2008" testtime "%c" strftime = ] unit-test
{ t } [ "PM" testtime "%p" strftime = ] unit-test

{ "1.2" } [ 125/100 "%.1f" sprintf ] unit-test
{ "2" } [ 5/2 "%.0f" sprintf ] unit-test
{ "2e+00" } [ 5/2 "%.0e" sprintf ] unit-test
{ "4e+00" } [ 7/2 "%.0e" sprintf ] unit-test
{ "1e+00" } [ 1.0 "%.0e" sprintf ] unit-test

{ "00" } [ 2020 1 1 <date> "%U" strftime ] unit-test
{ "00" } [ 2020 1 1 <date> "%W" strftime ] unit-test

{ "44" } [ 2020 11 6 <date> "%U" strftime ] unit-test
{ "44" } [ 2020 11 6 <date> "%W" strftime ] unit-test

{ "00" } [ 2022 1 1 <date> "%U" strftime ] unit-test
{ "01" } [ 2022 1 2 <date> "%U" strftime ] unit-test
{ "01" } [ 2022 1 3 <date> "%U" strftime ] unit-test

{ "00" } [ 2022 1 1 <date> "%W" strftime ] unit-test
{ "00" } [ 2022 1 2 <date> "%W" strftime ] unit-test
{ "01" } [ 2022 1 3 <date> "%W" strftime ] unit-test

{ "34" } [ 2022 8 27 <date> "%U" strftime ] unit-test
{ "35" } [ 2022 8 28 <date> "%U" strftime ] unit-test
{ "35" } [ 2022 8 29 <date> "%U" strftime ] unit-test

{ "34" } [ 2022 8 27 <date> "%W" strftime ] unit-test
{ "34" } [ 2022 8 28 <date> "%W" strftime ] unit-test
{ "35" } [ 2022 8 29 <date> "%W" strftime ] unit-test
