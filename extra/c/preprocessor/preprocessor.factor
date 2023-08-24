! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs c.lexer combinators
combinators.short-circuit io io.directories io.encodings.utf8
io.files io.pathnames io.streams.string kernel make math
sequences sequences.parser splitting unicode ;
IN: c.preprocessor

: initial-library-paths ( -- seq )
    V{ "/usr/include" } clone ;

: initial-symbol-table ( -- hashtable )
    H{
        { "__APPLE__" "" }
        { "__amd64__" "" }
        { "__x86_64__" "" }
    } clone ;

TUPLE: preprocessor-state library-paths symbol-table
include-nesting include-nesting-max processing-disabled?
ifdef-nesting warnings errors
pragmas
include-nexts
ifs elifs elses ;

: <preprocessor-state> ( -- preprocessor-state )
    preprocessor-state new
        initial-library-paths >>library-paths
        initial-symbol-table >>symbol-table
        0 >>include-nesting
        200 >>include-nesting-max
        0 >>ifdef-nesting
        V{ } clone >>warnings
        V{ } clone >>errors
        V{ } clone >>pragmas
        V{ } clone >>include-nexts
        V{ } clone >>ifs
        V{ } clone >>elifs
        V{ } clone >>elses ;

DEFER: preprocess-file

ERROR: unknown-c-preprocessor sequence-parser name ;

ERROR: bad-include-line line ;

ERROR: header-file-missing path ;

:: read-standard-include ( preprocessor-state path -- )
    preprocessor-state dup library-paths>>
    [ path append-path file-exists? ] find nip
    [
        dup [
            path append-path
            preprocess-file
        ] with-directory
    ] [
        ! path header-file-missing
        drop
    ] if* ;

: read-local-include ( preprocessor-state path -- )
    dup file-exists? [ preprocess-file ] [ 2drop ] if ;

: skip-whitespace/comments ( sequence-parser -- sequence-parser )
    skip-whitespace
    {
        { [ dup take-c-comment ] [ skip-whitespace/comments ] }
        { [ dup take-c++-comment ] [ skip-whitespace/comments ] }
        [ ]
    } cond ;

: handle-include ( preprocessor-state sequence-parser -- )
    skip-whitespace/comments advance dup previous {
        { CHAR: < [ CHAR: > take-until-object read-standard-include ] }
        { CHAR: \" [ CHAR: \" take-until-object read-local-include ] }
        [ bad-include-line ]
    } case ;

: (readlns) ( -- )
    readln "\\" ?tail [ , ] dip [ (readlns) ] when ;

: readlns ( -- string ) [ (readlns) ] { } make concat ;

: take-define-identifier ( sequence-parser -- string )
    skip-whitespace/comments
    [ current { [ blank? ] [ CHAR: ( = ] } 1|| ] take-until ;

:: handle-define ( preprocessor-state sequence-parser -- )
    sequence-parser take-define-identifier :> ident
    sequence-parser skip-whitespace/comments take-rest :> def
    def "\\" ?tail [ readlns append ] when :> def
    def ident preprocessor-state symbol-table>> set-at ;

: handle-undef ( preprocessor-state sequence-parser -- )
    take-token swap symbol-table>> delete-at ;

: handle-ifdef ( preprocessor-state sequence-parser -- )
    [ [ 1 + ] change-ifdef-nesting ] dip
    take-token over symbol-table>> key?
    [ drop ] [ t >>processing-disabled? drop ] if ;

: handle-ifndef ( preprocessor-state sequence-parser -- )
    [ [ 1 + ] change-ifdef-nesting ] dip
    take-token over symbol-table>> key?
    [ t >>processing-disabled? drop ]
    [ drop ] if ;

: handle-endif ( preprocessor-state sequence-parser -- )
    drop [ 1 - ] change-ifdef-nesting drop ;

: handle-if ( preprocessor-state sequence-parser -- )
    [ [ 1 + ] change-ifdef-nesting ] dip
    skip-whitespace/comments take-rest swap ifs>> push ;

: handle-elif ( preprocessor-state sequence-parser -- )
    skip-whitespace/comments take-rest swap elifs>> push ;

: handle-else ( preprocessor-state sequence-parser -- )
    skip-whitespace/comments take-rest swap elses>> push ;

: handle-pragma ( preprocessor-state sequence-parser -- )
    skip-whitespace/comments take-rest swap pragmas>> push ;

: handle-include-next ( preprocessor-state sequence-parser -- )
    skip-whitespace/comments take-rest swap include-nexts>> push ;

: handle-error ( preprocessor-state sequence-parser -- )
    skip-whitespace/comments take-rest swap errors>> push ;
    ! nip take-rest throw ;

: handle-warning ( preprocessor-state sequence-parser -- )
    skip-whitespace/comments
    take-rest swap warnings>> push ;

: parse-directive ( preprocessor-state sequence-parser string -- )
    {
        { "warning" [ handle-warning ] }
        { "error" [ handle-error ] }
        { "include" [ handle-include ] }
        { "define" [ handle-define ] }
        { "undef" [ handle-undef ] }
        { "ifdef" [ handle-ifdef ] }
        { "ifndef" [ handle-ifndef ] }
        { "endif" [ handle-endif ] }
        { "if" [ handle-if ] }
        { "elif" [ handle-elif ] }
        { "else" [ handle-else ] }
        { "pragma" [ handle-pragma ] }
        { "include_next" [ handle-include-next ] }
        [ unknown-c-preprocessor ]
    } case ;

: parse-directive-line ( preprocessor-state sequence-parser -- )
    advance dup take-token
    pick processing-disabled?>> [
        "endif" = [
            drop f >>processing-disabled?
            [ 1 - ] change-ifdef-nesting
            drop
        ] [ 2drop ] if
    ] [
        parse-directive
    ] if ;

: preprocess-line ( preprocessor-state sequence-parser -- )
    skip-whitespace/comments dup current CHAR: # =
    [ parse-directive-line ]
    [ swap processing-disabled?>> [ drop ] [ write-full nl ] if ] if ;

: preprocess-lines ( preprocessor-state -- )
    readln
    [ <sequence-parser> [ preprocess-line ] [ drop preprocess-lines ] 2bi ]
    [ drop ] if* ;

ERROR: include-nested-too-deeply ;

: check-nesting ( preprocessor-state -- preprocessor-state )
    [ 1 + ] change-include-nesting
    dup [ include-nesting>> ] [ include-nesting-max>> ] bi > [
        include-nested-too-deeply
    ] when ;

: preprocess-file ( preprocessor-state path -- )
    [ check-nesting ] dip
    [ utf8 [ preprocess-lines ] with-file-reader ]
    [ drop [ 1 - ] change-include-nesting drop ] 2bi ;

: start-preprocess-file ( path -- preprocessor-state string )
    dup parent-directory [
        [
            [ <preprocessor-state> dup ] dip preprocess-file
        ] with-string-writer
    ] with-directory ;
