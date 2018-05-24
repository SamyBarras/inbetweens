/*
  // https://processing.org/examples/flocking.html
  // http://natureofcode.com/book/chapter-6-autonomous-agents/
*/
Flock flock;
Flock bgflock;

class Flock {
  ArrayList<Boid> boids;
  
  Flock() {
    boids = new ArrayList<Boid>();
  }

  void run(PGraphics target) {
    for ( int i= 0; i < boids.size(); i++) {
      boids.get(i).run(boids,target);
      if (boids.get(i).life == 0 && boids.get(i).hidden == true){
        boids.remove(i);
      }
    }
  }

  boolean addBoid(Boid b) {
    boids.add(b);
    return true;
  }
  
  Boid getBoid(int index){
    return boids.get(index);
  }
  
  void boids_explosion (int maxBds, PVector dest, color pcolor) {
    int random_type = round(random(1,4));
    int flockSize = boids.size();
    int averageNumBoids = round(map(flockSize, 0, maxBds, 80, 5));
    if (random_type == 2) averageNumBoids = round(map(flockSize, 0, maxBds, 30,5)); 
    if (random_type == 3) averageNumBoids = round(map(flockSize, 0, maxBds, 10,5)); 
    int myquantity = round(random(averageNumBoids-5, averageNumBoids+5));
    if (random_type==3) {
      pcolor = blendColor(pcolor,pcolor,ADD);
    }
    for (int x = 0; x < myquantity; x++){
      addBoid(new Boid(dest.x, dest.y, random_type, pcolor));
    }
  }

}
class Boid {

  PVector loc, l, vel, acc;
  int type, life, checkL;
  float r, wandertheta;
  float maxforce, attract_maxforce, maxspeed;
  boolean is_avoiding = false;
  boolean is_alone = false;
  boolean hidden = false;
  boolean fillBoid = false;
  float angle = random(TWO_PI);
  int neighbours = 0;
  float desiredseparation = 25.0f;
  color col = color(255,255,255);
  int neighboursNum = 0;
  int star_pts = 3;
  
  Boid(float x, float y, int typeof, color _col) { 
    acc = new PVector(0,0);
    loc = new PVector (x,y);
    type = typeof;
    col = _col;
    wandertheta = 0.0;
    maxforce = 0.04;
    attract_maxforce = 0.06;
    checkL = 50;
    star_pts = round(random(3,4));
    
    if (type == 2) {
      r = size_mult * 4 + random(-2,2);
      desiredseparation += 20.0;
    }
    else r = size_mult * 2.0 + random(-1,1);
    switch (type) {
      case 0 :
        life = 1;
        maxspeed = 3.0; 
        vel = new PVector(cos(angle), sin(angle));
        break;
      case 1 :
        life = lifeTime*round(random(2,5));
        maxspeed = 10.0;
        maxforce = 0.08;
        desiredseparation = 10.0;
        vel = new PVector(random(2,3),random(2,3));
        break;
      case 2 :
        life = lifeTime*round(random(2,5));
        maxspeed = 4.0; 
        vel = new PVector(cos(angle),sin(angle)*3);
        break;
      case 3 :
        life = lifeTime*round(random(2,5));
        maxspeed = 4.0; 
        vel = new PVector(random(2,3),sin(angle)*3);
        break;
      case 4 :
        life = lifeTime*1;
        maxspeed = 3.0; 
        vel = new PVector(cos(angle*1.5), sin(angle));
        break;
    }
  }

  void run(ArrayList<Boid> boids, PGraphics target) {
    if (life > 0) obstacleAvoid();
    flock(boids);
    update();
    borders();
    render(target);
  }
  Boid clone()
  {
    Boid cboid = new Boid(this);
    return cboid;
  }
  Boid(Boid tboid)
  {
    this.loc = new PVector(tboid.loc.x, tboid.loc.y);
    this.col = tboid.col;
    this.type = tboid.type;
    this.is_avoiding = tboid.is_avoiding;
    this.neighbours = tboid.neighbours;
    this.vel = tboid.vel;
  }
  void flock(ArrayList<Boid> boids) {
    PVector sep = separate(boids);
    PVector ali = align(boids, 100); 
    PVector coh = cohesion(boids);  
    PVector hide = hide(); 
    PVector kiss = kissTheVisitor();
    PVector avoidBlob = avoidVisitor();
    
    if (!is_avoiding) {
      switch (type) {
      case 0 :
        sep.mult(1.5);
        ali.mult(0.8);
        coh.mult(1.0);
        break;
      case 1 :
        sep.mult(5.0);
        ali.mult(0.5);
        coh.mult(3.0);
        break;
      case 2 :
        sep.mult(1.5);
        ali.mult(1.0);
        coh.mult(1.0);
        break;
      case 3 :
        sep.mult(1.5);
        ali.mult(0.8);
        coh.mult(1.0);
        break;
      case 4 :
        sep.mult(1.5);
        ali.mult(0.8);
        coh.mult(1.0);
        break;
      }
    }
    else {
      sep.mult(0.5);
      ali.mult(0);
      coh.mult(0);
    }
    //
    if (visitor) {
      if (type == 1) {
        kiss.mult(5.0);
        sep.mult(3.0);
        ali.mult(1.0);
        coh.mult(0.5);
        applyForce(kiss);
      }
      else if (type == 2) {
        avoidBlob.mult(4.0);
        applyForce(avoidBlob);
      }
      else if (type == 3) {
        hide.mult(2.0);
        applyForce(hide);
      }
      else ;
    }
    if (life == 0 && type != 3) {
      hide.mult(2);
      applyForce(hide);
    }
    if (type == 3 && life < 500) {
        sep.mult(0);
        ali.mult(0);
        coh.mult(0);
    }
    if (type == 3 && life == 0) { hidden = true; };
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
  }
  void update() {
    vel.add(acc);
    if (type == 3 && life < 200) {
      vel.mult(life/200.0f);
    }
    vel.limit(maxspeed);
    loc.add(vel);
    acc.mult(0);
    if (life > 0){
      if (type != 0) { 
        if (type == 1 && visitor == false) life--; 
        if (type != 1) life--;
      }
    }
    
  }
  
  void applyForce(PVector force) {
    acc.add(force);
  }
  
  void obstacleAvoid() {
    
    boolean projected = false;
    float checkLength = checkL*vel.mag();
    PVector forward,ray,projection,force,lateral;
    float dotProd, dis;
    float theta = vel.heading() + radians(90);
    forward = vel.get();
    forward.normalize();
    ray = forward.get();
    ray.mult(checkLength);
    lateral = forward.get();
    lateral.set(lateral.y,-lateral.x,0);
    lateral.mult(r*2);
    ArrayList p = new ArrayList();
    p.add(new PVector(lateral.x,lateral.y));
    p.add(new PVector(-lateral.x,-lateral.y));
    p.add(new PVector(ray.x-lateral.x,ray.y-lateral.y));
    p.add(new PVector(ray.x+lateral.x,ray.y+lateral.y));
    Poly check = new Poly(theta, loc.x, loc.y,p);
    if (type == 1) {
       ArrayList po = new ArrayList();
        int mult = 5;
        po.add(new PVector(-r*mult,0));
        po.add(new PVector(0,r*mult));
        po.add(new PVector(r*mult,0));
        po.add(new PVector(0,-r*mult));
      check = new Poly(theta, loc.x, loc.y, po);
    }
    
    for ( int i = 0; i < obstacles.size(); i++ ) {
      Obstacle ob = (Obstacle)obstacles.get(i);
      projection = overlap(check, ob);
      if ( (projection.x != 0) || (projection.y != 0) ) {
        projected = true;
        is_avoiding = true;
        projection.normalize();
        force = lateral.get();
        force.normalize();
        force.mult( projection.dot(force) );
        force.limit(maxforce);
        acc.add(force);
      }
    }
    if ( projected == false ) {
      is_avoiding = false;
      wander();
    }
    
  }  
  
  /////////////////////////////////////////////////////
  void render(PGraphics target) {
    float theta = vel.heading() + radians(90);
    target.fill(0,255,255);
    if (is_alone) target.fill(255,0,0);
    target.stroke(0);
    target.pushMatrix();
    target.translate(loc.x,loc.y);
    target.rotate(theta);
    target.noFill();
    
    if (type == 1) {
      if (neighboursNum > 0) { 
        int alpha = round(map(neighboursNum,0,7,100,255));
        color acol = color(red(col),green(col),blue(col),alpha);
        target.stroke(acol);
        if (fillBoid == true) fill(acol);
      }
      else {
        target.stroke(col);
        if (fillBoid == true) fill(col);
      }
      target.strokeWeight(1.5);
      target.ellipse(0,0,2,2);
      target.strokeWeight(1);
    }
    else if(type == 2) {
      target.stroke(col);
      target.fill(0);
      target.ellipse(0,0,r*2,r*5);
      target.fill(col);
      target.ellipse(0,0,r,r);
      target.fill(0);
      target.line(0,-r*2.5,0,r*2.5);
      target.noFill();
    }
    else if (type == 3) {
      target.stroke(col);
        float alphaLife = map(life, 0, 150, 0, 255);
        target.stroke(red(col),green(col),blue(col), alphaLife);
      star(0., 0., r/1.5, r*3, star_pts, target);
      target.fill(col);
      target.ellipse(0,0,r,r);
    }
    else {
      target.stroke(col);
      if (fillBoid == true) fill(col);
      target.beginShape(TRIANGLES);
      target.vertex(0, -r*2);
      target.vertex(-r, r);
      target.vertex(r, r);
      target.endShape();
      target.ellipse(0,-r*2,r/2,r/2);
      target.noFill();
      target.ellipse(0,-r*2,r*2,r*2);
      target.line(0,r,sin(frameCount)*random(-2,2),r*4);
      
    }
    target.popMatrix();
  }
  
  void borders() {
    if (loc.x < -r) loc.x = flocka.width+r;//width+r;
    if (loc.y < -r) loc.y = flocka.height+r;//height+r;
    if (loc.x > flocka.width+r) loc.x = -r;
    if (loc.y > flocka.height+r) loc.y = -r;
  }
  
  void wander() {
    
    if (type == 3) {
    float wanderR = 16.0f;    
    float wanderD = 30.0f;    
    float change = 0.3f;//0.25f;
    wandertheta += random(-change,change);   
  
    PVector circleloc = vel.get();  
    circleloc.normalize();       
    circleloc.mult(wanderD);  
    circleloc.add(loc);            
    
    PVector circleOffSet = new PVector(wanderR*cos(wandertheta),wanderR*sin(wandertheta));
    PVector target = PVector.add(circleloc,circleOffSet);
    
    
    acc.add(steer(target,false));  
   
    }
  }
  
  PVector steer(PVector target, boolean slowdown) {
    PVector steer;  
    PVector desired = PVector.sub(target,loc);
    float d = desired.mag();
    
    if(is_alone)  maxspeed = 4.0;
    else maxspeed = 2.0;
    if (d > 0) {
      desired.normalize();
      if ((slowdown) && (d < 100.0f)) desired.mult(maxspeed*(d/100.0f));
      else desired.mult(maxspeed);
      steer = PVector.sub(desired,vel);
      steer.limit(maxforce); 
      
    } else {
      steer = new PVector(0,0);
    }
    return steer;
  }
  
    PVector separate (ArrayList<Boid> boids) {
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
      for (int b = 0; b < boids.size(); b++){
      Boid other = boids.get(b);
      float d = PVector.dist(loc, other.loc);
      if (type == other.type) {
        if ((d > 0) && (d < desiredseparation)) {
          PVector diff = PVector.sub(loc, other.loc);
          diff.normalize();
          diff.div(d);  
          steer.add(diff);
          count++;      
        }
      }
      else {
        if ((d > 0) && (d < desiredseparation*2)) {
          PVector diff = PVector.sub(loc, other.loc);
          diff.normalize();
          diff.div(d);    
          steer.add(diff);
          count++;     
        }
      }
    }
    if (count > 0) {
      steer.div((float)count);
    }
   if (steer.mag() > 0) {
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(vel);
      steer.limit(maxforce);
    }
    return steer;
  }
    PVector align (ArrayList<Boid> boids, int min_dist) {
    float neighbordist = min_dist;
    PVector sum = new PVector(0, 0);
    PVector steer = new PVector (0,0);
    int acount = 0;
    float tmp_dist = sqrt(width*width+height*height);
    Boid closestBoid = this;
    neighboursNum = 0;
       for (int b = 0; b < boids.size(); b++){
      Boid other = boids.get(b);
      float d = PVector.dist(loc, other.loc);
      if (d < tmp_dist && other != this && other.neighbours > 2 && type == other.type  && col == other.col) {
          tmp_dist = d;
          neighboursNum += 1;
          closestBoid = other;
      }
      if ((d > 0) && (d < neighbordist)) {
        if(other.is_avoiding == false) {
          sum.add(other.vel);
          acount++;
        }
      }
    }
    neighbours = acount;
    if (acount > 0) {
      is_alone = false;
      sum.div((float)acount);
      sum.normalize();
      sum.mult(maxspeed);
      steer = PVector.sub(sum, vel);
      steer.limit(maxforce);
    } 
    else {
      is_alone = true;
      steer = steer(closestBoid.loc, true);
    }
    return steer;
  }
  PVector cohesion (ArrayList<Boid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);  
    int count = 0;
    for (int b = 0; b < boids.size(); b++){
      Boid other = boids.get(b);
      float d = PVector.dist(loc, other.loc);
      if (((d > 0) && (d < neighbordist)) && (type == other.type) && (col == other.col)) {
        sum.add(other.loc); 
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return steer(sum,false);
    } 
    else {
      return new PVector(0, 0);
    }
  }
  
  PVector hide () {
    
   PVector desired = new PVector(0,0);
   PVector steer = new PVector(0,0);
    if (obstacles.size() >= 1) {
      Obstacle closestObs = obstacles.get(0);
      float dist = sqrt(width*width+height*height);
      //
      for (int i = 0; i < obstacles.size(); i++) {
        float newdist = dist(obstacles.get(i).centroid.x,obstacles.get(i).centroid.y, loc.x,loc.y);
        if (newdist < dist) {
          dist = newdist;
          closestObs = obstacles.get(i);
          if (newdist < 10) hidden = true;
        }
      }
       desired = PVector.sub(closestObs.centroid, loc);
      desired.setMag(maxspeed);
      steer = PVector.sub(desired, vel);
      steer.limit(attract_maxforce);
    }
    return steer;
    
    
  }
  PVector avoidVisitor() {
    PVector desired = new PVector (0,0);
    PVector steer = new PVector (0,0);
    float dist = sqrt(width*width+height*height);
    PVector mouse = new PVector (mouseX,mouseY);
    //love visitors
    if (use_kinects) {
      Visitor closestVstr = visitors.get(0);
      for (int i = 0; i < visitors.size(); i++) {
        float newdist = dist(visitors.get(i).position.x,visitors.get(i).position.y, loc.x, loc.y);
        if (newdist < dist) {
          dist = newdist;
          closestVstr = visitors.get(i);
        }
      }
      if (dist < sfzone) {
        desired = PVector.sub(closestVstr.position, loc);
        desired.mult(-1);
        steer = PVector.sub(desired, vel);
        steer.limit(attract_maxforce); 
      }
    }
    else {
      dist = dist(mouse.x, mouse.y, loc.x,loc.y);
      desired = PVector.sub(mouse, loc);
      if (dist < sfzone ) {
        desired.mult(-1);
        steer = PVector.sub(desired, vel);
        steer.limit(attract_maxforce);
      }
    }
    return steer;
  }
  PVector kissTheVisitor() {
    PVector desired = new PVector (0,0);
    PVector steer = new PVector (0,0);
    float dist = sqrt(width*width+height*height);
    PVector mouse = new PVector (mouseX,mouseY);
    //love visitors
    if (use_kinects) {
      Visitor closestVstr = visitors.get(0);
      for (int i = 0; i < visitors.size(); i++) {
        float newdist = dist(visitors.get(i).position.x,visitors.get(i).position.y, loc.x, loc.y);
        if (newdist < dist) {
          dist = newdist;
          closestVstr = visitors.get(i);
        }
      }
      desired = PVector.sub(closestVstr.position, loc);
      desired.normalize();
      desired.mult(2);
      desired.mult(maxspeed);
      if (dist < sfzone) {
        desired.mult(-1);
      }
    }
    else {
      dist = dist(mouse.x, mouse.y, loc.x,loc.y);
      desired = PVector.sub(mouse, loc);
      desired.normalize();
      desired.mult(2);
      desired.mult(maxspeed);
      if (dist < sfzone ) {
        desired.mult(-1);
      }
    }
    steer = PVector.sub(desired, vel);
    steer.limit(attract_maxforce);  
    return steer;
  }
}