USING: xmode.tokens xmode.rules xmode.keyword-map xml.data
xml.utilities xml assocs kernel combinators sequences
math.parser namespaces parser xmode.utilities regexp io.files ;
IN: xmode.loader.syntax

SYMBOL: ignore-case?

! Rule tag parsing utilities
: (parse-rule-tag) ( rule-set tag specs class -- )
    construct-rule swap init-from-tag swap add-rule ; inline

: RULE:
    scan scan-word
    parse-definition { } make
    swap [ (parse-rule-tag) ] 2curry (TAG:) ; parsing

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
    "NAME" over at "VALUE" rot at ;

: parse-props-tag ( tag -- assoc )
    child-tags
    [ parse-prop-tag ] H{ } map>assoc ;

: position-attrs ( tag -- at-line-start? at-whitespace-end? at-word-start? )
    ! XXX Wrong logic!
    { "AT_LINE_START" "AT_WHITESPACE_END" "AT_WORD_START" }
    swap [ at string>boolean ] curry map first3 ;

: parse-literal-matcher ( tag -- matcher )
    dup children>string
    ignore-case? get <string-matcher>
    swap position-attrs <matcher> ;

: parse-regexp-matcher ( tag -- matcher )
    dup children>string ignore-case? get <regexp>
    swap position-attrs <matcher> ;

: shared-tag-attrs ( -- )
    { "TYPE" string>token set-rule-body-token } , ; inline

: delegate-attr ( -- )
    { "DELEGATE" f set-rule-delegate } , ;

: regexp-attr ( -- )
    { "HASH_CHAR" f set-rule-chars } , ;

: match-type-attr ( -- )
    { "MATCH_TYPE" string>match-type set-rule-match-token } , ;

: span-attrs ( -- )
    { "NO_LINE_BREAK" string>boolean set-rule-no-line-break? } ,
    { "NO_WORD_BREAK" string>boolean set-rule-no-word-break? } ,
    { "NO_ESCAPE" string>boolean set-rule-no-escape? } , ;

: literal-start ( -- )
    [ parse-literal-matcher swap set-rule-start ] , ;

: regexp-start ( -- )
    [ parse-regexp-matcher swap set-rule-start ] , ;

: literal-end ( -- )
    [ parse-literal-matcher swap set-rule-end ] , ;

! SPAN's children
<TAGS: parse-begin/end-tag ( rule tag -- )

TAG: BEGIN
    ! XXX
    parse-literal-matcher swap set-rule-start ;

TAG: END
    ! XXX
    parse-literal-matcher swap set-rule-end ;

TAGS>

: parse-begin/end-tags ( -- )
    [
        ! XXX: handle position attrs on span tag itself
        child-tags [ parse-begin/end-tag ] with each
    ] , ;

: init-span-tag ( -- ) [ drop init-span ] , ;

: init-eol-span-tag ( -- ) [ drop init-eol-span ] , ;

: parse-keyword-tag ( tag keyword-map -- )
    >r dup name-tag string>token swap children>string r> set-at ;
