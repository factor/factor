USING: macros quotations math math.functions math.trig 
sequences.deep kernel make fry combinators grouping ;
IN: 4DNav.deep

! USING: bake ;
! MACRO: deep-cleave-quots ( seq -- quot )
!    [ [ quotation? ] deep-filter ]
!    [ [ dup quotation? [ drop , ] when ] deep-map ]
!    bi '[ _ cleave _ bake ] ;

: make-matrix ( quot width -- matrix ) 
    [ { } make ] dip group ; inline

