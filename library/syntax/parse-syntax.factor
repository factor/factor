! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004, 2005 Slava Pestov.
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

! Bootstrapping trick; see doc/bootstrap.txt.
IN: !syntax
USE: syntax

USE: errors
USE: hashtables
USE: kernel
USE: lists
USE: math
USE: namespaces
USE: parser
USE: strings
USE: words
USE: vectors
USE: unparser

: parsing ( -- )
    #! Mark the most recently defined word to execute at parse
    #! time, rather than run time. The word can use 'scan' to
    #! read ahead in the input stream.
    word t "parsing" set-word-property ; parsing

: inline ( -- )
    #! Mark the last word to be inlined.
    word  t "inline" set-word-property ; parsing

! The variable "in-definition" is set inside a : ... ;.
! ( and #! then add "stack-effect" and "documentation"
! properties to the current word if it is set.

! Booleans
: t t swons ; parsing
: f f swons ; parsing

! Lists
: [ f ; parsing
: ] reverse swons ; parsing

! Conses (whose cdr might not be a list)
: [[ f ; parsing
: ]] 2unlist swons swons ; parsing

! Vectors
: { f ; parsing
: } reverse list>vector swons ; parsing

! Hashtables
: {{ f ; parsing
: }} alist>hash swons ; parsing

! Complex numbers
: #{ f ; parsing
: }# 2unlist swap rect> swons ; parsing

! Do not execute parsing word
: POSTPONE: ( -- ) scan-word swons ; parsing

: :
    #! Begin a word definition. Word name follows.
    CREATE [ define-compound ] [ ] "in-definition" on ; parsing

: ;
    #! End a word definition.
    "in-definition" off reverse swap call ; parsing

! Symbols
: SYMBOL:
    #! A symbol is a word that pushes itself when executed.
    CREATE define-symbol ; parsing

: \
    #! Parsed as a piece of code that pushes a word on the stack
    #! \ foo ==> [ foo ] car
    scan-word unit swons  \ car swons ; parsing

! Vocabularies
: DEFER:
    #! Create a word with no definition. Used for mutually
    #! recursive words.
    CREATE drop ; parsing

: FORGET: scan-word forget ; parsing

: USE:
    #! Add vocabulary to search path.
    scan "use" cons@ ; parsing

: USING:
    #! A list of vocabularies terminated with ;
    string-mode on
    [ string-mode off [ "use" cons@ ] each ]
    f ; parsing

: IN:
    #! Set vocabulary for new definitions.
    scan dup "use" cons@ "in" set ; parsing

! Char literal
: CHAR: ( -- ) 0 scan next-char drop swons ; parsing

! String literal
: parse-string ( n str -- n )
    2dup str-nth CHAR: " = [
        drop 1 +
    ] [
        [ next-char swap , ] keep parse-string
    ] ifte ;

: "
    "col" [
        "line" get [ parse-string ] make-string swap
    ] change swons ; parsing

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

: (BASE) ( base -- )
    #! Read a number in a specific base.
    scan swap base> swons ;

: HEX: 16 (BASE) ; parsing
: DEC: 10 (BASE) ; parsing
: OCT: 8 (BASE) ; parsing
: BIN: 2 (BASE) ; parsing
