!:folding=indent:collapseFolds=1:

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

: s@ ( variable value -- )
    #! Sets the value of a variable in the current namespace.
    namespace [ "java.lang.String" "java.lang.Object" ]
    "factor.FactorNamespace"
    "setVariable" jinvoke ; inline

: @ ( value variable -- )
    swap s@ ; inline

: has-namespace? ( a -- boolean )
    "factor.FactorObject" is ; inline

: lazy ( var [ a ] -- value )
    ! If the value of the variable is f, set the value to the
    ! result of evaluating [ a ].
    over $ [ drop $ ] [ dip dupd @ ] ifte ;

: namespace? ( a -- boolean )
    "factor.FactorNamespace" is ; inline

: <namespace> ( -- namespace )
    namespace
    [ "factor.FactorNamespace" ] "factor.FactorNamespace" jnew ;

: <objnamespace> ( object -- namespace )
    namespace swap
    [ "factor.FactorNamespace" "java.lang.Object" ]
    "factor.FactorNamespace" jnew ;

: extend ( object code -- object )
    ! Used in code like this:
    ! : <subclass>
    !      <superclass> [
    !          ....
    !      ] extend ;
    over [ bind ] dip ;

: import ( class pairs -- )
    ! Import some static variables from a Java class into the
    ! current namespace.
    namespace [ "java.lang.String" "factor.Cons" ]
    "factor.FactorNamespace" "importVars"
    jinvoke ;

: parent ( -- namespace )
    ! Push the parent of the current namespace.
    namespace [ ] "factor.FactorNamespace" "getParent" jinvoke ;

: this ( -- object )
    ! Returns the object bound to the current namespace, or if
    ! no object is bound, the namespace itself.
    namespace dup
    [ ] "factor.FactorNamespace" "getThis" jinvoke dup rot ?
    ; inline

: vars ( -- list )
    vars-values [ car ] inject ;

: vars-values ( -- list )
    namespace [ ] "factor.FactorNamespace" "toVarValueList"
    jinvoke ;

: values ( -- list )
    vars-values [ cdr ] inject ;

: vars. ( -- )
    ! Print a list of defined variables.
    vars [ print ] each ;

: var. ( [ name , value ] -- )
    uncons unparse swap relative>absolute-object-path
    "link" swap cons unit write-attr ;

: value. ( max [ name , value ] -- )
    dup [ car tuck pad-string write write ] dip
    ": " write
    var. terpri ;

: vars-values. ( namespace -- )
    #! Prints all name/value pairs defined in the current
    #! namespace to standard output.
    [ vars max-str-length vars-values ] bind
    [ dupd value. ] each drop ;
