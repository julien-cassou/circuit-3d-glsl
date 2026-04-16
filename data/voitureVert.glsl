#define PROCESSING_LIGHT_SHADER

uniform mat4 transform;
attribute vec4 vertex;
attribute vec3 normal;
attribute vec4 color;
uniform mat3 normalMatrix;

uniform vec3 voiturePos;
uniform vec3 circuitOffset;

varying vec3 vNormal;
varying vec3 vWorldPos;
varying vec4 vertColor;

void main() {
  vWorldPos = (vertex.xyz * 10.0) + voiturePos + circuitOffset;
  vNormal = normalize(normalMatrix * normal);
  vertColor = color;
  
  gl_Position = transform * vertex;
}