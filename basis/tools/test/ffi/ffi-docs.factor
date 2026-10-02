USING: help.markup help.syntax kernel tools.test ;
IN: tools.test.ffi

HELP: ffi-report?
{ $var-description "Enables diagnostic FFI coverage and skip reports. Reports are disabled by default. Set this variable to " { $link t } " or set the " { $snippet "FACTOR_FFI_REPORT" } " environment variable to " { $snippet "1" } " to enable them. " { $link silent-tests? } " suppresses these reports even when enabled." }
{ $notes "Reporting does not change test execution or coverage requirements. In particular, " { $snippet "FACTOR_REQUIRE_SMALL_FLOATS=1" } " still fails if the required fixtures are unavailable or their coverage is incomplete." } ;
