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

!!! Minimum amount of words needed to be able to read other
!!! resources.

USE: combinators

IN: stack

~<< dup A -- A A >>~
~<< swap A B -- B A >>~

IN: streams

: <breader> ( reader -- breader )
    #! Wrap a Reader in a BufferedReader.
    [ "java.io.Reader" ] "java.io.BufferedReader" jnew ;

: <ireader> ( inputstream -- breader )
    #! Wrap a InputStream in an InputStreamReader.
    [ "java.io.InputStream" ] "java.io.InputStreamReader" jnew ;

: <rreader> ( path -- inputstream )
    #! Create a Reader for reading the specified resource from
    #! the classpath.
    "factor.FactorInterpreter"
    [ "java.lang.String" ]
    "java.lang.Class" "getResourceAsStream" jinvoke
    <ireader> <breader> ;

IN: strings

: cat2 ( str str -- str )
    #! Concatenate two strings.
    swap
    [ "java.lang.String" ] "java.lang.String" "concat" jinvoke ;

IN: parser

: parse* ( parser -- list )
    #! Reads until EOF.
    [ ] "factor.FactorReader" "parse" jinvoke ;

: <parser> ( filename reader -- parser )
    #! Creates a parser with the default vocabularies:
    #! IN: user
    #! USE: user USE: builtins
    interpreter
    [
        "java.lang.String"
        "java.io.BufferedReader"
        "factor.FactorInterpreter"
    ]
    "factor.FactorReader" jnew ;

: parse-stream ( filename reader -- list )
    #! Reads until end-of-file from the reader, building a parse
    #! tree. The filename is used for error reporting.
    <parser> parse* ;

: parse-resource ( resource -- list )
    dup <rreader> swap "resource:" swap cat2 swap parse-stream ;

: run-resource ( path -- )
    #! Reads and runs a source file from a resource path.
    parse-resource call ;

!!!

IN: init DEFER: boot

interpreter "factor.FactorInterpreter" "mini" jvar-get [
    "/library/platform/jvm/boot-mini.factor" run-resource
] [
    "/library/platform/jvm/boot-sumo.factor" run-resource
] ifte

boot
