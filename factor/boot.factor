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

! Minimum amount of words needed to be able to read other
! resources.

~<< dup A -- A A >>~

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

: parse* ( filename reader -- list )
    #! Reads until end-of-file from the reader, building a parse
    #! tree. The filename is used for error reporting.
    interpreter
    [
        "java.lang.String"
        "java.io.Reader"
        "factor.FactorInterpreter"
    ]
    "factor.FactorReader" jnew
    [ ] "factor.FactorReader" "parse" jinvoke ;

: parse-resource ( resource -- list )
    dup <rreader> parse* ;

: run-resource ( path -- )
    #! Reads and runs a source file from a resource path.
    parse-resource call ;

: ifte ( cond [ if true ] [ if false ] -- )
    #! Two-way branching. The condition is a generalized
    #! boolean; a value of f is taken to be false, any other
    #! value is taken to be true. The condition is popped off
    #! before either branch is taken.
    #!
    #! In order to compile, the two branches must have the same
    #! stack effect difference.
    ? call ;

: callframe ( -- callframe )
    ! Push the current callframe.
    interpreter "factor.FactorInterpreter" "callframe" jvar$ ;

: global ( -- namespace )
    interpreter "factor.FactorInterpreter" "global" jvar$ ;

: namespace ( -- namespace )
    ! Push the current namespace.
    callframe "factor.FactorCallFrame" "namespace" jvar$ ;

: $ ( variable -- value )
    #! Pushes the value of a variable in the current namespace.
    namespace [ "java.lang.String" ] "factor.FactorNamespace"
    "getVariable" jinvoke ;

: word ( -- word )
    ! Pushes most recently defined word.
    global [ $last ] bind ;

: inline ( -- )
    #! Marks the most recently defined word to be inlined.
    t word "factor.FactorWord" "inline" jvar@ ;

!!!

! Load the standard library.

$fasl [
    "/factor/boot.fasl" run-resource
    t @compile
] [
    "/factor/combinators.factor"       run-resource
    "/factor/compiler.factor"          run-resource
    "/factor/continuations.factor"     run-resource
    "/factor/debugger.factor"          run-resource
    "/factor/dictionary.factor"        run-resource
    "/factor/examples.factor"          run-resource
    "/factor/format.factor"            run-resource
    "/factor/httpd.factor"             run-resource
    "/factor/inspector.factor"         run-resource
    "/factor/interpreter.factor"       run-resource
    "/factor/irc.factor"               run-resource
    "/factor/lists.factor"             run-resource
    "/factor/math.factor"              run-resource
    "/factor/miscellaneous.factor"     run-resource
    "/factor/namespaces.factor"        run-resource
    "/factor/network.factor"           run-resource
    "/factor/parser.factor"            run-resource
    "/factor/presentation.factor"      run-resource
    "/factor/prettyprint.factor"       run-resource
    "/factor/random.factor"            run-resource
    "/factor/stack.factor"             run-resource
    "/factor/stream.factor"            run-resource
    "/factor/strings.factor"           run-resource
    "/factor/trace.factor"             run-resource
    "/factor/listener/listener.factor" run-resource
    "/factor/test/test.factor"         run-resource

    ! Inline some words defined before 'inline' was defined
    #=callframe [ t @inline ] bind
    #=global    [ t @inline ] bind
    #=namespace [ t @inline ] bind
    #=$         [ t @inline ] bind
] ifte

"/version.factor" run-resource

! Initialize constants.

"java.lang.System" "in"  jvar-static$ <ireader> <breader> @stdin
"java.lang.System" "out" jvar-static$ <owriter> @stdout
$stdin $stdout <char-stream> @stdio

2.7182818284590452354 @e
3.14159265358979323846 @pi

1.0 0.0 / @inf
-1.0 0.0 / @-inf

"user.home" system-property @~
"file.separator" system-property @/

t @user-init

! Parse command line arguments.

: cli-param ( param -- )
    #! Handle a command-line argument starting with '-' by
    #! setting that variable to t, or if the argument is
    #! prefixed with 'no-', setting the variable to f.
    dup "no-" str-head? dup [
        f s@ drop
    ] [
        drop t s@
    ] ifte ;

: cli-arg ( argument -- boolean )
    #! Handle a command-line argument.
    "-" str-head? [ cli-param ] when* ;

$args [ cli-arg ] each

! Auto-dump if specified in command line
$fasl not $auto-dump and [
    t @compile
    dump-boot-image
    "Auto dump complete" print
    f @interactive
] when

! Run user init file if it exists

$~ $/ ".factor-rc" cat3 @init-path

$user-init [
    $init-path dup exists? [ run-file ] [ drop ] ifte
] when

! If we're run stand-alone, start the interpreter in the current
! terminal.
$interactive [
    [ @top-level-continuation ] callcc0

    initial-interpreter-loop
] when
