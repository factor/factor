USING: help.markup help.syntax io kernel math quotations
opengl.gl assocs ;
IN: opengl.capabilities

HELP: gl-version
{ $values { "version" "The version string from the OpenGL implementation" } }
{ $description "Wrapper for " { $snippet "GL_VERSION glGetString" } " that removes the vendor-specific information from the version string." } ;

HELP: gl-vendor-version
{ $values { "version" "The vendor-specific version information from the OpenGL implementation" } }
{ $description "Wrapper for " { $snippet "GL_VERSION glGetString" } " that returns only the vendor-specific information from the version string." } ;

HELP: has-gl-version?
{ $values { "version" "A version string" } { "?" boolean } }
{ $description "Compares the version string returned by " { $link gl-version } " to " { $snippet "version" } ". Returns true if the implementation version meets or exceeds " { $snippet "version" } "." } ;

HELP: require-gl-version
{ $values { "version" "A version string" } }
{ $description "Throws an exception if " { $link has-gl-version? } " returns false for " { $snippet "version" } "." } ;

HELP: glsl-version
{ $values { "version" "The GLSL version string from the OpenGL implementation" } }
{ $description "Wrapper for " { $snippet "GL_SHADING_LANGUAGE_VERSION glGetString" } " that removes the vendor-specific information from the version string." } ;

HELP: glsl-vendor-version
{ $values { "version" "The vendor-specific GLSL version information from the OpenGL implementation" } }
{ $description "Wrapper for " { $snippet "GL_SHADING_LANGUAGE_VERSION glGetString" } " that returns only the vendor-specific information from the version string." } ;

HELP: has-glsl-version?
{ $values { "version" "A version string" } { "?" boolean } }
{ $description "Compares the version string returned by " { $link glsl-version } " to " { $snippet "version" } ". Returns true if the implementation version meets or exceeds " { $snippet "version" } "." } ;

HELP: require-glsl-version
{ $values { "version" "A version string" } }
{ $description "Throws an exception if " { $link has-glsl-version? } " returns false for " { $snippet "version" } "." } ;

HELP: gl-extensions
{ $values { "seq" "A sequence of strings naming the implementation-supported OpenGL extensions" } }
{ $description "Wrapper for " { $snippet "GL_EXTENSIONS glGetString" } " that returns a sequence of extension names supported by the OpenGL implementation." } ;

HELP: has-gl-extensions?
{ $values { "extensions" "A sequence of extension name strings" } { "?" boolean } }
{ $description "Returns true if the set of " { $snippet "extensions" } " is a subset of the implementation-supported extensions returned by " { $link gl-extensions } ". Elements of " { $snippet "extensions" } " can be sequences, in which case true will be returned if any one of the extensions in the subsequence are available." }
{ $examples "Testing for framebuffer object and pixel buffer support:"
    { $code "{
    { \"GL_EXT_framebuffer_object\" \"GL_ARB_framebuffer_object\" }
    \"GL_ARB_pixel_buffer_object\"
} has-gl-extensions?" }
} ;

HELP: has-gl-version-or-extensions?
{ $values { "version" "A version string" } { "extensions" "A sequence of extension name strings" } { "?" boolean } }
{ $description "Returns true if either " { $link has-gl-version? } " or " { $link has-gl-extensions? } " returns true for " { $snippet "version" } " or " { $snippet "extensions" } ", respectively. Intended for use when required OpenGL functionality can be verified either by a minimum version or a set of equivalent extensions." } ;

HELP: require-gl-extensions
{ $values { "extensions" "A sequence of extension name strings" } }
{ $description "Throws an exception if " { $link has-gl-extensions? } " returns false for " { $snippet "extensions" } "." } ;

HELP: require-gl-version-or-extensions
{ $values { "version" "A version string" } { "extensions" "A sequence of extension name strings" } }
{ $description "Throws an exception if neither " { $link has-gl-version? } " nor " { $link has-gl-extensions? } " returns true for " { $snippet "version" } " or " { $snippet "extensions" } ", respectively. Intended for use when required OpenGL functionality can be verified either by a minimum version or a set of equivalent extensions." } ;

{ require-gl-version require-glsl-version require-gl-extensions require-gl-version-or-extensions has-gl-version? has-glsl-version? has-gl-extensions? has-gl-version-or-extensions? gl-version glsl-version gl-extensions } related-words

ABOUT: "gl-utilities"
