uniform highp mat4 u_projectionTransform;
uniform highp mat4 u_modelViewTransform;
uniform highp mat3 u_normalTransform;

attribute highp vec3 a_position;
attribute mediump vec3 a_normal;
attribute lowp vec4 a_color;

varying highp vec3 v_vertexPosition;
varying mediump vec3 v_vertexNormal;
varying lowp vec4 v_vertexColor;

void main(void) {
    highp vec3 position = (u_modelViewTransform * vec4(a_position, 1)).xyz;
    mediump vec3 normal = normalize(u_normalTransform * a_normal);
    
    v_vertexPosition = position;
    v_vertexNormal = normal;
    v_vertexColor = a_color;
    
    gl_Position = u_projectionTransform * vec4(position, 1);
}