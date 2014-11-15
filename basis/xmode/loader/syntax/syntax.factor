! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators kernel lexer make
namespaces parser sequences splitting xml.data xml.syntax
xml.syntax.private xml.traversal xmode.rules xmode.tokens
xmode.utilities ;
IN: xmode.loader.syntax

! Rule tag parsing utilities
: (parse-rule-tag) ( rule-set tag specs class -- )
    new swap init-from-tag swap add-rule ; inline

SYNTAX: RULE:
    scan-token scan-word scan-word [
        [ parse-definition call( -- ) ] { } make
        swap [ (parse-rule-tag) ] 2curry
    ] dip swap define-tag ;

! Attribute utilities
: string>boolean ( string -- ? ) "TRUE" = ;

: string>match-type ( string -- obj )
    {
        { "RULE" [ f ] }
        { "CONTEXT" [ t ] }
        [ string>token ]
    } case ;

: string>rule-set-name ( string -- name ) "MAIN" or ;

! PROP, PROPS
: parse-prop-tag ( tag -- key value )
    [ "NAME" attr ] [ "VALUE" attr ] bi ;

: parse-props-tag ( tag -- assoc )
    children-tags
    [ parse-prop-tag ] H{ } map>assoc ;

: position-attrs ( tag -- at-line-start? at-whitespace-end? at-word-start? )
    ! XXX Wrong logic!
    { "AT_LINE_START" "AT_WHITESPACE_END" "AT_WORD_START" }
    [ attr string>boolean ] with map first3 ;

: parse-literal-matcher ( tag -- matcher )
    dup children>string
    rule-set get ignore-case?>> <string-matcher>
    swap position-attrs <matcher> ;

: parse-regexp-matcher ( tag -- matcher )
    dup children>string
    rule-set get ignore-case?>> <?insensitive-regexp>
    swap position-attrs <matcher> ;

: shared-tag-attrs ( -- )
    { "TYPE" string>token body-token<< } , ; inline

: parse-delegate ( string -- pair )
    "::" split1 [ rule-set get swap ] unless* 2array ;

: delegate-attr ( -- )
    { "DELEGATE" f delegate<< } , ;

: regexp-attr ( -- )
    { "HASH_CHAR" f chars<< } , ;

: match-type-attr ( -- )
    { "MATCH_TYPE" string>match-type match-token<< } , ;

: span-attrs ( -- )
    { "NO_LINE_BREAK" string>boolean no-line-break?<< } ,
    { "NO_WORD_BREAK" string>boolean no-word-break?<< } ,
    { "NO_ESCAPE" string>boolean no-escape?<< } , ;

: literal-start ( -- )
    [ parse-literal-matcher >>start drop ] , ;

: regexp-start ( -- )
    [ parse-regexp-matcher >>start drop ] , ;

: literal-end ( -- )
    [ parse-literal-matcher >>end drop ] , ;

! SPAN's children
TAGS: parse-begin/end-tag ( rule tag -- )

TAG: BEGIN parse-begin/end-tag
    ! XXX
    parse-literal-matcher >>start drop ;

TAG: END parse-begin/end-tag
    ! XXX
    parse-literal-matcher >>end drop ;

: parse-begin/end-tags ( -- )
    [
        ! XXX: handle position attrs on span tag itself
        children-tags [ parse-begin/end-tag ] with each
    ] , ;

: init-span-tag ( -- ) [ drop init-span ] , ;

: init-eol-span-tag ( -- ) [ drop init-eol-span ] , ;

: parse-keyword-tag ( tag keyword-map -- )
    [ dup main>> string>token swap children>string ] dip set-at ;
