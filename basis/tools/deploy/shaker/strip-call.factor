! Copyright (C) 2009 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: tools.deploy.shaker.call

IN: combinators
USE: combinators.private

: call-effect ( word effect -- ) call-effect-unsafe ; inline

: execute-effect ( word effect -- ) execute-effect-unsafe ; inline