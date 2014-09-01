void main() {
    vec4 color = texture2D(u_texture, v_tex_coord).rgba;
    if (color.a > 0.5) {
        gl_FragColor.rgba = vec4(1.0, 1.0, 1.0, 1.0);
    } else {
        gl_FragColor.rgba = color.rgba;
    }
}