USING: accessors assocs bson calendar formatting hashtables io
io.encodings.binary io.streams.byte-array kernel math
math.parser mongodb.driver namespaces ranges sequences strings
tools.time ;
FROM: mongodb.driver => find ;
FROM: memory => gc ;
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

: small-doc ( -- quot )
    "small" set-doc [ ] ; inline

: medium-doc ( -- quot )
    "medium" set-doc [ ] ; inline

: large-doc ( -- quot )
    "large" set-doc [ ] ; inline

: small-doc-prepare ( -- quot: ( i -- doc ) )
    small-doc drop
    '[ "x" DOC-SMALL clone [ set-at ] keep ] ;

: medium-doc-prepare ( -- quot: ( i -- doc ) )
    medium-doc drop
    '[ "x" DOC-MEDIUM clone [ set-at ] keep ] ;

: large-doc-prepare ( -- quot: ( i -- doc ) )
    large-doc drop
    [
        "x" DOC-LARGE clone [ set-at ] keep
        [ now "access-time" ] dip
        [ set-at ] keep
    ] ;

: (insert) ( quot: ( i -- doc ) collection -- )
    [ trial-size ] 2dip
    '[ _ call( i -- doc ) [ _ ] dip
    result get lasterror>> [ save ] [ save-unsafe ] if ] each-integer ;

: (prepare-batch) ( i b quot: ( i -- doc ) -- batch-seq )
    [ [ * ] keep 1 range boa ] dip
    '[ _ call( i -- doc ) ] map ;

: (insert-batch) ( quot: ( i -- doc ) collection -- )
    [ trial-size batch-size [ / ] keep ] 2dip
    '[ _ _ (prepare-batch) [ _ ] dip
        result get lasterror>> [ save ] [ save-unsafe ] if
    ] each-integer ;

: bchar ( boolean -- char )
    [ "t" ] [ "f" ] if ; inline

: collection-name ( -- collection )
    collection "benchmark" get*
    result get doc>>
    result get index>> bchar
    "%s-%s-%s" sprintf
    [ [ result get ] dip >>collection drop ] keep ;

: prepare-collection ( -- collection )
    collection-name
    [ "_x_idx" drop-index ] keep
    [ drop-collection ] keep
    [ create-collection ] keep ;

: prepare-index ( collection -- )
    "_x_idx" [ "x" asc ] key-spec <index-spec> t >>unique? ensure-index ;

: insert ( doc-quot: ( i -- doc ) -- quot: ( -- ) )
    prepare-collection
    result get index>> [ [ prepare-index ] keep ] when
    result get batch>>
    [ '[ _ _ (insert-batch) ] ] [ '[ _ _ (insert) ] ] if ;

: serialize ( doc-quot: ( i -- doc ) -- quot: ( -- ) )
    '[ trial-size [ _ call( i -- doc ) assoc>bv drop ] each-integer ] ;

: deserialize ( doc-quot: ( i -- doc ) -- quot: ( -- ) )
    [ 0 ] dip call( i -- doc ) assoc>bv
    '[ trial-size [  _ binary [ H{ } stream>assoc drop ] with-byte-reader ] times ] ;

: check-for-key ( assoc key -- )
    CHECK-KEY [ swap key? [ "ups... where's the key" throw ] unless ] [ 2drop ] if ;

: (check-find-result) ( result -- )
    "x" check-for-key ; inline

: (find) ( cursor -- )
    [ find [ (check-find-result) ] each (find) ] when* ; inline recursive

: find-one ( quot -- quot: ( -- ) )
    drop
    [ trial-size
      collection-name
      trial-size 2 / "x" associate
      '[ _ _ <query> 1 limit (find) ] times ] ;

: find-all ( quot -- quot: ( -- ) )
    drop
    collection-name
    H{ } clone
    '[ _ _ <query> (find) ] ;

: find-range ( quot -- quot: ( -- ) )
    drop
    [
        trial-size batch-size /i
        collection-name
        trial-size 2 / "$gt" H{ } clone [ set-at ] keep
        [ trial-size 2 / batch-size + "$lt" ] dip [ set-at ] keep
        "x" H{ } clone [ set-at ] keep
        '[ _ _ <query> (find) ] times
    ] ;

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
      1000000000 / [ /i ] [ result get batch>> [ [ batch-size /i ] dip ] when /i ] 2bi
    "%-18s: {batch:%s,index:%s;errchk:%s} %10s docs/s %10s ops/s"
    sprintf print flush ;

: print-separator ( -- )
    "---------------------------------------------------------------------------------" print flush ; inline

: print-separator-bold ( -- )
    "=================================================================================" print flush ; inline

: print-header ( -- )
    trial-size
    batch-size
    "MongoDB Factor Driver Benchmark\n%d ops per Trial, Batch-Size: %d"
    sprintf print flush
    print-separator-bold ;

: with-result ( options quot -- )
    '[ <result> _ call( options -- time ) print-result ] with-scope ;

: [bench-quot] ( feat-seq op-word -- quot: ( doc-word -- ) )
    '[
        _ swap _
        '[
            [
                [ _ execute( -- quot ) ] dip
                [ execute( -- ) ] each _ execute( quot -- quot ) gc
                benchmark 
            ] with-result
        ] each
        print-separator
    ] ;

: run-serialization-bench ( doc-word-seq feat-seq -- )
    "Serialization Tests" print
    print-separator-bold
    \ serialize [bench-quot] '[ _ call( doc-word -- ) ] each ;

: run-deserialization-bench ( doc-word-seq feat-seq -- )
    "Deserialization Tests" print
    print-separator-bold
    \ deserialize [bench-quot] '[ _ call( doc-word -- ) ] each ;

: run-insert-bench ( doc-word-seq feat-seq -- )
    "Insert Tests" print
    print-separator-bold
    \ insert [bench-quot] '[ _ call( doc-word -- ) ] each ;

: run-find-one-bench ( doc-word-seq feat-seq -- )
    "Query Tests - Find-One" print
    print-separator-bold
    \ find-one [bench-quot] '[ _ call( doc-word -- ) ] each ;

: run-find-all-bench ( doc-word-seq feat-seq -- )
    "Query Tests - Find-All" print
    print-separator-bold
    \ find-all [bench-quot] '[ _ call( doc-word -- ) ] each ;

: run-find-range-bench ( doc-word-seq feat-seq -- )
    "Query Tests - Find-Range" print
    print-separator-bold
    \ find-range [bench-quot] '[ _ call( doc-word -- ) ] each ;


: run-benchmarks ( -- )
    "db" "db" get* "host" "127.0.0.1" get* "port" 27017 get* ensure-number <mdb>
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
