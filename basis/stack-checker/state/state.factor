! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs arrays namespaces sequences kernel definitions
math effects accessors words fry classes.algebra
compiler.units stack-checker.values stack-checker.visitor
stack-checker.errors ;
IN: stack-checker.state

! Did the current control-flow path throw an error?
SYMBOL: terminated?

! Number of inputs current word expects from the stack
SYMBOL: input-count

DEFER: commit-literals

! Compile-time data stack
: meta-d ( -- stack ) commit-literals \ meta-d get ;

! Compile-time retain stack
: meta-r ( -- stack ) \ meta-r get ;

! Uncommitted literals. This is a form of local dead-code
! elimination; the goal is to reduce the number of IR nodes
! which get constructed. Technically it is redundant since
! we do global DCE later, but it speeds up compile time.
SYMBOL: literals

: (push-literal) ( obj -- )
    dup <literal> make-known
    [ nip \ meta-d get push ] [ #push, ] 2bi ;

: commit-literals ( -- )
    literals get [
        [ [ (push-literal) ] each ] [ delete-all ] bi
    ] unless-empty ;

: current-stack-height ( -- n ) meta-d length input-count get - ;

: current-effect ( -- effect )
    input-count get meta-d length terminated? get effect boa ;

: init-inference ( -- )
    terminated? off
    V{ } clone \ meta-d set
    V{ } clone literals set
    0 input-count set ;
