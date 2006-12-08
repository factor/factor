! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions generic hashtables tools io
kernel math namespaces parser prettyprint sequences
sequences-internals strings styles vectors words errors help ;
IN: errors

: :edit ( -- )
    error get delegates [ parse-error? ] find-last nip [
        dup parse-error-file ?resource-path
        swap parse-error-line edit-location
    ] when* ;

: (:help-multi)
    "This error has multiple delegates:" print
    help-outliner terpri ;

: (:help-none)
    drop "No help for this error. " print ;

: :help ( -- )
    error get delegates [ error-help ] map [ ] subset
    {
        { [ dup empty? ] [ (:help-none) ] }
        { [ dup length 1 = ] [ first help ] }
        { [ t ] [ (:help-multi) ] }
    } cond ;
