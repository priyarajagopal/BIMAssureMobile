varying lowp vec3 v_vertexPosition;
varying lowp vec3 v_vertexNormal;
varying lowp vec4 v_vertexColor;

void main(void) {
    gl_FragColor = v_vertexColor;
}