#version 110

uniform sampler2D color_texture, normal_texture, depth_texture;
uniform vec4 line_color;

varying vec2 texcoord;

const float sample_step = 1.0/512.0;
const float depth_weight = 8.0;

float
border_factor(vec2 texcoord)
{
    float depth_samples[8];
    
    depth_samples[0] = texture2D(depth_texture, texcoord + vec2(-sample_step, -sample_step)).x;
    depth_samples[1] = texture2D(depth_texture, texcoord + vec2( 0,           -sample_step)).x;
    depth_samples[2] = texture2D(depth_texture, texcoord + vec2( sample_step, -sample_step)).x;

    depth_samples[3] = texture2D(depth_texture, texcoord + vec2(-sample_step,  0          )).x;

    depth_samples[4] = texture2D(depth_texture, texcoord + vec2( sample_step,  0          )).x;

    depth_samples[5] = texture2D(depth_texture, texcoord + vec2(-sample_step,  sample_step)).x;
    depth_samples[6] = texture2D(depth_texture, texcoord + vec2( 0,            sample_step)).x;
    depth_samples[7] = texture2D(depth_texture, texcoord + vec2( sample_step,  sample_step)).x;

    float horizontal = 1.0 * depth_samples[0] + 2.0 * depth_samples[3] + 1.0 * depth_samples[5]
                     - 1.0 * depth_samples[2] - 2.0 * depth_samples[4] - 1.0 * depth_samples[7];

    float vertical   = 1.0 * depth_samples[0] + 2.0 * depth_samples[1] + 1.0 * depth_samples[2]
                     - 1.0 * depth_samples[5] - 2.0 * depth_samples[6] - 1.0 * depth_samples[7];

    return depth_weight * sqrt(horizontal*horizontal + vertical*vertical);
}

void
main()
{
    gl_FragColor = mix(
        texture2D(color_texture, texcoord),
        line_color,
        border_factor(texcoord)
    );
}
