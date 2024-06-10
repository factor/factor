USING: io.streams.escape-codes io.styles tools.test ;

{ "Hello" } [ "\e[4mHello\e[0m" strip-ansi-escapes ] unit-test
{ "\e[1m\e[3m" } [ { bold italic } ansi-font-style ] unit-test
{ { "-a- b" "\e[1mA\e[0m   B" } } [
  { { "-a-" "b" } { "\e[1mA\e[0m" "B" } } format-ansi-table
] unit-test
