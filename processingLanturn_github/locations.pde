class Locations {


  public String locName;
  public float locLat;
  public float locLon;
  public int hue;
  public int sat;
  public int vib;
  public int fadeRate;
  public int pulseRate;
  public int rainbowRate;
  public String song;
  public boolean played;

  Locations(String templocName, float templocLat, float templocLon, int tempHue, int tempSat, int tempVib, int tempFade, int tempPulse, String tempSong, boolean tempPlayed) {
    locName = templocName;
    locLat = templocLat;
    locLon = templocLon;
    hue = tempHue;
    sat = tempSat;
    vib = tempVib;
    fadeRate = tempFade;
    pulseRate = tempPulse;
    song = tempSong;
    played = tempPlayed;
  }
}