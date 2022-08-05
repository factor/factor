USING: accessors assocs kernel math.parser namespaces sequences
xml xml.data xml.syntax xml.traversal xmode.keyword-map
xmode.loader.syntax xmode.rules xmode.tokens xmode.utilities ;
IN: xmode.loader

! Based on org.gjt.sp.jedit.XModeHandler

! RULES and its children
TAGS: parse-rule-tag ( rule-set tag -- )

TAG: PROPS parse-rule-tag
    parse-props-tag >>props drop ;

TAG: IMPORT parse-rule-tag
    "DELEGATE" attr swap import-rule-set ;

TAG: TERMINATE parse-rule-tag
    "AT_CHAR" attr string>number >>terminate-char drop ;

RULE: SEQ seq-rule parse-rule-tag
    shared-tag-attrs delegate-attr literal-start ;

RULE: SEQ_REGEXP seq-rule parse-rule-tag
    shared-tag-attrs delegate-attr regexp-attr regexp-start ;

RULE: SPAN span-rule parse-rule-tag
    shared-tag-attrs delegate-attr match-type-attr span-attrs parse-begin/end-tags init-span-tag ;

RULE: SPAN_REGEXP span-rule parse-rule-tag
    shared-tag-attrs delegate-attr match-type-attr span-attrs regexp-attr parse-regexp-begin/end-tags init-span-tag ;

RULE: EOL_SPAN eol-span-rule parse-rule-tag
    shared-tag-attrs delegate-attr match-type-attr literal-start init-eol-span-tag ;

RULE: EOL_SPAN_REGEXP eol-span-rule parse-rule-tag
    shared-tag-attrs delegate-attr match-type-attr regexp-attr regexp-start init-eol-span-tag ;

RULE: MARK_FOLLOWING mark-following-rule parse-rule-tag
    shared-tag-attrs match-type-attr literal-start ;

RULE: MARK_PREVIOUS mark-previous-rule parse-rule-tag
    shared-tag-attrs match-type-attr literal-start ;

TAG: KEYWORDS parse-rule-tag
    rule-set get ignore-case?>> <keyword-map>
    swap children-tags [ over parse-keyword-tag ] each
    swap keywords<< ;

: ?<regexp> ( string/f -- regexp/f )
    dup [ rule-set get ignore-case?>> <?insensitive-regexp> ] when ;

: (parse-rules-tag) ( tag -- rule-set )
    rule-set get {
        { "SET" string>rule-set-name name<< }
        { "IGNORE_CASE" string>boolean ignore-case?<< }
        { "HIGHLIGHT_DIGITS" string>boolean highlight-digits?<< }
        { "DIGIT_RE" ?<regexp> digit-re<< }
        { "ESCAPE" f add-escape-rule }
        { "DEFAULT" string>token default<< }
        { "NO_WORD_SEP" f no-word-sep<< }
    } init-from-tag ;

: parse-rules-tag ( tag -- rule-set )
    <rule-set> rule-set [
        [ (parse-rules-tag) ] [ children-tags ] bi
        [ parse-rule-tag ] with each
        rule-set get
    ] with-variable ;

: merge-rule-set-props ( props rule-set -- )
    [ assoc-union ] change-props drop ;

! Top-level entry points
: parse-mode-tag ( tag -- rule-sets )
    dup "RULES" tags-named [
        parse-rules-tag [ name>> ] keep
    ] H{ } map>assoc
    swap "PROPS" tag-named [
        parse-props-tag over values
        [ merge-rule-set-props ] with each
    ] when* ;

: parse-mode ( filename -- rule-sets )
    file>xml parse-mode-tag ;
