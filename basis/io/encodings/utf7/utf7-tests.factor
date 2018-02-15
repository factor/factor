USING: io.encodings.string io.encodings.utf7 kernel sequences strings
tools.test ;

{
    {
        "~/b&AOU-g&APg-"
        "b&AOU-x"
        "b&APg-x"
        "test"
        "Skr&AOQ-ppost"
        "Ting &- S&AOU-ger"
        "~/F&APg-lder/mailb&AOU-x &- stuff + more"
        "~peter/mail/&ZeVnLIqe-/&U,BTFw-"
    }
} [
    {
        "~/bågø"
        "båx"
        "bøx"
        "test"
        "Skräppost"
        "Ting & Såger"
        "~/Følder/mailbåx & stuff + more"
        "~peter/mail/日本語/台北"
    } [ utf7imap4 encode >string ] map
] unit-test

{ t } [
    {
        "~/bågø"
        "båx"
        "bøx"
        "test"
        "Skräppost"
        "Ting & Såger"
        "~/Følder/mailbåx & stuff + more"
        "~peter/mail/日本語/台北"
    } dup [ utf7 encode utf7 decode ] map =
] unit-test

{ t } [
    {
        "~/bågø"
        "båx"
        "bøx"
        "test"
        "Skräppost"
        "Ting & Såger"
        "~/Følder/mailbåx & stuff + more"
        "~peter/mail/日本語/台北"
    } dup [ utf7imap4 encode utf7imap4 decode ] map =
] unit-test
