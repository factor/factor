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

IN: parser

USE: combinators
USE: errors
USE: hashtables
USE: kernel
USE: lists
USE: logic
USE: math
USE: namespaces
USE: stack
USE: strings
USE: words
USE: vectors
USE: unparser

! Colon defs
: CREATE ( -- word )
    scan "in" get create dup set-word
    dup f "documentation" set-word-property
    dup f "stack-effect" set-word-property
    dup "line-number" get "line" set-word-property
    dup "col"         get "col"  set-word-property
    dup "file"        get "file" set-word-property ;

! \x
: unicode-escape>ch ( -- esc )
    #! Read \u....
    next-ch digit> 16 *
    next-ch digit> + 16 *
    next-ch digit> + 16 *
    next-ch digit> + ;

: ascii-escape>ch ( ch -- esc )
    [
        [ CHAR: e | CHAR: \e ]
        [ CHAR: n | CHAR: \n ]
        [ CHAR: r | CHAR: \r ]
        [ CHAR: t | CHAR: \t ]
        [ CHAR: s | CHAR: \s ]
        [ CHAR: \s | CHAR: \s ]
        [ CHAR: 0 | CHAR: \0 ]
        [ CHAR: \\ | CHAR: \\ ]
        [ CHAR: \" | CHAR: \" ]
    ] assoc ;

: escape ( ch -- esc )
    dup CHAR: u = [
        drop unicode-escape>ch
    ] [
        ascii-escape>ch
    ] ifte ;

: parse-escape ( -- )
    next-ch escape dup [ drop "Bad escape" throw ] unless ;

: parse-ch ( ch -- ch )
    dup CHAR: \\ = [ drop parse-escape ] when ;

: doc-comment-here? ( parsed -- ? )
    not "in-definition" get and ;

: parsed-stack-effect ( parsed str -- parsed )
    over doc-comment-here? [
        word stack-effect [
            drop
        ] [
            word swap "stack-effect" set-word-property
        ] ifte
    ] [
        drop
    ] ifte ;

: documentation+ ( word str -- )
    over "documentation" word-property [
        swap "\n" swap cat3
    ] when*
    "documentation" set-word-property ;

: parsed-documentation ( parsed str -- parsed )
    over doc-comment-here? [
        word swap documentation+
    ] [
        drop
    ] ifte ;

IN: syntax

: inline ( -- )
    #! Mark the last word to be inlined.
    word  t "inline" set-word-property ; parsing

! The variable "in-definition" is set inside a : ... ;.
! ( and #! then add "stack-effect" and "documentation"
! properties to the current word if it is set.

! Constants
: t t parsed ; parsing
: f f parsed ; parsing

! Lists
: [ f ; parsing
: ] reverse parsed ; parsing

: | ( syntax: | cdr ] )
    #! See the word 'parsed'. We push a special sentinel, and
    #! 'parsed' acts accordingly.
    "|" ; parsing

! Vectors
: { f ; parsing
: } reverse list>vector parsed ; parsing

! Hashtables
: {{ f ; parsing
: }} alist>hash parsed ; parsing

! Do not execute parsing word
: POSTPONE: ( -- ) scan-word parsed ; parsing

: :
    #! Begin a word definition. Word name follows.
    CREATE [ ] "in-definition" on ; parsing

: ;-hook ( word def -- )
    ";-hook" get [ call ] [ define-compound ] ifte* ;

: ;
    #! End a word definition.
    "in-definition" off reverse ;-hook ; parsing

! Symbols
: SYMBOL: CREATE define-symbol ; parsing

: \
    #! Parsed as a piece of code that pushes a word on the stack
    #! \ foo ==> [ foo ] car
    scan-word unit parsed  \ car parsed ; parsing

! Vocabularies
: DEFER: CREATE drop ; parsing
: USE: scan "use" cons@ ; parsing
: IN: scan dup "use" cons@ "in" set ; parsing

! Char literal
: CHAR: ( -- ) next-word-ch parse-ch parsed ; parsing

! String literal
: parse-string ( -- )
    next-ch dup CHAR: " = [
        drop
    ] [
        parse-ch , parse-string
    ] ifte ;

: "
    #! Note the ugly hack to carry the new value of 'pos' from
    #! the make-string scope up to the original scope.
    [ parse-string "col" get ] make-string
    swap "col" set parsed ; parsing

! Complex literal
: #{
    #! Read #{ real imaginary #}
    scan str>number scan str>number rect> "}" expect parsed ;
    parsing

! Comments
: (
    #! Stack comment.
    ")" until parsed-stack-effect ; parsing

: !
    #! EOL comment.
    until-eol drop ; parsing

: #!
    #! Documentation comment.
    until-eol parsed-documentation ; parsing

! Reading numbers in other bases

: BASE: ( base -- )
    #! Read a number in a specific base.
    scan swap base> parsed ;

: HEX: 16 BASE: ; parsing
: DEC: 10 BASE: ; parsing
: OCT: 8 BASE: ; parsing
: BIN: 2 BASE: ; parsing
