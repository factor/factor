! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: calendar combinators.short-circuit kernel math math.order
shuffle threads ;
IN: backoff

: exponential-backoff-from ( quot: ( -- success? ) max-seconds max-count/f n -- )
    2dup { [ drop ] [ <= ] } 2&& [
        4drop
    ] [
        [ nip 2^ min seconds sleep call ] 4keep 5roll [
            4drop
        ] [
            1 + exponential-backoff-from
        ] if
    ] if ; inline recursive

: exponential-backoff-count ( quot: ( -- success? ) max-seconds max-count -- )
    0 exponential-backoff-from ; inline

: exponential-backoff ( quot: ( -- success? ) max-seconds -- )
    f exponential-backoff-count ; inline
