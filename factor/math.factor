!:folding=indent:collapseFolds=0:

! $Id$
!
! Copyright (C) 2003 Slava Pestov.
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

: 0= (x -- boolean)
    0 = ;

: 1= (x -- boolean)
    1 = ;

: fixnum? (obj -- boolean)
    "java.lang.Integer" is ;

: >fixnum (num -- fixnum)
    [ ] "java.lang.Number" "intValue" jmethod jinvoke ;

: bignum? (obj -- boolean)
    "java.math.BigInteger" is ;

: >bignum (num -- bignum)
    [ ] "java.lang.Number" "longValue" jmethod jinvoke
    [ "long" ] "java.math.BigInteger" "valueOf" jmethod jinvokeStatic ;

: realnum? (obj -- boolean)
    dup  "java.lang.Float"  is
    swap "java.lang.Double" is or ;

: >realnum (num -- realnum)
    [ ] "java.lang.Number" "doubleValue" jmethod jinvoke ;

: ratio? (obj -- boolean)
    "factor.FactorRatio" is ;

: + (a b -- a+b)
    [ "java.lang.Number" "java.lang.Number" ] "factor.FactorMath" "add"
    jmethod jinvokeStatic ;

: +@ (num var --)
    dup [ $ + ] dip @ ;

: - (a b -- a-b)
    [ "java.lang.Number" "java.lang.Number" ] "factor.FactorMath" "subtract"
    jmethod jinvokeStatic ;

: -@ (num var --)
    dup [ $ -- ] dip @ ;

: -- (a b -- b-a)
    swap - ;

: --@ (var num --)
    [ dup $ - ] dip s@ ;

: * (a b -- a*b)
    [ "java.lang.Number" "java.lang.Number" ] "factor.FactorMath" "multiply"
    jmethod jinvokeStatic ;

: *@ (num var --)
    dup [ $ * ] dip @ ;

: / (a b -- a/b)
    [ "java.lang.Number" "java.lang.Number" ] "factor.FactorMath" "divide"
    jmethod jinvokeStatic ;

: /@ (num var --)
    dup [ $ / ] dip @ ;

: // (a b -- b/a)
    swap / ;

: //@ (num var --)
    [ dup $ / ] dip s@ ;

: > (a b -- boolean)
    [ "float" "float" ] "factor.FactorMath" "greater" jmethod jinvokeStatic ;

: >= (a b -- boolean)
    [ "float" "float" ] "factor.FactorMath" "greaterEqual" jmethod jinvokeStatic ;

: < (a b -- boolean)
    [ "float" "float" ] "factor.FactorMath" "less" jmethod jinvokeStatic ;

: <= (a b -- boolean)
    [ "float" "float" ] "factor.FactorMath" "lessEqual" jmethod jinvokeStatic ;

: and (a b -- a&b)
    f ? ;

: mag2 (x y -- mag)
    ! Returns the magnitude of the vector (x,y).
    sq swap sq + sqrt ;

: neg (x -- -x)
    0 swap - ;

: neg@ (var --)
    dup $ 0 swap - s@ ;

: not (a -- a)
    ! Pushes f is the object is not f, t if the object is f.
    f t ? ;

: not@ (boolean -- boolean)
    dup $ not s@ ;

: pred (n -- n-1)
    1 - ;

: succ (n -- nsucc)
    1 + ;

: pred@ (var --)
    dup $ 1 - s@ ;

: or (a b -- a|b)
    t swap ? ;

: recip (x -- 1/x)
    1 // ;

: sq (x -- x^2)
    dup * ;

: sqrt (x -- sqrt x)
    [ "double" ] "java.lang.Math" "sqrt" jmethod jinvokeStatic ;

: succ@ (var --)
    dup $ 1 + s@ ;

: deg2rad (degrees -- radians)
    $pi * 180 / ;

: rad2deg (radians -- degrees)
    180 * $pi / ;

: fib (n -- nth fibonacci number)
    ! This is the naive implementation, for benchmarking purposes.
    [ dup 1 <= ] [ ] [ pred dup pred ] [ + ] binrec ;

: fac (n -- n!)
    ! This is the naive implementation, for benchmarking purposes.
    1 swap [ succ * ] times* ;

: harmonic (n -- 1 + 1/2 + 1/3 + ... + 1/n)
    0 swap [ succ recip + ] times* ;

2.7182818284590452354 @e
3.14159265358979323846 @pi

1.0 0.0 / @inf
-1.0 0.0 / @-inf
