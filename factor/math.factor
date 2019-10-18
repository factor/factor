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

: 0= (x -- boolean)
    0 = ; inline

: 0>f ( obj -- obj )
    ! If 0 a the top of the stack, turn it into f.
    dup 0 = [ drop f ] when ;

: 1= (x -- boolean)
    1 = ; inline

: 2^ ( x -- 2^x )
    1 swap [ 2 * ] times ;

: number? (obj -- boolean)
    "java.lang.Number" is ; inline

: fixnum? (obj -- boolean)
    "java.lang.Integer" is ; inline

: >fixnum (num -- fixnum)
    [ ] "java.lang.Number" "intValue" jinvoke ; inline

: bignum? (obj -- boolean)
    "java.math.BigInteger" is ; inline

: >bignum (num -- bignum)
    [ ] "java.lang.Number" "longValue" jinvoke
    [ "long" ] "java.math.BigInteger" "valueOf" jinvoke-static
    ; inline

: integer? ( obj -- ? )
    dup fixnum? swap bignum? or ; inline

: realnum? (obj -- boolean)
    dup  "java.lang.Float"  is
    swap "java.lang.Double" is or ; inline

: >realnum (num -- realnum)
    [ ] "java.lang.Number" "doubleValue" jinvoke ; inline

: ratio? (obj -- boolean)
    "factor.FactorRatio" is ; inline

: + (a b -- a+b)
    [ "java.lang.Number" "java.lang.Number" ]
    "factor.FactorMath" "add"
    jinvoke-static ; inline

: v+ ( A B -- A+B )
    [ + ] 2map ;

: +@ (num var --)
    dup [ $ + ] dip @ ;

: - (a b -- a-b)
    [ "java.lang.Number" "java.lang.Number" ]
    "factor.FactorMath" "subtract"
    jinvoke-static ; inline

: v- ( A B -- A-B )
    [ - ] 2map ;

: -@ (num var --)
    dup [ $ swap - ] dip @ ;

: * (a b -- a*b)
    [ "java.lang.Number" "java.lang.Number" ]
    "factor.FactorMath" "multiply"
    jinvoke-static ; inline

: v* ( A B -- A*B )
    [ * ] 2map ;

: v. ( A B -- A.B )
    ! Dot product.
    v* 0 swap [ + ] each ;

: *@ (num var --)
    dup [ $ * ] dip @ ;

: / (a b -- a/b)
    [ "java.lang.Number" "java.lang.Number" ]
    "factor.FactorMath" "divide"
    jinvoke-static ; inline

: v/ ( A B -- A/B )
    [ / ] 2map ;

: /@ (num var --)
    dup [ $ / ] dip @ ;

: > (a b -- boolean)
    [ "float" "float" ] "factor.FactorMath" "greater"
    jinvoke-static ; inline

: >= (a b -- boolean)
    [ "float" "float" ] "factor.FactorMath" "greaterEqual"
    jinvoke-static ; inline

: < (a b -- boolean)
    [ "float" "float" ] "factor.FactorMath" "less"
    jinvoke-static ; inline

: <= (a b -- boolean)
    [ "float" "float" ] "factor.FactorMath" "lessEqual"
    jinvoke-static ; inline

: and (a b -- a&b)
    f ? ; inline

: break-if-not-integer ( x -- )
    integer? [
        "Not a rational: " swap cat2 error
    ] unless ;

: denominator ( x/y -- x )
    dup ratio? [
        "factor.FactorRatio" "denominator" jvar$
    ] [
        break-if-not-integer 1
    ] ifte ;

: gcd ( a b -- c )
    [ "java.lang.Number" "java.lang.Number" ]
    "factor.FactorMath" "gcd" jinvoke-static ;

: logand ( x y -- x&y )
    #! Bitwise and.
    [ "java.lang.Number" "java.lang.Number" ]
    "factor.FactorMath" "and"
    jinvoke-static ; inline

: mag2 ( x y -- mag )
    #! Returns the magnitude of the vector (x,y).
    [ sq ] 2apply + sqrt ;

: max ( x y -- z )
    2dup > -rot ? ;

: min ( x y -- z )
    2dup < -rot ? ;

: neg (x -- -x)
    [ "java.lang.Number" ] "factor.FactorMath" "neg"
    jinvoke-static ; inline

: neg@ (var --)
    dup $ 0 swap - s@ ;

: not (a -- a)
    ! Pushes f is the object is not f, t if the object is f.
    f t ? ; inline

: not@ (boolean -- boolean)
    dup $ not s@ ;

: numerator ( x/y -- x )
    dup ratio? [
        "factor.FactorRatio" "numerator" jvar$
    ] [
        dup break-if-not-integer
    ] ifte ;

: pow ( x y -- x^y )
    [ "double" "double" ] "java.lang.Math" "pow" jinvoke-static
    ; inline

: pred (n -- n-1)
    1 - ; inline

: succ (n -- nsucc)
    1 + ; inline

: pred@ (var --)
    dup $ pred s@ ;

: or (a b -- a|b)
    t swap ? ; inline

: recip (x -- 1/x)
    1 swap / ;

: rem ( x y -- remainder )
    [ "double" "double" ] "java.lang.Math" "IEEEremainder"
    jinvoke-static ; inline

: round ( x to -- y )
    dupd rem - ;

: sq (x -- x^2)
    dup * ; inline

: sqrt (x -- sqrt x)
    [ "double" ] "java.lang.Math" "sqrt" jinvoke-static ; inline

: succ@ (var --)
    dup $ succ s@ ;

: deg2rad (degrees -- radians)
    $pi * 180 / ;

: rad2deg (radians -- degrees)
    180 * $pi / ;

: fib (n -- nth fibonacci number)
    ! This is the naive implementation, for benchmarking purposes.
    dup 1 <= [
        drop 1
    ] [
        pred dup fib swap pred fib +
    ] ifte ;

: fac (n -- n!)
    ! This is the naive implementation, for benchmarking purposes.
    1 swap [ succ * ] times* ;

: harmonic (n -- 1 + 1/2 + 1/3 + ... + 1/n)
    0 swap [ succ recip + ] times* ;
