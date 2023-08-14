
USING: html multiline tools.test xml.writer ;

{
    [=[ <a href="https://en.wikipedia.org/wiki/Minor_%28linear_algebra%29">minor on Wikipedia</a>]=]
} [
    "minor on Wikipedia"
    "https://en.wikipedia.org/wiki/Minor_(linear_algebra)"
    simple-link xml>string
] unit-test

{
    [=[ <a href="https://en.wikipedia.org/wiki/Minor_%28linear_algebra%29">minor on Wikipedia</a>]=]
} [
    "minor on Wikipedia"
    "https://en.wikipedia.org/wiki/Minor_%28linear_algebra%29"
    simple-link xml>string
] unit-test
