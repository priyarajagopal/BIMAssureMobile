uniform highp mat4 u_projectionTransform;
uniform highp mat4 u_modelViewTransform;
uniform highp mat3 u_normalTransform;

attribute highp vec3 a_position;
attribute highp vec3 a_normal;
attribute highp vec4 a_color;

uniform highp vec4 u_light0_color;
uniform highp vec4 u_light0_position;
uniform highp vec4 u_light1_color;
uniform highp vec4 u_light1_position;
uniform highp vec4 u_light2_color;
uniform highp vec4 u_light2_position;
uniform highp vec4 u_light3_color;
uniform highp vec4 u_light3_position;
uniform highp vec4 u_light4_color;
uniform highp vec4 u_light4_position;
uniform highp vec4 u_light5_color;
uniform highp vec4 u_light5_position;

varying highp vec3 v_vertexPosition;
varying highp vec3 v_vertexNormal;
varying highp vec4 v_vertexColor;

void calcLight(
    highp vec4 lightColor, highp vec4 lightPosition,
    highp vec3 position, highp vec3 normal, highp vec4 color,
    inout highp vec3 lightContrib) {
    
    highp vec4 lightIntensity = lightColor;
    highp vec3 lightDirection = normalize(lightPosition.xyz - position);
    highp float lightAttenuation = max(0.0, dot(normal, lightDirection));
    
    // highp float lightAttenuation = 0.0;
    lightIntensity.rgb *= lightAttenuation;
    lightContrib += lightIntensity.rgb;
}

void main(void) {
    highp vec3 position = (u_modelViewTransform * vec4(a_position, 1)).xyz;
    highp vec3 normal = normalize(u_normalTransform * a_normal);
    
    v_vertexPosition = position;
    v_vertexNormal = normal;
    v_vertexColor = a_color;
    
    gl_Position = u_projectionTransform * vec4(position, 1);
    
    highp vec3 lightContrib = vec3(0);
    
    // Properly support front and back facing normals.
    // highp float frontFacing = float(gl_FrontFacing);
    // frontFacing = (frontFacing * 2.0) - 1.0;
    // highp vec3 normal = normalize(v_vertexNormal.xyz);
    
    calcLight(u_light0_color, u_light0_position, v_vertexPosition, normal, v_vertexColor, lightContrib);
    calcLight(u_light1_color, u_light1_position, v_vertexPosition, normal, v_vertexColor, lightContrib);
    calcLight(u_light2_color, u_light2_position, v_vertexPosition, normal, v_vertexColor, lightContrib);
    calcLight(u_light3_color, u_light3_position, v_vertexPosition, normal, v_vertexColor, lightContrib);
    calcLight(u_light4_color, u_light4_position, v_vertexPosition, normal, v_vertexColor, lightContrib);
    calcLight(u_light5_color, u_light5_position, v_vertexPosition, normal, v_vertexColor, lightContrib);
    
    // Average the light values
    // lightContrib = lightContrib / 6.0;
    
    highp vec4 outputColor = vec4(0);
    outputColor.rgb = v_vertexColor.rgb * lightContrib;
    outputColor.a = v_vertexColor.a;
    
    v_vertexColor = outputColor;
}