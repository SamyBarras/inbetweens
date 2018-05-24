ArrayList<Obstacle> obstacles;
Table obs_table;

class Obstacle {
  float x,y;
  ArrayList points;
  PVector centroid;
  Obstacle(ArrayList p) {
    points = p;
    centroid = findCentroid(points);
  }
  void show() {
    pushMatrix();
    fill(150);
    stroke(0);
    ellipse(centroid.x,centroid.y,10,10);
    beginShape();
    //translate(x,y);
    for ( int i = 0; i < points.size(); i++ ) {
      PVector v = (PVector)points.get(i);
      vertex( v.x, v.y );
    }
    endShape(CLOSE);
    popMatrix();
  }
}
class Poly {
  float x,y;
  ArrayList points;
  float theta;
  
  Poly(float _theta, float _x,float _y,ArrayList p) {
    x = _x;
    y = _y;
    points = p;
    theta = _theta;
  }
  void show() {
    pushMatrix();
    fill(150);
    stroke(0);
    beginShape();
    translate(x,y);
    //rotate(theta);
    for ( int i = 0; i < points.size(); i++ ) {
      PVector v = (PVector)points.get(i);
      vertex( v.x, v.y );
    }
    endShape(CLOSE);
    popMatrix();
  }
}