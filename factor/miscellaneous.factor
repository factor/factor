!:folding=indent:collapseFolds=1:

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

: = (a b -- boolean)
    ! Returns true if a = b.
    [ "java.lang.Object" "java.lang.Object" ]
    "factor.FactorLib" "equal" jinvoke-static ;

: class-of ( obj -- class )
    [ ] "java.lang.Object" "getClass" jinvoke ;

: clone (obj -- obj)
    [ ] "factor.PublicCloneable" "clone" jinvoke ;

: cloneArray (obj -- obj)
    [ [ "java.lang.Object" ] ]
    "factor.FactorLib" "cloneArray"
    jinvoke-static ;

: deepCloneArray (obj -- obj)
    [ [ "java.lang.Object" ] ]
    "factor.FactorLib" "deepCloneArray"
    jinvoke-static ;

: is ( obj class -- boolean )
    ! Like "instanceof" in Java.
    [ "java.lang.Object" ] "java.lang.Class" "isInstance"
    jinvoke ;

: not= (a b -- boolean)
    = not ;

: 2= (a b c d -- boolean)
    ! Returns true if a = c, b = d.
    swapd = [ = ] dip and ;

: >=< (x y obj1 obj2 obj3 -- obj)
    ! If x > y, pushes obj1, if x = y, pushes obj2, else obj3.
    [
        "float" "float"
        "java.lang.Object" "java.lang.Object"  "java.lang.Object"
    ]
    "factor.FactorLib" "branch3" jinvoke-static ;

: error (msg --)
    [ "java.lang.String" ] "factor.FactorLib" "error" jinvoke-static ;

: exit* (code --)
    [ |int ] |java.lang.System |exit jinvoke-static ;

: millis (-- millis)
    ! Pushes the current time, in milliseconds.
    [ ] |java.lang.System |currentTimeMillis jinvoke-static
    >bignum ;

: stack? ( obj -- ? )
    "factor.FactorArrayStack" is ;

: stack>list (stack -- list)
    ! Turns a callstack or datastack object into a list.
    [ ] "factor.FactorArrayStack" "toList" jinvoke ;

: system-property ( name -- value )
    [ "java.lang.String" ] "java.lang.System" "getProperty"
    jinvoke-static ;

: time (code --)
    ! Evaluates the given code and prints the time taken to execute it.
    millis >r call millis r> - . ;
