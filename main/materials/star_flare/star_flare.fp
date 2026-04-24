#version 140

in mediump vec2 var_atlas_origin;
in mediump vec2 var_atlas_u;
in mediump vec2 var_atlas_v;
in mediump vec2 var_local_uv;

out vec4 out_fragColor;

uniform mediump sampler2D texture_sampler;
uniform fs_uniforms {
    mediump vec4 tint;
    // radial_params: x=inner radius, y=outer radius, z=outer alpha, w=inner alpha
    mediump vec4 radial_params;
    // rotation_params: x=time, y=velocity, z=unused, w=unused
    mediump vec4 rotation_params;
};

void main() {
    mediump vec2 centered_uv = var_local_uv - vec2(0.5);

    mediump float radial_t = smoothstep(radial_params.x, max(radial_params.x + 0.0001, radial_params.y), length(centered_uv));
    mediump float radial_alpha = clamp(mix(radial_params.w, radial_params.z, radial_t), 0.0, 1.0);

    mediump float angle = rotation_params.x * rotation_params.y;
    mediump float s = sin(angle);
    mediump float c = cos(angle);
    mediump vec2 rotated_local_uv = vec2(centered_uv.x * c - centered_uv.y * s, centered_uv.x * s + centered_uv.y * c) + vec2(0.5);

    mediump vec2 atlas_uv = var_atlas_origin + var_atlas_u * rotated_local_uv.x + var_atlas_v * rotated_local_uv.y;
    mediump vec4 tint_pm = vec4(tint.xyz * tint.w, tint.w);
    mediump vec4 color = texture(texture_sampler, atlas_uv) * tint_pm;

    out_fragColor = color * radial_alpha;
}
