USING: tools.test math opengl opengl.gl ;
IN: opengl.tests

{ 2 1 } [ { GL_TEXTURE_2D } [ + ] all-enabled ] must-infer-as

{ 2 1 } [ { GL_TEXTURE_2D } [ + ] all-enabled-client-state ] must-infer-as
