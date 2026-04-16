PImage cubeMap;
PImage cubeMapJour;
PImage cubeMapNuit;

PShape cubeShape;
PShape solShape;
PShape voiture;
PShape voiture2;
PShape circuit;
PShape map;
PShape cactus;
ArrayList<PVector> cactusPos;
  
boolean zPressed = false;
boolean sPressed = false;
boolean qPressed = false;
boolean dPressed = false;  

float vitesse = 0.00;
float variation = 0.01;

PVector v1 = new PVector(0, 0);
PVector v2 = new PVector(8, 1);
ArrayList<PVector> pts;

PImage tx;
PImage damier;

final float camDistance = 70; 
final float camHauteur = 70;

ArrayList<PVector> tangentes;
ArrayList<PVector> pointsControle1;
ArrayList<PVector> pointsControle2;

final int circuitX = -480;
final int circuitY = 75;
final int circuitZ = - 420;

boolean modeNuit = false;

PShader phare;
PShader voitureShader;

static int NB_TOUR = 0;

void setup() {
  size(800, 600, P3D);
  // Chargements
  phare = loadShader("phareFrag.glsl", "phareVert.glsl");
  voitureShader = loadShader("voitureFrag.glsl", "voitureVert.glsl");
  cubeMapJour = loadImage("desert.png");
  generateNightCubemap();
  cubeMap = cubeMapJour;
  voiture = loadShape("Car.obj");
  voiture.setStroke(false);
  voiture2 = loadShape("Car.obj");
  voiture2.setStroke(false);
  cactus = loadShape("model.obj");
  
  // Initialisations
  generateCubeMap();  
  generateSol();
  initCircuit();
  initCactus();
  
  // Création des deux textures
  tx = createImage(200, 200, RGB);
  tx.loadPixels();
  for (int j=0; j < 200; j++) {
    for (int i=0; i < 200; i++) {
      int loc = j*200 + i;
      tx.pixels[loc] = color(80); 
      
      // Bandes Blanches Milieu
      if (i > 90 && i < 110) {
        int cond = (j / 10) % 4;
        if (cond == 1 || cond == 2) {
           tx.pixels[loc] = color(255); 
        }
      }
      
      // BORDS : ROUGE/BLANC
      if (i < 10 || i > 190) {
        if ((j / 10) % 2 == 0) {
          tx.pixels[loc] = color(255, 0, 0); // Rouge
        } else {
          tx.pixels[loc] = color(255); // Blanc
        }  
      }
    }
  }
  tx.updatePixels();
  
  damier = createImage(200, 200, RGB);
  damier.loadPixels();
  for (int j=0; j < 200; j++) {
    for (int i=0; i < 200; i++) {
      int loc = j*200 + i;
      int cond = (j/10) % 2;
      if (cond == 0) {
         if((i/10) % 2 == 0) damier.pixels[loc] = color(0);
         else damier.pixels[loc] = color(255);
      }
      else {
        if((i/10) % 2 == 0) damier.pixels[loc] = color(255);
         else damier.pixels[loc] = color(0);
      }
    }
  }
  damier.updatePixels();
  
  generateCircuit();  
  generateCircuitMap();
  
}
  
  
void draw() {
  background(0);
  resetShader();
  
  if (zPressed) {
    vitesse += 0.0005;
    if(vitesse >= 0.03) vitesse = 0.03;
  }
  if (sPressed) {
    vitesse -= 0.0005;
    if(vitesse <= 0.0) vitesse = 0.0; 
  }
  if (dPressed) {
    variation += 0.1;
    if (variation > 1) variation = 1;
  }
  if (qPressed) {
    variation -= 0.1;
    if (variation < -1) variation = -1;
  }
  // Gestion de la vitesse de la voiture
  vitesse = vitesse - 0.0002;
  if(vitesse <= 0.0) vitesse = 0.0;
  
  v1.x += vitesse;
  v1.y = variation;
  
  // Calcul du Tour actuelle, utilisé ensuite pour l'affichage
  int tourActu = (int) (v1.x / pts.size());
  if (tourActu > NB_TOUR) {
    NB_TOUR = tourActu;
  }
  
  // Calcul des PVector utilisé par notre voiture
  PVector actuel = posVoiture(v1);  
  PVector devant = posVoiture(new PVector(v1.x + 0.05, v1.y));

  PVector direction = PVector.sub(devant, actuel);
  direction.normalize();
  
  // Calcul inclinaison de la Voiture 1
  float adjV1 = dist(actuel.x, actuel.z, devant.x, devant.z);
  float oppV1 = actuel.y - devant.y;
  float inclinaison1 = atan2(oppV1, adjV1);

  PVector pos = posVoiture(v2);
  PVector posDevant = posVoiture(new PVector(v2.x + 0.015, v2.y));
  
  // Calcul inclinaison de la Voiture 2
  float adjV2 = dist(pos.x, pos.z, posDevant.x, posDevant.z);
  float oppV2 = pos.y - posDevant.y;
  float inclinaison2 = atan2(oppV2, adjV2);
  
  // Positionnement de la caméra
  PVector hauteurDefault = new PVector(0, -1, 0); 
  PVector right = hauteurDefault.cross(direction).normalize();
  PVector hauteurVoiture = direction.cross(right).normalize();

  PVector posCam = actuel.copy();
  posCam.sub(PVector.mult(direction, camDistance));
  posCam.add(PVector.mult(hauteurVoiture, camHauteur));

  float worldX = posCam.x + circuitX;
  float worldY = posCam.y + circuitY;
  float worldZ = posCam.z + circuitZ;

  PVector posTarget = devant.copy();
  posTarget.add(PVector.mult(hauteurVoiture, 15)); 

  float targetX = posTarget.x + circuitX;
  float targetY = posTarget.y + circuitY;
  float targetZ = posTarget.z + circuitZ;
  
  camera(worldX, worldY, worldZ, targetX, targetY, targetZ, 0, 1, 0);
  
  // Dessin Cube
  resetShader();
  hint(DISABLE_DEPTH_TEST); // On desactive la profondeur, pour que le cube suive la caméra
  pushMatrix();
    translate(worldX - 1000, worldY - 1000, worldZ - 1000);      
    scale(2000);
    shape(cubeShape);
  popMatrix(); 
  hint(ENABLE_DEPTH_TEST);

  // Activer les lumières
  if (modeNuit) {
    // Settings des phares
    phare.set("camPos", worldX, worldY, worldZ);
    phare.set("fogColor", 0.0, 0.0, 0.0 / 255.0);
    phare.set("ambientLight", 2.0/255.0, 2.0/255.0, 5.0/255.0);
    // Settings de la voiture V2, pour l'éclairer
    voitureShader.set("camPos", worldX, worldY, worldZ);
    voitureShader.set("fogColor", 0.0, 0.0, 0.0 / 255.0);
    voitureShader.set("ambientLight", 2.0/255.0, 2.0/255.0, 5.0/255.0); 
    voitureShader.set("voiturePos", pos.x, pos.y, pos.z);
    ambientLight(2, 2, 5);
    drawSpot(actuel, direction, 40);
  }
  else {
    resetShader();
    lights();
  }
  
  // Dessin Voiture 1
  pushMatrix();
    translate(circuitX, circuitY, circuitZ); 
    translate(actuel.x, actuel.y, actuel.z);
    float angle = atan2(devant.x - actuel.x, devant.z - actuel.z); // Calcul de l'angle de rotation sur le circuit
    rotateY(angle + PI);
    rotateX(PI - inclinaison1);
    
    scale(10);
    shape(voiture);
  popMatrix();
  
  if(modeNuit) {
    voitureShader.set("circuitOffset", (float)circuitX, (float)circuitY, (float)circuitZ);
    shader(voitureShader);
  }
  else {
    resetShader();
    lights();
  }
  
  // Dessin Voiture 2
  pushMatrix();
    translate(circuitX, circuitY, circuitZ); 
    v2.x += 0.015;
    translate(pos.x, pos.y, pos.z);
    float angle2 = atan2(posDevant.x - pos.x, posDevant.z - pos.z); // Pareil que la Voit 1
    rotateY(angle2 + PI);
    rotateX(PI - inclinaison2);
    scale(10);
    shape(voiture2);
  popMatrix();
  
  // On dessine les cactus
  drawCactus();
  // Triche, on utilise le shader qui applique les lights des phares à la voiture, pour les cactus ! 
  // On active les phares pour le Sol en changeant les décalages de coords.
  if (modeNuit) {
    shader(phare);
    phare.set("circuitOffset", (float)(circuitX - 17000), (float)(circuitY + 8), (float)(circuitZ - 17000));
} else {
    resetShader();
    noLights();
  }
  
  // Dessin du sol
  pushMatrix();
    translate(circuitX - 1000 - 16000, circuitY + 8, circuitZ - 1000 - 16000); 
    shape(solShape);
  popMatrix();
  
  // Activation shader pour le circuit
  if (modeNuit) {
    shader(phare);
     phare.set("circuitOffset", (float)circuitX, (float)circuitY, (float)circuitZ);
     }
  else { 
     resetShader();
     lights();
  }
  // Dessin du circuit
  pushMatrix();
    translate(circuitX, circuitY, circuitZ); 
    shape(circuit);
  popMatrix();
  
  resetShader();
  drawMinimap();
  drawHud();
}

void keyPressed() {
  if (key == 'z' || key == 'Z') zPressed = true;
  if (key == 's' || key == 'S') sPressed = true;
  if (key == 'q' || key == 'Q') qPressed = true;
  if (key == 'd' || key == 'D') dPressed = true;
}

void keyReleased() {
  if (key == 'z' || key == 'Z') zPressed = false;
  if (key == 's' || key == 'S') sPressed = false;
  if (key == 'q' || key == 'Q') qPressed = false;
  if (key == 'd' || key == 'D') dPressed = false;

  // On garde ton code pour le mode nuit ici, car on veut qu'il ne s'active qu'une seule fois au relâchement
  if (key == 'n' || key == 'N') {
    modeNuit = !modeNuit;
    switchSkybox(modeNuit);
  }
}
