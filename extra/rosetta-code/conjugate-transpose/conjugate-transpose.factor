! Copyright (c) 2012 Anonymous
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math.functions math.matrices sequences ;
IN: rosetta-code.conjugate-transpose

! https://rosettacode.org/wiki/Conjugate_transpose

! Suppose that a matrix M contains complex numbers. Then the
! conjugate transpose of M is a matrix MH containing the complex
! conjugates of the matrix transposition of M.

! This means that row j, column i of the conjugate transpose
! equals the complex conjugate of row i, column j of the original
! matrix.

! In the next list, M must also be a square matrix.

! A Hermitian matrix equals its own conjugate transpose: MH = M.

! A normal matrix is commutative in multiplication with its
! conjugate transpose: MHM = MMH.

! A unitary matrix has its inverse equal to its conjugate
! transpose: MH = M − 1. This is true iff MHM = In and iff MMH =
! In, where In is the identity matrix.

! Given some matrix of complex numbers, find its conjugate
! transpose. Also determine if it is a Hermitian matrix, normal
! matrix, or a unitary matrix.

: conj-t ( matrix -- conjugate-transpose )
    flip [ [ conjugate ] map ] map ;

: hermitian-matrix? ( matrix -- ? )
    dup conj-t = ;

: normal-matrix? ( matrix -- ? )
    dup conj-t [ mdot ] [ swap mdot ] 2bi = ;

: unitary-matrix? ( matrix -- ? )
    [ dup conj-t mdot ] [ length <identity-matrix> ] bi = ;
