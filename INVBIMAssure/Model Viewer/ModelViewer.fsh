uniform vec4 u_light0_color;
uniform vec4 u_light0_position;
uniform vec4 u_light1_color;
uniform vec4 u_light1_position;
uniform vec4 u_light2_color;
uniform vec4 u_light2_position;
uniform vec4 u_light3_color;
uniform vec4 u_light3_position;
uniform vec4 u_light4_color;
uniform vec4 u_light4_position;
uniform vec4 u_light5_color;
uniform vec4 u_light5_position;

varying lowp vec3 v_vertexPosition;
varying lowp vec3 v_vertexNormal;
varying lowp vec4 v_vertexColor;

void calcLight(vec4 lightColor, vec4 lightPosition, inout vec3 lightContrib) {
    vec4 lightIntensity = lightColor;
    vec3 lightDirection = normalize(lightPosition.xyz - v_vertexPosition);
    float lightAttenuation = max(0.0, dot(v_vertexNormal, lightDirection));
    
    lightIntensity.rgb *= lightAttenuation;
    lightContrib += lightIntensity.rgb * v_vertexColor.a;
}

void main(void) {
    vec3 lightContrib = vec3(0);
    
    // Properly support front and back facing normals.
    v_vertexNormal = normalize(v_vertexNormal.xyz) * ((float(gl_FrontFacing) * 2.0) - 1.0);
    
    calcLight(u_light0_color, u_light0_position, lightContrib);
    calcLight(u_light1_color, u_light1_position, lightContrib);
    calcLight(u_light2_color, u_light2_position, lightContrib);
    calcLight(u_light3_color, u_light3_position, lightContrib);
    calcLight(u_light4_color, u_light4_position, lightContrib);
    calcLight(u_light5_color, u_light5_position, lightContrib);
    
    vec4 outputColor = vec4(0);
    outputColor.rgb = v_vertexColor.rgb * lightContrib;
    outputColor.a = v_vertexColor.a;
    
    gl_FragColor = v_color;
}