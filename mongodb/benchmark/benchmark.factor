USING: mongodb.driver calendar math fry kernel assocs math.ranges
sequences formatting combinators namespaces io tools.time prettyprint
accessors words ;

IN: mongodb.benchmark

SYMBOLS: per-trial batch-size collection host db port ;

: get* ( symbol default -- value )
    [ get ] dip or ; inline

TUPLE: result doc index batch lasterror ;

: <result> ( -- ) result new result set ; inline

CONSTANT: DOC-SMALL H{ }

CONSTANT: DOC-MEDIUM H{ { "integer" 5 }
                        { "number" 5.05 }
                        { "boolean" f }
                        { "array"
                          { "test" "benchmark" } } }

CONSTANT: DOC-LARGE H{ { "base_url" "http://www.example.com/test-me" }
                       { "total_word_count" 6743 }
                       { "access_time" f } 
                       { "meta_tags" H{ { "description" "i am a long description string" }
                                        { "author" "Holly Man" }
                                        { "dynamically_created_meta_tag" "who know\n what" } } }
                       { "page_structure" H{ { "counted_tags" 3450 }
                                             { "no_of_js_attached" 10 }
                                             { "no_of_images" 6 } } }
                       { "harvested_words" { "10gen" "web" "open" "source" "application" "paas" 
                                             "platform-as-a-service" "technology" "helps" 
                                             "developers" "focus" "building" "mongodb" "mongo"
                                             "10gen" "web" "open" "source" "application" "paas" 
                                             "platform-as-a-service" "technology" "helps" 
                                             "developers" "focus" "building" "mongodb" "mongo"
                                             "10gen" "web" "open" "source" "application" "paas" 
                                             "platform-as-a-service" "technology" "helps" 
                                             "developers" "focus" "building" "mongodb" "mongo"
                                             "10gen" "web" "open" "source" "application" "paas" 
                                             "platform-as-a-service" "technology" "helps" 
                                             "developers" "focus" "building" "mongodb" "mongo"
                                             "10gen" "web" "open" "source" "application" "paas" 
                                             "platform-as-a-service" "technology" "helps" 
                                             "developers" "focus" "building" "mongodb" "mongo"
                                             "10gen" "web" "open" "source" "application" "paas" 
                                             "platform-as-a-service" "technology" "helps" 
                                             "developers" "focus" "building" "mongodb" "mongo"
                                             "10gen" "web" "open" "source" "application" "paas" 
                                             "platform-as-a-service" "technology" "helps" 
                                             "developers" "focus" "building" "mongodb" "mongo"
                                             "10gen" "web" "open" "source" "application" "paas" 
                                             "platform-as-a-service" "technology" "helps" 
                                             "developers" "focus" "building" "mongodb" "mongo"
                                             "10gen" "web" "open" "source" "application" "paas" 
                                             "platform-as-a-service" "technology" "helps" 
                                             "developers" "focus" "building" "mongodb" "mongo"
                                             "10gen" "web" "open" "source" "application" "paas" 
                                             "platform-as-a-service" "technology" "helps" 
                                             "developers" "focus" "building" "mongodb" "mongo"
                                             "10gen" "web" "open" "source" "application" "paas" 
                                             "platform-as-a-service" "technology" "helps" 
                                             "developers" "focus" "building" "mongodb" "mongo"
                                             "10gen" "web" "open" "source" "application" "paas" 
                                             "platform-as-a-service" "technology" "helps" 
                                             "developers" "focus" "building" "mongodb" "mongo"
                                             "10gen" "web" "open" "source" "application" "paas" 
                                             "platform-as-a-service" "technology" "helps" 
                                             "developers" "focus" "building" "mongodb" "mongo"
                                             "10gen" "web" "open" "source" "application" "paas" 
                                             "platform-as-a-service" "technology" "helps" 
                                             "developers" "focus" "building" "mongodb" "mongo"
                                             "10gen" "web" "open" "source" "application" "paas" 
                                             "platform-as-a-service" "technology" "helps" 
                                             "developers" "focus" "building" "mongodb" "mongo"
                                             "10gen" "web" "open" "source" "application" "paas" 
                                             "platform-as-a-service" "technology" "helps" 
                                             "developers" "focus" "building" "mongodb" "mongo"
                                             "10gen" "web" "open" "source" "application" "paas" 
                                             "platform-as-a-service" "technology" "helps" 
                                             "developers" "focus" "building" "mongodb" "mongo"
                                             "10gen" "web" "open" "source" "application" "paas" 
                                             "platform-as-a-service" "technology" "helps" 
                                             "developers" "focus" "building" "mongodb" "mongo"
                                             "10gen" "web" "open" "source" "application" "paas" 
                                             "platform-as-a-service" "technology" "helps" 
                                             "developers" "focus" "building" "mongodb" "mongo"
                                             "10gen" "web" "open" "source" "application" "paas" 
                                             "platform-as-a-service" "technology" "helps" 
                                             "developers" "focus" "building" "mongodb" "mongo" } } }

: small-doc ( -- quot: ( i -- doc ) )
    result [ "small" >>doc ] change
    DOC-SMALL clone 
    '[ "x" _ [ set-at ] keep ] ; inline

: medium-doc ( -- quot: ( i -- doc ) )
    result [ "medium" >>doc ] change
    DOC-MEDIUM clone
    '[ "x" _ [ set-at ] keep ] ; inline

: large-doc ( -- quot: ( i -- doc ) )
    result [ "large" >>doc ] change
    DOC-LARGE clone 
    '[ "x" _ [ set-at ] keep 
       [ now "access-time" ] dip
       [ set-at ] keep ] ;

: (insert) ( quot: ( i -- doc ) collection -- )
    [ per-trial get ] 2dip
    '[ _ call [ _ ] dip
       result get lasterror>> [ save ] [ save-unsafe ] if ] each-integer ; inline

: (prepare-batch) ( i b quot: ( i -- doc ) -- )
    [ [ * ] keep 1 range boa ] dip
    '[ _ call ] map ; inline

: (insert-batch) ( quot: ( i -- doc ) collection -- )
    [ per-trial get batch-size get [ / ] keep ] 2dip
    '[ _ _ (prepare-batch) [ _ ] dip
       result get lasterror>> [ save ] [ save-unsafe ] if
    ] each-integer ; inline

: prepare-collection ( -- collection )
    collection "benchmark" get*
    [ "_x_idx" drop-index ] keep
    [ drop-collection ] keep
    [ create-collection ] keep ; inline

: prepare-index ( collection -- )
    "_x_idx" H{ { "x" 1 } } ensure-index ; inline

: insert ( doc-quot: ( i -- doc ) -- quot: ( -- ) )
    prepare-collection 
    result get index>> [ [ prepare-index ] keep ] when
    result get batch>>
    [ '[ _ _ (insert-batch) ] ] [ '[ _ _ (insert) ] ] if ;

: batch ( -- )
    result [ t >>batch ] change ; inline
   
: index ( -- )
    result [ t >>index ] change ; inline

: errcheck ( -- )
    result [ t >>lasterror ] change ; inline

: bchar ( boolean -- char )
    [ "t" ] [ "f" ] if ; inline

: print-result ( time -- )
    [ result get [ doc>> ] keep
      [ batch>> bchar ] keep
      [ index>> bchar ] keep
      lasterror>> bchar
      per-trial get ] dip
    1000000 / /i
    "%-6s: {batch:%s,index:%s;errchk:%s} %7s op/s"
    sprintf print flush ; inline

: print-separator ( -- )
    "-----------------------------------------------" print flush ; inline

: print-header ( -- )
    per-trial get
    batch-size get
    "MongoDB Factor Driver Benchmark\n%d ops per Trial, Batch-Size: %d\n"
    sprintf print flush
    print-separator ;

: with-result ( quot: ( -- ) -- )
    [ <result> ] prepose
    [ print-result ] compose with-scope ; inline

: run-insert-bench ( doc-word-seq feat-seq -- )
    '[ _ swap
       '[ [ [ _ execute ] dip
            [ execute ] each insert benchmark ] with-result ] each
       print-separator ] each ;
    
: run-benchmarks ( -- )
    db "db" get* host "127.0.0.1" get* port 27020 get* <mdb>
    [
        print-header
        { small-doc medium-doc large-doc }
        { { } { errcheck } { batch } { batch errcheck }
          { index } { index errcheck } { batch index errcheck } } run-insert-bench
    ] with-db ;
        

