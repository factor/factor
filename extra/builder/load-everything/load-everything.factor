
USING: kernel continuations io io.files prettyprint vocabs.loader
       tools.time tools.browser ;

IN: builder.load-everything

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: runtime ( quot -- time ) benchmark nip ;

: log-runtime ( quot file -- )
  >r runtime r> <file-writer> [ . ] with-stream ;

: log-object ( object file -- ) <file-writer> [ . ] with-stream ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: do-load-everything ( -- )
  [ [ load-everything ] catch ] "../load-everything-time" log-runtime
  [ require-all-error-vocabs    "../load-everything-log"  log-object ]
  when ;

MAIN: do-load-everything