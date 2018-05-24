boolean editMode = false;
boolean UIActive = false;
boolean is_drawing_obs = false;
int clic_count;
PVector mousePos;
ArrayList tempShape = new ArrayList();

void keyPressed() {
  switch(key) {
    case 'e' :
      editMode = !editMode;
      UIActive = !UIActive;
      break;
    case 'i' :
      UIActive = !UIActive;
      break;
    case 'd' :
      debug = !debug;
      break;
    case 'v' :
      visitor = !visitor;
      break;
    case 'k' :
      use_kinects = !use_kinects;
      break;
  }
  
  if (editMode == true){
    if(key == 'n') {
      is_drawing_obs = !is_drawing_obs;
      if (is_drawing_obs){
        clic_count = 0;
      }
    }
    if (key == ENTER && is_drawing_obs) {
      String plist = new String();
      ArrayList newShape = new ArrayList ();
      for (int i=0; i < tempShape.size(); i++) {
        newShape.add(tempShape.get(i));
        plist += tempShape.get(i).toString();
      }
      tempShape.clear();
      updateObstaclesData(plist);      
      is_drawing_obs = !is_drawing_obs;
      
    }
  }
}

void mousePressed() {
  mousePos = new PVector(mouseX,mouseY);
  if (editMode == true) {
    if (is_drawing_obs) {
      clic_count += 1;
      tempShape.add(new PVector(mouseX,mouseY));
    }
  }
  else {
    flock.boids_explosion(maxBoids, mousePos,color(255,0,0));
  }
}