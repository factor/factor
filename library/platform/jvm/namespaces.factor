! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004 Slava Pestov.
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

IN: namespaces
USE: combinators
USE: kernel
USE: lists
USE: logic
USE: stack
USE: strings
USE: vectors

DEFER: namespace

: namestack* ( -- stack )
    #! Push the namespace stack.
    interpreter
    "factor.FactorInterpreter" "namestack" jvar-get ; inline

: set-namestack* ( stack -- )
    #! Set the namespace stack.
    interpreter
    "factor.FactorInterpreter" "namestack" jvar-set ; inline

: >n ( namespace -- n:namespace )
    #! Push a namespace on the namespace stack.
    namestack* vector-push ; inline

: n> ( n:namespace -- namespace )
    #! Pop the top of the namespace stack.
    namestack* vector-pop ; inline

: namestack ( -- stack )
    namestack* clone ; inline

: set-namestack ( stack -- )
    clone set-namestack* ; inline

: global ( -- namespace )
    interpreter "factor.FactorInterpreter" "global" jvar-get ;

: set-global ( namespace -- )
    interpreter "factor.FactorInterpreter" "global" jvar-set ;

: get* ( variable namespace -- value )
    #! Pushes the value of a variable in an explicitly-specified
    #! namespace.
    [ "java.lang.String" ]
    "factor.FactorNamespace" "getVariable" jinvoke ; inline

: get ( variable -- value )
    #! Pushes the value of a variable.
    interpreter
    [ "java.lang.String" ]
    "factor.FactorInterpreter" "getVariable" jinvoke ; inline

: put* ( variable value namespace -- )
    #! Sets the value of a variable in an explicitly-specified
    #! namespace.
    [ "java.lang.String" "java.lang.Object" ]
    "factor.FactorNamespace" "setVariable" jinvoke ; inline

: put ( variable value -- )
    #! Set the value of a variable in the current namespace.
    namespace put* ; inline

: set ( value variable -- )
    #! Set the value of a variable in the current namespace.
    swap put ; inline

: set* ( value variable namespace -- )
    swapd put* ; inline

: <namespace> ( -- namespace )
    [ ] "factor.FactorNamespace" jnew ;

: <objnamespace> ( object -- namespace )
    [ "java.lang.Object" ] "factor.FactorNamespace" jnew ;

: namespace-of ( obj -- namespace )
    [ "java.lang.Object" ] "factor.FactorJava" "toNamespace"
    jinvoke-static ;

: bind ( namespace quot -- )
    #! Execute a quotation with a namespace on the namestack.
    swap namespace-of >n call n> drop ; inline

: has-namespace? ( a -- boolean )
    "factor.FactorObject" is ; inline

: import ( class pairs -- )
    #! Import some static variables from a Java class into the
    #! current namespace.
    namespace [ "java.lang.String" "factor.Cons" ]
    "factor.FactorNamespace" "importVars"
    jinvoke ;

: namespace? ( a -- boolean )
    "factor.FactorNamespace" is ; inline

: this ( -- object )
    ! Returns the object bound to the current namespace, or if
    ! no object is bound, the namespace itself.
    namespace dup
    [ ] "factor.FactorNamespace" "getThis" jinvoke dup rot ?
    ; inline

: vars ( -- list )
    namespace [ ] "factor.FactorNamespace" "toVarList"
    jinvoke ;

: vars-values ( -- list )
    namespace [ ] "factor.FactorNamespace" "toVarValueList"
    jinvoke ;

: values ( -- list )
    namespace [ ] "factor.FactorNamespace" "toValueList"
    jinvoke ;
