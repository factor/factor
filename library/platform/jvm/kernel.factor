! :folding=indent:collapseFolds=1:

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

IN: kernel

: word ( -- word )
    ! Pushes most recently defined word.
    interpreter "factor.FactorInterpreter" "last" jvar-get ;

: inline ( -- )
    #! Marks the most recently defined word to be inlined.
    t word "factor.FactorWord" "inline" jvar-set ;

: interpret-only ( -- )
    #! Marks the most recently defined word as an interpret-only word;
    #! attempting to compile it will raise an error.
    t word "factor.FactorWord" "interpretOnly" jvar-set ;

: hashcode ( obj -- hashcode )
    #! If two objects are =, they must have equal hashcodes.
    [ ] "java.lang.Object" "hashCode" jinvoke ;

: eq? ( a b -- ? )
    #! Returns true if a and b are the same object.
    [ "java.lang.Object" "java.lang.Object" ]
    "factor.FactorLib" "eq" jinvoke-static ;

: = ( a b -- ? )
    #! Push t if a is isomorphic to b.
    [ "java.lang.Object" "java.lang.Object" ]
    "factor.FactorLib" "equal" jinvoke-static ;

: class-of ( obj -- class )
    [ ] "java.lang.Object" "getClass" jinvoke
    [ ] "java.lang.Class" "getName" jinvoke ;

: clone ( obj -- obj )
    [ ] "factor.PublicCloneable" "clone" jinvoke ;

: clone-array ( obj -- obj )
    [ [ "java.lang.Object" ] ]
    "factor.FactorLib" "cloneArray"
    jinvoke-static ;

: deep-clone-array ( obj -- obj )
    [ [ "java.lang.Object" ] ]
    "factor.FactorLib" "deepCloneArray"
    jinvoke-static ;

: is ( obj class -- boolean )
    ! Like "instanceof" in Java.
    [ "java.lang.Object" ] "java.lang.Class" "isInstance"
    jinvoke ;

: toplevel ( -- )
    interpreter
    [ ] "factor.FactorInterpreter" "topLevel" jinvoke ;

: exec ( args -- exitCode )
    [ [ "java.lang.String" ] ] "factor.FactorLib" "exec"
    jinvoke-static ;

: exit* ( code -- )
    [ "int" ] "java.lang.System" "exit" jinvoke-static ;

: garbage-collection ( -- )
    [ ] "java.lang.System" "gc" jinvoke-static ;

IN: arithmetic
DEFER: >bignum

IN: kernel

: millis ( -- millis )
    ! Pushes the current time, in milliseconds.
    [ ] "java.lang.System" "currentTimeMillis" jinvoke-static
    >bignum ;

: system-property ( name -- value )
    [ "java.lang.String" ] "java.lang.System" "getProperty"
    jinvoke-static ;

: java? t ;
: native? f ;
: version "factor.FactorInterpreter" "VERSION" jvar-static-get ;

: jvm-runtime ( -- java.lang.Runtime )
  #! Return the java.lang.Runtime object for the JVM
  f "java.lang.Runtime" "getRuntime" jinvoke-static ;

: free-memory ( -- int )
  #! Return the free memory in the JVM.
  jvm-runtime f "java.lang.Runtime" "freeMemory" jinvoke ;

: total-memory ( -- int )
  #! Return the total memory available to the JVM.
  jvm-runtime f "java.lang.Runtime" "totalMemory" jinvoke ;

: room free-memory total-memory ;
