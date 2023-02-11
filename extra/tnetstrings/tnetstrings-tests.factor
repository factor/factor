! Copyright (C) 2011 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: kernel tnetstrings sequences tools.test ;

{ t } [
    {
        { H{ } "0:}" }
        { { } "0:]" }
        { "" "0:\"" }
        { t "4:true!" }
        { f "5:false!" }
        { 12345 "5:12345#" }
        { "this is cool" "12:this is cool\"" }
        {
            H{ { "hello" { 12345678901 "this" } } }
            "34:5:hello\"22:11:12345678901#4:this\"]}"
        }
        {
            { 12345 67890 "xxxxx" }
            "24:5:12345#5:67890#5:xxxxx\"]"
        }
    } [
        first2 [ tnetstring> = ] [ swap >tnetstring = ] 2bi and
    ] all?
] unit-test
