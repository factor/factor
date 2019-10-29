! Copyright (C) 2019 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors ascii constructors kernel prettyprint.backend
prettyprint.custom sequences sequences.private ;
IN: modern.lexer

ERROR: ws-expected string ;

TUPLE: ws string ;
CONSTRUCTOR: <ws> ws ( string -- ws )
    dup string>> [ blank? not ] any? [ ws-expected ] when ;

: no-ws ( seq -- seq' )
    [ ws? ] reject ;

M: ws nth string>> nth ;
M: ws nth-unsafe string>> nth-unsafe ;
M: ws length string>> length ;

! Weird experiment
! M: ws pprint*
    ! drop ;
    ! string>> dup "\"" "\"" pprint-string ;

TUPLE: lexed tokens ;

TUPLE: bracket < lexed tag payload ;
CONSTRUCTOR: <bracket> bracket ( tag payload -- obj ) ;

TUPLE: dbracket < lexed tag payload ;
CONSTRUCTOR: <dbracket> dbracket ( tag payload -- obj ) ;

TUPLE: brace < lexed tag payload ;
CONSTRUCTOR: <brace> brace ( tag payload -- obj ) ;

TUPLE: dbrace < lexed tag payload ;
CONSTRUCTOR: <dbrace> dbrace ( tag payload -- obj ) ;

TUPLE: lcolon < lexed tag payload ;
: <lcolon> ( tag payload -- obj )
    lcolon new
        swap no-ws >>payload
        swap >>tag ; inline

TUPLE: ucolon < lexed name effect body ;
CONSTRUCTOR: <ucolon> ucolon ( name effect body -- obj ) ;

TUPLE: dquote < lexed tag payload ;
CONSTRUCTOR: <dquote> dquote ( tag payload -- obj ) ;

TUPLE: section < lexed payload ;
CONSTRUCTOR: <section> section ( payload -- obj ) ;

TUPLE: named-section < lexed name payload ;
CONSTRUCTOR: <named-section> named-section ( name payload -- obj ) ;

TUPLE: backslash < lexed object ;
CONSTRUCTOR: <backslash> backslash ( object -- obj ) ;

TUPLE: hashtag < lexed object ;
CONSTRUCTOR: <hashtag> hashtag ( object -- obj ) ;

TUPLE: token < lexed name ;
CONSTRUCTOR: <token> token ( name -- obj ) ;
