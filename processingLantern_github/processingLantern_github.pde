//Processing Lanturn Version 0.1 //<>// //<>// //<>// //<>//
/*
To-Do
 -introduction explaining rules, linear path, with visible endpoint
 -
 */

//input your media files into sketch folder, and adjust names to object locations below
//CREATE YOUR POINTS OF INTEREST HERE....(NAME, LATIITUDE, LONGITUDE, HUE, SATURATION, VIBRANCY, FADERATE, PULSERATE, RAINBOWRATE, SONGNAME) 
Locations[] waypoint;
int locIndex = 0;
int prevLocIndex;

Locations home = new Locations("home", 41.7359, -74.6773, 100, 255, 255, 0, 0, 0, "../sounds/track1.mp3");
Locations lab = new Locations("Lab", 41.7351, -74.6738, 140, 255, 100, 1, 1, 0, "../sounds/track2.mp3");
Locations hac = new Locations("hac", 41.7361, -74.6742, 60, 255, 230, 2, 4, 0, "../sounds/track3.mp3");

//allowable distance for detection of GPS (about 10m)
float range = 0.0001;

import processing.serial.*;
import ddf.minim.*;
AudioPlayer[] track;
Minim minim;

//variable for background music, noFix and Flashlight
int bgMusic = 0;
int noFixTrack = 1;
int flTrack = 2; //flashlight warning track
int prevTrack = 1;

Serial port;
float currLat;
float currLon;

String input;
Boolean receivedGPSData = false;

boolean startupFinished = false;
boolean firstContact = false;

void setup() {
  waypoint = new Locations[3]; //number of locations estalished above
  waypoint[0] = home;
  waypoint[1] = lab;
  waypoint[2] = hac;

  //Array to store music tracks......+3 for bg,noFix and, flashlight
  track = new AudioPlayer[waypoint.length + 3];
  minim = new Minim(this);

  track[bgMusic] = minim.loadFile("../sounds/background.mp3");
  println("background.mp3 file loaded");

  track[noFixTrack] = minim.loadFile("../sounds/noFixAlert.mp3");
  println("noFixAlert file Loaded");

  track[flTrack] = minim.loadFile("../sounds/flashlight.mp3");
  println("flashlight file Loaded!");

  for (int x = 3; x < track.length; x++) {
    println("Setup track#: " + x);
    track[x] = minim.loadFile(waypoint[x - 3].song); //waypoint computer numbering tracks (w/ bg) is regular
  }

  port = new Serial(this, "/dev/cu.SLAB_USBtoUART", 115200);
  port.bufferUntil(10);
  delay(2000);
  handshake();
  startup();
}

void draw() {
  //println("draw Loop start");
  if (firstContact == true) {
    if (receivedGPSData == true) {
      if (input != null) {
        if (input.equals("FLASHLIGHT MODE")) {
          eventTrigger(flTrack);
          println("flashlight mode engaged");
        } else if (input.equals("No Fix")) {  // use .equals() for string comparison because strings are objects in Java
          noFixAlert();
          delay(100);
        } else {
          float[] data = float(split(input, ","));
          currLat = data[0];
          currLon = data[1];

          //to ensure it doesn't continuously search while playing a track
          if (track[prevLocIndex + 3].isPlaying()) {
            println("Waypoint Location Playing");
          } else {
            ///////start at 2 to skip bg and NoFix
            for ( locIndex = 0; locIndex < waypoint.length; locIndex++) {
              if (inRange( waypoint[locIndex].locLat, waypoint[locIndex].locLon)) {
                println("Found Location: " + waypoint[locIndex].locName);
                eventTrigger(locIndex + 3); //plus two to correct for bgMusic + noFix in tracks
                bulbUpdate(locIndex);
                prevLocIndex = locIndex;
                return;
              } else {
                eventTrigger(bgMusic);
                // function to play bg music and lighting
              }
            }
          }
        }
      }
      delay(100);
    }
    //askGPSData();
    //delay(3000);
  }
}

void noFixAlert() {
  println("No Fix Alert issued: please wait");
  eventTrigger(noFixTrack);
}

void startup() {
  delay(1200);
  output(0, 255, 255, 1, 0, 7);
  AudioPlayer startup;
  startup = minim.loadFile("../sounds/startup.mp3");
  startup.play();
  while (startup.isPlaying()) {
    delay(100);
  }
  //output(0, 0, 0, 0, 0, 0); //blank
  delay(200);
  startupFinished = true;
  println("Startup Finished");
}
