USING: kernel math.blas.vectors math.functions sequences system tools.test ;

! disable on linux-x86-32
os linux? cpu x86.32? and [

! clone

{ svector{ 1.0 2.0 3.0 } } [ svector{ 1.0 2.0 3.0 } clone ] unit-test
{ f } [ svector{ 1.0 2.0 3.0 } dup clone eq? ] unit-test
{ dvector{ 1.0 2.0 3.0 } } [ dvector{ 1.0 2.0 3.0 } clone ] unit-test
{ f } [ dvector{ 1.0 2.0 3.0 } dup clone eq? ] unit-test
{ cvector{ 1.0 C{ 2.0 3.0 } 4.0 } } [ cvector{ 1.0 C{ 2.0 3.0 } 4.0 } clone ] unit-test
{ f } [ cvector{ 1.0 C{ 2.0 3.0 } 4.0 } dup clone eq? ] unit-test
{ zvector{ 1.0 C{ 2.0 3.0 } 4.0 } } [ zvector{ 1.0 C{ 2.0 3.0 } 4.0 } clone ] unit-test
{ f } [ zvector{ 1.0 C{ 2.0 3.0 } 4.0 } dup clone eq? ] unit-test

! nth

{ 1.0 } [ 2 svector{ 3.0 2.0 1.0 } nth ] unit-test
{ 1.0 } [ 2 dvector{ 3.0 2.0 1.0 } nth ] unit-test

{ C{ 1.0 2.0 } }
[ 2 cvector{ C{ -3.0 -2.0 } C{ -1.0 0.0 } C{ 1.0 2.0 } } nth ] unit-test

{ C{ 1.0 2.0 } }
[ 2 zvector{ C{ -3.0 -2.0 } C{ -1.0 0.0 } C{ 1.0 2.0 } } nth ] unit-test

! set-nth

{ svector{ 3.0 2.0 0.0 } } [ 0.0 2 svector{ 3.0 2.0 1.0 } [ set-nth ] keep ] unit-test
{ dvector{ 3.0 2.0 0.0 } } [ 0.0 2 dvector{ 3.0 2.0 1.0 } [ set-nth ] keep ] unit-test

{ cvector{ C{ -3.0 -2.0 } C{ -1.0 0.0 } C{ 3.0 4.0 } } } [
    C{ 3.0 4.0 } 2
    cvector{ C{ -3.0 -2.0 } C{ -1.0 0.0 } C{ 1.0 2.0 } }
    [ set-nth ] keep
] unit-test
{ zvector{ C{ -3.0 -2.0 } C{ -1.0 0.0 } C{ 3.0 4.0 } } } [
    C{ 3.0 4.0 } 2
    zvector{ C{ -3.0 -2.0 } C{ -1.0 0.0 } C{ 1.0 2.0 } }
    [ set-nth ] keep
] unit-test

! V+

{ svector{ 11.0 22.0 } } [ svector{ 1.0 2.0 } svector{ 10.0 20.0 } V+ ] unit-test
{ dvector{ 11.0 22.0 } } [ dvector{ 1.0 2.0 } dvector{ 10.0 20.0 } V+ ] unit-test

{ cvector{ 11.0 C{ 22.0 33.0 } } }
[ cvector{ 1.0 C{ 2.0 3.0 } } cvector{ 10.0 C{ 20.0 30.0 } } V+ ]
unit-test

{ zvector{ 11.0 C{ 22.0 33.0 } } }
[ zvector{ 1.0 C{ 2.0 3.0 } } zvector{ 10.0 C{ 20.0 30.0 } } V+ ]
unit-test

! V-

{ svector{ 9.0 18.0 } } [ svector{ 10.0 20.0 } svector{ 1.0 2.0 } V- ] unit-test
{ dvector{ 9.0 18.0 } } [ dvector{ 10.0 20.0 } dvector{ 1.0 2.0 } V- ] unit-test

{ cvector{ 9.0 C{ 18.0 27.0 } } }
[ cvector{ 10.0 C{ 20.0 30.0 } } cvector{ 1.0 C{ 2.0 3.0 } } V- ]
unit-test

{ zvector{ 9.0 C{ 18.0 27.0 } } }
[ zvector{ 10.0 C{ 20.0 30.0 } } zvector{ 1.0 C{ 2.0 3.0 } } V- ]
unit-test

! Vneg

{ svector{ 1.0 -2.0 } } [ svector{ -1.0 2.0 } Vneg ] unit-test
{ dvector{ 1.0 -2.0 } } [ dvector{ -1.0 2.0 } Vneg ] unit-test

{ cvector{ 1.0 C{ -2.0 3.0 } } } [ cvector{ -1.0 C{ 2.0 -3.0 } } Vneg ] unit-test
{ zvector{ 1.0 C{ -2.0 3.0 } } } [ zvector{ -1.0 C{ 2.0 -3.0 } } Vneg ] unit-test

! n*V

{ svector{ 100.0 200.0 } } [ 10.0 svector{ 10.0 20.0 } n*V ] unit-test
{ dvector{ 100.0 200.0 } } [ 10.0 dvector{ 10.0 20.0 } n*V ] unit-test

{ cvector{ C{ 20.0 4.0 } C{ 8.0 12.0 } } }
[ C{ 10.0 2.0 } cvector{ 2.0 C{ 1.0 1.0 } } n*V ]
unit-test

{ zvector{ C{ 20.0 4.0 } C{ 8.0 12.0 } } }
[ C{ 10.0 2.0 } zvector{ 2.0 C{ 1.0 1.0 } } n*V ]
unit-test

! V*n

{ svector{ 100.0 200.0 } } [ svector{ 10.0 20.0 } 10.0 V*n ] unit-test
{ dvector{ 100.0 200.0 } } [ dvector{ 10.0 20.0 } 10.0 V*n ] unit-test

{ cvector{ C{ 20.0 4.0 } C{ 8.0 12.0 } } }
[ cvector{ 2.0 C{ 1.0 1.0 } } C{ 10.0 2.0 } V*n ]
unit-test

{ zvector{ C{ 20.0 4.0 } C{ 8.0 12.0 } } }
[ zvector{ 2.0 C{ 1.0 1.0 } } C{ 10.0 2.0 } V*n ]
unit-test

! V/n

{ svector{ 1.0 2.0 } } [ svector{ 4.0 8.0 } 4.0 V/n ] unit-test
{ dvector{ 1.0 2.0 } } [ dvector{ 4.0 8.0 } 4.0 V/n ] unit-test

{ cvector{ C{ 0.0 -4.0 } 1.0 } }
[ cvector{ C{ 4.0 -4.0 } C{ 1.0 1.0 } } C{ 1.0 1.0 } V/n ]
unit-test

{ zvector{ C{ 0.0 -4.0 } 1.0 } }
[ zvector{ C{ 4.0 -4.0 } C{ 1.0 1.0 } } C{ 1.0 1.0 } V/n ]
unit-test

! V.

{ 7.0 } [ svector{ 1.0 2.5 } svector{ 2.0 2.0 } V. ] unit-test
{ 7.0 } [ dvector{ 1.0 2.5 } dvector{ 2.0 2.0 } V. ] unit-test
{ C{ 7.0 7.0 } } [ cvector{ C{ 1.0 1.0 } 2.5 } cvector{ 2.0 C{ 2.0 2.0 } } V. ] unit-test
{ C{ 7.0 7.0 } } [ zvector{ C{ 1.0 1.0 } 2.5 } zvector{ 2.0 C{ 2.0 2.0 } } V. ] unit-test

! V.conj

{ C{ 7.0 3.0 } } [ cvector{ C{ 1.0 1.0 } 2.5 } cvector{ 2.0 C{ 2.0 2.0 } } V.conj ] unit-test
{ C{ 7.0 3.0 } } [ zvector{ C{ 1.0 1.0 } 2.5 } zvector{ 2.0 C{ 2.0 2.0 } } V.conj ] unit-test

! Vnorm

{ t } [ svector{ 3.0 4.0 } Vnorm 5.0 0.000001 ~ ] unit-test
{ t } [ dvector{ 3.0 4.0 } Vnorm 5.0 0.000001 ~ ] unit-test

{ t } [ cvector{ C{ 3.0 4.0 } 12.0 } Vnorm 13.0 0.000001 ~ ] unit-test
{ t } [ zvector{ C{ 3.0 4.0 } 12.0 } Vnorm 13.0 0.000001 ~ ] unit-test

! Vasum

{ 6.0 } [ svector{ 1.0 2.0 -3.0 } Vasum ] unit-test
{ 6.0 } [ dvector{ 1.0 2.0 -3.0 } Vasum ] unit-test

{ 15.0 } [ cvector{ 1.0 C{ -2.0 3.0 } C{ 4.0 -5.0 } } Vasum ] unit-test
{ 15.0 } [ zvector{ 1.0 C{ -2.0 3.0 } C{ 4.0 -5.0 } } Vasum ] unit-test

! Vswap

{ svector{ 2.0 2.0 } svector{ 1.0 1.0 } }
[ svector{ 1.0 1.0 } svector{ 2.0 2.0 } Vswap ]
unit-test

{ dvector{ 2.0 2.0 } dvector{ 1.0 1.0 } }
[ dvector{ 1.0 1.0 } dvector{ 2.0 2.0 } Vswap ]
unit-test

{ cvector{ 2.0 C{ 2.0 2.0 } } cvector{ C{ 1.0 1.0 } 1.0 } }
[ cvector{ C{ 1.0 1.0 } 1.0 } cvector{ 2.0 C{ 2.0 2.0 } } Vswap ]
unit-test

{ zvector{ 2.0 C{ 2.0 2.0 } } zvector{ C{ 1.0 1.0 } 1.0 } }
[ zvector{ C{ 1.0 1.0 } 1.0 } zvector{ 2.0 C{ 2.0 2.0 } } Vswap ]
unit-test

! Viamax

{ 3 } [ svector{ 1.0 -5.0 4.0 -6.0 -1.0 } Viamax ] unit-test
{ 3 } [ dvector{ 1.0 -5.0 4.0 -6.0 -1.0 } Viamax ] unit-test
{ 0 } [ cvector{ C{ 2.0 -5.0 } 4.0 -6.0 -1.0 } Viamax ] unit-test
{ 0 } [ zvector{ C{ 2.0 -5.0 } 4.0 -6.0 -1.0 } Viamax ] unit-test

! Vamax

{ -6.0 } [ svector{ 1.0 -5.0 4.0 -6.0 -1.0 } Vamax ] unit-test
{ -6.0 } [ dvector{ 1.0 -5.0 4.0 -6.0 -1.0 } Vamax ] unit-test
{ C{ 2.0 -5.0 } } [ cvector{ C{ 2.0 -5.0 } 4.0 -6.0 -1.0 } Vamax ] unit-test
{ C{ 2.0 -5.0 } } [ zvector{ C{ 2.0 -5.0 } 4.0 -6.0 -1.0 } Vamax ] unit-test

! Vsub

{ svector{ -5.0 4.0 -6.0 } } [ svector{ 1.0 -5.0 4.0 -6.0 -1.0 } 1 3 Vsub ] unit-test
{ dvector{ -5.0 4.0 -6.0 } } [ dvector{ 1.0 -5.0 4.0 -6.0 -1.0 } 1 3 Vsub ] unit-test
{ cvector{ -5.0 C{ 4.0 3.0 } -6.0 } } [ cvector{ 1.0 -5.0 C{ 4.0 3.0 } -6.0 -1.0 } 1 3 Vsub ] unit-test
{ zvector{ -5.0 C{ 4.0 3.0 } -6.0 } } [ zvector{ 1.0 -5.0 C{ 4.0 3.0 } -6.0 -1.0 } 1 3 Vsub ] unit-test

] unless
