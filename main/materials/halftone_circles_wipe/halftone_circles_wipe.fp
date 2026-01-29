#version 140

in mediump vec2 var_texcoord0;
in mediump vec4 var_color;

out vec4 out_fragColor;

uniform mediump sampler2D texture_sampler;
uniform fs_uniforms {
    mediump vec4 progress;
    mediump vec4 dot_spacing;
    mediump vec4 dot_radius;
    mediump vec4 min_dot_radius;
    mediump vec4 edge_size;
    mediump vec4 softness;
    mediump vec4 tex_size;
};

void main() {
        // ---- PARAMETERS ----
    float u_progress = progress.x;   // 0..1 (replace with uniform if needed)
    float u_dotSpacing = dot_spacing.x;                // pixels
    float u_dotRadius = dot_radius.x;                  // max radius
    float u_minDotRadius = min_dot_radius.x;               // tiny dots
    float u_edge = edge_size.x;                  // transition softness (cells)
    float u_softness = softness.x;                   // AA

    vec4 base = texture(texture_sampler, var_texcoord0) * var_color;

    // Texture size in pixels (requires GL 3+ style textureSize; #version 140 supports it)
    vec2 texSize = max(tex_size.xy, vec2(1.0));

    // Pixel-space coordinate
    vec2 p = var_texcoord0.xy * texSize;

    // --- Dot grid ---
    float spacing = max(1.0, u_dotSpacing);
    vec2 cell = floor(p / spacing);
    vec2 center = (cell + vec2(0.5)) * spacing;

    float distToCenter = length(p - center);

    // --- Top->bottom front ---
    float y = 1.0 - (p.y / max(1.0, texSize.y));  // inverted: 0 at top, 1 at bottom
    float band = (u_edge * spacing) / max(1.0, texSize.y);

    // revealed = 1 on top of the front, 0 on bottom (smooth band)
    float revealed = 1.0 - smoothstep(u_progress - band, u_progress + band, y);

    // Dot radius changes from tiny -> big depending on revealed
    float radius = mix(u_minDotRadius, u_dotRadius, revealed);

    // Circle mask with soft edge
    float circle = 1.0 - smoothstep(radius - u_softness, radius + u_softness, distToCenter);

    // Optional: fade dot opacity by how "revealed" we are (keeps right side subtle)
    float dotAlpha = circle * mix(0.15, 1.0, revealed);

    // Overlay solid dots on top of the sprite:
    // "Over" compositing using dotColor alpha
    // vec4 dot_value = vec4(u_dotColor.xyz, u_dotColor.w * dotAlpha);

    // vec4(mix(base.xyz, dot_value.xyz, dot_value.w), base.w);

    out_fragColor = vec4(base.xyz * dotAlpha, dotAlpha);
}
