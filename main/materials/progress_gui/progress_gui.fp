#version 140

in mediump vec2 var_texcoord0;
in mediump vec4 var_color;

out vec4 out_fragColor;

uniform mediump sampler2D texture_sampler;
uniform fs_uniforms {
    mediump vec4 color_bar;
    mediump vec4 color_bg;
    mediump vec4 color_division;
    mediump vec4 params; // x = bar length, y = background length, z = division width, w = division interval
};

void main() {
    vec4 base = texture(texture_sampler, var_texcoord0) * var_color;

    float x = clamp(var_texcoord0.x, 0.0, 1.0);
    float bar_length = clamp(params.x, 0.0, 1.0);
    float bg_length = clamp(params.y, 0.0, 1.0);
    float division_width = max(params.z, 0.0);
    float division_interval = max(params.w, 0.0);

    float bg_mask = step(x, bg_length);
    float bar_mask = step(x, bar_length);

    vec4 color = color_bg * bg_mask;
    color = mix(color, color_bar, bar_mask);

    float division_mask = 0.0;
    if (division_interval > 0.0 && division_width > 0.0) {
        float half_division_width = division_width * 0.5;
        float division_x = mod(x, division_interval);
        division_x = min(division_x, division_interval - division_x);
        division_mask = 1.0 - step(half_division_width, division_x);

        float edge_width = max(half_division_width, 0.0001);
        float inner_mask = step(edge_width, x) * step(x, 1.0 - edge_width);
        division_mask *= inner_mask * bg_mask;
    }

    color = mix(color, color_division, division_mask);

    out_fragColor = vec4(color.rgb * base.a, color.a * base.a);
}
