//Processing Lanturn Version 0.1 //<>//
/*
To-Do
- get battery to keep fixes for GPS CR1220
- background
-algorithm to detect if in range or not for preset locations
- send data as INTS via Serial and only have:"HUE,SATURATION,VIBRANCE,FADE_RATE(1-9),PULSE_RATE (1-9)"
- if fade rate or pulserate is 0 then they are skipped
-background music plays and lanturn returns to white after playing an exerpt or out of range of a topic
-introduction explaining rules, linear path,with visible endpoint
*/

//input your media files here

//CREATE YOUR POINTS OF INTEREST HERE....(NAME, LATIITUDE, LONGITUDE, HUE, SATURATION, VIBRANCY, FADERATE, PULSERATE, SONGNAME) 
Locations[] waypoint;
int locIndex = 0;

Locations home = new Locations("home", 41.7359, -74.6773, 100, 255, 255, 0, 0, "track1.mp3");
Locations lab = new Locations("Lab", 41.7351, -74.6738, 140, 255, 100, 1, 1, "track2.mp3");
Locations hac = new Locations("hac", 41.7361, -74.6742, 60, 255, 230, 2, 4, "track3.mp3");



float range = 0.0001;

import processing.serial.*;
import ddf.minim.*;
AudioPlayer[] track;
Minim minim;


Serial port;
float currLat;
float currLon;
String input;

void setup() {
  waypoint = new Locations[3]; //number of locations estalished above
  AudioPlayer[] track = new AudioPlayer[waypoint.length];
  
  waypoint[0] = home;
  waypoint[1] = lab;
  waypoint[2] = hac;
  
  minim = new Minim(this);
  for (int x = 0; x < waypoint.length; x++) {
    track[x] = minim.loadFile(waypoint[x].song);
    println("song " + (x + 1) + " loaded!");
  }
  port = new Serial(this, "/dev/cu.SLAB_USBtoUART", 115200);
  port.bufferUntil('\n');
  
  output(255,255,255,1,1);
  delay(500);
  output(85,255,255,1,0);
  delay(500);
  output(170,255,255,1,0);
  delay(500);
}

void draw() {
}

// function to wait for serial message to read data
// if nothing show red, else record corrdinates
void serialEvent(Serial port) {
  input = port.readStringUntil('\n');
 
  // .trim()removes any whitespace and 'unseen' characters from input like return,space and tab
  //also removes Unicode "nbsp" character
  input = input.trim();
  println(input);
  if (input.equals("No Fix")) {  // use .equals() for string comparison because strings are objects in Java
    background(255, 0, 0);
    if (track[1].isPlaying()) {
    }
    if ( !track[1].isPlaying()) {
    for (int i = 5; i > 0; i--) {
        println("Countdown: " + i );
        delay(500);
      }
        track[2].play();
    }
    ///call output function
  }
  
  
  else {
    float[] data = float(split(input, ","));
    currLat = data[0];
    currLon = data[1];
    println(currLat + "," + currLon);
    
    if(inRange( waypoint[locIndex].locLat, waypoint[locIndex].locLon)){
      output(waypoint[locIndex].hue, waypoint[locIndex].sat, waypoint[locIndex].vib, waypoint[locIndex].fadeRate, waypoint[locIndex].pulseRate);
      //playTrack([locIndex]); 
      //play function to go here 
      //-handle playing tracks to completion
      //-not allowing to be interferred
      //replayable after certain period
    }
    else{
      //intermission(); function to play bg music and lighting here
  }
}
}

//function to determine if you're close enough to GPS coordinates to trigger event
boolean inRange(float locLat, float locLon) {
  float latDifference = abs(currLat - locLat);
  float lonDifference = abs(currLon - locLon);
  if (latDifference <= range && lonDifference <= range) {
    return true;
  } else {
    return false;
  }
}

void output(int hue, int sat, int vib, int fadeRate, int pulseRate){
  String comma = ",";
  String finalOutput = str(hue) + comma + str(sat) + comma + str(vib) + comma + fadeRate + comma + pulseRate;
  println(finalOutput);
  port.write(finalOutput);
}


void intermission(int intensity){
 //bg[intensity].play();
}

void waypointPlay(int trackNum){
  if (track[trackNum].isPlaying()){
    return;
  }
  else{
    track[trackNum].play();
  }
}
    