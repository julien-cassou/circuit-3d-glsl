uniform sampler2D texture;
uniform vec3 pharePosGauche;
uniform vec3 pharePosDroite;
uniform vec3 phareDir;
uniform vec3 ambientLight;
uniform vec3 camPos;
uniform vec3 fogColor;

varying vec3 vNormal;
varying vec3 vWorldPos;
varying vec2 vTexCoord;

/**
* Méthode qui permet de calculer l'intensité de couleur d'un phare donné sur le
* pixel actuel.
* @param fragPos la position du pixel
* @param lightPos la position de la light utilisé (le Phare de la voiture)
* @param lightDir la direction du phare calculé via processing
* @param la normal au vecteur contenant le pixel actuel
* @return l'intensité de la couleur du Phare.
**/

float calculPhareLight(vec3 fragPos, vec3 lightPos, vec3 lightDir, vec3 normal) {
  vec3 vecPixLumiere = normalize(fragPos - lightPos);
  float brightness = max(dot(normal, -vecPixLumiere), 0.0);
  float angleLight = dot(vecPixLumiere, lightDir);
  
  if (angleLight < 0.85 ) {
  	return 0.0;
  }

  float spotIntensity = smoothstep(0.85, 1.0, angleLight);
  float dist = distance(lightPos, fragPos);
  float attenuation = 1.0 / (1.0 + 0.005 * dist + 0.00005 * (dist * dist));

  return brightness * spotIntensity * attenuation * 10.0;
}



void main() {
  vec4 texColor = texture2D(texture, vTexCoord);
  vec3 normal = normalize(vNormal);
  
  // Calcul de la lumière du phare de Gauche
  float lightGauche = calculPhareLight(vWorldPos, pharePosGauche, phareDir, normal);

  // Calcul de la lumière du phare de Droite
  float lightDroite = calculPhareLight(vWorldPos, pharePosDroite, phareDir, normal);

  vec3 finalColor = texColor.rgb * (ambientLight + (lightGauche + lightDroite));
  float distCam = distance(vWorldPos, camPos);

  float fogMin = 600.0;
  float fogMax = 1800.0;

  // On calcule le % d'opacité du brouillard selon la distance
  float fogFactor = smoothstep(fogMin, fogMax, distCam);
  finalColor = mix(finalColor, fogColor, fogFactor);
  gl_FragColor = vec4(finalColor, texColor.a);
}