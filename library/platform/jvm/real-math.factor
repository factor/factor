!:folding=indent:collapseFolds=0:

! $Id$
!
! Copyright (C) 2003, 2004 Slava Pestov.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

!!! This file defines words that call methods in the
!!! java.lang.Math class. These work with real arguments only,
!!! and should not be called directly, use the words in the
!!! 'math' vocabulary instead.

IN: real-math
USE: arithmetic
USE: kernel
USE: stack

: fabs ( x -- abs )
    [ "double" ] "java.lang.Math" "abs"
    jinvoke-static ; inline

: facos ( x -- acos )
    [ "double" ] "java.lang.Math" "acos"
    jinvoke-static ; inline

: fasin ( x -- asin )
    [ "double" ] "java.lang.Math" "asin"
    jinvoke-static ; inline

: fatan ( x -- atan )
    [ "double" ] "java.lang.Math" "atan"
    jinvoke-static ; inline

: fatan2 ( x y -- atan2 )
    [ "double" "double" ] "java.lang.Math" "atan2"
    jinvoke-static ; inline

: fcos ( x -- cos )
    [ "double" ] "java.lang.Math" "cos"
    jinvoke-static ; inline

: fexp ( x -- exp )
    [ "double" ] "java.lang.Math" "exp"
    jinvoke-static ; inline

: fcosh ( x -- cosh )
    fexp dup recip + 2 / ;

: flog ( x -- exp )
    [ "double" ] "java.lang.Math" "log"
    jinvoke-static ; inline

: fpow ( x y -- x^y )
    [ "double" "double" ] "java.lang.Math" "pow"
    jinvoke-static ; inline

: fsin ( x -- sin )
    [ "double" ] "java.lang.Math" "sin"
    jinvoke-static ; inline

: fsinh ( x -- cosh )
    fexp dup recip - 2 / ;

: fsqrt ( x -- sqrt x )
    [ "double" ] "java.lang.Math" "sqrt"
    jinvoke-static ; inline
