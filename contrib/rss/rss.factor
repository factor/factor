! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
IN: rss
USING: kernel http-client sequences namespaces math errors io ;

: (replace) ( str1 str2 string -- )
  pick over ! str1 str2 string str1 string
  start dup -1 = [ ! str1 str2 string n
    drop % 2drop
  ] [ 
    dup    ! str1 str2 string n n-1
    pick swap head % ! str1 str2 string n )
    >r pick length r> + tail ! str1 str2 tail
    over % (replace)     
  ] if ;
  
: replace ( str1 str2 string -- string )
  #! Replace occurences of str1 with str2 inside string.
  [ (replace) ] "" make ;

: find-start-tag ( tag seq -- n )
  #! Find the start XML tag in the sequence. Return f if not found.
  #! If found return the index of the start of the contents of that tag.
  dup rot "<" swap append swap start dup 0 >= [ ! seq index
    ">" -rot start* dup 0 >= [ 1 + ] [ drop f ] if
  ] [
    2drop f
  ] if  ;

: find-end-tag ( tag seq -- n )
  #! Find the end XML tag in the sequence. Return -1 if not found.
  #! If found return the index of the data following the end tag.
  #! If found return the index of one beyond the last items of the contents of that tag.
  swap "</" swap append swap start dup 0 >= [ drop f ] unless ;

: (between-tags) ( tag seq -- content )
  #! Return a string containing the contents of the XML tag contained in seq. Returns
  #! false if the tag is not found.
  [ find-start-tag [ "no start tag" throw ] unless* ] 2keep [ find-end-tag 2dup and ] keep swap [ subseq ] when ;

: between-tags ( tag seq -- content )
  [ (between-tags) ] catch [ 3drop "" ] when* ;

: between-tags-index ( tag seq -- start end bool )
  #! Return the start and end index of the data contained with an xml tag.
  #! Returns t if a match is found, else f along with the indexes.
  [ find-start-tag ] 2keep find-end-tag 2dup and ;

: (child-tags) ( list tag seq -- list )
  2dup between-tags-index ! list tag seq start end bool
  [
    dup 1 + >r ! list tag seq start end r: end
    pick subseq ! list tag seq item r: end
    -rot >r >r over push r> r> r> ! list tag seq end
    over length rot subseq  (child-tags) 
  ] [
    drop drop drop drop drop 
  ] if ;
  
: child-tags ( tag seq -- list )
  #! Return a list of strings, each string containing the contents of all
  #! child tags in the XML data sequence.
  V{ } clone -rot (child-tags) ;

TUPLE: rss title link entries ;
TUPLE: rss-entry title link description pub-date ;

: entities-mapping ( -- entities )
  {
    { "&lt;" "<" }
    { "&gt;" ">" }
    { "&amp;" "&" }
    { "&quot;" "\"" }
    { "&apos;" "'" }
  } ;

: replace-entities ( string -- string )
  entities-mapping [ first2 rot replace ] each ;

: non-empty ( str1 str2 -- str )
  #! Return the string that is not empty.
  over empty? [ nip ] [ drop ] if ;

: process-rss-string ( string -- rss )
  "rss" swap between-tags 
  "channel" swap between-tags
  [ "title" swap between-tags replace-entities ] keep
  [ "link" swap between-tags ] keep
  "item" swap child-tags [
    [ "title" swap between-tags replace-entities ] keep
    [ "link" swap between-tags ] keep
    [ "guid" swap between-tags non-empty ] keep
    [ "description" swap between-tags replace-entities ] keep
    "pubDate" swap between-tags <rss-entry>
  ] map <rss> ;

: load-rss-file ( filename -- rss )
  #! Load an RSS file and process it, returning it as an rss tuple.
  <file-reader> [ contents process-rss-string ] keep stream-close ;

: rss-get ( url -- rss )
  #! Retrieve an RSS file, return as an rss tuple.
  http-get rot 200 = [
    nip process-rss-string 
  ] [
    2drop "Error retrieving rss file" throw
  ] if ;
