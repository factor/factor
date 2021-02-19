USING: accessors classes.dispatch.covariant-tuples classes.dispatch.eql kernel
parser prettyprint.custom sequences ;

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
