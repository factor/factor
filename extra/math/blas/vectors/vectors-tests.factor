USING: kernel math.blas.vectors math.functions sequences tools.test ;
IN: math.blas.vectors.tests

! clone

{ Svector{ 1.0 2.0 3.0 } } [ Svector{ 1.0 2.0 3.0 } clone ] unit-test
{ f } [ Svector{ 1.0 2.0 3.0 } dup clone eq? ] unit-test
{ Dvector{ 1.0 2.0 3.0 } } [ Dvector{ 1.0 2.0 3.0 } clone ] unit-test
{ f } [ Dvector{ 1.0 2.0 3.0 } dup clone eq? ] unit-test
{ Cvector{ 1.0 C{ 2.0 3.0 } 4.0 } } [ Cvector{ 1.0 C{ 2.0 3.0 } 4.0 } clone ] unit-test
{ f } [ Cvector{ 1.0 C{ 2.0 3.0 } 4.0 } dup clone eq? ] unit-test
{ Zvector{ 1.0 C{ 2.0 3.0 } 4.0 } } [ Zvector{ 1.0 C{ 2.0 3.0 } 4.0 } clone ] unit-test
{ f } [ Zvector{ 1.0 C{ 2.0 3.0 } 4.0 } dup clone eq? ] unit-test

! nth

{ 1.0 } [ 2 Svector{ 3.0 2.0 1.0 } nth ] unit-test
{ 1.0 } [ 2 Dvector{ 3.0 2.0 1.0 } nth ] unit-test

{ C{ 1.0 2.0 } }
[ 2 Cvector{ C{ -3.0 -2.0 } C{ -1.0 0.0 } C{ 1.0 2.0 } } nth ] unit-test

{ C{ 1.0 2.0 } }
[ 2 Zvector{ C{ -3.0 -2.0 } C{ -1.0 0.0 } C{ 1.0 2.0 } } nth ] unit-test

! set-nth

{ Svector{ 3.0 2.0 0.0 } } [ 0.0 2 Svector{ 3.0 2.0 1.0 } [ set-nth ] keep ] unit-test
{ Dvector{ 3.0 2.0 0.0 } } [ 0.0 2 Dvector{ 3.0 2.0 1.0 } [ set-nth ] keep ] unit-test

{ Cvector{ C{ -3.0 -2.0 } C{ -1.0 0.0 } C{ 3.0 4.0 } } } [
    C{ 3.0 4.0 } 2
    Cvector{ C{ -3.0 -2.0 } C{ -1.0 0.0 } C{ 1.0 2.0 } }
    [ set-nth ] keep
] unit-test
{ Zvector{ C{ -3.0 -2.0 } C{ -1.0 0.0 } C{ 3.0 4.0 } } } [
    C{ 3.0 4.0 } 2
    Zvector{ C{ -3.0 -2.0 } C{ -1.0 0.0 } C{ 1.0 2.0 } }
    [ set-nth ] keep
] unit-test

! V+

{ Svector{ 11.0 22.0 } } [ Svector{ 1.0 2.0 } Svector{ 10.0 20.0 } V+ ] unit-test
{ Dvector{ 11.0 22.0 } } [ Dvector{ 1.0 2.0 } Dvector{ 10.0 20.0 } V+ ] unit-test

{ Cvector{ 11.0 C{ 22.0 33.0 } } }
[ Cvector{ 1.0 C{ 2.0 3.0 } } Cvector{ 10.0 C{ 20.0 30.0 } } V+ ]
unit-test

{ Zvector{ 11.0 C{ 22.0 33.0 } } }
[ Zvector{ 1.0 C{ 2.0 3.0 } } Zvector{ 10.0 C{ 20.0 30.0 } } V+ ]
unit-test

! V-

{ Svector{ 9.0 18.0 } } [ Svector{ 10.0 20.0 } Svector{ 1.0 2.0 } V- ] unit-test
{ Dvector{ 9.0 18.0 } } [ Dvector{ 10.0 20.0 } Dvector{ 1.0 2.0 } V- ] unit-test

{ Cvector{ 9.0 C{ 18.0 27.0 } } }
[ Cvector{ 10.0 C{ 20.0 30.0 } } Cvector{ 1.0 C{ 2.0 3.0 } } V- ]
unit-test

{ Zvector{ 9.0 C{ 18.0 27.0 } } }
[ Zvector{ 10.0 C{ 20.0 30.0 } } Zvector{ 1.0 C{ 2.0 3.0 } } V- ]
unit-test

! Vneg

{ Svector{ 1.0 -2.0 } } [ Svector{ -1.0 2.0 } Vneg ] unit-test
{ Dvector{ 1.0 -2.0 } } [ Dvector{ -1.0 2.0 } Vneg ] unit-test

{ Cvector{ 1.0 C{ -2.0 3.0 } } } [ Cvector{ -1.0 C{ 2.0 -3.0 } } Vneg ] unit-test
{ Zvector{ 1.0 C{ -2.0 3.0 } } } [ Zvector{ -1.0 C{ 2.0 -3.0 } } Vneg ] unit-test

! n*V

{ Svector{ 100.0 200.0 } } [ 10.0 Svector{ 10.0 20.0 } n*V ] unit-test
{ Dvector{ 100.0 200.0 } } [ 10.0 Dvector{ 10.0 20.0 } n*V ] unit-test

{ Cvector{ C{ 20.0 4.0 } C{ 8.0 12.0 } } }
[ C{ 10.0 2.0 } Cvector{ 2.0 C{ 1.0 1.0 } } n*V ]
unit-test

{ Zvector{ C{ 20.0 4.0 } C{ 8.0 12.0 } } }
[ C{ 10.0 2.0 } Zvector{ 2.0 C{ 1.0 1.0 } } n*V ]
unit-test

! V*n

{ Svector{ 100.0 200.0 } } [ Svector{ 10.0 20.0 } 10.0 V*n ] unit-test
{ Dvector{ 100.0 200.0 } } [ Dvector{ 10.0 20.0 } 10.0 V*n ] unit-test

{ Cvector{ C{ 20.0 4.0 } C{ 8.0 12.0 } } }
[ Cvector{ 2.0 C{ 1.0 1.0 } } C{ 10.0 2.0 } V*n ]
unit-test

{ Zvector{ C{ 20.0 4.0 } C{ 8.0 12.0 } } }
[ Zvector{ 2.0 C{ 1.0 1.0 } } C{ 10.0 2.0 } V*n ]
unit-test

! V/n

{ Svector{ 1.0 2.0 } } [ Svector{ 4.0 8.0 } 4.0 V/n ] unit-test
{ Dvector{ 1.0 2.0 } } [ Dvector{ 4.0 8.0 } 4.0 V/n ] unit-test

{ Cvector{ C{ 0.0 -4.0 } 1.0 } }
[ Cvector{ C{ 4.0 -4.0 } C{ 1.0 1.0 } } C{ 1.0 1.0 } V/n ]
unit-test

{ Zvector{ C{ 0.0 -4.0 } 1.0 } }
[ Zvector{ C{ 4.0 -4.0 } C{ 1.0 1.0 } } C{ 1.0 1.0 } V/n ]
unit-test

! V.

{ 7.0 } [ Svector{ 1.0 2.5 } Svector{ 2.0 2.0 } V. ] unit-test
{ 7.0 } [ Dvector{ 1.0 2.5 } Dvector{ 2.0 2.0 } V. ] unit-test
{ C{ 7.0 7.0 } } [ Cvector{ C{ 1.0 1.0 } 2.5 } Cvector{ 2.0 C{ 2.0 2.0 } } V. ] unit-test
{ C{ 7.0 7.0 } } [ Zvector{ C{ 1.0 1.0 } 2.5 } Zvector{ 2.0 C{ 2.0 2.0 } } V. ] unit-test

! V.conj

{ C{ 7.0 3.0 } } [ Cvector{ C{ 1.0 1.0 } 2.5 } Cvector{ 2.0 C{ 2.0 2.0 } } V.conj ] unit-test
{ C{ 7.0 3.0 } } [ Zvector{ C{ 1.0 1.0 } 2.5 } Zvector{ 2.0 C{ 2.0 2.0 } } V.conj ] unit-test

! Vnorm

{ t } [ Svector{ 3.0 4.0 } Vnorm 5.0 0.000001 ~ ] unit-test
{ t } [ Dvector{ 3.0 4.0 } Vnorm 5.0 0.000001 ~ ] unit-test

{ t } [ Cvector{ C{ 3.0 4.0 } 12.0 } Vnorm 13.0 0.000001 ~ ] unit-test
{ t } [ Zvector{ C{ 3.0 4.0 } 12.0 } Vnorm 13.0 0.000001 ~ ] unit-test

! Vasum

{ 6.0 } [ Svector{ 1.0 2.0 -3.0 } Vasum ] unit-test
{ 6.0 } [ Dvector{ 1.0 2.0 -3.0 } Vasum ] unit-test

{ 15.0 } [ Cvector{ 1.0 C{ -2.0 3.0 } C{ 4.0 -5.0 } } Vasum ] unit-test
{ 15.0 } [ Zvector{ 1.0 C{ -2.0 3.0 } C{ 4.0 -5.0 } } Vasum ] unit-test

! Vswap

{ Svector{ 2.0 2.0 } Svector{ 1.0 1.0 } }
[ Svector{ 1.0 1.0 } Svector{ 2.0 2.0 } Vswap ]
unit-test

{ Dvector{ 2.0 2.0 } Dvector{ 1.0 1.0 } }
[ Dvector{ 1.0 1.0 } Dvector{ 2.0 2.0 } Vswap ]
unit-test

{ Cvector{ 2.0 C{ 2.0 2.0 } } Cvector{ C{ 1.0 1.0 } 1.0 } }
[ Cvector{ C{ 1.0 1.0 } 1.0 } Cvector{ 2.0 C{ 2.0 2.0 } } Vswap ]
unit-test

{ Zvector{ 2.0 C{ 2.0 2.0 } } Zvector{ C{ 1.0 1.0 } 1.0 } }
[ Zvector{ C{ 1.0 1.0 } 1.0 } Zvector{ 2.0 C{ 2.0 2.0 } } Vswap ]
unit-test

! Viamax

{ 3 } [ Svector{ 1.0 -5.0 4.0 -6.0 -1.0 } Viamax ] unit-test
{ 3 } [ Dvector{ 1.0 -5.0 4.0 -6.0 -1.0 } Viamax ] unit-test
{ 0 } [ Cvector{ C{ 2.0 -5.0 } 4.0 -6.0 -1.0 } Viamax ] unit-test
{ 0 } [ Zvector{ C{ 2.0 -5.0 } 4.0 -6.0 -1.0 } Viamax ] unit-test

! Vamax

{ -6.0 } [ Svector{ 1.0 -5.0 4.0 -6.0 -1.0 } Vamax ] unit-test
{ -6.0 } [ Dvector{ 1.0 -5.0 4.0 -6.0 -1.0 } Vamax ] unit-test
{ C{ 2.0 -5.0 } } [ Cvector{ C{ 2.0 -5.0 } 4.0 -6.0 -1.0 } Vamax ] unit-test
{ C{ 2.0 -5.0 } } [ Zvector{ C{ 2.0 -5.0 } 4.0 -6.0 -1.0 } Vamax ] unit-test

! Vsub

{ Svector{ -5.0 4.0 -6.0 } } [ Svector{ 1.0 -5.0 4.0 -6.0 -1.0 } 1 3 Vsub ] unit-test
{ Dvector{ -5.0 4.0 -6.0 } } [ Dvector{ 1.0 -5.0 4.0 -6.0 -1.0 } 1 3 Vsub ] unit-test
{ Cvector{ -5.0 C{ 4.0 3.0 } -6.0 } } [ Cvector{ 1.0 -5.0 C{ 4.0 3.0 } -6.0 -1.0 } 1 3 Vsub ] unit-test
{ Zvector{ -5.0 C{ 4.0 3.0 } -6.0 } } [ Zvector{ 1.0 -5.0 C{ 4.0 3.0 } -6.0 -1.0 } 1 3 Vsub ] unit-test
