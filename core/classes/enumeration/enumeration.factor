USING: classes words kernel math sequences make combinators parser assocs classes.private lexer accessors ;
IN: classes.enumeration

PREDICATE: enumeration-class < class
    "metatype" word-prop enumeration-class eq? ;

: define-enum-class ( class superclass member-assoc -- ) 
    dup -rotd [ values index ] curry 
    {
        [ drop f f enumeration-class define-class ] 
        [ nip "predicate-definition" set-word-prop ]
        [ 2drop swap "enum-member-assoc" set-word-prop ]
        [ nip [ define-predicate ] keepd update-classes ] 
    } 3cleave ;

<PRIVATE
: define-enum-elt-word ( class name counter -- counter ) 
    [ 
        [ suffix! ] curry [ CHAR: . prefix [ dup name>> ] dip append create-word-in ] dip
        [ define-syntax ] keepd swap [ "parent-enum" set-word-prop ] keepd
    ] keep [ [ swap ,, ] [ "enum-elt-value" set-word-prop ] 2bi ] keep ;
: parse-enum-elt ( class name counter counter-quot -- counter counter-quot )
    pick {
        { 
            "{" 
            [
                nipd scan-word-name -rot 
                [ define-enum-elt-word ] dip
                \ } parse-until 2 index-or-length head
                {
                    { [ dup length 0 = ] [ drop ] }
                    { [ dup length 1 = ] [ nipd first swap ] }
                    [ 2nip first2 ]
                } cond
            ]
        }
        [ drop [ define-enum-elt-word ] dip ]
    } case 
    [ call( current -- next ) ] keep ;
: parse-enum-elts ( class starting-counter counter-quot -- ) 
    [
        [ scan-word-name dup ";" = not ] 2dip 
        rot 
        [ [ dup ] 3dip parse-enum-elt t ] 
        [ nipd f ] if 
    ] loop 3drop ;
: parse-enum ( class -- ) 
    [
        scan-word-name
        {
            { ";" [ f ";" unexpected ] }
            { "<" [ scan-word [ dup 0 [ 1 + ] parse-enum-elts ] dip ] } ! TODO: add type checking to parse-enum-elts
            [ [ dup dup ] dip 0 [ 1 + ] parse-enum-elt parse-enum-elts fixnum ]
        } case
    ] H{ } make define-enum-class ;
PRIVATE>
