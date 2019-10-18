USING: xml-errors xml-data kernel state-parser kernel namespaces
    errors strings math sequences hashtables char-classes arrays ;
IN: xml-tokenize

! -- Parsing names

: version=1.0? ( -- ? )
    prolog-data get prolog-version "1.0" = ;

! version=1.0? is calculated once and passed around for efficiency
: name-start-char? ( 1.0? char -- ? )
    swap [ 1.0name-start-char? ] [ 1.1name-start-char? ] if ;

: name-char? ( 1.0? char -- ? )
    swap [ 1.0name-char? ] [ 1.1name-char? ] if ;

: (parse-name) ( -- str )
    version=1.0? dup
    new-record get-char name-start-char? [
        [ dup get-char name-char? not ] skip-until
        drop end-record
    ] [
        "Malformed name" <xml-string-error> throw
    ] if ;

: parse-name ( -- name )
    (parse-name) get-char CHAR: : =
    [ next (parse-name) ] [ "" swap ] if f <name> ;

!   -- Parsing strings

: expect ( ch -- )
    get-char 2dup = [ 2drop ] [
        >r ch>string r> ch>string <expected> throw
    ] if next ;

: expect-string* ( num -- )
    #! only skips string, and only for when you're sure the string is there
    [ next ] times ;

: expect-string ( string -- )
    ! TODO: add error if this isn't long enough
    new-record dup length [ next ] times
    end-record 2dup = [ 2drop ]
    [ <expected> throw ] if ;

: entities
    #! We have both directions here as a shortcut.
    H{
        { "lt"    CHAR: <  }
        { "gt"    CHAR: >  }
        { "amp"   CHAR: &  }
        { "apos"  CHAR: '  }
        { "quot"  CHAR: "  }
        { CHAR: < "&lt;"   }
        { CHAR: > "&gt;"   }
        { CHAR: & "&amp;"  }
        { CHAR: ' "&apos;" }
        { CHAR: " "&quot;" }
    } ;


: ?bad-name [ <bad-name> throw ] when ;
: assert-name ( string -- string/* )
    dup "" = ?bad-name
    version=1.0? over first name-start-char?
    not ?bad-name
    version=1.0? over [ name-char? ] all-with?
    not ?bad-name ;

: (parse-entity) ( string -- )
    dup entities hash [ push-record ] [ 
        prolog-data get prolog-standalone
        [ <no-entity> throw ] [
            0 end-record* , assert-name
            <entity> , next new-record
        ] if
    ] ?if ;

: parse-entity ( -- )
    next unrecord unrecord 
    ! the following line is in a scope to shield this
    ! word from the record-altering side effects of
    ! take-until.
    [ CHAR: ; take-char ] with-scope
    "#" ?head [
        "x" ?head 16 10 ? base>
        push-record
    ] [ (parse-entity) ] if ;

: (parse-char) ( ch -- )
    get-char {
        { [ dup not ]
          [ 2drop 0 end-record* , ] }
        { [ 2dup = ]
          [ 2drop end-record , next ] }
        { [ CHAR: & = ]
          [ parse-entity (parse-char) ] }
        { [ t ] [ next (parse-char) ] }
    } cond ;

: parse-char ( ch -- array )
    [ new-record (parse-char) ] { } make ;

: parse-quot ( ch -- array )
    parse-char get-char
    [ "XML file ends in a quote" <xml-string-error> throw ] unless ;

: parse-text ( -- array )
    CHAR: < parse-char ;

! -- Parsing tags

: start-tag ( -- name ? )
    #! Outputs the name and whether this is a closing tag
    get-char CHAR: / = dup [ next ] when
    parse-name swap ;

: parse-prop-value ( -- seq )
    get-char dup "'\"" member? [
        next parse-quot
    ] [
        "Attribute lacks quote" <xml-string-error> throw
    ] if ;

: parse-prop ( -- )
    [ parse-name ] with-scope
    pass-blank CHAR: = expect pass-blank
    [ parse-prop-value ] with-scope
    swap set ;

: (middle-tag) ( -- )
    pass-blank version=1.0? get-char name-start-char?
    [ parse-prop (middle-tag) ] when ;

: middle-tag ( -- hash )
    [ (middle-tag) ] make-hash pass-blank ;

: end-tag ( string hash -- tag )
    pass-blank get-char CHAR: / =
    [ <contained> next ] [ <opener> ] if ;

: skip-comment ( -- comment )
    "--" expect-string
    "--" take-string
    <comment>
    CHAR: > expect ;

: cdata ( -- string )
    "[CDATA[" expect-string "]]>" take-string next ;

: direct ( -- object )
    {
        { [ "--" string-matches? ] [ skip-comment ] }
        { [ "[CDATA[" string-matches? ] [ cdata ] }
        { [ t ] [ CHAR: > take-char <directive> next ] }
    } cond ;

: instruct ( -- instruction )
    "?>" take-string 
    dup length 3 >= [
        dup 3 head-slice >lower "xml" = [
            <bad-prolog> throw
        ] when
    ] when
    <instruction> ;

: make-tag ( -- tag )
    {
        { [ get-char dup CHAR: ! = ] [ drop next direct ] }
        { [ CHAR: ? = ] [ next instruct ] } 
        { [ start-tag ] [ <closer> CHAR: > expect  ] }
        { [ t ] [ middle-tag end-tag CHAR: > expect ] }
    } cond ;
