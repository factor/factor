USING: furnace furnace.actions furnace.callbacks accessors
http http.server http.server.responses tools.test
namespaces io fry sequences
splitting kernel hashtables continuations ;
IN: furnace.callbacks.tests

[ 123 ] [
    [
        <request> "GET" >>method init-request
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
    <action> [
        [
            "hello" print
            <html-content>
        ] show-page
        "byebye" print
        [ 123 ] show-final
    ] >>display
    <callback-responder> "r" set

    [ 123 ] [
        <request> init-request

        [
            exit-continuation set
            <request> "GET" >>method init-request
            { } "r" get call-responder
        ] callcc1

        body>> first

        <request>
            "GET" >>method
            dup url>> rot cont-id associate >>query drop
            dup url>> "/" >>path drop
        init-request

        [
            exit-continuation set
            { }
            "r" get call-responder
        ] callcc1

        ! get-post-get
        <request>
            "GET" >>method
            dup url>> rot "location" header query>> >>query drop
            dup url>> "/" >>path drop
        init-request

        [
            exit-continuation set
            { }
            "r" get call-responder
        ] callcc1
    ] unit-test
] with-scope
