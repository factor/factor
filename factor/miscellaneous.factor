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

: >str (obj -- string)
    ! Returns the Java string representation of this object.
    [ ] "java.lang.Object" "toString" jmethod jinvoke ;

: = (a b -- boolean)
    ! Returns true if a = b.
    [ "java.lang.Object" "java.lang.Object" ]
    "factor.FactorLib" "equal" jmethod jinvokeStatic ;

: clone (obj -- obj)
    [ ] "factor.PublicCloneable" "clone" jmethod jinvoke ;

: cloneArray (obj -- obj)
    [ "[Ljava.lang.Object;" ] "factor.FactorLib" "cloneArray"
    jmethod jinvokeStatic ;

: deepCloneArray (obj -- obj)
    [ "[Ljava.lang.Object;" ] "factor.FactorLib" "deepCloneArray"
    jmethod jinvokeStatic ;

: is (obj class -- boolean)
    ! Like "instanceof" in Java.
    [ "java.lang.Object" ] "java.lang.Class" "isInstance"
    jmethod jinvoke ;

: not= (a b -- boolean)
    = not ;

: 2= (a b c d -- boolean)
    ! Returns true if a = c, b = d.
    swapd = [ = ] dip and ;

: ? (cond obj1 obj2 -- obj)
    ! Pushes obj1 if cond is true, obj2 if cond is false.
    [ "boolean" "java.lang.Object" "java.lang.Object" ]
    "factor.FactorLib" "branch2" jmethod jinvokeStatic ;

: >=< (x y obj1 obj2 obj3 -- obj)
    ! If x > y, pushes obj1, if x = y, pushes obj2, else obj3.
    [
        "float" "float"
        "java.lang.Object" "java.lang.Object"  "java.lang.Object"
    ]
    "factor.FactorLib" "branch3" jmethod jinvokeStatic ;

: error (msg --)
    [ "java.lang.String" ] "factor.FactorLib" "error" jmethod jinvokeStatic ;

: exit* (code --)
    [ |int ] |java.lang.System |exit jmethod jinvokeStatic ;

: exit (--)
    0 exit* ;

: millis (-- millis)
    ! Pushes the current time, in milliseconds.
    [ ] |java.lang.System |currentTimeMillis jmethod jinvokeStatic
    >bignum ;

: stack>list (stack -- list)
    ! Turns a callstack or datastack object into a list.
    [ ] "factor.FactorArrayStack" "toList" jmethod jinvoke ;

: time (code --)
    ! Evaluates the given code and prints the time taken to execute it.
    millis swap dip millis -- . ;
