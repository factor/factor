! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: kernel printf tools.test ;

[ t ] [ "10" [ "%d" { 10 } sprintf ] call = ] unit-test

[ t ] [ "123.456" [ "%f" { 123.456 } sprintf ] call = ] unit-test

[ t ] [ "123.10" [ "%01.2f" { 123.1 } sprintf ] call = ] unit-test

[ t ] [ "1.2345" [ "%.4f" { 1.23456789 } sprintf ] call = ] unit-test

[ t ] [ "  1.23" [ "%6.2f" { 1.23456789 } sprintf ] call = ] unit-test

[ t ] [ "3.625e+8" [ "%.3e" { 362525200 } sprintf ] call = ] unit-test

[ t ] [ "2008-09-10" 
      [ "%04d-%02d-%02d" { 2008 9 10 } sprintf ] call = ] unit-test

[ t ] [ "Hello, World!" 
      [ "%s" { "Hello, World!" } sprintf ] call = ] unit-test

[ t ] [ "printf test" 
      [ "printf test" { } sprintf ] call = ] unit-test

[ t ] [ "char a = 'a'"
      [ "char %c = 'a'" { CHAR: a } sprintf ] call = ] unit-test

[ t ] [ "00" [ "%02x" { HEX: 0 } sprintf ] call = ] unit-test

[ t ] [ "ff" [ "%02x" { HEX: ff } sprintf ] call = ] unit-test

[ t ] [ "signed -3 = unsigned 4294967293 = hex fffffffd"
      [ "signed %d = unsigned %u = hex %x" { -3 -3 -3 } sprintf ] call = ] unit-test

[ t ] [ "0 message(s)"
      [ "%d %s(s)%" { 0 "message" } sprintf ] call = ] unit-test

[ t ] [ "0 message(s) with %"
      [ "%d %s(s) with %%" { 0 "message" } sprintf ] call = ] unit-test

[ t ] [ "justif: \"left      \""
      [ "justif: \"%-10s\"" { "left" } sprintf ] call = ] unit-test

[ t ] [ "justif: \"     right\""
      [ "justif: \"%10s\"" { "right" } sprintf ] call = ] unit-test

[ t ] [ " 3: 0003 zero padded" 
      [ " 3: %04d zero padded" { 3 } sprintf ] call = ] unit-test

[ t ] [ " 3: 3    left justif" 
      [ " 3: %-4d left justif" { 3 } sprintf ] call = ] unit-test

[ t ] [ " 3:    3 right justif" 
      [ " 3: %4d right justif" { 3 } sprintf ] call = ] unit-test

[ t ] [ " -3: -003 zero padded"
      [ " -3: %04d zero padded" { -3 } sprintf ] call = ] unit-test

[ t ] [ " -3: -3   left justif"
      [ " -3: %-4d left justif" { -3 } sprintf ] call = ] unit-test

[ t ] [ " -3:   -3 right justif"
      [ " -3: %4d right justif" { -3 } sprintf ] call = ] unit-test

[ t ] [ "There are 10 monkeys in the kitchen" 
      [ "There are %d monkeys in the %s" { 10 "kitchen" } sprintf ] call = ] unit-test

[ f ] [ "%d" [ "%d" 10 sprintf ] call = ] unit-test

[ t ] [ "[monkey]" [ "[%s]" { "monkey" } sprintf ] call = ] unit-test
[ t ] [ "[    monkey]" [ "[%10s]" { "monkey" } sprintf ] call = ] unit-test
[ t ] [ "[monkey    ]" [ "[%-10s]" { "monkey" } sprintf ] call = ] unit-test
[ t ] [ "[0000monkey]" [ "[%010s]" { "monkey" } sprintf ] call = ] unit-test
[ t ] [ "[####monkey]" [ "[%'#10s]" { "monkey" } sprintf ] call = ] unit-test
[ t ] [ "[many monke]" [ "[%10.10s]" { "many monkeys" } sprintf ] call = ] unit-test


