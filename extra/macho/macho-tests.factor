! Copyright (C) 2010 Erik Charlebois.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien io io.streams.string kernel literals macho
multiline sequences strings system tools.test ;
IN: macho.tests

STRING: validation-output
0000000100000f1c __stub_helper    stub helpers
0000000100001040 __program_vars  _pvars
0000000100001068 __data          _NXArgc
0000000100001070 __data          _NXArgv
0000000100001080 __data          ___progname
0000000100000000                 __mh_execute_header
0000000100001078 __data          _environ
0000000100000ef8 __text          _main
0000000100000ebc __text          start
0000000000000000                 ___gxx_personality_v0
0000000000000000                 _exit
0000000000000000                 _printf
0000000000000000                 dyld_stub_binder

;

cpu ppc? [
    { $ validation-output }
    [ [ "resource:extra/macho/a.macho" macho-nm ] with-string-writer ]
    unit-test

    { t } [
        "resource:extra/macho/a2.macho" [
            >c-ptr fat-binary-members first data>> >c-ptr macho-header 64-bit?
        ] with-mapped-macho
    ] unit-test
] unless

! Throw an exception if the struct is not defined/handled
os macosx? [
    { } [ vm-path dylib-exports drop ] unit-test
] when
