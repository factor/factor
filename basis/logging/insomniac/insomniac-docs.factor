USING: help.markup help.syntax logging.analysis ;
IN: logging.insomniac

HELP: insomniac-sender
{ $var-description "The originating e-mail address for mailing log reports. Must be set before " { $vocab-link "logging.insomniac" } " is used." } ;

HELP: insomniac-recipients
{ $var-description "A sequence of e-mail addresses to mail log reports to. Must be set before " { $vocab-link "logging.insomniac" } " is used." } ;

HELP: email-log-report
{ $values { "service" "a log service name" } { "word-names" "a sequence of strings" } }
{ $description "E-mails a log report for the given log service. The " { $link insomniac-sender } " and " { $link insomniac-recipients } " parameters must be set up first. The " { $snippet "word-names" } " parameter is documented in " { $link analyze-entries } "." } ;

HELP: schedule-insomniac
{ $values { "service" "a log service name" } { "word-names" "a sequence of strings" } }
{ $description "Starts a thread which e-mails log reports and rotates logs daily." } ;

ARTICLE: "logging.insomniac" "Automated log analysis"
"The " { $vocab-link "logging.insomniac" } " vocabulary builds on the " { $vocab-link "logging.analysis" } " vocabulary. It provides support for e-mailing log reports and rotating logs on a daily basis. E-mails are sent using the " { $vocab-link "smtp" } " vocabulary."
$nl
"Required configuration parameters:"
{ $subsections
    insomniac-sender
    insomniac-recipients
}
"E-mailing a one-off report:"
{ $subsections email-log-report }
"E-mailing reports and rotating logs on a daily basis:"
{ $subsections schedule-insomniac } ;

ABOUT: "logging.insomniac"
