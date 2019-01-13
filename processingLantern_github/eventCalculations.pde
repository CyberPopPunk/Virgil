void eventTrigger(int trackNumber) {
  //play a track from tracknumber parameter, tracks replay after finished if in same location and
  //a track will play immediately once the game has started to avoid an error
  if (track[trackNumber].isPlaying()) {
    println("still playing");
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
    }
    else{
      println("noFixTrack played first time");
      track[prevTrack].pause();
    }
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
