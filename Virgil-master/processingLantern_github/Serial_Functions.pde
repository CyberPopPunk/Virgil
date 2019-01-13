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

void output(int hue, int sat, int vib, int fadeRate, int pulseRate, int rainbowRate) {
  delay(100);
  String comma = ",";
  String finalOutput = 'L' + str(hue) + comma + str(sat) + comma + str(vib) + comma + str(fadeRate) + comma + str(pulseRate) + comma + str(rainbowRate);
  println(finalOutput);
  port.write(finalOutput);
}