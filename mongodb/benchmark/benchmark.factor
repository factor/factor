USING: calendar math fry kernel assocs math.ranges bson.reader io.streams.byte-array
sequences formatting combinators namespaces io tools.time prettyprint io.encodings.binary
accessors words mongodb.driver strings math.parser tools.walker bson.writer ;

IN: mongodb.benchmark

SYMBOL: collection

: get* ( symbol default -- value )
    [ get ] dip or ; inline

: ensure-number ( v -- n )
    dup string? [ string>number ] when ; inline

: trial-size ( -- size )
    "per-trial" 5000 get* ensure-number ; inline flushable

: batch-size ( -- size )
    "batch-size" 100 get* ensure-number ; inline flushable

TUPLE: result doc collection index batch lasterror ;

: <result> ( -- ) result new result set ; inline


CONSTANT: CHECK-KEY f 

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

: set-doc ( name -- )
    [ result ] dip '[ _ >>doc ] change ; inline

: small-doc ( -- )
    "small" set-doc ; inline

: medium-doc ( -- )
    "medium" set-doc ; inline

: large-doc ( -- )
    "large" set-doc ; inline

: small-doc-prepare ( -- quot: ( i -- doc ) )
    small-doc
    '[ "x" DOC-SMALL clone [ set-at ] keep ] ; inline

: medium-doc-prepare ( -- quot: ( i -- doc ) )
    medium-doc
    '[ "x" DOC-MEDIUM clone [ set-at ] keep ] ; inline

: large-doc-prepare ( -- quot: ( i -- doc ) )
    large-doc
    [ "x" DOC-LARGE clone [ set-at ] keep 
       [ now "access-time" ] dip
       [ set-at ] keep ] ;

: (insert) ( quot: ( i -- doc ) collection -- )
    [ trial-size ] 2dip
    '[ _ call [ _ ] dip
       result get lasterror>> [ save ] [ save-unsafe ] if ] each-integer ; inline

: (prepare-batch) ( i b quot: ( i -- doc ) -- )
    [ [ * ] keep 1 range boa ] dip
    '[ _ call ] map ; inline

: (insert-batch) ( quot: ( i -- doc ) collection -- )
    [ trial-size batch-size [ / ] keep ] 2dip
    '[ _ _ (prepare-batch) [ _ ] dip
       result get lasterror>> [ save ] [ save-unsafe ] if
    ] each-integer ; inline

: bchar ( boolean -- char )
    [ "t" ] [ "f" ] if ; inline

: collection-name ( -- collection )
    collection "benchmark" get*
    result get doc>>
    result get index>> bchar
    "%s-%s-%s" sprintf
    [ [ result get ] dip >>collection drop ] keep ; inline
    
: prepare-collection ( -- collection )
    collection-name
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

: serialize ( doc-quot: ( i -- doc ) -- quot: ( -- ) )
    '[ trial-size [ _ call assoc>bv drop ] each-integer ] ; inline

: deserialize ( doc-quot: ( i -- doc ) -- quot: ( -- ) )
    [ 0 ] dip call assoc>bv
    '[ trial-size [  _ binary [ H{ } stream>assoc 2drop ] with-byte-reader ] times ] ; inline

: check-for-key ( assoc key -- )
    CHECK-KEY [ swap key? [ "ups... where's the key" throw ] unless ] [ 2drop ] if ; inline

: (check-find-result) ( result -- )
    "x" check-for-key ; inline
  
: (find) ( cursor -- )
    [ find [ (check-find-result) ] each (find) ] when* ; inline recursive

: find-one ( -- quot: ( -- ) )
    [ trial-size
      collection-name
      trial-size 2 / "x" H{ } clone [ set-at ] keep
      '[ _ _ <query> 1 limit (find) ] times ] ;
  
: find-all ( -- quot: ( -- ) )
      collection-name
      H{ } clone
      '[ _ _ <query> (find) ] ;
  
: find-range ( -- quot: ( -- ) )
    [ trial-size batch-size /i
       collection-name
       trial-size 2 / "$gt" H{ } clone [ set-at ] keep
       [ trial-size 2 / batch-size + "$lt" ] dip [ set-at ] keep
       "x" H{ } clone [ set-at ] keep
       '[ _ _ <query> find [ "x" check-for-key ] each drop ] times ] ;

: batch ( -- )
    result [ t >>batch ] change ; inline
   
: index ( -- )
    result [ t >>index ] change ; inline

: errcheck ( -- )
    result [ t >>lasterror ] change ; inline

: print-result ( time -- )
    [ result get [ collection>> ] keep
      [ batch>> bchar ] keep
      [ index>> bchar ] keep
      lasterror>> bchar
      trial-size ] dip
    1000000 / /i
    "%-18s: {batch:%s,index:%s;errchk:%s} %10s docs/s"
    sprintf print flush ; inline

: print-separator ( -- )
    "----------------------------------------------------------------" print flush ; inline

: print-separator-bold ( -- )
    "================================================================" print flush ; inline

: print-header ( -- )
    trial-size
    batch-size
    "MongoDB Factor Driver Benchmark\n%d ops per Trial, Batch-Size: %d"
    sprintf print flush
    print-separator-bold ;

: with-result ( quot: ( -- ) -- )
    [ <result> ] prepose
    [ print-result ] compose with-scope ; inline

: bench-quot ( feat-seq op-word -- quot: ( elt -- ) )
    '[ _ swap _
       '[ [ [ _ execute ] dip
            [ execute ] each _ execute benchmark ] with-result ] each
       print-separator ] ; inline

: run-serialization-bench ( doc-word-seq feat-seq -- )
    "Serialization Tests" print
    print-separator-bold
    \ serialize bench-quot each ; inline

: run-deserialization-bench ( doc-word-seq feat-seq -- )
    "Deserialization Tests" print
    print-separator-bold
    \ deserialize bench-quot each ; inline
    
: run-insert-bench ( doc-word-seq feat-seq -- )
    "Insert Tests" print
    print-separator-bold 
    \ insert bench-quot each ; inline

: run-find-one-bench ( doc-word-seq feat-seq -- )
    "Query Tests - Find-One" print
    print-separator-bold
    \ find-one bench-quot each ; inline

: run-find-all-bench ( doc-word-seq feat-seq -- )
    "Query Tests - Find-All" print
    print-separator-bold
    \ find-all bench-quot each ; inline

: run-find-range-bench ( doc-word-seq feat-seq -- )
    "Query Tests - Find-Range" print
    print-separator-bold
    \ find-range bench-quot each ; inline

    
: run-benchmarks ( -- )
    "db" "db" get* "host" "127.0.0.1" get* "port" 27020 get* ensure-number <mdb>
    [ print-header
      ! serialization
      { small-doc-prepare medium-doc-prepare
        large-doc-prepare }
      { { } } run-serialization-bench
      ! deserialization
      { small-doc-prepare medium-doc-prepare
        large-doc-prepare }
      { { } } run-deserialization-bench
      ! insert
      { small-doc-prepare medium-doc-prepare
        large-doc-prepare }
      { { } { index } { errcheck } { index errcheck }
        { batch } { batch errcheck } { batch index errcheck }
      } run-insert-bench
      ! find-one
      { small-doc medium-doc large-doc }
      { { } { index } } run-find-one-bench
      ! find-all
      { small-doc medium-doc large-doc }
      { { } { index } } run-find-all-bench
      ! find-range
      { small-doc medium-doc large-doc }
      { { } { index } } run-find-range-bench        
    ] with-db ;
        
MAIN: run-benchmarks

