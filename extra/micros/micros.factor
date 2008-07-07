IN: micros
USING: micros.backend system kernel combinators vocabs.loader math ;

: micros ( -- n ) (micros) ; inline

: micro-time ( quot -- n )
  micros slip micros swap - ; inline

{
    { [ os unix? ] [ "micros.unix" ] }
    { [ os windows? ] [ "micros.windows" ] }
} cond require

