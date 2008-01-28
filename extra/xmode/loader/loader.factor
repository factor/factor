USING: xmode.loader.syntax xmode.tokens xmode.rules
xmode.keyword-map xml.data xml.utilities xml assocs kernel
combinators sequences math.parser namespaces parser
xmode.utilities regexp io.files ;
IN: xmode.loader

! Based on org.gjt.sp.jedit.XModeHandler

! RULES and its children
<TAGS: parse-rule-tag

TAG: PROPS ( rule-set tag -- )
    parse-props-tag swap set-rule-set-props ;

TAG: IMPORT ( rule-set tag -- )
    "DELEGATE" swap at swap import-rule-set ;

TAG: TERMINATE ( rule-set tag -- )
    "AT_CHAR" swap at string>number swap set-rule-set-terminate-char ;

RULE: SEQ seq-rule
    shared-tag-attrs delegate-attr literal-start ;

RULE: SEQ_REGEXP seq-rule
    shared-tag-attrs delegate-attr regexp-attr regexp-start ;

RULE: SPAN span-rule
    shared-tag-attrs delegate-attr match-type-attr span-attrs parse-begin/end-tags init-span-tag ;

RULE: SPAN_REGEXP span-rule
    shared-tag-attrs delegate-attr match-type-attr span-attrs regexp-attr parse-begin/end-tags init-span-tag ;

RULE: EOL_SPAN eol-span-rule
    shared-tag-attrs delegate-attr match-type-attr literal-start init-eol-span-tag ;

RULE: EOL_SPAN_REGEXP eol-span-rule
    shared-tag-attrs delegate-attr match-type-attr regexp-attr regexp-start init-eol-span-tag ;

RULE: MARK_FOLLOWING mark-following-rule
    shared-tag-attrs match-type-attr literal-start ;

RULE: MARK_PREVIOUS mark-previous-rule
    shared-tag-attrs match-type-attr literal-start ;

TAG: KEYWORDS ( rule-set tag -- key value )
    ignore-case? get <keyword-map>
    swap child-tags [ over parse-keyword-tag ] each
    swap set-rule-set-keywords ;

TAGS>

: ?<regexp> dup [ ignore-case? get <regexp> ] when ;

: (parse-rules-tag) ( tag -- rule-set )
    <rule-set>
    {
        { "SET" string>rule-set-name set-rule-set-name }
        { "IGNORE_CASE" string>boolean set-rule-set-ignore-case? }
        { "HIGHLIGHT_DIGITS" string>boolean set-rule-set-highlight-digits? }
        { "DIGIT_RE" ?<regexp> set-rule-set-digit-re }
        { "ESCAPE" f add-escape-rule }
        { "DEFAULT" string>token set-rule-set-default }
        { "NO_WORD_SEP" f set-rule-set-no-word-sep }
    } init-from-tag ;

: parse-rules-tag ( tag -- rule-set )
    dup (parse-rules-tag) [
        dup rule-set-ignore-case? ignore-case? [
            swap child-tags [ parse-rule-tag ] with each
        ] with-variable
    ] keep ;

: merge-rule-set-props ( props rule-set -- )
    [ rule-set-props union ] keep set-rule-set-props ;

! Top-level entry points
: parse-mode-tag ( tag -- rule-sets )
    dup "RULES" tags-named [
        parse-rules-tag dup rule-set-name swap
    ] H{ } map>assoc
    swap "PROPS" tag-named [
        parse-props-tag over values
        [ merge-rule-set-props ] with each
    ] when* ;

: parse-mode ( stream -- rule-sets )
    read-xml parse-mode-tag ;
