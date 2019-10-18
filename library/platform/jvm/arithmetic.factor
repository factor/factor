! :folding=indent:collapseFolds=0:

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

IN: arithmetic
USE: combinators
USE: kernel
USE: logic
USE: stack

: + ( a b -- a+b )
    [ "java.lang.Number" "java.lang.Number" ]
    "factor.math.FactorMath" "add"
    jinvoke-static ; inline

: - ( a b -- a-b )
    [ "java.lang.Number" "java.lang.Number" ]
    "factor.math.FactorMath" "subtract"
    jinvoke-static ; inline

: * ( a b -- a*b )
    [ "java.lang.Number" "java.lang.Number" ]
    "factor.math.FactorMath" "multiply"
    jinvoke-static ; inline

: / ( a b -- a/b )
    [ "java.lang.Number" "java.lang.Number" ]
    "factor.math.FactorMath" "divide"
    jinvoke-static ; inline

: mod ( a b -- a%b )
    [ "java.lang.Number" "java.lang.Number" ]
    "factor.math.FactorMath" "mod"
    jinvoke-static ; inline

: /mod ( a b -- a/b a%b )
    2dup / >fixnum -rot mod ;

: > ( a b -- boolean )
    [ "java.lang.Number" "java.lang.Number" ]
    "factor.math.FactorMath" "greater"
    jinvoke-static ; inline

: >= ( a b -- boolean )
    [ "java.lang.Number" "java.lang.Number" ]
    "factor.math.FactorMath" "greaterEqual"
    jinvoke-static ; inline

: < ( a b -- boolean )
    [ "java.lang.Number" "java.lang.Number" ]
    "factor.math.FactorMath" "less"
    jinvoke-static ; inline

: <= ( a b -- boolean )
    [ "java.lang.Number" "java.lang.Number" ]
    "factor.math.FactorMath" "lessEqual"
    jinvoke-static ; inline

: >=< ( x y obj1 obj2 obj3 -- obj )
    ! If x > y, pushes obj1, if x = y, pushes obj2, else obj3.
    [
        "float" "float"
        "java.lang.Object" "java.lang.Object"  "java.lang.Object"
    ]
    "factor.FactorLib" "branch3" jinvoke-static ;

: bitand ( x y -- x&y )
    #! Bitwise and.
    [ "java.lang.Number" "java.lang.Number" ]
    "factor.math.FactorMath" "and"
    jinvoke-static ; inline

: bitor ( x y -- x|y )
    #! Bitwise or.
    [ "java.lang.Number" "java.lang.Number" ]
    "factor.math.FactorMath" "or"
    jinvoke-static ; inline

: bitxor ( x y -- x^y )
    #! Bitwise exclusive or.
    [ "java.lang.Number" "java.lang.Number" ]
    "factor.math.FactorMath" "xor"
    jinvoke-static ; inline

: bitnot ( x -- ~x )
    #! Bitwise complement.
    [ "java.lang.Number" ]
    "factor.math.FactorMath" "not"
    jinvoke-static ; inline

: shift< ( x by -- )
    #! Shift 'by' bits to the left.
    [ "java.lang.Number" "int" ]
    "factor.math.FactorMath" "shiftLeft"
    jinvoke-static ; inline

: shift> ( x by -- )
    #! Shift 'by' bits to the right.
    [ "java.lang.Number" "int" ]
    "factor.math.FactorMath" "shiftRight"
    jinvoke-static ; inline

: shift>> ( x by -- )
    #! Shift 'by' bits to the right, without performing sign
    #! extension.
    [ "java.lang.Number" "int" ]
    "factor.math.FactorMath" "shiftRightUnsigned"
    jinvoke-static ; inline

: rem ( x y -- remainder )
    [ "double" "double" ] "java.lang.Math" "IEEEremainder"
    jinvoke-static ; inline

: gcd ( a b -- c )
    [ "java.lang.Number" "java.lang.Number" ]
    "factor.math.FactorMath" "gcd" jinvoke-static ;
