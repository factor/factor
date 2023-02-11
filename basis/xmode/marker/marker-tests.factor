USING: xmode.tokens xmode.catalog
xmode.marker tools.test kernel ;

{
    {
        T{ token f "int" KEYWORD3 }
        T{ token f " " f }
        T{ token f "x" f }
    }
} [ f "int x" "c" load-mode tokenize-line nip ] unit-test

{
    {
        T{ token f "\"" LITERAL1 }
        T{ token f "hello\\\"" LITERAL1 }
        T{ token f " " LITERAL1 }
        T{ token f "world" LITERAL1 }
        T{ token f "\"" LITERAL1 }
    }
} [ f "\"hello\\\" world\"" "c" load-mode tokenize-line nip ] unit-test

{
    {
        T{ token f "\"" LITERAL1 }
        T{ token f "hello\\\ world" LITERAL1 }
        T{ token f "\"" LITERAL1 }
    }
} [ f "\"hello\\\ world\"" "c" load-mode tokenize-line nip ] unit-test

{
    {
        T{ token f "int" KEYWORD3 }
        T{ token f " " f }
        T{ token f "x" f }
    }
} [ f "int x" "java" load-mode tokenize-line nip ] unit-test

{
    {
        T{ token f "#" COMMENT1 }
        T{ token f " " COMMENT1 }
        T{ token f "hello" COMMENT1 }
        T{ token f " " COMMENT1 }
        T{ token f "world" COMMENT1 }
    }
} [ f "# hello world" "python" load-mode tokenize-line nip ] unit-test


{
    {
        T{ token f "hello" f }
        T{ token f " " f }
        T{ token f "world" f }
        T{ token f ":" f }
    }
} [ f "hello world:" "java" load-mode tokenize-line nip ] unit-test

{
    {
        T{ token f "hello_world" LABEL }
        T{ token f ":" OPERATOR }
    }
} [ f "hello_world:" "java" load-mode tokenize-line nip ] unit-test

{
    {
        T{ token f "\t" f }
        T{ token f "hello_world" LABEL }
        T{ token f ":" OPERATOR }
    }
} [ f "\thello_world:" "java" load-mode tokenize-line nip ] unit-test

{
    {
        T{ token f "<!" KEYWORD2 }
        T{ token f "ELEMENT" KEYWORD2 }
        T{ token f " " KEYWORD2 }
        T{ token f "%" LITERAL2 }
        T{ token f "hello" LITERAL2 }
        T{ token f ";" LITERAL2 }
        T{ token f " " KEYWORD2 }
        T{ token f ">" KEYWORD2 }
    }
} [
    f "<!ELEMENT %hello; >" "xml" load-mode tokenize-line nip
] unit-test

{
    {
        T{ token f "<!" KEYWORD2 }
        T{ token f "ELEMENT" KEYWORD2 }
        T{ token f " " KEYWORD2 }
        T{ token f "%" LITERAL2 }
        T{ token f "hello-world" LITERAL2 }
        T{ token f ";" LITERAL2 }
        T{ token f " " KEYWORD2 }
        T{ token f ">" KEYWORD2 }
    }
} [
    f "<!ELEMENT %hello-world; >" "xml" load-mode tokenize-line nip
] unit-test

{
    {
        T{ token f "$" KEYWORD2 }
        T{ token f "FOO" KEYWORD2 }
    }
} [
    f "$FOO" "shellscript" load-mode tokenize-line nip
] unit-test

{
    {
        T{ token f "AND" KEYWORD1 }
    }
} [
    f "AND" "pascal" load-mode tokenize-line nip
] unit-test

{
    {
        T{ token f "Comment {" COMMENT1 }
        T{ token f "XXX" COMMENT1 }
        T{ token f "}" COMMENT1 }
    }
} [
    f "Comment {XXX}" "rebol" load-mode tokenize-line nip
] unit-test

{

} [
    f "font:75%/1.6em \"Lucida Grande\", \"Lucida Sans Unicode\", verdana, geneva, sans-serif;" "css" load-mode tokenize-line 2drop
] unit-test

{
    {
        T{ token f "<" MARKUP }
        T{ token f "aaa" MARKUP }
        T{ token f ">" MARKUP }
    }
} [ f "<aaa>" "html" load-mode tokenize-line nip ] unit-test
