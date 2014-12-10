attribute vec4 a_position;
attribute vec3 a_normal;
attribute vec4 a_color;

uniform mat4 u_projection;

varying lowp vec4 v_color;

void main(void) {
    v_color = a_color;
    
    gl_Position = u_projection * a_position;
}