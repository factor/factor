USING: calendar tools.cal.private tools.test ;
IN: tools.cal.tests

{
    "    October 2010    "
} [
    2010 10 10 <date> month-header
] unit-test

{
    "                              2010                              "
} [
    2010 10 10 <date> year-header
] unit-test
