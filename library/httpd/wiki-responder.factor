! :folding=indent:collapseFolds=0:

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

IN: wiki-responder
USE: combinators
USE: format
USE: html
USE: lists
USE: logic
USE: kernel
USE: math
USE: namespaces
USE: parser
USE: regexp
USE: stdio
USE: stack
USE: strings
USE: words

USE: httpd
USE: httpd-responder

! : wiki-word? ( word -- ? )
!     #! A WikiWord starts with a capital and contains more than
!     #! one capital letter.
!     dup str-length 0 > [
!         0 over str-nth LETTER? [
!             0 swap [ LETTER? [ succ ] when ] str-each 1 = not
!         ] [
!             drop f
!         ] ifte
!     ] [
!         drop f
!     ] ifte ;
! 
! : wiki-formatting ( str -- )
!     #! If a word with this name exists in the wiki-formatting
!     #! vocabulary, its a special text style sequence.
!     [ "wiki-formatting" ] search ;
! 
! : (wiki-parser) ( text -- )
!     [
!         scan dup wiki-word? [
!             <a href= dup a> write </a>
!         ] [
!             write
!         ] ifte " " write
!     ] with-parser ;
