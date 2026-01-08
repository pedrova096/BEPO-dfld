varying highp vec4 var_position;
varying mediump vec3 var_normal;
varying mediump vec4 var_light;
varying mediump vec2 var_texcoord0;

uniform lowp sampler2D tex0;
uniform lowp sampler2D tex1;
uniform lowp sampler2D tex2;

void main() {
    vec4 color_world = texture2D(tex0, var_texcoord0.xy);  // Base color
    vec4 color_light = texture2D(tex1, var_texcoord0.xy);  // Light texture (white = lit, transparent = no light)
    vec4 color_normal = texture2D(tex2, var_texcoord0.xy); // Normal map

    // Convert normal from [0,1] to [-1,1]
    vec3 normal = normalize(color_normal.rgb * 2.0 - 1.0);

    // Fixed light direction (from bottom to top)
    vec3 lightDir = normalize(vec3(0.0, 1.0, 0.0));

    // Compute diffuse lighting
    float diff = max(dot(normal, lightDir), 0.0);
    diff = diff * color_normal.a;
    diff = diff == 0.0 ? 1.0 : diff;

    gl_FragColor = color_world; // * vec4(1.0, 0.0, 0.0, 1.0); // Preserve original alpha
}
