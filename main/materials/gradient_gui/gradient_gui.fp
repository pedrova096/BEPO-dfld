#version 140

in mediump vec2 var_texcoord0;
in mediump vec4 var_color;

out vec4 out_fragColor;

uniform mediump sampler2D texture_sampler;
uniform fs_uniforms {
    mediump vec4 color_top;
    mediump vec4 color_mid;
    mediump vec4 color_bottom;
    mediump vec4 blend_points;
};

void main() {
    vec4 base = texture(texture_sampler, var_texcoord0) * var_color;
    float y = clamp(var_texcoord0.y, 0.0, 1.0);
    float has_mid = step(0.0001, dot(color_mid, color_mid));

    float top_to_mid = smoothstep(0.0, max(0.001, blend_points.x), y);
    float mid_to_top = smoothstep(blend_points.x, max(blend_points.x + 0.001, blend_points.y), y);

    vec3 gradient_with_mid = mix(
        mix(color_bottom.rgb, color_mid.rgb, top_to_mid),
        color_top.rgb,
        mid_to_top
    );
    vec3 gradient_without_mid = mix(color_bottom.rgb, color_top.rgb, y);
    vec3 gradient = mix(gradient_without_mid, gradient_with_mid, has_mid);

    out_fragColor = vec4(gradient * base.a, base.a);
}
