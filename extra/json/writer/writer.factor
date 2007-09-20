! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel io.streams.string io strings splitting sequences math 
       math.parser assocs tuples classes words namespaces 
       hashtables ;
IN: json.writer

#! Writes the object out to a stream in JSON format
GENERIC: json-print ( obj -- )

: >json ( obj -- string )
  #! Returns a string representing the factor object in JSON format
  [ json-print ] string-out ;

M: f json-print ( f -- )
  "false" write ;

M: string json-print ( obj -- )
  CHAR: " write1 "\"" split "\\\"" join CHAR: \r swap remove "\n" split "\\r\\n" join write CHAR: " write1 ;

M: number json-print ( num -- )  
  number>string write ;

M: sequence json-print ( array -- string ) 
  CHAR: [ write1 [ >json ] map "," join write CHAR: ] write1 ;

: (jsvar-encode) ( char -- char )
  #! Convert the given character to a character usable in
  #! javascript variable names.
  dup H{ { CHAR: - CHAR: _ } } at dup [ nip ] [ drop ] if ;

: jsvar-encode ( string -- string )
  #! Convert the string so that it contains characters usable within
  #! javascript variable names.
  [ (jsvar-encode) ] map ;
  
: slots ( object -- values names )
  #! Given an object return an array of slots names and a sequence of slot values
  #! the slot name and the slot value. 
  [ tuple-slots ] keep class "slot-names" word-prop ;

: slots>fields ( values names -- array )
  #! Convert the arrays containing the slot names and values
  #! to an array of strings suitable for describing that slot
  #! as a field in a javascript object.
  [ 
    [ jsvar-encode >json % " : " % >json % ] "" make 
  ] 2map ;

M: object json-print ( object -- string )
  CHAR: { write1 slots slots>fields "," join write CHAR: } write1 ;

M: hashtable json-print ( hashtable -- string )
  CHAR: { write1 
  [ [ swap jsvar-encode >json % CHAR: : , >json % ] "" make ]
  { } assoc>map "," join write 
  CHAR: } write1 ;
  
