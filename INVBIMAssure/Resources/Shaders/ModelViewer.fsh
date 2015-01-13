uniform lowp vec4 u_light0_color;
uniform highp vec4 u_light0_position;
uniform lowp vec4 u_light1_color;
uniform highp vec4 u_light1_position;
uniform lowp vec4 u_light2_color;
uniform highp vec4 u_light2_position;
uniform lowp vec4 u_light3_color;
uniform highp vec4 u_light3_position;
uniform lowp vec4 u_light4_color;
uniform highp vec4 u_light4_position;
uniform lowp vec4 u_light5_color;
uniform highp vec4 u_light5_position;

varying highp vec3 v_vertexPosition;
varying mediump vec3 v_vertexNormal;
varying lowp vec4 v_vertexColor;

void calcLight(
               lowp vec4 lightColor, highp vec4 lightPosition,
               highp vec3 position, mediump vec3 normal, lowp vec4 color,
               inout highp vec3 lightContrib) {
    
    mediump vec4 lightIntensity = lightColor;
    mediump vec3 lightDirection = normalize(lightPosition.xyz - position);
    mediump float lightAttenuation = max(0.0, dot(normal, lightDirection));
    
    // highp float lightAttenuation = 0.0;
    lightIntensity.rgb *= lightAttenuation;
    lightContrib += lightIntensity.rgb;
}

void main(void) {
    highp vec3 lightContrib = vec3(0);
    
    // Properly support front and back facing normals.
    mediump float frontFacing = float(gl_FrontFacing);
    frontFacing = (frontFacing * 2.0) - 1.0;
    
    mediump vec3 normal = normalize(v_vertexNormal.xyz);
    
    calcLight(u_light0_color, u_light0_position, v_vertexPosition, normal, v_vertexColor, lightContrib);
    calcLight(u_light1_color, u_light1_position, v_vertexPosition, normal, v_vertexColor, lightContrib);
    calcLight(u_light2_color, u_light2_position, v_vertexPosition, normal, v_vertexColor, lightContrib);
    calcLight(u_light3_color, u_light3_position, v_vertexPosition, normal, v_vertexColor, lightContrib);
    calcLight(u_light4_color, u_light4_position, v_vertexPosition, normal, v_vertexColor, lightContrib);
    calcLight(u_light5_color, u_light5_position, v_vertexPosition, normal, v_vertexColor, lightContrib);
    
    // Average the light values
    // lightContrib = lightContrib / 6.0;
    
    mediump vec4 outputColor = vec4(0);
    outputColor.rgb = v_vertexColor.rgb * lightContrib;
    outputColor.a = v_vertexColor.a;
    
    gl_FragColor = outputColor;
}