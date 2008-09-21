! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: kernel printf tools.test ;

[ "%s" printf ] must-infer 

[ "%s" sprintf ] must-infer

[ t ] [ "10" 10 "%d" sprintf = ] unit-test

[ t ] [ "+10" 10 "%+d" sprintf = ] unit-test

[ t ] [ "-10" -10 "%d" sprintf = ] unit-test

[ t ] [ "  -10" -10 "%5d" sprintf = ] unit-test

[ t ] [ "-0010" -10 "%05d" sprintf = ] unit-test

[ t ] [ "+0010" 10 "%+05d" sprintf = ] unit-test

[ t ] [ "123.456" 123.456 "%f" sprintf = ] unit-test

[ t ] [ "123.10" 123.1 "%01.2f" sprintf = ] unit-test

[ t ] [ "1.2345" 1.23456789 "%.4f" sprintf = ] unit-test

[ t ] [ "  1.23" 1.23456789 "%6.2f" sprintf = ] unit-test

[ t ] [ "1.234e+08" 123400000 "%e" sprintf = ] unit-test

[ t ] [ "-1.234e+08" -123400000 "%e" sprintf = ] unit-test

[ t ] [ "1.234567e+08" 123456700 "%e" sprintf = ] unit-test

[ t ] [ "3.625e+08" 362525200 "%.3e" sprintf = ] unit-test

[ t ] [ "2.5e-03" 0.0025 "%e" sprintf = ] unit-test

[ t ] [ "2.5E-03" 0.0025 "%E" sprintf = ] unit-test

[ t ] [ "   1.0E+01" 10 "%10.1E" sprintf = ] unit-test

[ t ] [ "  -1.0E+01" -10 "%10.1E" sprintf = ] unit-test

[ t ] [ "  -1.0E+01" -10 "%+10.1E" sprintf = ] unit-test

[ t ] [ "  +1.0E+01" 10 "%+10.1E" sprintf = ] unit-test

[ t ] [ "-001.0E+01" -10 "%+010.1E" sprintf = ] unit-test

[ t ] [ "+001.0E+01" 10 "%+010.1E" sprintf = ] unit-test

[ t ] [ "ff" HEX: ff "%x" sprintf = ] unit-test

[ t ] [ "FF" HEX: ff "%X" sprintf = ] unit-test

[ t ] [ "0f" HEX: f "%02x" sprintf = ] unit-test

[ t ] [ "0F" HEX: f "%02X" sprintf = ] unit-test

[ t ] [ "2008-09-10" 
        2008 9 10 "%04d-%02d-%02d" sprintf = ] unit-test

[ t ] [ "Hello, World!" 
        "Hello, World!" "%s" sprintf = ] unit-test

[ t ] [ "printf test" 
        "printf test" sprintf = ] unit-test

[ t ] [ "char a = 'a'"
        CHAR: a "char %c = 'a'" sprintf = ] unit-test

[ t ] [ "00" HEX: 0 "%02x" sprintf = ] unit-test

[ t ] [ "ff" HEX: ff "%02x" sprintf = ] unit-test

[ t ] [ "0 message(s)"
        0 "message" "%d %s(s)" sprintf = ] unit-test

[ t ] [ "0 message(s) with %"
        0 "message" "%d %s(s) with %%" sprintf = ] unit-test

[ t ] [ "justif: \"left      \""
        "left" "justif: \"%-10s\"" sprintf = ] unit-test

[ t ] [ "justif: \"     right\""
        "right" "justif: \"%10s\"" sprintf = ] unit-test

[ t ] [ " 3: 0003 zero padded" 
        3 " 3: %04d zero padded" sprintf = ] unit-test

[ t ] [ " 3: 3    left justif" 
        3 " 3: %-4d left justif" sprintf = ] unit-test

[ t ] [ " 3:    3 right justif" 
        3 " 3: %4d right justif" sprintf = ] unit-test

[ t ] [ " -3: -003 zero padded"
        -3 " -3: %04d zero padded" sprintf = ] unit-test

[ t ] [ " -3: -3   left justif"
        -3 " -3: %-4d left justif" sprintf = ] unit-test

[ t ] [ " -3:   -3 right justif"
        -3 " -3: %4d right justif" sprintf = ] unit-test

[ t ] [ "There are 10 monkeys in the kitchen" 
        10 "kitchen" "There are %d monkeys in the %s" sprintf = ] unit-test

[ f ] [ "%d" 10 "%d" sprintf = ] unit-test

[ t ] [ "[monkey]" "monkey" "[%s]" sprintf = ] unit-test

[ t ] [ "[    monkey]" "monkey" "[%10s]" sprintf = ] unit-test

[ t ] [ "[monkey    ]" "monkey" "[%-10s]" sprintf = ] unit-test

[ t ] [ "[0000monkey]" "monkey" "[%010s]" sprintf = ] unit-test

[ t ] [ "[####monkey]" "monkey" "[%'#10s]" sprintf = ] unit-test

[ t ] [ "[many monke]" "many monkeys" "[%10.10s]" sprintf = ] unit-test



