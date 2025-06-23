! Copyright (C) 2007, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators command-line io.directories kernel namespaces
sequences system tools.deploy.backend tools.deploy.config
tools.deploy.config.editor vocabs vocabs.loader command-line.parser math ;
IN: tools.deploy

ERROR: no-vocab-main vocab ;

: check-vocab-main ( vocab -- vocab )
    [ require ] keep dup vocab-main [ no-vocab-main ] unless ;

: deploy ( vocab -- )
    dup find-vocab-root [ no-vocab ] unless
    check-vocab-main
    deploy-directory get [
        dup deploy-config [
            deploy*
        ] with-variables
    ] with-directory ;

: deploy-image-only ( vocab image -- )
    [ vm-path ] 2dip
    swap dup deploy-config make-deploy-image drop ;

{
    { [ os macos? ] [ "tools.deploy.macos" ] }
    { [ os windows? ] [ "tools.deploy.windows" ] }
    { [ os unix? ] [ "tools.deploy.unix" ] }
} cond require

: deploy-main ( -- )
    "All boolean options above can be inverted by prefixing no- to the option name. for example, --console becomes --no-console" program-epilog set-global
    {
        T{ option
            { name "--console" }
            { required? f }
            { #args 0 }
            { help "If specified, enables the creation of a console application after deployment" }
            { const t }
            { variable deploy-console? }
        }
        T{ option
            { name "--ui" }
            { required? f }
            { #args 0 }
            { help "If specified, enables the the inclusion of the ui framework" }
            { const t }
            { variable deploy-ui? }
        }
        T{ option
            { name "--unicode" }
            { required? f }
            { #args 0 }
            { help "If specified, enables the the inclusion of full support for CHAR: " }
            { const t }
            { variable deploy-unicode? }
        }
        T{ option
            { name "--strip-word-props" }
            { required? f }
            { #args 0 }
            { help "If specified, enables the stripping of word properties the compiler thinks are unused" }
            { const t }
            { variable deploy-word-props? }
        }
        T{ option
            { name "--keep-c-type-info" }
            { required? f }
            { #args 0 }
            { help "If specified, disables the stripping of metadata for c types" }
            { const t }
            { variable deploy-c-types? }
        }
        T{ option
            { name "--reflection" }
            { required? f }
            { meta "LEVEL" }
            { #args 1 }
            { type integer }
            { validate [ [ 6 <= ] [ 0 > ] bi and ] }
            { help "Sets the level of reflection that is required for the deployed executable. Must be an integer between 1 and 6 (inclusive). See the help for the deploy-reflection variable to learn more" }
            { variable deploy-reflection }
        }
        T{ option
            { name "--include-help" }
            { required? f }
            { #args 0 }
            { help "If specified, enables the inclusion of documentation for all included words. This option is only helpful in a few niche situations, and shouldn't be used normally" }
            { const t }
            { variable deploy-help? }
        }
        T{ option
            { name "--include-math" }
            { required? f }
            { #args 0 }
            { help "If specified, enables the inclusion of ratio and complex number support. This option is only helpful in a few niche situations, and shouldn't be used normally" }
            { const t }
            { variable deploy-math? }
        }
        T{ option
            { name "--include-threads" }
            { required? f }
            { #args 0 }
            { help "If specified, enables the inclusion of thread support. This option is only helpful in a few niche situations, and shouldn't be used normally" }
            { const t }
            { variable deploy-threads? }
        }
        T{ option
            { name "--io" }
            { required? f }
            { meta "LEVEL" }
            { #args 1 }
            { type integer }
            { validate [ [ 3 <= ] [ 0 > ] bi and ] }
            { help "Sets the level of io support required. Must be an integer between 1 and 3 (inclusive). See the help for the deploy-io variable to learn more. This option is only helpful in a few niche situations, and shouldn't be used normally" }
            { variable deploy-io }
        }
        T{ option 
            { name "" }
            { required? t }
            { #args "+" }
            { help "The vocabulary or vocabularies to be deployed" }
            { variable "vocabs-to-deploy" }
        }
    }
    parse-options [ "vocabs-to-deploy" get [ [ require ] [ deploy ] bi ] each ] with-variables
    f program-epilog set-global ;

MAIN: deploy-main
