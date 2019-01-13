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
