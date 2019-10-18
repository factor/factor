USING: parser words sequences namespaces kernel assocs ;
IN: xmode.tokens

! Based on org.gjt.sp.jedit.syntax.Token
SYMBOL: tokens

: string>token ( string -- id ) tokens get at ;

: TOKENS:
    ";" parse-tokens [
        create-in dup define-symbol
        dup word-name swap
    ] H{ } map>assoc tokens set-global ; parsing

TOKENS: COMMENT1 COMMENT2 COMMENT3 COMMENT4 DIGIT FUNCTION
INVALID KEYWORD1 KEYWORD2 KEYWORD3 KEYWORD4 LABEL LITERAL1
LITERAL2 LITERAL3 LITERAL4 MARKUP OPERATOR END NULL ;

TUPLE: token str id ;

C: <token> token
