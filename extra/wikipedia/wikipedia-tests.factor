USING: calendar tools.test urls wikipedia.private ;
IN: wikipedia.tests

{
    URL" http://en.wikipedia.org/wiki/October_10"
} [
    2010 10 10 <date> historical-url
] unit-test
