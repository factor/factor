USING: help.markup help.syntax mediawiki.api ;
IN: mediawiki.api

ARTICLE: "mediawiki.api" "MediaWiki API"
{ $url "https://www.mediawiki.org/wiki/API:Main_page" }
{ $heading "Configuration" }
"Set " { $snippet "endpoint" } " to the API entry point. An "
"example for Wikimedia wikis:"
{ $code
"USING: formatting mediawiki.api namespaces ;"
": wikimedia-url ( lang family -- str )"
"    \"https://%s.%s.org/w/api.php\" sprintf ;"
"\"en\" \"wikipedia\" wikimedia-url endpoint set-global" }
$nl
"For Wikimedia wikis, also provide contact information in " {
$snippet "contact" } " so that wiki operators can contact you in "
"case of malfunction, including username or email, and possibly "
"the task name:"
{ $code
"USING: mediawiki.api namespaces ;"
"\"BotName/Task1 (email@address.tld)\" contact set-global" }
$nl
"OAuth login with an owner-only consumer:"
{ $code
"USING: mediawiki.api namespaces ;"
"\"consumer-token\""
"\"consumer-secret\""
"\"access-token\""
"\"access-secret\""
"<oauth-login> oauth-login set-global" }
$nl
"Login with username and password:"
{ $code
"USING: mediawiki.api namespaces ;"
"\"username\""
"\"password\""
"<password-login> password-login set-global" }
$nl
"If both login methods are given, OAuth is preferred. If none "
"are given, you're not logged in."
$nl
"If you use several wikis simultaneously, you might want to save "
"your " { $snippet "cookies" } " (if you use the password login "
"method) and your " { $snippet "csrf-token" } ". You also should "
"invalidate your csrf-token before using an action that requires "
"a csrf token in a wiki for the first time:"
{ $code
"USING: mediawiki.api namespaces ;"
"f csrf-token set-global" }

{ $heading "Usage" }
"Main entry point:"
{ $subsections api-call }
"Query the API:"
{ $subsections query page-content }
"Actions that require a csrf token:"
{ $subsections token-call edit-page move-page email }
"Sometimes you need to loop over a non-query API call:"
{ $subsection call-continue } ;

HELP: api-call
{ $values
    { "params" "an assoc of API parameters" }
    { "assoc" "a parsed JSON result" } }
{ $description
"Makes a call to a MediaWiki API. Retries on certain error"
"conditions. Uses a maxlag value of 5 and, in the case of"
"replication lag, pauses for the amount of time specified by the"
"API. Pauses 10 minutes on non-200 status codes and 5 minutes"
"when the database is set to readonly. Prints debug information"
"on non-200 status codes and JSON parse failure. Prints API"
"warnings and errors." }
{ $examples
{ $code
"USING: locals mediawiki.api ;"
"{"
"    { \"meta\" \"tokens\" }"
"    { \"type\" \"watch\" }"
"} query \"watchtoken\" of"
"[| token | {"
"    { \"action\" \"watch\" }"
"    { \"titles\" {"
"       \"Volkswagen Beetle\""
"       \"Factor (programming language)\""
"   } }"
"    { \"token\" token }"
"} api-call ] call drop" } } ;

HELP: query
{ $values
    { "params" "an assoc of query parameters" }
    { "seq" "a stripped parsed JSON result" } }
{ $description
"Makes an API query and extracts the query result from the"
"JSON."
$nl
"The following two code snippets are equivalent:"
{ $code
"{"
"     { \"action\" \"query\" }"
"     { \"meta\" \"userinfo\" }"
"} api-call"
"\"query\" \"userinfo\" \"name\" [ of ] tri@" }
{ $code " { { \"meta\" \"userinfo\" } } query \"name\" of" }
$nl
"The following two code snippets are also equivalent:"
{ $code
"{"
"    { \"action\" \"query\" }"
"    { \"list\" \"watchlistraw\" }"
"} api-call"
"\"watchlistraw\" of" }
{ $code " { { \"list\" \"watchlistraw\" } } query" } } ;

HELP: page-content
{ $values
    { "title" "a page title" }
    { "content" "a page content" } }
{ $description
"Gets the page content of the most current revision." } ;

HELP: token-call
{ $values
    { "params" "an assoc of API call parameters" }
    { "assoc" "a parsed JSON result" } }
{ $description
"Constructs API call with csrf token, fetches token if necessary." }
{ $notes "This word is used in the implementation of "
{ $links edit-page move-page } " and " { $link email } "." } ;

HELP: edit-page
{ $values
    { "title" "a page title" }
    { "text" "a page content" }
    { "summary" "an edit summary" }
    { "params" "an assoc of additional parameters (section,
    minor)" }
    { "assoc" "a parsed JSON result" } }
{ $description
"Changes the content of a page. In conjunction with "
{ $link page-content } ", it uses the revision timstamp and the"
"timestamp of when you begin editing for edit-conflict"
"detection."
$nl
"You can disable the bot flag by setting " { $snippet "botflag" }
" to " { $link f } ":"
{ $code "f botflag set-global" } } ;

HELP: move-page
{ $values
    { "from" "a page source" }
    { "to" "a page destination" }
    { "reason" "a summary" }
    { "params" "an assoc of additional parameters" }
    { "assoc" "a parsed JSON result" } }
{ $description
"Moves " { $snippet "from" } " to " { $snippet "to" } ". Also moves"
"talk pages." } ;

HELP: email
{ $values
    { "target" "a username" }
    { "subject" "a subject line" }
    { "text" "a message body" }
    { "assoc" "a parsed JSON result" } }
{ $description "Sends an email to " { $snippet "target" } "." } ;

HELP: call-continue
{ $values
    { "params" "an assoc of API call parameters" }
    { "quot1" { $quotation ( params -- obj assoc ) } }
    { "quot2" { $quotation ( ... -- ... ) } }
    { "seq" { "a sequence" } } }
{ $description "Calls the API until all input is consumed." }
{ $notes "This word is used in the implementation of "
{ $link query } "." }
{ $examples
{ $code
"USING: mediawiki.api assocs kernel ;"
"{"
"    { \"meta\" \"tokens\" }"
"    { \"type\" \"watch\" }"
"} query \"watchtoken\" of "
"\"Category:Concatenative programming languages\""
"\"Category:Stack-oriented programming languages\""
"[| token cat | {"
"    { \"action\" \"watch\" }"
"    { \"generator\" \"categorymembers\" }"
"    { \"gcmtitle\" cat }"
"    { \"gcmnamespace\" 0 }"
"    { \"gcmtype\" \"page\" }"
"    { \"gcmlimit\" 50 }"
"    { \"token\" token }"
"} [ api-call dup ] [ ] call-continue drop ] bi-curry@ bi" } } ;

ABOUT: "mediawiki.api"
