USING: multiline ;
IN: terrain.shaders

STRING: terrain-vertex-shader

uniform sampler2D heightmap;

varying vec2 heightcoords;

const vec4 COMPONENT_SCALE = vec4(0.5, 0.01, 0.002, 0.0);

float height(sampler2D map, vec2 coords)
{
    vec4 v = texture2D(map, coords);
    return dot(v, COMPONENT_SCALE);
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

varying vec2 heightcoords;

const vec4 COMPONENT_SCALE = vec4(0.5, 0.01, 0.002, 0.0);

float height(sampler2D map, vec2 coords)
{
    vec4 v = texture2D(map, coords);
    return dot(v, COMPONENT_SCALE);
}

void main()
{
    gl_FragColor = texture2D(heightmap, heightcoords);
}

;
