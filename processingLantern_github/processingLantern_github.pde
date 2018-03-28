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

Locations home = new Locations("home", 41.7359, -74.6773, 100, 255, 255, 0, 0, 0, "track1.mp3");
Locations lab = new Locations("Lab", 41.7351, -74.6738, 140, 255, 100, 1, 1, 0, "track2.mp3");
Locations hac = new Locations("hac", 41.7361, -74.6742, 60, 255, 230, 2, 4, 0, "track3.mp3");

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

  track[bgMusic] = minim.loadFile("background.mp3");
  println("background.mp3 file loaded");

  track[noFixTrack] = minim.loadFile("noFixAlert.mp3");
  println("noFixAlert file Loaded");

  track[flTrack] = minim.loadFile("flashlight.mp3");
  println("flashlight file Loaded!");

  for (int x = 3; x < track.length; x++) {
    println("Setup track#: " + x);
    track[x] = minim.loadFile(waypoint[x - 3].song); //waypoint computer numbering tracks (w/ bg) is regular
  }

  port = new Serial(this, "/dev/cu.SLAB_USBtoUART", 115200);
  port.bufferUntil('\n');
  delay(1000);
  startup();
  handshake();
}

void draw() {
  println("draw Loop start");
  delay(1000);
  if (firstContact == true) {
    if (receivedGPSData == true) {
      if (input != null) {
        if (input.equals("FLASHLIGHT MODE")) {
          eventTrigger(flTrack);
          println("flashlight mode engaged");
        } else if (input.equals("No Fix")) {  // use .equals() for string comparison because strings are objects in Java
          noFixAlert();
          delay(100);
        } else if (input.equals("A")) {
          println("A in Serial buffer");
          port.clear();
          delay(300);
        } else {
          float[] data = float(split(input, ","));
          currLat = data[0];
          currLon = data[1];

          //to ensure it doesn't continuously search while playing a track
          if (track[prevLocIndex + 3].isPlaying()) {
            println("Waypoint Location Playing");
          } 
          else {
            ///////start at 2 to skip bg and NoFix
            for ( locIndex = 0; locIndex < waypoint.length; locIndex++) {
              if (inRange( waypoint[locIndex].locLat, waypoint[locIndex].locLon)) {
                println("Found Location: " + waypoint[locIndex].locName);
                eventTrigger(locIndex + 3); //plus two to correct for bgMusic + noFix in tracks
                bulbUpdate(locIndex);
                prevLocIndex = locIndex;
                return;
              } else {
                intermission();// function to play bg music and lighting her
              }
            }
          }
        }
      }
      delay(100);
    }
    askGPSData();
  }
}

// function to wait for serial message to read data
// if nothing show red, else record corrdinates

/*

void serialEvent(Serial port) {
  if (startupFinished == true) {
    println("Serial Event triggered");
    updateInput();
    if (input != null) {
      //handshake to sync via serial?
      
      // .trim()removes any whitespace and 'unseen' characters from input like return,space and tab
      //also removes Unicode "nbsp" character
      input = input.trim();
      println("  Trimmed Input: --" + input + "--   ");
    } else {
      println("Input is null.");
      return;
    }
    receivedGPSData = true;
  }
}

/*
void handshake() {
  while (firstContact == false) {
    println("first contact false Initiate Handshake");
    updateInput();
    if ( str(input.charAt(0)).equals("A")) {
      port.write("A"); //write A to port to initialize handshake
      firstContact = true;
      println("First Contact established, Serial port cleared");
      port.clear();
    }
  }
}

void askGPSData() {
  port.write('R');
  println("Data Request Sent...");
  receivedGPSData = false;
}

void updateInput() {
  input = port.readStringUntil('\n');
  println("INPUT Update: " + input);
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

void output(int hue, int sat, int vib, int fadeRate, int pulseRate, int rainbowRate) {
  delay(100);
  String comma = ",";
  String finalOutput = 'L' + str(hue) + comma + str(sat) + comma + str(vib) + comma + str(fadeRate) + comma + str(pulseRate) + comma + str(rainbowRate);
  println(finalOutput);
  port.write(finalOutput);
}

void bulbUpdate(int adjLocIndex) {
  output(waypoint[adjLocIndex].hue, waypoint[adjLocIndex].sat, waypoint[adjLocIndex].vib, waypoint[adjLocIndex].fadeRate, waypoint[adjLocIndex].pulseRate, waypoint[adjLocIndex].rainbowRate);
}

//function to easily send background lighting
void bgLight() {
  output(27, 255, 255, 1, 0, 0);
}

void noFixLight() {
  output(255, 255, 255, 1, 1, 0);
}

void eventTrigger(int trackNumber) {
  //play a track from tracknumber parameter, tracks replay after about 5 minutes and
  //a track will play immediately once the game has started to avoid an error
  if (track[trackNumber].isPlaying()) {
    //println("still playing");
  } else if (trackNumber == bgMusic && prevTrack == noFixTrack) { //if intermission Music and light sent is played
    track[prevTrack].pause();
    bgLight();
    track[trackNumber].play(0);
  } else if ( trackNumber == bgMusic) {
    if (prevTrack == bgMusic) {
      println("No Location Found, Playing BG music.");
      track[trackNumber].play(0);
    } else {
      println("bg music first-time 'else' statement");
      bgLight();
      track[trackNumber].play(0);
    }
  } else if (trackNumber == noFixTrack) { //if NoFixAlert is played
    println("No Fix track queued");
    if ( prevTrack == noFixTrack) {
      println("noFix Track with prevTrack NoFix");
      track[flTrack].play(0);
    }
    println("noFixTrack played first time");
    track[prevTrack].pause();
    noFixLight();
    track[trackNumber].play(0);
  } else if (trackNumber == flTrack) { //if flashlight mode engaged
    if (prevTrack == flTrack) {
      track[flTrack].play(0);
    } else {
      track[prevTrack].pause();
      output(0, 0, 255, 0, 0, 0);
      track[trackNumber].play(0);
    }
  } else {
    if (prevTrack == bgMusic || prevTrack == flTrack) {
      track[bgMusic].pause();
      track[flTrack].pause();
    }
    track[trackNumber].play(0);
    ////////output Light according to objects properties
    output(waypoint[locIndex].hue, waypoint[locIndex].sat, waypoint[locIndex].vib, waypoint[locIndex].fadeRate, waypoint[locIndex].pulseRate, waypoint[locIndex].rainbowRate);
  }
  prevTrack = trackNumber;
}
*/
void noFixAlert() {
  println("No Fix Alert issued: please wait");
  eventTrigger(noFixTrack);
}

//function to send bg music and lighting simultaneously
void intermission() {
  eventTrigger(bgMusic);
}

void startup() {
  delay(1200);
  output(0, 255, 255, 1, 0, 5);
  AudioPlayer startup;
  startup = minim.loadFile("startup.mp3");
  startup.play();
  while (startup.isPlaying()) {
    delay(100);
  }
  output(0, 0, 0, 1, 0, 0); //blank
  delay(1000);
  startupFinished = true;
  println("Startup Finished");
}