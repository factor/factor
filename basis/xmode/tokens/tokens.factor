USING: assocs kernel namespaces parser words.symbol ;
IN: xmode.tokens

! Based on org.gjt.sp.jedit.syntax.Token
<<
SYMBOL: tokens

{
    "COMMENT1" "COMMENT2" "COMMENT3" "COMMENT4" "DIGIT"
    "FUNCTION" "INVALID" "KEYWORD1" "KEYWORD2" "KEYWORD3"
    "KEYWORD4" "LABEL" "LITERAL1" "LITERAL2" "LITERAL3"
    "LITERAL4" "MARKUP" "OPERATOR" "END" "NULL"
} [
    dup create-word-in dup define-symbol
] H{ } map>assoc tokens set-global
>>

: string>token ( string -- id ) tokens get at ;

TUPLE: token str id ;

C: <token> token
