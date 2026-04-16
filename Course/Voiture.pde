/**
* Méthode qui calcule la position actuelle de la voiture sur le circuit.
* @param v1 : Un PVector de la forme (Point sur le circuit, décalage sur le circuit)
* @return Un PVector contenant les coordonnées où l'on place la voiture.
**/
PVector posVoiture(PVector v1) {
  float largeur = 30;
  float pas = 0.005;
  int i = int(v1.x) % pts.size();
  float t = (v1.x - int(v1.x));
  
  // Vérification du Calcul de tangente
  if (tangentes == null || tangentes.size() == 0) {
    return new PVector(0, 0, 0);
  }
  
  PVector p1 = pts.get(i);
  PVector p2 = pts.get((i + 1) % pts.size()); 
  PVector pControle1 = pointsControle1.get(i);
  PVector pControle2 = pointsControle2.get(i);
  
  float xA = bezierPoint(p1.x, pControle1.x, pControle2.x, p2.x, t);
  float yA = bezierPoint(p1.y, pControle1.y, pControle2.y, p2.y, t);
  float zA = bezierPoint(p1.z, pControle1.z, pControle2.z, p2.z, t);
  
  // Point B pour calculer la tangente
  float xB = bezierPoint(p1.x, pControle1.x, pControle2.x, p2.x, t + pas);
  float yB = bezierPoint(p1.y, pControle1.y, pControle2.y, p2.y, t + pas);
  float zB = bezierPoint(p1.z, pControle1.z, pControle2.z, p2.z, t + pas);

  PVector pA = new PVector(xA, yA, zA);
  PVector pB = new PVector(xB, yB, zB);

  // Tangente et Ortho au point A
  PVector tgA = PVector.sub(pB, pA);
  PVector orthoA = new PVector(-tgA.z, 0, tgA.x).setMag(largeur);
  
  return new PVector(pA.x + (orthoA.x * v1.y), pA.y + (orthoA.y * v1.y), pA.z + (orthoA.z * v1.y));
}
  
/**
* Méthode qui dessine les deux Phares d'une voiture
**/
public void drawSpot(PVector pos, PVector direction, float intensite) {
   if (intensite <= 0) return;
   // Ecart entre les phares
   PVector ortho = new PVector(-direction.z, direction.y, direction.x);
   ortho.setMag(24);
   
   // On place les phares sur le pare-choc
   PVector avant = direction.copy();
   avant.setMag(24);
   
   float hauteurLight = -20.0;
   
   PVector posGauche = new PVector(
    pos.x + ortho.x + avant.x,
    pos.y + hauteurLight + avant.y,
    pos.z + ortho.z + avant.z
   );
   PVector posDroite = new PVector(
     pos.x - ortho.x + avant.x,
     pos.y + hauteurLight + avant.y,
     pos.z - ortho.z + avant.z
   );
   
   float inclinaisonSol = 0.4;
   PVector dirFaisceau = new PVector(
     direction.x,
     direction.y + inclinaisonSol,
     direction.z
  );
  dirFaisceau.normalize();
  
  posGauche.add(circuitX, circuitY, circuitZ);
  posDroite.add(circuitX, circuitY, circuitZ);
  
  phare.set("pharePosGauche", posGauche.x, posGauche.y, posGauche.z);
  phare.set("pharePosDroite", posDroite.x, posDroite.y, posDroite.z);
  phare.set("phareDir", dirFaisceau.x, dirFaisceau.y, dirFaisceau.z);
  
  voitureShader.set("pharePosGauche", posGauche.x, posGauche.y, posGauche.z);
  voitureShader.set("pharePosDroite", posDroite.x, posDroite.y, posDroite.z);
  voitureShader.set("phareDir", dirFaisceau.x, dirFaisceau.y, dirFaisceau.z);
}
