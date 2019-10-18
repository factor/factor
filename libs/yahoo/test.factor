USING: test yahoo kernel io xml sequences ;

[ T{
    result
    f
    "Official Foo Fighters"
    "http://www.foofighters.com/"
    "Official site with news, tour dates, discography, store, community, and more."
} ] [ "libs/yahoo/test-results.xml" resource-path <file-reader> read-xml parse-yahoo first ] unit-test

[ "http://search.yahooapis.com/WebSearchService/V1/webSearch?appid=Factor-search&query=hi&results=1" ] [ "hi" 1 query ] unit-test
