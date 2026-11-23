
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;

uniform float curvature : hint_range(0.0, 0.3) = 0.08;
uniform float scanline_strength : hint_range(0.0, 1.0) = 0.2;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.4;
uniform float chromatic_aberration : hint_range(0.0, 0.01) = 0.002;
uniform float noise_strength : hint_range(0.0, 0.1) = 0.01;
uniform float brightness : hint_range(0.0, 2.0) = 1.0;

void fragment() {
    vec2 uv = SCREEN_UV;

    // CRT curvature
    vec2 centered = uv * 2.0 - 1.0;
    float r2 = dot(centered, centered);

    uv = centered * (1.0 - curvature * r2) * 0.5 + 0.5;

    // Screen boundaries
    if (uv.x < 0.0 || uv.x > 1.0 ||
        uv.y < 0.0 || uv.y > 1.0) {
        COLOR = vec4(0.0, 0.0, 0.0, 1.0);
    }

    // Chromatic aberration
    float red = texture(
        screen_texture,
        uv + vec2(chromatic_aberration, 0.0)
    ).r;

    float green = texture(screen_texture, uv).g;

    float blue = texture(
        screen_texture,
        uv - vec2(chromatic_aberration, 0.0)
    ).b;

    vec3 col = vec3(red, green, blue);

    // Scanlines
    float scanline = 0.5 + 0.5 * cos(SCREEN_UV.y * 1200.0);
    col *= 1.0 - scanline * scanline_strength;

    // Vignette
    float vignette = 1.0 - r2 * vignette_strength;
    col *= clamp(vignette, 0.0, 1.0);

    // Animated noise
    float noise = fract(
        sin(dot(SCREEN_UV * (TIME + 1.0),
        vec2(12.9898, 78.233))) * 43758.5453
    );

    col += (noise - 0.5) * noise_strength;

    // Brightness
    col *= brightness;

    COLOR = vec4(col, 1.0);
}