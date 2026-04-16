#define PROCESSING_TEXLIGHT_SHADER


uniform mat4 transform;
attribute vec4 vertex;
attribute vec3 normal;
attribute vec2 texCoord;


uniform vec3 circuitOffset;

varying vec3 vNormal;
varying vec3 vWorldPos;
varying vec2 vTexCoord;

void main() {
  vWorldPos = vertex.xyz + circuitOffset;
  vNormal = normal;
  vTexCoord = texCoord;
  
  gl_Position = transform * vertex;
}