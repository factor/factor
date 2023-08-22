! Copyright (C) 2009, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.live-intervals
compiler.cfg.linear-scan.ranges hints kernel math namespaces
sequences ;
IN: compiler.cfg.linear-scan.allocation.splitting

: split-uses ( uses n -- before after )
    [ '[ n>> _ < ] filter ] [ '[ n>> _ > ] filter ] 2bi ;

ERROR: splitting-too-early ;

ERROR: splitting-too-late ;

ERROR: splitting-atomic-interval ;

: check-split ( live-interval n -- )
    check-allocation? get [
        [ [ live-interval-start ] dip > [ splitting-too-early ] when ]
        [ [ live-interval-end ] dip < [ splitting-too-late ] when ]
        [
            drop ranges>> ranges-endpoints =
            [ splitting-atomic-interval ] when
        ] 2tri
    ] [ 2drop ] if ; inline

: split-before ( before -- before' )
    f >>spill-to ; inline

: split-after ( after -- after' )
    f >>reg f >>reload-from ; inline

:: split-interval ( live-interval n -- before after )
    live-interval n check-split
    live-interval clone :> before
    live-interval clone :> after
    live-interval uses>> n split-uses before after [ uses<< ] bi-curry@ bi*
    live-interval ranges>> n split-ranges before after [ ranges<< ] bi-curry@ bi*
    before split-before
    after split-after ;

HINTS: split-interval live-interval-state object ;
