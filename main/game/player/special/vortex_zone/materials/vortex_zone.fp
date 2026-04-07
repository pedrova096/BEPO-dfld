#version 140

in mediump vec2 var_texcoord0;
in mediump vec4 var_tint;

uniform lowp sampler2D texture0;

out lowp vec4 frag_color;

// u_time.x = time; u_center.xy = center (uv)
// u_params: x = speed, y = line thickness (uv), z = spacing between rings (uv)
// u_ring: x = maxR (uv), y = fade width at edge (uv), z = center soften width (uv, 0 = off)
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
    vec2 p = uv - u_center.xy;
    float r = length(p);

    // Pattern in r (UV): rings are true circles
    float speed = u_params.x;
    float thickness_uv = max(0.002, u_params.y);
    float spacing_uv = max(0.001, u_params.z);

    // Repeating band: phase 0..1 per ring; +t*speed so rings move inward (smaller r) over time
    float phase = fract(r / spacing_uv + t * speed);
    float d_phase = abs(phase - 0.5);

    // Thickness in UV so the outline is the same width all around the circle
    float half_thickness_phase = (thickness_uv * 0.5) / spacing_uv;
    float aa_phase = fwidth(r) / spacing_uv;
    float ring = 1.0 - smoothstep(half_thickness_phase - aa_phase, half_thickness_phase + aa_phase, d_phase);

    // Fade by radius: 0 at r >= edgeR, 1 at r <= edgeR - fadeWidth. Set edgeR to circle rim in UV (e.g. 0.5).
    float edgeR = u_ring.x;
    float fadeWidth = max(0.001, u_ring.y);
    float fade = 1.0 - smoothstep(edgeR - fadeWidth, edgeR, r);
    float centerSoften = u_ring.z;
    float center_fade = centerSoften > 0.0 ? smoothstep(0.0, centerSoften, r) : 1.0;

    // Constant ring color (no pulse or time-based change)
    vec4 ring_color = u_color;
    vec4 base = texture(texture0, uv) * var_tint;
    frag_color = mix(base, ring_color, ring * fade * center_fade);
}
