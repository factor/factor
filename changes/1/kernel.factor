USING: combinators.smart ;
IN: kernel

: special-while ( initial pred: ( a -- ? ) body: ( b -- a ) -- final )
    [ [ preserving ] curry ] dip while ; inline

: special-until ( initial pred: ( a -- ? ) body: ( b -- a ) -- final )
    [ [ preserving ] curry ] dip until ; inline

: special-if ( ? true: ( -- x ) false: ( -- x ) -- choice )
    if ; inline
