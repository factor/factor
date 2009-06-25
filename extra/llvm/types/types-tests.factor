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

[ t ] [ TYPE: i32 ; TYPE: i32 ; [ >tref ] bi@ = ] unit-test
[ t ] [ TYPE: i32 * ; TYPE: i32 * ; [ >tref ] bi@ = ] unit-test