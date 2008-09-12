USING: accessors kernel parser sequences words effects ;
IN: values

: VALUE:
    CREATE-WORD { f } clone [ first ] curry
    (( -- value )) define-declared ; parsing

: set-value ( value word -- )
    def>> first set-first ;

: get-value ( word -- value )
    def>> first first ;

: change-value ( word quot -- )
    over >r >r get-value r> call r> set-value ; inline
