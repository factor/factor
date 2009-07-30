#version 110

struct sphere
{
    vec3 center;
    float radius;
    vec4 color;
};

uniform sphere spheres[4];
uniform float floor_height;
uniform vec4 floor_color[2];
uniform vec4 background_color;
uniform vec3 light_direction;

varying vec3 ray_origin, ray_direction;

const float FAR_AWAY = 1.0e20;
const vec4 reflection_color = vec4(1.0, 0.0, 1.0, 0.0);

float sphere_intersect(sphere s, vec3 ro, vec3 rd)
{
    vec3 dist = (ro - s.center);

    float b = dot(dist, normalize(rd));
    float c = dot(dist, dist) - s.radius*s.radius;
    float d = b * b - c;

    return d > 0.0 ? -b - sqrt(d) : FAR_AWAY;
}

float floor_intersect(float height, vec3 ro, vec3 rd)
{
    return (height - ro.y) / rd.y;
}

void
cast_ray(vec3 ro, vec3 rd, out sphere intersect_sphere, out bool intersect_floor, out float intersect_distance)
{
    intersect_floor = false;
    intersect_distance = FAR_AWAY;

    for (int i = 0; i < 4; ++i) {
        float d = sphere_intersect(spheres[i], ro, rd);

        if (d > 0.0 && d < intersect_distance) {
            intersect_distance = d;
            intersect_sphere = spheres[i];
        }
    }

    if (intersect_distance >= FAR_AWAY) {
        intersect_distance = floor_intersect(floor_height, ro, rd);
        if (intersect_distance < 0.0)
            intersect_distance = FAR_AWAY;
        intersect_floor = intersect_distance < FAR_AWAY;
    }
}

vec4 render_floor(vec3 at, float distance, bool shadowed)
{
    vec3 at2 = 0.125 * at;

    float dropoff = exp(-0.005 * abs(distance)) * 0.8 + 0.2;
    float fade = 0.5 * dropoff + 0.5;

    vec4 color = fract((floor(at2.x) + floor(at2.z)) * 0.5) == 0.0
        ? mix(floor_color[1], floor_color[0], fade)
        : mix(floor_color[0], floor_color[1], fade);

    float light = shadowed ? 0.2 : dropoff;

    return color * light * dot(vec3(0.0, 1.0, 0.0), -light_direction);
}

vec4 sphere_color(vec4 color, vec3 normal, vec3 eye_ray, bool shadowed)
{
    float light = shadowed
        ? 0.2
        : max(dot(normal, -light_direction), 0.0) * 0.8 + 0.2;

    float spec = shadowed
        ? 0.0
        : 0.3 * pow(max(dot(reflect(-light_direction, normal), eye_ray), 0.0), 100.0);
        
    return color * light + vec4(spec);
}

bool reflection_p(vec4 color)
{
    vec4 difference = color - reflection_color;
    return dot(difference, difference) == 0.0;
}

vec4 render_sphere(sphere s, vec3 at, vec3 eye_ray, bool shadowed)
{
    vec3 normal = normalize(at - s.center);

    vec4 color;

    if (reflection_p(s.color)) {
        sphere reflect_sphere;
        bool reflect_floor;
        float reflect_distance;
        vec3 reflect_direction = reflect(eye_ray, normal);

        cast_ray(at, reflect_direction, reflect_sphere, reflect_floor, reflect_distance);

        vec3 reflect_at = at + reflect_direction * reflect_distance;
        if (reflect_floor)
            color = render_floor(reflect_at, reflect_distance, false);
        else if (reflect_distance < FAR_AWAY) {
            vec3 reflect_normal = normalize(reflect_at - reflect_sphere.center);

            color = sphere_color(reflect_sphere.color, reflect_normal, reflect_direction, false);
        } else {
            color = background_color;
        }
    } else
        color = s.color;

    return sphere_color(color, normal, eye_ray, shadowed);
}

void
main()
{
    vec3 ray_direction_normalized = normalize(ray_direction);

    sphere intersect_sphere;
    bool intersect_floor;
    float intersect_distance;

    cast_ray(ray_origin, ray_direction_normalized, intersect_sphere, intersect_floor, intersect_distance);

    vec3 at = ray_origin + ray_direction_normalized * intersect_distance;

    sphere shadow_sphere;
    bool shadow_floor;
    float shadow_distance;

    cast_ray(at - 0.0001 * light_direction, -light_direction, shadow_sphere, shadow_floor, shadow_distance);

    bool shadowed = shadow_distance < FAR_AWAY;

    if (intersect_floor)
        gl_FragColor = render_floor(at, intersect_distance, shadowed);
    else if (intersect_distance < FAR_AWAY)
        gl_FragColor = render_sphere(intersect_sphere, at, ray_direction_normalized, shadowed);
    else
        gl_FragColor = background_color;
}

