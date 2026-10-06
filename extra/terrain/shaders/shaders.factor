USING: multiline ;
IN: terrain.shaders

STRING: sky-vertex-shader

uniform float sky_theta;
varying vec3 direction;

void main()
{
    vec4 v = vec4(gl_Vertex.xy, 1.0, 1.0);
    gl_Position = v;

    vec4 p = gl_ProjectionMatrixInverse * v;
    p.z = -abs(p.z);

    float s = sin(sky_theta), c = cos(sky_theta);
    direction = mat3(1, 0, 0,  0, c, s,  0, -s, c)
        * (gl_ModelViewMatrixInverse * vec4(p.xyz, 0.0)).xyz;
}

;

STRING: sky-core-vertex-shader
#version 150

uniform mat4 projection, modelview;
uniform float sky_theta;
out vec3 direction;

void main()
{
    vec2 xy = vec2((gl_VertexID == 1) ? 3.0 : -1.0,
                   (gl_VertexID == 2) ? 3.0 : -1.0);
    vec4 v = vec4(xy, 1.0, 1.0);
    gl_Position = v;
    vec4 p = inverse(projection) * v;
    p.z = -abs(p.z);
    float s = sin(sky_theta), c = cos(sky_theta);
    direction = mat3(1, 0, 0,  0, c, s,  0, -s, c)
        * (inverse(modelview) * vec4(p.xyz, 0.0)).xyz;
}
;

STRING: sky-core-pixel-shader
#version 150

uniform sampler2D sky;
uniform float sky_gradient;
in vec3 direction;
out vec4 color;

void main()
{
    float t = texture(sky, normalize(direction).xy * 0.5 + vec2(0.5)).r + sky_gradient;
    color = mix(vec4(0.25, 0.0, 0.5, 1.0), vec4(0.6, 0.5, 0.75, 1.0), sin(6.28*t));
}
;

STRING: terrain-core-vertex-shader
#version 150

uniform mat4 projection, modelview;
uniform sampler2D heightmap;
uniform vec4 component_scale;
in vec4 position;
out vec2 heightcoords;

void main()
{
    float height = dot(texture(heightmap, position.xz), component_scale);
    gl_Position = projection * modelview * (position + vec4(0, height, 0, 0));
    heightcoords = position.xz;
}
;

STRING: terrain-core-pixel-shader
#version 150

uniform sampler2D heightmap;
in vec2 heightcoords;
out vec4 color;

void main()
{
    color = texture(heightmap, heightcoords);
}
;

STRING: sky-pixel-shader

uniform sampler2D sky;
uniform float sky_gradient, sky_theta;

const vec4 SKY_COLOR_A = vec4(0.25, 0.0, 0.5,  1.0),
           SKY_COLOR_B = vec4(0.6,  0.5, 0.75, 1.0);

varying vec3 direction;

void main()
{
    float t = texture2D(sky, normalize(direction.xyz).xy * 0.5 + vec2(0.5)).x + sky_gradient;
    gl_FragColor = mix(SKY_COLOR_A, SKY_COLOR_B, sin(6.28*t));
}

;

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
