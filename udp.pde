/**
 * (./) udp.pde - how to use UDP library as unicast connection
 * (cc) 2006, Cousot stephane for The Atelier Hypermedia
 https://github.com/una1veritas/Processing-sketches/blob/master/libraries/udp/examples/udp/udp.pde
 *
 * Create a communication between Processing<->Pure Data @ http://puredata.info/
 * This program also requires to run a small program on Pd to exchange data  
 * (hum!!! for a complete experimentation), you can find the related Pd patch
 * at http://hypermedia.loeil.org/processing/udp.pd
 * 
 * -- note that all Pd input/output messages are completed with the characters 
 * ";\n". Don't refer to this notation for a normal use. --
 */

// import UDP library
import hypermedia.net.*;
UDP udp;  // define the UDP object
String message = "";
//

void udpConnect() {
  udp = new UDP( this, 9000 );
  //udp.log( true );     // <-- printout the connection activity
  udp.listen( true );
}


/** 
 * on key pressed event:
 * send the current key value over the network
 */
 /*
void keyPressed() {
    
    String message  = str(key);  // the message to send
    String ip       = "localhost";  // the remote IP address
    int port        = 8000;    // the destination port
    
    // formats the message for Pd
    message = message+" -- salut super long message 9 0 12;\n";
    // send the message
    udp.send( message, ip, port );
    
}
*/
/**
 * To perform any action on datagram reception, you need to implement this 
 * handler in your code. This method will be automatically called by the UDP 
 * object each time he receive a nonnull message.
 * By default, this method have just one argument (the received message as 
 * byte[] array), but in addition, two arguments (representing in order the 
 * sender IP address and his port) can be set like below.
 */
 /*
int upos_x, upos_y, _r, _g, _b;
float time;
*/
// void receive( byte[] data ) {       // <-- default handler
void receive( byte[] data, String ip, int port ) {  // <-- extended handler
  // get the "real" message =
  // forget the ";\n" at the end <-- !!! only for a communication with Pd !!!
  data = subset(data, 0, data.length);
  message = new String( data ); 
  // print the result
  //println( "receive: \""+message+"\" from "+ip+" on port "+port );
  
  // process data
  //get route
  String route = message.substring(0,7); // keep this template for messages : /xroute vars
  String vars = message.substring(8);
  
  if (route.matches("/kinect")) {
    String[] q = vars.split("[a-z]");
    for (int i=1; i < q.length; i++) {
      String[] datas = q[i].split(" ");
      visitors.get(i-1).update(int(datas[1]),int(datas[2]),int(datas[3]));
    }
  }
 if (route.matches("/maxBds")) {
    maxBoids = int(vars);
  }
  
 if (route.matches("/blobsz")) {
    sfzone = int(vars);
  }
  
 if (route.matches("/bdsize")) {
    size_mult = int(vars);
  }
  
 if (route.matches("/explos")) {
    String[] newVars = vars.split(" ");
    println(newVars[2]);
    PVector newExplosionPt = new PVector(int(newVars[1]),int(newVars[2]));
    switch(newVars[0]) {
      case "a":
        explosion_points.set(0,newExplosionPt);
        break;
      case "b":
        explosion_points.set(1,newExplosionPt);
        break;
      case "c":
        explosion_points.set(2,newExplosionPt);
        break;
    }
  }
 if (route.matches("/trigge")) {
    String[] newVars = vars.split(" ");
    generateParticles (newVars);
  }
  
  if (route.matches("/trogge")) {
    String[] newVars = vars.split(" ");
    generateRandomParticles (newVars);
  }
  
}

void generateParticles (String[] vars) {
  int _r = int(vars[1]);
  int _g = int(vars[2]);
  int _b = int(vars[3]);
  color pcolor = color(_r,_g,_b);
  PVector targetPos = new PVector(0,0);
  
  switch(vars[4]) {
    case "a":
      targetPos = explosion_points.get(0);
      break;
    case "b":
      targetPos = explosion_points.get(1);
      break;
    case "c":
      targetPos = explosion_points.get(2);
      break;
  }
  flock.boids_explosion(maxBoids, targetPos, pcolor);
}


void generateRandomParticles (String[] vars) {
  int _r = int(vars[1]);
  int _g = int(vars[2]);
  int _b = int(vars[3]);
  color pcolor = color(_r,_g,_b);
  PVector targetPos = new PVector(0,0);
  
  switch(vars[4]) {
    case "a":
      targetPos = obstacles.get(0).centroid;
      break;
    case "b":
      targetPos = obstacles.get(1).centroid;
      break;
    case "c":
      targetPos = obstacles.get(2).centroid;
      break;
  }
  flock.boids_explosion(maxBoids, targetPos, pcolor);
}