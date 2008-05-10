
USING: kernel namespaces debugger system io io.files io.sockets
       io.encodings.utf8 prettyprint benchmark
       builder.util builder.common ;

IN: builder.report

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: (report) ( -- )

  "Build machine:   " write host-name             print
  "CPU:             " write cpu                   .
  "OS:              " write os                    .
  "Build directory: " write build-dir             print
  "git id:          " write "git-id" eval-file    print nl

  status-vm   get f = [ "compile-log"  cat   "vm compile error" throw ] when
  status-boot get f = [ "boot-log" 100 cat-n "Boot error"       throw ] when
  status-test get f = [ "test-log" 100 cat-n "Test error"       throw ] when

  "Boot time: " write "boot-time" eval-file milli-seconds>time print
  "Load time: " write "load-time" eval-file milli-seconds>time print
  "Test time: " write "test-time" eval-file milli-seconds>time print nl

  "Did not pass load-everything: " print "load-everything-vocabs" cat
      
  "Did not pass test-all: "        print "test-all-vocabs"        cat
                                         "test-failures"          cat
      
  "help-lint results:"             print "help-lint"              cat

  "Benchmarks: " print "benchmarks" eval-file benchmarks. ;

: report ( -- ) "report" utf8 [ [ (report) ] try ] with-file-writer ;