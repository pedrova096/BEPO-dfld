#version 140

in mediump vec2 var_texcoord0;
in mediump vec4 var_tint;

uniform lowp sampler2D texture0;

out lowp vec4 frag_color;

// u_time.x = time
// u_params: x = speed, y = line thickness (uv), z = spacing (uv), w = chevron height (uv, how tall the ^ is)
uniform fs_uniforms {
    mediump vec4 u_time;
    mediump vec4 u_center;
    mediump vec4 u_params;
    mediump vec4 u_ring;
    mediump vec4 u_color;
};

void main() {
    float t = u_time.x;
    vec2 uv = var_texcoord0.xy;
    float u = uv.x;
    float v = uv.y;

    float speed = u_params.x;
    float thickness_uv = max(0.002, u_params.y);
    float spacing_uv = max(0.001, u_params.z);
    float chevron_h = max(0.0, u_params.w);

    // Inverse-V (^): tip at u=0.5, wings lower at u=0 and u=1. Effective v for the band follows the chevron.
    float v_eff = v - chevron_h * (1.0 - 2.0 * abs(u - 0.5));

    // Repeating band in v_eff. -t*speed so lines move bottom→top
    float phase = fract(v_eff / spacing_uv - t * speed);
    float d_phase = abs(phase - 0.5);

    float half_thickness_phase = (thickness_uv * 0.5) / spacing_uv;
    float aa_phase = fwidth(v_eff) / spacing_uv;
    float line = 1.0 - smoothstep(half_thickness_phase - aa_phase, half_thickness_phase + aa_phase, d_phase);

    float fadeTop = smoothstep(0.0, max(0.001, u_ring.x), v);
    float fadeBottom = smoothstep(1.0, 1.0 - max(0.001, u_ring.y), v);
    float fade = fadeTop * fadeBottom;

    vec4 line_color = u_color;
    vec4 base = texture(texture0, uv) * var_tint;
    frag_color = mix(base, line_color, line * fade);
}
