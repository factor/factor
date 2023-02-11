! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: site-watcher.db site-watcher.email site-watcher.spider
spider spider.report
accessors kernel sequences
xml.writer concurrency.combinators ;
IN: site-watcher.spider

: <site-spider> ( spidering-site -- spider )
    [ max-depth>> ]
    [ max-count>> ]
    [ site>> url>> ]
    tri
    <spider>
        swap >>max-count
        swap >>max-depth ;

: spider-and-email ( spidering-site -- )
    [ ]
    [ <site-spider> run-spider spider-report xml>string ]
    [ site>> url>> "Spidered " prefix ] tri
    send-site-email ;

: spider-sites ( -- )
    f spidering-sites [ spider-and-email ] parallel-each ;
