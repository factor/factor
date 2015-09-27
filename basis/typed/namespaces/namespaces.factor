USING: arrays classes fry kernel kernel.private locals macros
namespaces ;
IN: typed.namespaces

ERROR: variable-type-error variable value type ;

<PRIVATE

MACRO: declare1 ( type -- quot: ( value -- value ) )
    1array '[ _ declare ] ;

: typed-get-unsafe ( name type -- value )
    [ get ] dip declare1 ; inline

: typed-get-global-unsafe ( name type -- value )
    [ get-global ] dip declare1 ; inline

PRIVATE>

:: (typed-get) ( name type getter: ( name -- value ) -- value )
    name getter call :> value
    value type instance? [ name value type variable-type-error ] unless
    value type declare1 ; inline

: typed-get ( name type -- value )
    [ get ] (typed-get) ; inline

: typed-get-global ( name type -- value )
    [ get-global ] (typed-get) ; inline

:: (typed-set) ( value name type setter: ( value name -- ) -- )
    value type instance? [ name value type variable-type-error ] unless
    value name setter call ; inline

: typed-set ( value name type -- )
    [ set ] (typed-set) ; inline

: typed-set-global ( value name type -- )
    [ set-global ] (typed-set) ; inline
