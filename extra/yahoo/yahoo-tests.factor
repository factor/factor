USING: tools.test yahoo kernel io.files xml sequences accessors urls ;

{ T{
    result
    f
    "Official Foo Fighters"
    "http://www.foofighters.com/"
    "Official site with news, tour dates, discography, store, community, and more."
} } [ "resource:extra/yahoo/test-results.xml" file>xml parse-yahoo first ] unit-test

{
    URL" https://search.yahooapis.com/WebSearchService/V1/webSearch?appid=Factor-search&query=hi&results=2&similar_ok=1"
} [
    "hi" <search> "Factor-search" >>appid 2 >>results t >>similar-ok query
] unit-test
