/**
* Méthode qui écrit le nb de Tour en vert.
**/
public void drawHud() {
  hint(DISABLE_DEPTH_TEST);
  camera(); 
  noLights();

  fill(0, 255, 0);
  textSize(20);
  textAlign(LEFT, TOP);
  
  text("TOUR : " + NB_TOUR, 200, 10); 
  hint(ENABLE_DEPTH_TEST); 
}
