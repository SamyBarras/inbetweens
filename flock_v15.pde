/*
  --------------------------------------------
  samy.barras@gmail.com
  --------------------------------------------
  With help of :
     --> https://processing.org/examples/flocking.html
     --> http://natureofcode.com/book/chapter-6-autonomous-agents/
     --> http://www.metanetsoftware.com/technique/tutorialA.html
  --------------------------------------------
*/

boolean debug = false;
int quantity = round(random(20,50));
int lifeTime = 1000;
boolean use_kinects = true;
int maxVisitors = 10;
int maxBoids;
int size_mult = 1;
int sfzone  = 80;
PFont font;
PGraphics console, edit, vstrs, flocka, flockb;
int fi = 1;
ArrayList<PVector> explosion_points;

import codeanticode.syphon.*;

SyphonServer server;
int nServers = 2;
SyphonServer[] servers;

void setup() {
  frameRate(25);
  size(2560, 1600, P3D);
  noSmooth();
  font = createFont("Avenir", 6);
  console = createGraphics(width, height);
  edit = createGraphics(width, height);
  flocka = createGraphics(width, height);
  flockb = createGraphics(640,480);
  maxBoids = 700;
  flock = new Flock();
  bgflock = new Flock();
  explosion_points = new ArrayList<PVector>(3);
  
  explosion_points.add(new PVector(200,200));
  explosion_points.add(new PVector(300,200));
  explosion_points.add(new PVector(400,200));
  
  obstacles = new ArrayList<Obstacle>();
  loadObstaclesData();
  visitors = new ArrayList<Visitor>();
  for (int i = 0; i < maxVisitors; i++) {
    visitors.add(new Visitor(0,0,0, false));
  }
  vstrs = createGraphics(width, height);
  //
  for (int i = 0; i < 100; i++) {
    flock.addBoid(new Boid(width/2,height/2,0,color(100,255,255)));
  }
  for (int i = 0; i < 200; i++) {
    bgflock.addBoid(new Boid(width/2,height/2,0,color(255)));
  }
  udpConnect(); 
  server = new SyphonServer(this, "full-gui");
  servers = new SyphonServer[nServers];
  for (int i = 0; i < nServers; i++) { 
    servers[i] = new SyphonServer(this, "Processing Syphon."+i);
  }
}

void draw() {
  background(0);
  if (use_kinects) {
    visitorNum = 0;
    for (Visitor v : visitors) {
        if (v.active == true) visitorNum++;
    }
    if (visitorNum > 0) visitor = true;
    else visitor = false;
    if (UIActive == true) {
      //vstrs
      vstrs.beginDraw();
      vstrs.clear();
      for (Visitor vstr : visitors) {
        vstrs.fill(125,0,0);
        ellipseMode(RADIUS);
        vstrs.ellipse(vstr.position.x, vstr.position.y, vstr.size, vstr.size);
      }
      vstrs.endDraw();
      image(vstrs, 0, 0);
    }
  }
  /* EDITION MODE */
  if (editMode == true) {
    edit.beginDraw();
    edit.background(color(125,125,125));
    edit.fill(255);
    edit.strokeWeight(1);
    edit.stroke(255);
    edit.line(0, mouseY, width, mouseY); // x
    edit.line(mouseX, 0, mouseX, height); // y
    edit.noStroke();
    edit.stroke(255,0,0);
    drawObstacles(edit);
    edit.endDraw();
    //
    image(edit, 0, 0);
  }
  /* CONSOLE */
  if (UIActive == true) {
    console.beginDraw();
    console.textFont(font,12);
    console.clear();
    
    console.noFill();
    console.stroke(255,0,0);
    drawObstacles(console);
    draw_explosionPts(console);
    
    console.translate(0,50);
    console.text("fps : "+int(frameRate),20,20);
    console.text("boids : " + flock.boids.size() + "(/" + maxBoids + ")", 20,40);
    console.text("obstacles : " + obstacles.size(), 20,60);
    console.text("use kinects :" + use_kinects + " / num visitors : " + visitorNum,20,80);
    console.text("udp last message : " + message, 20,100);
    
    console.endDraw();
    image(console, 0, 0);
  }
  
  flocka.beginDraw();
    flocka.clear();
    flock.run(flocka);
        flocka.stroke(0);
        flocka.fill(0);
    if(!UIActive && !editMode){
    for (int o = 0; o < obstacles.size(); o++) {
      Obstacle obs = obstacles.get(o);
      flocka.beginShape();
        for (int i=0; i <obs.points.size(); i++) {
          PVector v = (PVector)obs.points.get(i);
          flocka.vertex( v.x, v.y );
        }
        flocka.endShape(CLOSE);
    }
  }
  flocka.endDraw();
  image(flocka, 0, 0);
  server.sendScreen();
}