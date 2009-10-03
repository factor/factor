USING: assocs help.markup help.syntax kernel
tools.deploy.config ;
IN: tools.deploy.config.editor

ARTICLE: "deploy-config" "Deployment configuration"
"The deployment configuration is a key/value mapping stored in the " { $snippet "deploy.factor" } " file in the vocabulary's directory. If this file does not exist, the default deployment configuration is used:"
{ $subsections default-config }
"The deployment configuration can be read and written with a pair of words:"
{ $subsections
    deploy-config
    set-deploy-config
}
"A utility word is provided to load the configuration, change a flag, and store it back to disk:"
{ $subsections set-deploy-flag }
"The " { $link "ui.tools.deploy" } " provides a graphical way of editing the configuration." ;

HELP: deploy-config
{ $values { "vocab" "a vocabulary specifier" } { "assoc" assoc } }
{ $description "Loads a vocabulary's deployment configuration from the " { $snippet "deploy.factor" } " file in the vocabulary's directory. If the file does not exist, the " { $link default-config } " is output." } ;

HELP: set-deploy-config
{ $values { "assoc" assoc } { "vocab" "a vocabulary specifier" } }
{ $description "Stores a vocabulary's deployment configuration to the " { $snippet "deploy.factor" } " file in the vocabulary's directory." } ;

HELP: set-deploy-flag
{ $values { "value" object } { "key" object } { "vocab" "a vocabulary specifier" } }
{ $description "Modifies an entry in a vocabulary's deployment configuration on disk." } ;

ABOUT: "deploy-config"
