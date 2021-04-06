USING: accessors arrays classes.dispatch.class classes.dispatch.covariant-tuples
classes.dispatch.eql effects.parser generic.multi generic.parser kernel parser
prettyprint.custom sequences words ;

IN: classes.dispatch.syntax

! * Literal syntax for dispatch specifiers

! Currently only covariant-tuple. For the moment just some convenience to
! identify and print multi-methods using the existing single method code with
! something like M\ D{ class1 class2 } generic
! But defining with M: D{ class1 class2 } generic ... ; does not turn the generic
! into a multi-generic !

: interpret-dispatch-spec ( seq -- dispatch-type )
    [ dup wrapper? [ wrapped>> <eql-specializer> ] when ] map
    <covariant-tuple> ;


SYNTAX: D{
        \ } [ interpret-dispatch-spec ] parse-literal ;

M: covariant-tuple pprint* pprint-object ;
M: covariant-tuple pprint-delims
    drop \ D{ \ } ;
M: covariant-tuple >pprint-sequence classes>> ;

: scan-new-class-method ( -- method )
    scan-class
    bootstrap-word <class-specializer> 1array <covariant-tuple> scan-word create-multi-method-in ;

: (CM:) ( -- method def ) [
        scan-new-class-method
        [ parse-method-definition ] with-method-definition
    ] with-definition ;

SYNTAX: CM: (CM:) define ;
