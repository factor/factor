USING: io kernel namespaces ;

! Closed input must reach EOF, and discarded output must still flush.
f read1 assert=
"output" print flush
error-stream get [ "error" print flush ] with-output-stream*
