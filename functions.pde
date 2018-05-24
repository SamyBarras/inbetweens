PVector overlap(Poly boid, Obstacle obs) { //boid is one that is projected (moves)

  PVector nor,pt,projection;
  float low1,high1,low2,high2,dt;  
  projection = new PVector(Float.MAX_VALUE,0);
  
  for ( int q = 0; q < boid.points.size(); q++ ) {
    if ( q == (boid.points.size()-1) ) {
      nor = PVector.sub((PVector)boid.points.get(0),(PVector)boid.points.get(q));
    }
    else {
      nor = PVector.sub((PVector)boid.points.get(q),(PVector)boid.points.get(q+1));
    }
    nor.set(-nor.y,nor.x,0); //rotate 90 degrees
    nor.normalize();
    
    //set the values so any value will work
    low1 = Float.MAX_VALUE;
    high1 = -Float.MAX_VALUE;
    for ( int i = 0; i < boid.points.size(); i++ ) {
      pt = PVector.add( (PVector)boid.points.get(i), new PVector(boid.x,boid.y) );
      dt = pt.dot(nor)+100;
      if ( dt < low1 ) { low1 = dt; }
      if ( dt > high1 ) { high1 = dt; }
    }
    low2 = Float.MAX_VALUE;
    high2 = -Float.MAX_VALUE;
    for ( int i = 0; i < obs.points.size(); i++ ) {
      //pt = PVector.add( (PVector)obs.points.get(i), new PVector(map(obs.x,0,width,0,flocka.width),map(obs.y,0,height,0,flocka.height)) );
      pt = PVector.add( (PVector)obs.points.get(i), new PVector(obs.x,obs.y) );
      dt = pt.dot(nor)+100;
      if ( dt < low2 ) { low2 = dt; }
      if ( dt > high2 ) { high2 = dt; }
    }
    //find projection using min overlap of low1-high1 and low2-high2
    //boid is the one that is projected (moves)
    float mid1,mid2;
    mid1 = 0.5f*(low1+high1);
    mid2 = 0.5f*(low2+high2);
    if ( mid1 < mid2 ) {
      if ( high1 < low2 ) { //no overlap
        return (new PVector(0,0)); //return a null vector
      }
      else { //test to see if projection is smallest
        if ( (high1-low2) < projection.mag() ) { //new smallest projection found
          projection = nor.get();
          projection.normalize();
          projection.mult(-(high1-low2)); 
        }
      }
    }
    else {
      if ( low1 > high2 ) { //no overlap
        return (new PVector(0,0)); //return a null vector
      }
      else {
        if ( (high2-low1) < projection.mag() ) { //new smallest projection found
          projection = nor.get();
          projection.normalize();
          projection.mult((high2-low1)); 
        }
      }
    }
  }
  
  //do same for obs/////////////////////////////////////////////////////////////////////////////
  for ( int q = 0; q < obs.points.size(); q++ ) {
    //println(boid.points.size());
    if ( q == (obs.points.size()-1) ) {
      nor = PVector.sub((PVector)obs.points.get(0),(PVector)obs.points.get(q));
    }
    else {
      nor = PVector.sub((PVector)obs.points.get(q),(PVector)obs.points.get(q+1));
    }
    nor.set(-nor.y,nor.x,0); //rotate 90 degrees
    nor.normalize();
    nor.mult(100);
    nor.normalize();
    //set the values so any value will work
    low1 = Float.MAX_VALUE;
    high1 = -Float.MAX_VALUE;
    for ( int i = 0; i < boid.points.size(); i++ ) {
      pt = PVector.add( (PVector)boid.points.get(i), new PVector(boid.x,boid.y) );
      dt = pt.dot(nor);
      if ( dt < low1 ) { low1 = dt; }
      if ( dt > high1 ) { high1 = dt; }
    }
    low2 = Float.MAX_VALUE;
    high2 = -Float.MAX_VALUE;
    for ( int i = 0; i < obs.points.size(); i++ ) {
      pt = PVector.add( (PVector)obs.points.get(i), new PVector(obs.x,obs.y) );
      dt = pt.dot(nor);
      if ( dt < low2 ) { low2 = dt; }
      if ( dt > high2 ) { high2 = dt; }
    }
    //find projection using min overlap of low1-high1 and low2-high2
    //boid is the one that is projected (moves)
    float mid1,mid2;
    mid1 = 0.5f*(low1+high1);
    mid2 = 0.5f*(low2+high2);
    if ( mid1 < mid2 ) {
      if ( high1 < low2 ) { //no overlap
        return (new PVector(0,0)); //return a null vector
      }
      else { //test to see if projection is smallest
        if ( (high1-low2) < projection.mag() ) { //new smallest projection found
          projection = nor.get();
          projection.normalize();
          projection.mult(-(high1-low2)); 
        }
      }
    }
    else {
      if ( low1 > high2 ) { //no overlap
        return (new PVector(0,0)); //return a null vector
      }
      else {
        if ( (high2-low1) < projection.mag() ) { //new smallest projection found
          projection = nor.get();
          projection.normalize();
          projection.mult((high2-low1)); 
        }
      }
    }
  }
  
  return projection;
}
//
void loadObstaclesData() {
  obs_table = loadTable("data/obstacles.csv", "header"); 
  obstacles.clear();
  
  if (obs_table.getRowCount() == 0) {
    obs_table = new Table();
    obs_table.addColumn("obs_num");
    obs_table.addColumn("points");
   }
  else{
    for (int i = 0; i < obs_table.getRowCount(); i++) {
      // Iterate over all the rows in a obs_table.
      TableRow row = obs_table.getRow(i);
      // Access the fields via their column name (or index).
      int num = row.getInt("obs_num");
      String spoints = row.getString("points").replace("[","");
      String[] points = spoints.split("]");
      ArrayList obs_points = new ArrayList();
      for (int p = 0; p < points.length; p++) {
        //println("--" + points[p]);
        String[] values = points[p].split(",");
        PVector newVec = new PVector(float(values[0]),float(values[1]));
        obs_points.add(newVec);
      }
      obstacles.add(new Obstacle(obs_points));
    }
  }
 
}
void updateObstaclesData (String points) {
      TableRow row = obs_table.addRow();
      row.setInt("obs_num", obstacles.size());
      row.setString("points", points);
      
    saveTable(obs_table, "data/obstacles.csv");
    loadObstaclesData();
}
void drawObstacles (PGraphics targetGraphic) {
  
    for (int o = 0; o < obstacles.size(); o++) {
      Obstacle obs = obstacles.get(o);
      targetGraphic.stroke(255,0,0);
      targetGraphic.noFill();
      targetGraphic.ellipse(obs.centroid.x,obs.centroid.y,10,10);
      targetGraphic.fill(255,0,0);
      targetGraphic.text(o, obs.centroid.x +10, obs.centroid.y+10);
      targetGraphic.noFill();
      targetGraphic.beginShape();
      //translate(x,y);
      for (int i=0; i <obs.points.size(); i++) {
        PVector v = (PVector)obs.points.get(i);
        targetGraphic.vertex( v.x, v.y );
      }
      targetGraphic.endShape(CLOSE);
      targetGraphic.stroke(255);
      targetGraphic.fill(255);
    }
     
}

void draw_explosionPts (PGraphics targetGraphic) {
    for (int p=0; p < explosion_points.size(); p++ ) {
      PVector cntr = explosion_points.get(p);
      targetGraphic.ellipse(cntr.x,cntr.y,10,10);
      targetGraphic.beginShape();
      targetGraphic.endShape(CLOSE);
    }
}

// find centroid of obstacle shapes
float avgx, avgy;
float [] avgArray = new float[2];
PVector findCentroid(ArrayList points) {
  float[] x = {};
  float[] y = {};
  for (int i=0; i < points.size(); i++) {
    PVector v = (PVector) points.get(i);
    x = append(x,v.x);
    y = append(y,v.y);
  }
  avgx = findAverage(x);
  avgy = findAverage(y);
  PVector centroid = new PVector(avgx,avgy);
  return centroid;
}
float findAverage(float [] anyArray) {
  int sum=0;
  for (int i=0; i<anyArray.length; i++){
    sum+=anyArray[i];
  }
  float avg = sum/anyArray.length;
  return avg;
}

void star(float x, float y, float radius1, float radius2, int npoints, PGraphics target) {
  float angle = TWO_PI / npoints;
  float halfAngle = angle/2.0;
  target.beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius2;
    float sy = y + sin(a) * radius2;
    target.vertex(sx, sy);
    sx = x + cos(a+halfAngle) * radius1;
    sy = y + sin(a+halfAngle) * radius1;
    target.vertex(sx, sy);
  }
  target.endShape(CLOSE);
}