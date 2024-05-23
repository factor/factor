USING: accessors continuations fry http.client images.loader
images.loader.private images.viewer io io.styles kernel memoize
prettyprint sequences twitter assocs ;
IN: twitter.prettyprint

MEMO: load-http-image ( url -- image/f )
    '[ _
        [ http-get nip ] [ image-class ] bi load-image*
    ] [ drop f ] recover ;

: user-image ( user -- image/f )
    profile-image-url>> load-http-image ;

CONSTANT: tweet-table-style
    H{ { table-gap { 5 5 } } }

CONSTANT: tweet-username-style
    H{
        { font-style bold }
    }

CONSTANT: tweet-text-style
    H{
        { font-name "sans-serif" }
        { font-size 16 }
        { wrap-margin 500 }
    }

CONSTANT: tweet-metadata-style
    H{
        { font-size 10 }
    }

: profile. ( user -- )
    tweet-table-style [
        [
            [ dup "profile_image_url" of load-http-image image. ] with-cell
            [
                tweet-username-style [
                    dup "name" of print
                    dup "screen_name" of write
                ] with-style
            ] with-cell
        ] with-row
    ] tabular-output nl
    drop ;

: tweet. ( status -- )
    tweet-table-style [
        [
            [ dup user>> user-image [ image. ] when* ] with-cell
            [
                H{ { wrap-margin 600 } } [
                    tweet-text-style [
                        tweet-username-style [
                            dup user>> screen-name>> write
                        ] with-style
                        bl dup text>> print

                        tweet-metadata-style [
                            dup created-at>> write
                            " via " write
                            dup source>> write
                        ] with-style
                    ] with-style
                ] with-nesting
            ] with-cell
        ] with-row
    ] tabular-output nl
    drop ;

: user-profile.      ( user -- ) user-profile      profile. ;
: friends-timeline.  ( -- )      friends-timeline  [ tweet. ] each ;
: public-timeline.   ( -- )      public-timeline   [ tweet. ] each ;
: user-timeline.     ( user -- ) user-timeline     [ tweet. ] each ;
: home-timeline.     ( -- )      home-timeline     [ tweet. ] each ;
: mentions-timeline. ( -- )      mentions-timeline [ tweet. ] each ;
