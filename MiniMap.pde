/**
* Méthode qui dessine la minimap. 
* On supprime la perspective, afin de faire un dessin en 2D, on applique
* aussi un scale au circuit pour bien le centrer dans le rectangle de la Map.
**/
void drawMinimap() {
  hint(DISABLE_DEPTH_TEST);
  camera();
  noLights();
  
  // Dessin du Rectangle Gris
  pushMatrix();
    fill(255, 50);
    rect(0, 0, 200, 150); 
  popMatrix();

  // Configuration de la vue
  pushMatrix();
    ortho(-width/2, width/2, -height/2, height/2); 
    
    resetMatrix();
    translate(-width/2 + 45, -height/2 + 100); 
    
    scale(0.1);
    rotateX(PI/2);
    
    // On dessine le circuit et les voitures
    pushMatrix();
      translate(circuitX, 0, circuitZ);
      shape(map);
      
      // Point Joueur
      PVector p1 = posVoiture(v1);
      pushMatrix();
        translate(p1.x, p1.y - 50, p1.z);
        fill(color(0, 255, 0));
        noStroke();
        sphere(40);
      popMatrix();
      
      // Point Adversaire
      PVector p2 = posVoiture(v2);
      pushMatrix();
        translate(p2.x, p2.y - 50, p2.z);
        fill(color(255, 0, 0));
        noStroke();
        sphere(40);
      popMatrix();
    popMatrix();
  popMatrix();
  
  fill(255);
  
  // On remet la perspective 
  perspective(); 
  hint(ENABLE_DEPTH_TEST);
}
  
/**
* Méthode qui créer un PShape du circuit, sans les coords Y, utilisé pour la Map.
**/
void generateCircuitMap() {
  map = createShape(GROUP);
  
  float pas = 0.002; 
  float largeur = 60;
  
  for (int i = 0; i < pts.size(); i++) {
    PShape segment = createShape();
    segment.beginShape(QUADS);
    segment.noStroke();
    
    PVector p1 = pts.get(i);
    PVector p2 = pts.get((i + 1) % pts.size()); 
    PVector pControle1 = pointsControle1.get(i);
    PVector pControle2 = pointsControle2.get(i);
    
    segment.fill(color(80));
    
    for (float t = 0.0; t < 1.0; t += pas) {
      // Point A
      float xA = bezierPoint(p1.x, pControle1.x, pControle2.x, p2.x, t);
      float zA = bezierPoint(p1.z, pControle1.z, pControle2.z, p2.z, t);
      
      // Point B
      float xB = bezierPoint(p1.x, pControle1.x, pControle2.x, p2.x, t + pas);
      float zB = bezierPoint(p1.z, pControle1.z, pControle2.z, p2.z, t + pas);
    
      PVector pA = new PVector(xA, 0, zA);
      PVector pB = new PVector(xB, 0, zB);
    
      // Tangente et Ortho au point A
      PVector tgA = PVector.sub(pB, pA);
      PVector orthoA = new PVector(-tgA.z, 0, tgA.x).setMag(largeur);
    
      // Tangente et Ortho au point B
      PVector pC = new PVector(bezierPoint(p1.x, pControle1.x, pControle2.x, p2.x, t + pas*2), 0,
                               bezierPoint(p1.z, pControle1.z, pControle2.z, p2.z, t + pas*2));
                               
      PVector tgB = PVector.sub(pC, pB);
      PVector orthoB = new PVector(-tgB.z, 0, tgB.x).setMag(largeur);
    
      segment.vertex(pA.x + orthoA.x, 0, pA.z + orthoA.z, 0, t*100);
      segment.vertex(pA.x - orthoA.x, 0, pA.z - orthoA.z, 200, t*100);
      segment.vertex(pB.x - orthoB.x, 0, pB.z - orthoB.z, 200, (t+pas)*100);
      segment.vertex(pB.x + orthoB.x, 0, pB.z + orthoB.z, 0, (t+pas)*100);
    }
    segment.endShape();
    map.addChild(segment);
  }
}
