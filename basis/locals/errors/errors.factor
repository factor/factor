! Copyright (C) 2007, 2008 Slava Pestov, Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel summary ;
IN: locals.errors

ERROR: >r/r>-in-lambda-error ;

M: >r/r>-in-lambda-error summary
    drop
    "Explicit retain stack manipulation is not permitted in lambda bodies" ;

ERROR: binding-form-in-literal-error ;

M: binding-form-in-literal-error summary
    drop "[let and [let* not permitted inside literals" ;

ERROR: local-writer-in-literal-error ;

M: local-writer-in-literal-error summary
    drop "Local writer words not permitted inside literals" ;

ERROR: local-word-in-literal-error ;

M: local-word-in-literal-error summary
    drop "Local words not permitted inside literals" ;

ERROR: :>-outside-lambda-error ;

M: :>-outside-lambda-error summary
    drop ":> cannot be used outside of lambda expressions" ;

ERROR: bad-local args obj ;

M: bad-local summary
    drop "You have found a bug in locals. Please report." ;

ERROR: bad-rewrite args obj ;

M: bad-rewrite summary
    drop "You have found a bug in locals. Please report." ;
