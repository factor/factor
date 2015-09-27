USING: kernel math.blas.matrices math.blas.vectors
sequences tools.test ;
IN: math.blas.matrices.tests

! clone

{ smatrix{
    { 1.0 2.0 3.0 }
    { 4.0 5.0 6.0 }
    { 7.0 8.0 9.0 }
} } [
    smatrix{
        { 1.0 2.0 3.0 }
        { 4.0 5.0 6.0 }
        { 7.0 8.0 9.0 }
    } clone
] unit-test
{ f } [
    smatrix{
        { 1.0 2.0 3.0 }
        { 4.0 5.0 6.0 }
        { 7.0 8.0 9.0 }
    } dup clone eq?
] unit-test

{ dmatrix{
    { 1.0 2.0 3.0 }
    { 4.0 5.0 6.0 }
    { 7.0 8.0 9.0 }
} } [
    dmatrix{
        { 1.0 2.0 3.0 }
        { 4.0 5.0 6.0 }
        { 7.0 8.0 9.0 }
    } clone
] unit-test
{ f } [
    dmatrix{
        { 1.0 2.0 3.0 }
        { 4.0 5.0 6.0 }
        { 7.0 8.0 9.0 }
    } dup clone eq?
] unit-test

{ cmatrix{
    { C{ 1.0 1.0 } 2.0          3.0          }
    { 4.0          C{ 5.0 2.0 } 6.0          }
    { 7.0          8.0          C{ 9.0 3.0 } }
} } [
    cmatrix{
        { C{ 1.0 1.0 } 2.0          3.0          }
        { 4.0          C{ 5.0 2.0 } 6.0          }
        { 7.0          8.0          C{ 9.0 3.0 } }
    } clone
] unit-test
{ f } [
    cmatrix{
        { C{ 1.0 1.0 } 2.0          3.0          }
        { 4.0          C{ 5.0 2.0 } 6.0          }
        { 7.0          8.0          C{ 9.0 3.0 } }
    } dup clone eq?
] unit-test

{ zmatrix{
    { C{ 1.0 1.0 } 2.0          3.0          }
    { 4.0          C{ 5.0 2.0 } 6.0          }
    { 7.0          8.0          C{ 9.0 3.0 } }
} } [
    zmatrix{
        { C{ 1.0 1.0 } 2.0          3.0          }
        { 4.0          C{ 5.0 2.0 } 6.0          }
        { 7.0          8.0          C{ 9.0 3.0 } }
    } clone
] unit-test
{ f } [
    zmatrix{
        { C{ 1.0 1.0 } 2.0          3.0          }
        { 4.0          C{ 5.0 2.0 } 6.0          }
        { 7.0          8.0          C{ 9.0 3.0 } }
    } dup clone eq?
] unit-test

! M.V

{ svector{ 3.0 1.0 6.0 } } [
    smatrix{
        {  0.0 1.0 0.0 1.0 }
        { -1.0 0.0 0.0 2.0 }
        {  0.0 0.0 1.0 3.0 }
    }
    svector{ 1.0 2.0 3.0 1.0 }
    M.V
] unit-test
{ svector{ -2.0 1.0 3.0 14.0 } } [
    smatrix{
        {  0.0 1.0 0.0 1.0 }
        { -1.0 0.0 0.0 2.0 }
        {  0.0 0.0 1.0 3.0 }
    } Mtranspose
    svector{ 1.0 2.0 3.0 }
    M.V
] unit-test

{ dvector{ 3.0 1.0 6.0 } } [
    dmatrix{
        {  0.0 1.0 0.0 1.0 }
        { -1.0 0.0 0.0 2.0 }
        {  0.0 0.0 1.0 3.0 }
    }
    dvector{ 1.0 2.0 3.0 1.0 }
    M.V
] unit-test
{ dvector{ -2.0 1.0 3.0 14.0 } } [
    dmatrix{
        {  0.0 1.0 0.0 1.0 }
        { -1.0 0.0 0.0 2.0 }
        {  0.0 0.0 1.0 3.0 }
    } Mtranspose
    dvector{ 1.0 2.0 3.0 }
    M.V
] unit-test

{ cvector{ 3.0 C{ 1.0 2.0 } 6.0 } } [
    cmatrix{
        {  0.0 1.0          0.0 1.0 }
        { -1.0 C{ 0.0 1.0 } 0.0 2.0 }
        {  0.0 0.0          1.0 3.0 }
    }
    cvector{ 1.0 2.0 3.0 1.0 }
    M.V
] unit-test
{ cvector{ -2.0 C{ 1.0 2.0 } 3.0 14.0 } } [
    cmatrix{
        {  0.0 1.0          0.0 1.0 }
        { -1.0 C{ 0.0 1.0 } 0.0 2.0 }
        {  0.0 0.0          1.0 3.0 }
    } Mtranspose
    cvector{ 1.0 2.0 3.0 }
    M.V
] unit-test

{ zvector{ 3.0 C{ 1.0 2.0 } 6.0 } } [
    zmatrix{
        {  0.0 1.0          0.0 1.0 }
        { -1.0 C{ 0.0 1.0 } 0.0 2.0 }
        {  0.0 0.0          1.0 3.0 }
    }
    zvector{ 1.0 2.0 3.0 1.0 }
    M.V
] unit-test
{ zvector{ -2.0 C{ 1.0 2.0 } 3.0 14.0 } } [
    zmatrix{
        {  0.0 1.0          0.0 1.0 }
        { -1.0 C{ 0.0 1.0 } 0.0 2.0 }
        {  0.0 0.0          1.0 3.0 }
    } Mtranspose
    zvector{ 1.0 2.0 3.0 }
    M.V
] unit-test

! V(*)

{ smatrix{
    { 1.0 2.0 3.0  4.0 }
    { 2.0 4.0 6.0  8.0 }
    { 3.0 6.0 9.0 12.0 }
} } [
    svector{ 1.0 2.0 3.0 } svector{ 1.0 2.0 3.0 4.0 } V(*)
] unit-test

{ dmatrix{
    { 1.0 2.0 3.0  4.0 }
    { 2.0 4.0 6.0  8.0 }
    { 3.0 6.0 9.0 12.0 }
} } [
    dvector{ 1.0 2.0 3.0 } dvector{ 1.0 2.0 3.0 4.0 } V(*)
] unit-test

{ cmatrix{
    { 1.0          2.0          C{ 3.0 -3.0 } 4.0            }
    { 2.0          4.0          C{ 6.0 -6.0 } 8.0            }
    { C{ 3.0 3.0 } C{ 6.0 6.0 } 18.0          C{ 12.0 12.0 } }
} } [
    cvector{ 1.0 2.0 C{ 3.0 3.0 } } cvector{ 1.0 2.0 C{ 3.0 -3.0 } 4.0 } V(*)
] unit-test

{ zmatrix{
    { 1.0          2.0          C{ 3.0 -3.0 } 4.0            }
    { 2.0          4.0          C{ 6.0 -6.0 } 8.0            }
    { C{ 3.0 3.0 } C{ 6.0 6.0 } 18.0          C{ 12.0 12.0 } }
} } [
    zvector{ 1.0 2.0 C{ 3.0 3.0 } } zvector{ 1.0 2.0 C{ 3.0 -3.0 } 4.0 } V(*)
] unit-test

! M.

{ smatrix{
    { 1.0 0.0  0.0 4.0  0.0 }
    { 0.0 0.0 -3.0 0.0  0.0 }
    { 0.0 4.0  0.0 0.0 10.0 }
    { 0.0 0.0  0.0 0.0  0.0 }
} } [
    smatrix{
        { 1.0 0.0  0.0 }
        { 0.0 0.0 -1.0 }
        { 0.0 2.0  0.0 }
        { 0.0 0.0  0.0 }
    } smatrix{
        { 1.0 0.0 0.0 4.0 0.0 }
        { 0.0 2.0 0.0 0.0 5.0 }
        { 0.0 0.0 3.0 0.0 0.0 }
    } M.
] unit-test

{ smatrix{
    { 1.0  0.0  0.0 0.0 }
    { 0.0  0.0  4.0 0.0 }
    { 0.0 -3.0  0.0 0.0 }
    { 4.0  0.0  0.0 0.0 }
    { 0.0  0.0 10.0 0.0 }
} } [
    smatrix{
        { 1.0 0.0 0.0 4.0 0.0 }
        { 0.0 2.0 0.0 0.0 5.0 }
        { 0.0 0.0 3.0 0.0 0.0 }
    } Mtranspose smatrix{
        { 1.0 0.0  0.0 }
        { 0.0 0.0 -1.0 }
        { 0.0 2.0  0.0 }
        { 0.0 0.0  0.0 }
    } Mtranspose M.
] unit-test

{ dmatrix{
    { 1.0 0.0  0.0 4.0  0.0 }
    { 0.0 0.0 -3.0 0.0  0.0 }
    { 0.0 4.0  0.0 0.0 10.0 }
    { 0.0 0.0  0.0 0.0  0.0 }
} } [
    dmatrix{
        { 1.0 0.0  0.0 }
        { 0.0 0.0 -1.0 }
        { 0.0 2.0  0.0 }
        { 0.0 0.0  0.0 }
    } dmatrix{
        { 1.0 0.0 0.0 4.0 0.0 }
        { 0.0 2.0 0.0 0.0 5.0 }
        { 0.0 0.0 3.0 0.0 0.0 }
    } M.
] unit-test

{ dmatrix{
    { 1.0  0.0  0.0 0.0 }
    { 0.0  0.0  4.0 0.0 }
    { 0.0 -3.0  0.0 0.0 }
    { 4.0  0.0  0.0 0.0 }
    { 0.0  0.0 10.0 0.0 }
} } [
    dmatrix{
        { 1.0 0.0 0.0 4.0 0.0 }
        { 0.0 2.0 0.0 0.0 5.0 }
        { 0.0 0.0 3.0 0.0 0.0 }
    } Mtranspose dmatrix{
        { 1.0 0.0  0.0 }
        { 0.0 0.0 -1.0 }
        { 0.0 2.0  0.0 }
        { 0.0 0.0  0.0 }
    } Mtranspose M.
] unit-test

{ cmatrix{
    { 1.0 0.0            0.0 4.0  0.0 }
    { 0.0 0.0           -3.0 0.0  0.0 }
    { 0.0 C{ 4.0 -4.0 }  0.0 0.0 10.0 }
    { 0.0 0.0            0.0 0.0  0.0 }
} } [
    cmatrix{
        { 1.0 0.0  0.0 }
        { 0.0 0.0 -1.0 }
        { 0.0 2.0  0.0 }
        { 0.0 0.0  0.0 }
    } cmatrix{
        { 1.0 0.0           0.0 4.0 0.0 }
        { 0.0 C{ 2.0 -2.0 } 0.0 0.0 5.0 }
        { 0.0 0.0           3.0 0.0 0.0 }
    } M.
] unit-test

{ cmatrix{
    { 1.0  0.0  0.0          0.0 }
    { 0.0  0.0 C{ 4.0 -4.0 } 0.0 }
    { 0.0 -3.0  0.0          0.0 }
    { 4.0  0.0  0.0          0.0 }
    { 0.0  0.0 10.0          0.0 }
} } [
    cmatrix{
        { 1.0 0.0           0.0 4.0 0.0 }
        { 0.0 C{ 2.0 -2.0 } 0.0 0.0 5.0 }
        { 0.0 0.0           3.0 0.0 0.0 }
    } Mtranspose cmatrix{
        { 1.0 0.0  0.0 }
        { 0.0 0.0 -1.0 }
        { 0.0 2.0  0.0 }
        { 0.0 0.0  0.0 }
    } Mtranspose M.
] unit-test

{ zmatrix{
    { 1.0 0.0            0.0 4.0  0.0 }
    { 0.0 0.0           -3.0 0.0  0.0 }
    { 0.0 C{ 4.0 -4.0 }  0.0 0.0 10.0 }
    { 0.0 0.0            0.0 0.0  0.0 }
} } [
    zmatrix{
        { 1.0 0.0  0.0 }
        { 0.0 0.0 -1.0 }
        { 0.0 2.0  0.0 }
        { 0.0 0.0  0.0 }
    } zmatrix{
        { 1.0 0.0           0.0 4.0 0.0 }
        { 0.0 C{ 2.0 -2.0 } 0.0 0.0 5.0 }
        { 0.0 0.0           3.0 0.0 0.0 }
    } M.
] unit-test

{ zmatrix{
    { 1.0  0.0  0.0          0.0 }
    { 0.0  0.0 C{ 4.0 -4.0 } 0.0 }
    { 0.0 -3.0  0.0          0.0 }
    { 4.0  0.0  0.0          0.0 }
    { 0.0  0.0 10.0          0.0 }
} } [
    zmatrix{
        { 1.0 0.0           0.0 4.0 0.0 }
        { 0.0 C{ 2.0 -2.0 } 0.0 0.0 5.0 }
        { 0.0 0.0           3.0 0.0 0.0 }
    } Mtranspose zmatrix{
        { 1.0 0.0  0.0 }
        { 0.0 0.0 -1.0 }
        { 0.0 2.0  0.0 }
        { 0.0 0.0  0.0 }
    } Mtranspose M.
] unit-test

! n*M

{ smatrix{
    { 2.0 0.0 }
    { 0.0 2.0 }
} } [
    2.0 smatrix{
        { 1.0 0.0 }
        { 0.0 1.0 }
    } n*M
] unit-test

{ dmatrix{
    { 2.0 0.0 }
    { 0.0 2.0 }
} } [
    2.0 dmatrix{
        { 1.0 0.0 }
        { 0.0 1.0 }
    } n*M
] unit-test

{ cmatrix{
    { C{ 2.0 1.0 } 0.0           }
    { 0.0          C{ -1.0 2.0 } }
} } [
    C{ 2.0 1.0 } cmatrix{
        { 1.0 0.0          }
        { 0.0 C{ 0.0 1.0 } }
    } n*M
] unit-test

{ zmatrix{
    { C{ 2.0 1.0 } 0.0           }
    { 0.0          C{ -1.0 2.0 } }
} } [
    C{ 2.0 1.0 } zmatrix{
        { 1.0 0.0          }
        { 0.0 C{ 0.0 1.0 } }
    } n*M
] unit-test

! Mrows, Mcols

{ svector{ 3.0 3.0 3.0 } } [
    2 smatrix{
        { 1.0 2.0 3.0 4.0 }
        { 2.0 2.0 3.0 4.0 }
        { 3.0 2.0 3.0 4.0 }
    } Mcols nth
] unit-test
{ svector{ 3.0 2.0 3.0 4.0 } } [
    2 smatrix{
        { 1.0 2.0 3.0 4.0 }
        { 2.0 2.0 3.0 4.0 }
        { 3.0 2.0 3.0 4.0 }
    } Mrows nth
] unit-test
{ 3 } [
    smatrix{
        { 1.0 2.0 3.0 4.0 }
        { 2.0 2.0 3.0 4.0 }
        { 3.0 2.0 3.0 4.0 }
    } Mrows length
] unit-test
{ 4 } [
    smatrix{
        { 1.0 2.0 3.0 4.0 }
        { 2.0 2.0 3.0 4.0 }
        { 3.0 2.0 3.0 4.0 }
    } Mcols length
] unit-test
{ svector{ 3.0 3.0 3.0 } } [
    2 smatrix{
        { 1.0 2.0 3.0 4.0 }
        { 2.0 2.0 3.0 4.0 }
        { 3.0 2.0 3.0 4.0 }
    } Mtranspose Mrows nth
] unit-test
{ svector{ 3.0 2.0 3.0 4.0 } } [
    2 smatrix{
        { 1.0 2.0 3.0 4.0 }
        { 2.0 2.0 3.0 4.0 }
        { 3.0 2.0 3.0 4.0 }
    } Mtranspose Mcols nth
] unit-test
{ 3 } [
    smatrix{
        { 1.0 2.0 3.0 4.0 }
        { 2.0 2.0 3.0 4.0 }
        { 3.0 2.0 3.0 4.0 }
    } Mtranspose Mcols length
] unit-test
{ 4 } [
    smatrix{
        { 1.0 2.0 3.0 4.0 }
        { 2.0 2.0 3.0 4.0 }
        { 3.0 2.0 3.0 4.0 }
    } Mtranspose Mrows length
] unit-test

{ dvector{ 3.0 3.0 3.0 } } [
    2 dmatrix{
        { 1.0 2.0 3.0 4.0 }
        { 2.0 2.0 3.0 4.0 }
        { 3.0 2.0 3.0 4.0 }
    } Mcols nth
] unit-test
{ dvector{ 3.0 2.0 3.0 4.0 } } [
    2 dmatrix{
        { 1.0 2.0 3.0 4.0 }
        { 2.0 2.0 3.0 4.0 }
        { 3.0 2.0 3.0 4.0 }
    } Mrows nth
] unit-test
{ 3 } [
    dmatrix{
        { 1.0 2.0 3.0 4.0 }
        { 2.0 2.0 3.0 4.0 }
        { 3.0 2.0 3.0 4.0 }
    } Mrows length
] unit-test
{ 4 } [
    dmatrix{
        { 1.0 2.0 3.0 4.0 }
        { 2.0 2.0 3.0 4.0 }
        { 3.0 2.0 3.0 4.0 }
    } Mcols length
] unit-test
{ dvector{ 3.0 3.0 3.0 } } [
    2 dmatrix{
        { 1.0 2.0 3.0 4.0 }
        { 2.0 2.0 3.0 4.0 }
        { 3.0 2.0 3.0 4.0 }
    } Mtranspose Mrows nth
] unit-test
{ dvector{ 3.0 2.0 3.0 4.0 } } [
    2 dmatrix{
        { 1.0 2.0 3.0 4.0 }
        { 2.0 2.0 3.0 4.0 }
        { 3.0 2.0 3.0 4.0 }
    } Mtranspose Mcols nth
] unit-test
{ 3 } [
    dmatrix{
        { 1.0 2.0 3.0 4.0 }
        { 2.0 2.0 3.0 4.0 }
        { 3.0 2.0 3.0 4.0 }
    } Mtranspose Mcols length
] unit-test
{ 4 } [
    dmatrix{
        { 1.0 2.0 3.0 4.0 }
        { 2.0 2.0 3.0 4.0 }
        { 3.0 2.0 3.0 4.0 }
    } Mtranspose Mrows length
] unit-test

{ cvector{ C{ 3.0 1.0 } C{ 3.0 2.0 } C{ 3.0 3.0 } } } [
    2 cmatrix{
        { C{ 1.0 1.0 } C{ 2.0 1.0 } C{ 3.0 1.0 } C{ 4.0 1.0 } }
        { C{ 1.0 2.0 } C{ 2.0 2.0 } C{ 3.0 2.0 } C{ 4.0 2.0 } }
        { C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } }
    } Mcols nth
] unit-test
{ cvector{ C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } } } [
    2 cmatrix{
        { C{ 1.0 1.0 } C{ 2.0 1.0 } C{ 3.0 1.0 } C{ 4.0 1.0 } }
        { C{ 1.0 2.0 } C{ 2.0 2.0 } C{ 3.0 2.0 } C{ 4.0 2.0 } }
        { C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } }
    } Mrows nth
] unit-test
{ 3 } [
    cmatrix{
        { C{ 1.0 1.0 } C{ 2.0 1.0 } C{ 3.0 1.0 } C{ 4.0 1.0 } }
        { C{ 1.0 2.0 } C{ 2.0 2.0 } C{ 3.0 2.0 } C{ 4.0 2.0 } }
        { C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } }
    } Mrows length
] unit-test
{ 4 } [
    cmatrix{
        { C{ 1.0 1.0 } C{ 2.0 1.0 } C{ 3.0 1.0 } C{ 4.0 1.0 } }
        { C{ 1.0 2.0 } C{ 2.0 2.0 } C{ 3.0 2.0 } C{ 4.0 2.0 } }
        { C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } }
    } Mcols length
] unit-test
{ cvector{ C{ 3.0 1.0 } C{ 3.0 2.0 } C{ 3.0 3.0 } } } [
    2 cmatrix{
        { C{ 1.0 1.0 } C{ 2.0 1.0 } C{ 3.0 1.0 } C{ 4.0 1.0 } }
        { C{ 1.0 2.0 } C{ 2.0 2.0 } C{ 3.0 2.0 } C{ 4.0 2.0 } }
        { C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } }
    } Mtranspose Mrows nth
] unit-test
{ cvector{ C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } } } [
    2 cmatrix{
        { C{ 1.0 1.0 } C{ 2.0 1.0 } C{ 3.0 1.0 } C{ 4.0 1.0 } }
        { C{ 1.0 2.0 } C{ 2.0 2.0 } C{ 3.0 2.0 } C{ 4.0 2.0 } }
        { C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } }
    } Mtranspose Mcols nth
] unit-test
{ 3 } [
    cmatrix{
        { C{ 1.0 1.0 } C{ 2.0 1.0 } C{ 3.0 1.0 } C{ 4.0 1.0 } }
        { C{ 1.0 2.0 } C{ 2.0 2.0 } C{ 3.0 2.0 } C{ 4.0 2.0 } }
        { C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } }
    } Mtranspose Mcols length
] unit-test
{ 4 } [
    cmatrix{
        { C{ 1.0 1.0 } C{ 2.0 1.0 } C{ 3.0 1.0 } C{ 4.0 1.0 } }
        { C{ 1.0 2.0 } C{ 2.0 2.0 } C{ 3.0 2.0 } C{ 4.0 2.0 } }
        { C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } }
    } Mtranspose Mrows length
] unit-test

{ zvector{ C{ 3.0 1.0 } C{ 3.0 2.0 } C{ 3.0 3.0 } } } [
    2 zmatrix{
        { C{ 1.0 1.0 } C{ 2.0 1.0 } C{ 3.0 1.0 } C{ 4.0 1.0 } }
        { C{ 1.0 2.0 } C{ 2.0 2.0 } C{ 3.0 2.0 } C{ 4.0 2.0 } }
        { C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } }
    } Mcols nth
] unit-test
{ zvector{ C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } } } [
    2 zmatrix{
        { C{ 1.0 1.0 } C{ 2.0 1.0 } C{ 3.0 1.0 } C{ 4.0 1.0 } }
        { C{ 1.0 2.0 } C{ 2.0 2.0 } C{ 3.0 2.0 } C{ 4.0 2.0 } }
        { C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } }
    } Mrows nth
] unit-test
{ 3 } [
    zmatrix{
        { C{ 1.0 1.0 } C{ 2.0 1.0 } C{ 3.0 1.0 } C{ 4.0 1.0 } }
        { C{ 1.0 2.0 } C{ 2.0 2.0 } C{ 3.0 2.0 } C{ 4.0 2.0 } }
        { C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } }
    } Mrows length
] unit-test
{ 4 } [
    zmatrix{
        { C{ 1.0 1.0 } C{ 2.0 1.0 } C{ 3.0 1.0 } C{ 4.0 1.0 } }
        { C{ 1.0 2.0 } C{ 2.0 2.0 } C{ 3.0 2.0 } C{ 4.0 2.0 } }
        { C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } }
    } Mcols length
] unit-test
{ zvector{ C{ 3.0 1.0 } C{ 3.0 2.0 } C{ 3.0 3.0 } } } [
    2 zmatrix{
        { C{ 1.0 1.0 } C{ 2.0 1.0 } C{ 3.0 1.0 } C{ 4.0 1.0 } }
        { C{ 1.0 2.0 } C{ 2.0 2.0 } C{ 3.0 2.0 } C{ 4.0 2.0 } }
        { C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } }
    } Mtranspose Mrows nth
] unit-test
{ zvector{ C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } } } [
    2 zmatrix{
        { C{ 1.0 1.0 } C{ 2.0 1.0 } C{ 3.0 1.0 } C{ 4.0 1.0 } }
        { C{ 1.0 2.0 } C{ 2.0 2.0 } C{ 3.0 2.0 } C{ 4.0 2.0 } }
        { C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } }
    } Mtranspose Mcols nth
] unit-test
{ 3 } [
    zmatrix{
        { C{ 1.0 1.0 } C{ 2.0 1.0 } C{ 3.0 1.0 } C{ 4.0 1.0 } }
        { C{ 1.0 2.0 } C{ 2.0 2.0 } C{ 3.0 2.0 } C{ 4.0 2.0 } }
        { C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } }
    } Mtranspose Mcols length
] unit-test
{ 4 } [
    zmatrix{
        { C{ 1.0 1.0 } C{ 2.0 1.0 } C{ 3.0 1.0 } C{ 4.0 1.0 } }
        { C{ 1.0 2.0 } C{ 2.0 2.0 } C{ 3.0 2.0 } C{ 4.0 2.0 } }
        { C{ 1.0 3.0 } C{ 2.0 3.0 } C{ 3.0 3.0 } C{ 4.0 3.0 } }
    } Mtranspose Mrows length
] unit-test

! Msub

{ smatrix{
    { 3.0 2.0 1.0 }
    { 0.0 1.0 0.0 }
} } [
    smatrix{
        { 0.0 1.0 2.0 3.0 2.0 }
        { 1.0 0.0 3.0 2.0 1.0 }
        { 2.0 3.0 0.0 1.0 0.0 }
    } 1 2 2 3 Msub
] unit-test

{ smatrix{
    { 3.0 0.0 }
    { 2.0 1.0 }
    { 1.0 0.0 }
} } [
    smatrix{
        { 0.0 1.0 2.0 3.0 2.0 }
        { 1.0 0.0 3.0 2.0 1.0 }
        { 2.0 3.0 0.0 1.0 0.0 }
    } Mtranspose 2 1 3 2 Msub
] unit-test

{ dmatrix{
    { 3.0 2.0 1.0 }
    { 0.0 1.0 0.0 }
} } [
    dmatrix{
        { 0.0 1.0 2.0 3.0 2.0 }
        { 1.0 0.0 3.0 2.0 1.0 }
        { 2.0 3.0 0.0 1.0 0.0 }
    } 1 2 2 3 Msub
] unit-test

{ dmatrix{
    { 3.0 0.0 }
    { 2.0 1.0 }
    { 1.0 0.0 }
} } [
    dmatrix{
        { 0.0 1.0 2.0 3.0 2.0 }
        { 1.0 0.0 3.0 2.0 1.0 }
        { 2.0 3.0 0.0 1.0 0.0 }
    } Mtranspose 2 1 3 2 Msub
] unit-test

{ cmatrix{
    { C{ 3.0 3.0 } 2.0 1.0 }
    { 0.0          1.0 0.0 }
} } [
    cmatrix{
        { 0.0 1.0 2.0          3.0 2.0 }
        { 1.0 0.0 C{ 3.0 3.0 } 2.0 1.0 }
        { 2.0 3.0 0.0          1.0 0.0 }
    } 1 2 2 3 Msub
] unit-test

{ cmatrix{
    { C{ 3.0 3.0 } 0.0 }
    { 2.0          1.0 }
    { 1.0          0.0 }
} } [
    cmatrix{
        { 0.0 1.0 2.0          3.0 2.0 }
        { 1.0 0.0 C{ 3.0 3.0 } 2.0 1.0 }
        { 2.0 3.0 0.0          1.0 0.0 }
    } Mtranspose 2 1 3 2 Msub
] unit-test

{ zmatrix{
    { C{ 3.0 3.0 } 2.0 1.0 }
    { 0.0          1.0 0.0 }
} } [
    zmatrix{
        { 0.0 1.0 2.0          3.0 2.0 }
        { 1.0 0.0 C{ 3.0 3.0 } 2.0 1.0 }
        { 2.0 3.0 0.0          1.0 0.0 }
    } 1 2 2 3 Msub
] unit-test

{ zmatrix{
    { C{ 3.0 3.0 } 0.0 }
    { 2.0          1.0 }
    { 1.0          0.0 }
} } [
    zmatrix{
        { 0.0 1.0 2.0          3.0 2.0 }
        { 1.0 0.0 C{ 3.0 3.0 } 2.0 1.0 }
        { 2.0 3.0 0.0          1.0 0.0 }
    } Mtranspose 2 1 3 2 Msub
] unit-test
