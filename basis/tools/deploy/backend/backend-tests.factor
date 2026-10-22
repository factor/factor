USING: bootstrap.image io.pathnames kernel pcre2 sequences sets
tools.deploy.backend tools.test ;
IN: tools.deploy.backend.tests

{ 8 8 } [ staging-profiles [ length ] [ members length ] bi ] unit-test
{ t } [
    { "math" "threads" "compiler" "io" } staging-profiles member?
] unit-test
{ t } [
    { "math" "threads" "compiler" "io" "ui" "unicode" "help" }
    staging-profiles member?
] unit-test
{ t } [
    staging-profiles [
        { "math" "threads" "compiler" "io" } head?
    ] all?
] unit-test
{ 11 } [
    staging-profiles [ { } [ suffix ] accumulate* ] map concat members length
] unit-test

: complete-match? ( str regexp -- ? )
    "^" "$" surround matches? ;

! deploy-command-line
{ t } [
    "image" "hello-world" "manifest.file" { "foob" } deploy-command-line
    {
        "-pic=0"
        "-i=.*foob.*"
        "-vocab-manifest-out=manifest.file"
        "-deploy-vocab=hello-world"
        "-deploy-config=.*hello-world"
        "-output-image=image"
        "-resource-path=.*"
        "-run=tools.deploy.shaker"
    } [ complete-match? ] 2all?
] unit-test

! input-image-name
{ t } [
    { "foo" } input-image-name file-name my-boot-image-name =
] unit-test

! staging-command-line
{ t } [
    { "one" "two" } staging-command-line
    {
        "-staging"
        "-no-user-init"
        "-pic=0"
        "-output-image.*"
        "-include=one two"
        "-i=.*"
        "-resource-path=.*"
        "-run=tools.deploy.restage"
    } [ complete-match? ] 2all?
] unit-test

{ t } [
    { "compiler" } staging-command-line
    {
        "-staging"
        "-no-user-init"
        "-pic=0"
        "-output-image=.*"
        "-include=compiler"
        "-i=.*"
        "-resource-path=.*"
        "-run=tools.deploy.restage"
    } [ complete-match? ] 2all?
] unit-test
