! Copyright (C) 2009 Matthew Willis.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel llvm.types sequences tools.test ;

[ T{ integer f 32 }  ] [ " i32 " parse-type ] unit-test
[ float ] [ " float " parse-type ] unit-test
[ T{ pointer f f x86_fp80 } ] [ " x86_fp80 * " parse-type ] unit-test
[ T{ vector f f 4 T{ integer f 32 } } ] [ " < 4 x i32 > " parse-type ] unit-test
[ T{ struct f f { float double } f } ] [ TYPE: { float , double } ; ] unit-test
[ T{ array f f 0 float } ] [ TYPE: [ 0 x float ] ; ] unit-test

[ label void metadata ]
[ [ " label " " void " " metadata " ] [ parse-type ] each ] unit-test

[ T{ function f f float { float float } t } ]
[ TYPE: float ( float , float , ... ) ; ] unit-test

[ T{ struct f f { float TYPE: i32 (i32)* ; } t } ]
[ TYPE: < { float, i32 (i32)* } > ; ] unit-test

[ t ] [ TYPE: i32 ; TYPE: i32 ; [ >tref ] same? ] unit-test
[ t ] [ TYPE: i32 * ; TYPE: i32 * ; [ >tref ] same? ] unit-test

[ TYPE: i32 ; ] [ TYPE: i32 ; >tref tref> ] unit-test
[ TYPE: float ; ] [ TYPE: float ; >tref tref> ] unit-test
[ TYPE: double ; ] [ TYPE: double ; >tref tref> ] unit-test
[ TYPE: x86_fp80 ; ] [ TYPE: x86_fp80 ; >tref tref> ] unit-test
[ TYPE: fp128 ; ] [ TYPE: fp128 ; >tref tref> ] unit-test
[ TYPE: ppc_fp128 ; ] [ TYPE: ppc_fp128 ; >tref tref> ] unit-test
[ TYPE: opaque ; ] [ TYPE: opaque ; >tref tref> ] unit-test
[ TYPE: label ; ] [ TYPE: label ; >tref tref> ] unit-test
[ TYPE: void ; ] [ TYPE: void ; >tref tref> ] unit-test
[ TYPE: i32* ; ] [ TYPE: i32* ; >tref tref> ] unit-test
[ TYPE: < 2 x i32 > ; ] [ TYPE: < 2 x i32 > ; >tref tref> ] unit-test
[ TYPE: [ 0 x i32 ] ; ] [ TYPE: [ 0 x i32 ] ; >tref tref> ] unit-test
[ TYPE: { i32, i32 } ; ] [ TYPE: { i32, i32 } ; >tref tref> ] unit-test
[ TYPE: < { i32, i32 } > ; ] [ TYPE: < { i32, i32 } > ; >tref tref> ] unit-test
[ TYPE: i32 ( i32 ) ; ] [ TYPE: i32 ( i32 ) ; >tref tref> ] unit-test
[ TYPE: \1* ; ] [ TYPE: \1* ; >tref tref> ] unit-test
[ TYPE: { i32, \2* } ; ] [ TYPE: { i32, \2* } ; >tref tref> ] unit-test
