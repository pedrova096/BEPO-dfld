#version 140

in mediump vec2 var_texcoord0;

out vec4 out_fragColor;

uniform mediump sampler2D texture_sampler;
uniform fs_uniforms {
    mediump vec4 tint;
    mediump vec4 source_color_1;
    mediump vec4 source_color_2;
    mediump vec4 source_color_3;
    mediump vec4 source_color_4;
    mediump vec4 source_color_5;
    mediump vec4 target_color_1;
    mediump vec4 target_color_2;
    mediump vec4 target_color_3;
    mediump vec4 target_color_4;
    mediump vec4 target_color_5;
};

void main() {
    // Pre-multiply alpha since all runtime textures already are
    mediump vec4 tint_pm = vec4(tint.xyz * tint.w, tint.w);
    mediump vec4 color = texture(texture_sampler, var_texcoord0.xy);
    if(color == source_color_1) {
        color = target_color_1;
    } else if(color == source_color_2) {
        color = target_color_2;
    } else if(color == source_color_3) {
        color = target_color_3;
    } else if(color == source_color_4) {
        color = target_color_4;
    } else if(color == source_color_5) {
        color = target_color_5;
    }
    out_fragColor = color * tint_pm;
}
