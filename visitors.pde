ArrayList<Visitor> visitors;
boolean visitor = false;
int visitorNum = 0;


class Visitor {
  PVector position;
  float size;
  boolean active = false;
  
  Visitor(int xpos, int ypos, int size, boolean active) {    
    this.position = new PVector(xpos, ypos);
    this.size = map(size, 0, 255, 0, 100);
    this.active = active;
    //
  }
  //
  void update (int x, int y, int size) {
    float newX = map(x, 0, 255, 0, width);
    float newY = map(y, 0, 255, 0, height);
    
    this.position = new PVector(newX,newY);
    
    if (size == 0 && x == 0 && y == 0) {
      this.active = false;
      //visitorNum--;
    }
    else {
      this.active = true;
    }
    this.size = map(size, 0, 255, 0, 100);
    
  }
  
  
}