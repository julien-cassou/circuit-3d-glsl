/** 
* Méthode qui permet d'initialiser les points du circuit.
**/
void initCircuit() {
  pts = new ArrayList<>();
  float ECHELLE = 120;
  pts.add(new PVector(8 * ECHELLE, 0 * ECHELLE, 1 * ECHELLE));
  pts.add(new PVector(3 * ECHELLE, 0 * ECHELLE, 1 * ECHELLE));
  pts.add(new PVector(2 * ECHELLE, -1 * ECHELLE, 5 * ECHELLE));
  pts.add(new PVector(3 * ECHELLE, -3 * ECHELLE, 9 * ECHELLE));
  pts.add(new PVector(7 * ECHELLE, -5 * ECHELLE, 10 * ECHELLE));
  pts.add(new PVector(12 * ECHELLE, -7 * ECHELLE, 9 * ECHELLE));
  pts.add(new PVector(12 * ECHELLE, -7 * ECHELLE, 6 * ECHELLE));
  pts.add(new PVector(10 * ECHELLE, -7 * ECHELLE, 5 * ECHELLE));
  pts.add(new PVector(9 * ECHELLE, -5 * ECHELLE, 7 * ECHELLE));
  pts.add(new PVector(12 * ECHELLE, -5 * ECHELLE, 11 * ECHELLE));
  pts.add(new PVector(15 * ECHELLE, -5 * ECHELLE, 10 * ECHELLE));
  pts.add(new PVector(15 * ECHELLE, -2 * ECHELLE, 3 * ECHELLE));
  pts.add(new PVector(13 * ECHELLE, 0 * ECHELLE, 1 * ECHELLE));
}

/**
* Méthode réalisant le chargement du circuit dans un PShape.
* On calcule des béziersPoints, afin de tracer pleins de petits QUADS.
* Update sur les QUADS, on les divise par 5, afin qu'il puisse subir 
* les shaders que l'on leur applique.
**/
void generateCircuit() {
  circuit = createShape(GROUP);

  float pas = 0.002; 
  float largeur = 60;
  
  // Précalcule de toutes les tangentes et points de contrôles
  tangentes = new ArrayList<PVector>();
  pointsControle1 = new ArrayList<PVector>();
  pointsControle2 = new ArrayList<PVector>();
  
  for (int i = 0; i < pts.size(); i++) {
    PVector p1 = pts.get(i);
    PVector p2 = pts.get((i + 1) % pts.size()); 
    
    PVector pAvant = pts.get((i - 1 + pts.size()) % pts.size());
    PVector pApres = pts.get((i + 2) % pts.size());

    // Tangentes basées sur les voisins
    PVector tg1 = PVector.sub(p2, pAvant);
    tg1.setMag(largeur);
    PVector tg2 = PVector.sub(pApres, p1);
    tg2.setMag(largeur);

    PVector pc1 = PVector.add(p1, tg1);
    PVector pc2 = PVector.sub(p2, tg2);
    
    tangentes.add(tg1);
    pointsControle1.add(pc1);
    pointsControle2.add(pc2);
  }
  
  // Générer le circuit avec les tangentes précalculées
  for (int i = 0; i < pts.size(); i++) {
    PShape segment = createShape();
    segment.beginShape(QUADS);
    segment.noStroke();
    
    PVector p1 = pts.get(i);
    PVector p2 = pts.get((i + 1) % pts.size()); 
    PVector pControle1 = pointsControle1.get(i);
    PVector pControle2 = pointsControle2.get(i);
    
    // On applique la texture du damier si on arrive vers la ligne d'arrivée
    if (i >= pts.size() - 1) {
      segment.texture(damier);
    } else {
      segment.texture(tx);
    }
    
    for (float t = 0.0; t < 1.0; t += pas) {
      // Point A
      float xA = bezierPoint(p1.x, pControle1.x, pControle2.x, p2.x, t);
      float yA = bezierPoint(p1.y, pControle1.y, pControle2.y, p2.y, t);
      float zA = bezierPoint(p1.z, pControle1.z, pControle2.z, p2.z, t);
      
      // Point B
      float xB = bezierPoint(p1.x, pControle1.x, pControle2.x, p2.x, t + pas);
      float yB = bezierPoint(p1.y, pControle1.y, pControle2.y, p2.y, t + pas);
      float zB = bezierPoint(p1.z, pControle1.z, pControle2.z, p2.z, t + pas);
    
      PVector pA = new PVector(xA, yA, zA);
      PVector pB = new PVector(xB, yB, zB);
    
      // Tangente et Ortho au point A
      PVector tgA = PVector.sub(pB, pA);
      PVector orthoA = new PVector(-tgA.z, 0, tgA.x).setMag(largeur);
    
      // Tangente et Ortho au point B
      PVector pC = new PVector(bezierPoint(p1.x, pControle1.x, pControle2.x, p2.x, t + pas*2), 
                               bezierPoint(p1.y, pControle1.y, pControle2.y, p2.y, t + pas*2), 
                               bezierPoint(p1.z, pControle1.z, pControle2.z, p2.z, t + pas*2));                         
      PVector tgB = PVector.sub(pC, pB);
      PVector orthoB = new PVector(-tgB.z, 0, tgB.x).setMag(largeur);
    
      int nbBandes = 5;
      
      for (int k = 0; k < nbBandes; k++) {
        // On calcule les pourcentages pour les Bords gauche et droite
        float f1 = (float) k / nbBandes;
        float f2 = (float) (k + 1) / nbBandes;

        PVector ptA1 = PVector.lerp(PVector.add(pA, orthoA), PVector.sub(pA, orthoA), f1);
        PVector ptA2 = PVector.lerp(PVector.add(pA, orthoA), PVector.sub(pA, orthoA), f2);
        
        PVector ptB1 = PVector.lerp(PVector.add(pB, orthoB), PVector.sub(pB, orthoB), f1);
        PVector ptB2 = PVector.lerp(PVector.add(pB, orthoB), PVector.sub(pB, orthoB), f2);

        // Pareil pour la texture
        float u1 = lerp(0, 200, f1);
        float u2 = lerp(0, 200, f2);

        // Normal  pour les shaders ! 
        segment.normal(0, -1, 0); 
        
        segment.vertex(ptA1.x, ptA1.y, ptA1.z, u1, t*100);
        segment.vertex(ptA2.x, ptA2.y, ptA2.z, u2, t*100);
        segment.vertex(ptB2.x, ptB2.y, ptB2.z, u2, (t+pas)*100);
        segment.vertex(ptB1.x, ptB1.y, ptB1.z, u1, (t+pas)*100);
      }
    }
    segment.endShape();
    circuit.addChild(segment);
  }
}
