! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs command-line compiler.errors debugger
io kernel namespaces sequences source-files.errors
source-files.errors.debugger summary ;
IN: tools.errors

! Tools for source-files.errors. Used by tools.tests and others
! for error reporting

: errors. ( errors -- )
    group-by-source-file sort-errors
    [
        [ nl "==== " write +listener-input+ or print nl ]
        [ [ nl ] [ error. ] interleave ]
        bi*
    ] assoc-each ;

: :errors ( -- ) compiler-errors get values errors. ;

: :linkage ( -- ) linkage-errors get values errors. ;

: :user-init-errors ( -- )
    user-init-errors get-global values errors. ;

M: not-compiled summary
    word>> name>> "The word " " cannot be executed because it failed to compile" surround ;

M: not-compiled error.
    [ summary print nl ] [ error>> error. ] bi ;
