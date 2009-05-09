USING: multiline ;
IN: terrain.shaders

STRING: terrain-vertex-shader

uniform sampler2D heightmap;
uniform vec4 component_scale;

varying vec2 heightcoords;

float height(sampler2D map, vec2 coords)
{
    vec4 v = texture2D(map, coords);
    return dot(v, component_scale);
}

void main()
{
    gl_Position = gl_ModelViewProjectionMatrix
        * (gl_Vertex + vec4(0, height(heightmap, gl_Vertex.xz), 0, 0));
    heightcoords = gl_Vertex.xz;
}

;

STRING: terrain-pixel-shader

uniform sampler2D heightmap;
uniform vec4 component_scale;

varying vec2 heightcoords;

float height(sampler2D map, vec2 coords)
{
    vec4 v = texture2D(map, coords);
    return dot(v, component_scale);
}

void main()
{
    gl_FragColor = texture2D(heightmap, heightcoords);
}

;
