USING: kernel parser sequences words effects ;
IN: values

: VALUE:
    CREATE-WORD { f } clone [ first ] curry
    (( -- value )) define-declared ; parsing

: set-value ( value word -- )
    word-def first set-first ;

: get-value ( word -- value )
    word-def first first ;

: change-value ( word quot -- )
    over >r >r get-value r> call r> set-value ; inline
