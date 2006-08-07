! Copyright (C) 2006 Chris Double.
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
!
USING: kernel strings namespaces math arrays sequences generic words hashtables kernel-internals io ;
IN: json

#! Writes the object out to a stream in JSON format
GENERIC: json-print ( obj -- )

: >json ( obj -- string )
  #! Returns a string representing the factor object in JSON format
  [ json-print ] string-out ;

M: f json-print ( f -- )
  "false" write ;

M: string json-print ( obj -- )
  CHAR: " write1 write CHAR: " write1 ;

M: number json-print ( num -- )  
  number>string write ;

M: sequence json-print ( array -- string ) 
  CHAR: [ write1 [ >json ] map "," join write CHAR: ] write1 ;

: (jsvar-encode) ( char -- char )
  #! Convert the given character to a character usable in
  #! javascript variable names.
  dup H{ { CHAR: - CHAR: _ } } hash dup [ nip ] [ drop ] if ;

: jsvar-encode ( string -- string )
  #! Convert the string so that it contains characters usable within
  #! javascript variable names.
  [ (jsvar-encode) ] map ;
  
: >tuple< ( object -- array )
  #! Return an array holding the value of the slots of the tuple
  dup class "slots" word-prop [ first slot ] map-with ;

: slots ( object -- values names )
  #! Given an object return an array of slots names and a sequence of slot values
  #! the slot name and the slot value. 
  [ >tuple< 1 tail ] keep class "slot-names" word-prop ;

: slots>fields ( values names -- array )
  #! Convert the arrays containing the slot names and values
  #! to an array of strings suitable for describing that slot
  #! as a field in a javascript object.
  [ 
    [ jsvar-encode >json % " : " % >json % ] "" make 
  ] 2map ;

M: object json-print ( object -- string )
  CHAR: { write1 slots slots>fields "," join write CHAR: } write1 ;