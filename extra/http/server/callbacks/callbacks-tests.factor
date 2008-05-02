IN: http.server.callbacks
USING: http.server.actions http.server.callbacks accessors
http.server http tools.test namespaces io fry sequences
splitting kernel hashtables continuations ;

[ 123 ] [
    [
        init-request

        <request> "GET" >>method request set
        [
            exit-continuation set
            { }
            <action> [ [ "hello" print 123 ] show-final ] >>display
            <callback-responder>
            call-responder
        ] callcc1
    ] with-scope
] unit-test

[
    init-request

    <action> [
        [
            "hello" print
            '[ , write ] <html-content>
        ] show-page
        "byebye" print
        [ 123 ] show-final
    ] >>display
    <callback-responder> "r" set

    [ 123 ] [
        [
            exit-continuation set
            <request> "GET" >>method request set
            { } "r" get call-responder
        ] callcc1

        body>> first

        <request>
            "GET" >>method
            swap cont-id associate >>query
            "/" >>path
        request set

        [
            exit-continuation set
            { }
            "r" get call-responder
        ] callcc1

        ! get-post-get
        <request>
            "GET" >>method
            swap "location" header "=" last-split1 nip cont-id associate >>query
            "/" >>path
        request set

        [
            exit-continuation set
            { }
            "r" get call-responder
        ] callcc1
    ] unit-test
] with-scope
