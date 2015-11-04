USING: tools.test yahoo kernel io.files xml sequences accessors urls ;

{ T{
    result
    f
    "Official Foo Fighters"
    "http://www.foofighters.com/"
    "Official site with news, tour dates, discography, store, community, and more."
} } [ "resource:extra/yahoo/test-results.xml" file>xml parse-yahoo first ] unit-test

{ URL" http://search.yahooapis.com/WebSearchService/V1/webSearch?similar_ok=1&appid=Factor-search&results=2&query=hi" }
[ "hi" <search> "Factor-search" >>appid 2 >>results t >>similar-ok query ] unit-test
