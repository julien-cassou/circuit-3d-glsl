/**
* Méthode qui permet de charger la CubeMap dans un PShape
* Elle se charge à partir de notre texture d'image.
**/
void generateCubeMap() {
  cubeShape = createShape();
  cubeShape.beginShape(QUADS);
  cubeShape.textureMode(IMAGE);
  cubeShape.texture(cubeMap);
  cubeShape.noStroke();

  float m = 1.5;
  
  // MUR 1 (Derrière)
  cubeShape.vertex(0, 0, 0, 0 + m, 256 + m);
  cubeShape.vertex( 1, 0, 0, 256 - m, 256 + m);
  cubeShape.vertex( 1,  1, 0, 256 - m, 512 - m);
  cubeShape.vertex(0,  1, 0, 0 + m, 512 - m);

  // MUR 2 (Droite)
  cubeShape.vertex( 1, 0, 0, 256 + m, 256 + m);
  cubeShape.vertex( 1, 0,  1, 512 - m, 256 + m);
  cubeShape.vertex( 1,  1,  1, 512 - m, 512 - m);
  cubeShape.vertex( 1,  1, 0, 256 + m, 512 - m);

  // MUR 3 (Devant)
  cubeShape.vertex( 1, 0,  1, 512 + m, 256 + m);
  cubeShape.vertex(0, 0,  1, 768 - m, 256 + m);
  cubeShape.vertex(0,  1,  1, 768 - m, 512 - m);
  cubeShape.vertex( 1,  1,  1, 512 + m, 512 - m);

  // MUR 4 (Gauche)
  cubeShape.vertex(0, 0,  1, 768 + m, 256 + m);
  cubeShape.vertex(0, 0, 0, 1024 - m, 256 + m);
  cubeShape.vertex(0,  1, 0, 1024 - m, 512 - m);
  cubeShape.vertex(0,  1,  1, 768 + m, 512 - m);

  // PLAFOND
  cubeShape.vertex(0, 0, 0, 256 + m, 0 + m);
  cubeShape.vertex( 1, 0, 0, 512 - m, 0 + m);
  cubeShape.vertex( 1, 0,  1, 512 - m, 256 - m);
  cubeShape.vertex(0, 0,  1, 256 + m, 256 - m);
  
  cubeShape.endShape();
}

/**
* Méthode permettant de charger aussi dans un PShape le sol.
* Il est générer via plein de QUADS qui prennent la texture du Sol.
**/
void generateSol() {
  solShape = createShape();
  solShape.beginShape(QUADS);
  solShape.textureMode(IMAGE);
  solShape.texture(cubeMap);
  solShape.noStroke();
  
  float uMin = 268; float uMax = 500;
  float vMin = 524; float vMax = 754;
  
  int tailleCase = 200; int nbCase = 160;
  
  for (int i = 0; i < nbCase; i++) {
    for (int j = 0; j < nbCase; j++) {
      float x = i * tailleCase ;
      float z = j * tailleCase;
      
      
      solShape.normal(0, -1, 0);
      
      solShape.vertex(x, 0, z, uMin, vMin);
      solShape.vertex(x, 0, z + tailleCase, uMin, vMax);
      solShape.vertex(x + tailleCase, 0, z + tailleCase, uMax, vMax);
      solShape.vertex(x  + tailleCase, 0, z, uMax, vMin);      
    }
  }
  solShape.endShape();
} 

/**
* Méthode permettant de créer la cube map de nuit.
* On change la couleur de tous les pixels de la cubeMap de base, 
* tout ça via une formule décidé : R * 0,02, G * 0,02, B * 0,05.
**/
void generateNightCubemap() {
  if (cubeMapNuit != null) return;
  
  cubeMapNuit = cubeMapJour.copy();
  cubeMapNuit.loadPixels();
  for (int i = 0; i < cubeMapNuit.pixels.length; i++) {
    color c = cubeMapNuit.pixels[i];
    cubeMapNuit.pixels[i] = color(red(c) * 0.02, green(c) * 0.02, blue(c) * 0.05);
  }
  cubeMapNuit.updatePixels();
}

/**
* Méthode utilisé pour changer de CubeMap, elle change en fonction de si le mode nuit est 
* activé ou non.
* @param nuit : un booléan qui indique si le mode nuit est activé
**/
void switchSkybox(boolean nuit) {
  cubeMap = nuit ? cubeMapNuit : cubeMapJour;
  generateCubeMap();
}
