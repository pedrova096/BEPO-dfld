#version 140

in mediump vec2 var_atlas_origin;
in mediump vec2 var_atlas_u;
in mediump vec2 var_atlas_v;
in mediump vec2 var_local_uv;

out vec4 out_fragColor;

uniform mediump sampler2D texture_sampler;
uniform fs_uniforms {
    mediump vec4 tint;
    // progress.x controls the centered inner sprite size from 0..1.
    mediump vec4 progress;
    // color_adjust.xy supports -1..1. Negative values boost, positive values reduce.
    mediump vec4 color_adjust;
};

mediump vec4 sample_sprite(mediump vec2 local_uv)
{
    mediump vec2 atlas_uv = var_atlas_origin + var_atlas_u * local_uv.x + var_atlas_v * local_uv.y;
    return texture(texture_sampler, atlas_uv);
}

mediump vec3 adjust_saturation_and_lightness(mediump vec3 color)
{
    mediump float saturation_adjust = clamp(color_adjust.x, -1.0, 1.0);
    mediump float lightness_adjust = clamp(color_adjust.y, -1.0, 1.0);
    mediump float luma = dot(color, vec3(0.299, 0.587, 0.114));
    mediump float saturation_factor = saturation_adjust < 0.0
        ? 1.0 + (-saturation_adjust)
        : 1.0 - saturation_adjust;
    mediump vec3 adjusted = vec3(luma) + (color - vec3(luma)) * saturation_factor;

    if (lightness_adjust < 0.0) {
        adjusted = mix(adjusted, vec3(1.0), -lightness_adjust);
    } else {
        adjusted = adjusted * (1.0 - lightness_adjust);
    }

    return clamp(adjusted, vec3(0.0), vec3(1.0));
}

void main()
{
    mediump float inner_size = clamp(progress.x, 0.0, 1.0);
    mediump vec4 tint_pm = vec4(tint.xyz * tint.w, tint.w);
    mediump vec4 outer = sample_sprite(var_local_uv);

    mediump vec2 inner_uv = (var_local_uv - vec2(0.5)) / max(inner_size, 0.0001) + vec2(0.5);
    mediump vec2 inner_bounds = step(vec2(0.0), inner_uv) * step(inner_uv, vec2(1.0));
    mediump float inner_in_bounds = inner_bounds.x * inner_bounds.y;
    mediump vec4 inner = sample_sprite(clamp(inner_uv, vec2(0.0), vec2(1.0)));
    mediump float overlap = inner_in_bounds * step(0.001, inner.a) * step(0.001, outer.a);

    mediump vec4 color = outer;
    mediump vec3 straight_rgb = color.a > 0.0 ? color.rgb / color.a : color.rgb;
    color.rgb = adjust_saturation_and_lightness(straight_rgb) * color.a;
    color = mix(color, inner, overlap);

    out_fragColor = color * tint_pm;
}
