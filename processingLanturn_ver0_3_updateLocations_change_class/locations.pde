class Locations {


  public String locName;
  public float locLat;
  public float locLon;
  public int hue;
  public int sat;
  public int vib;
  public int fadeRate;
  public int pulseRate;
  public String song;

  Locations(String templocName, float templocLat, float templocLon, int tempHue, int tempSat, int tempVib, int tempFade, int tempPulse, String tempSong) {
    locName = templocName;
    locLat = templocLat;
    locLon = templocLon;
    hue = tempHue;
    sat = tempSat;
    vib = tempVib;
    fadeRate = tempFade;
    pulseRate = tempPulse;
    song = tempSong;
  }
}