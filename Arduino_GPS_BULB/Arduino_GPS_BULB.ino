/***
  GPS LANTURN STORY PROJECT 0.7
  Jan 17 '18

  - function to skip around 256 limit for hue if closer ie 250 rollover 10 instead of 250 - 240 and cycle through colors
  - remove startup light etc within Arduino and Send from processing
  - charting GPS coordinates, understanding GPS drift
  and taking measurable tests.
  - flicker function?

  Raspi
    - recieve and send serial in processing sketches
    - calculate if in Range and then send data and play songs

  Credits: Michael Coney Experience design and producer,
  Programming assistance: Avi Burstein,
  special thanks, Mark Mcnamara
***/

#include <FastLED.h>
#define PIN            4
#define NUMPIXELS      24
CRGB leds[NUMPIXELS];
int fadeRate,
    pulseRate,
    rainbowRate,
    currSat,
    currVib,
    currHue,
    newHue,
    newSat,
    newVib,
    white = 23;

boolean flashlightState = false;
boolean messageSent = false;
int flashlightPin = 5;
int breakoutRead;

char tmp[1] = "a";

#ifdef __AVR__
#include <avr/power.h>
#endif

#include <Adafruit_GPS.h>
#include <SoftwareSerial.h>

// If using software serial, keep this line enabled
// (you can change the pin numbers to match your wiring):
SoftwareSerial mySerial(3, 2);
Adafruit_GPS GPS(&mySerial);
// this keeps track of whether we're using the interrupt
// off by default!
boolean usingInterrupt = false;
void useInterrupt(boolean); // Func prototype keeps Arduino 0023 happy

void setup()  {
  pinMode(flashlightPin, INPUT);
  FastLED.addLeds<NEOPIXEL, PIN>(leds, NUMPIXELS);
  bulb(0, 0, 0); //clear bulb from last poweron
  Serial.begin(115200); //115200 to read the GPS fast enough and echo without dropping chars
  GPS.begin(9600);
  // uncomment this line to turn on RMC (recommended minimum) and GGA (fix data) including altitude
  GPS.sendCommand(PMTK_SET_NMEA_OUTPUT_RMCGGA);

  // Set the update rate
  GPS.sendCommand(PMTK_SET_NMEA_UPDATE_1HZ);   // 1 Hz update rate
  // For the parsing code to work nicely and have time to sort thru the data, and
  // print it out we don't suggest using anything higher than 1 Hz

  // the nice thing about this code is you can have a timer0 interrupt go off
  // every 1 millisecond, and read data from the GPS for you. that makes the
  // loop code a heck of a lot easier!
  useInterrupt(true);
  pinMode(13, OUTPUT);
}
// Interrupt is called once a millisecond, looks for any new GPS data, and stores it
SIGNAL(TIMER0_COMPA_vect) {
  char c = GPS.read();
}

void useInterrupt(boolean v) {
  if (v) {
    // Timer0 is already used for millis() - we'll just interrupt somewhere
    // in the middle and call the "Compare A" function above
    OCR0A = 0xAF;
    TIMSK0 |= _BV(OCIE0A);
    usingInterrupt = true;
  }
  else {
    // do not call the interrupt function COMPA anymore
    TIMSK0 &= ~_BV(OCIE0A);
    usingInterrupt = false;
  }
}
uint32_t timer = millis();

void loop() {
  //FLASHLIGHT MODE BY PRESSING BUTTON
  //read the pin
  int pinReading = digitalRead(flashlightPin);
  //Serial.println(flashlightState);
  if (pinReading == HIGH) { //if btn pressed   
    flashlightState = !flashlightState;
    delay(275);
    if (flashlightState) {
      while (flashlightState) {
        if (messageSent == false) {
          delay(100);
          Serial.println("FLASHLIGHT MODE");
          messageSent = true;
        }
        if (digitalRead(flashlightPin) == HIGH) {
          //Serial.print("FLASHLIGHT OFF!");
          flashlightState = !flashlightState;
          messageSent = false;
          delay(500);
          break;
        }
      }
    }
  }

  if (GPS.newNMEAreceived()) {
    if (!GPS.parse(GPS.lastNMEA()))   // this also sets the newNMEAreceived() flag to false
      return;  // we can fail to parse a sentence in which case we should just wait for another
  }
  if (timer > millis())  timer = millis();
  // ^^^^if millis() or timer wraps around, we'll just reset it

  if (millis() - timer > 1000) { //1 second run code
    timer = millis(); // reset the timer
    //if you recieve anything via serial execute this code
    //NEEDS TO BE HERE SO INTERRUPTS AND GPS DON'T AFFECT IT

    while (Serial.available() > 0) {
      newHue = Serial.parseInt();
      newSat = Serial.parseInt();
      newVib = Serial.parseInt();
      fadeRate = Serial.parseInt();
      pulseRate = Serial.parseInt();
      rainbowRate = Serial.parseInt();

      //My Own Serial Flush
      while (Serial.available() > 0) {
        Serial.parseInt();
      }
      if (fadeRate > 0) {
        fadeDown(fadeRate);//fadeDown Vibrancy
        //Serial.print("fading Down");
        allChange(false); //change values wihout showing
        //Serial.print("changing Values");
        resetValues(); //reset values to current
        //Serial.print("resetting Values");
        if (pulseRate > 0) {
          fadeUp(pulseRate);
        }
        else {
          fadeUp(fadeRate);
        }
      }
      else {
        //Serial.println("Changing without Fading...");
        allChange(true);
        resetValues();
      }
    }
    if (pulseRate > 0) {
      pulse(pulseRate);
    }
    if (rainbowRate > 0) {
      rainbow(rainbowRate);
    }

    //..........GPS DETECTION AND SERIAL TRANSMISSION
    if (GPS.fix && !flashlightState) {
      Serial.print(GPS.latitudeDegrees, 4);
      Serial.print(",");
      Serial.println(GPS.longitudeDegrees, 4);
    }
    else if(!GPS.fix && !flashlightState) {
      Serial.println("No Fix");
    }
  }
}

void bulb( int h, int s, int v) {
  for (int i = 0; i < NUMPIXELS; i++) {
    leds[i].setHSV(h, s, v);
  }
  FastLED.showColor(CHSV(h, s, v));
}

void fadeDown(int tmpFadeRate) {
  for (int i = currVib; i > 0; i--) {
    bulb( currHue, currSat, i);
    delay(tmpFadeRate * 5);
    //Serial.print("Fade Down Level: "); Serial.println(i);
  }
}

void fadeUp(int tmpFadeRate) {
  for (int i = 0; i < currVib; i++) {
    bulb( currHue, currSat, i);
    delay(tmpFadeRate * 5);
    //Serial.print("Fade Up Level: "); Serial.println(i);
  }
}

void pulse(int pulseRate) {
  fadeDown(pulseRate);
  fadeUp(pulseRate);
}


void allChange(boolean light) {
  //Determine Which has the largest Gap in steps
  float hueGap = fabs(newHue - currHue);
  float satGap = fabs(newSat - currSat);
  float vibGap = fabs(newVib - currVib);
  float firstGapTest = max(hueGap, satGap);
  float largerGap = max(firstGapTest, vibGap);

  //determine increments for each according to largest gap
  float hueInc = hueGap / largerGap;
  float satInc = satGap / largerGap;
  float vibInc = vibGap / largerGap;

  //Establish directions to go either up or down
  float hueDirection,
        satDirection,
        vibDirection;
  int   hueLoop,
        satLoop,
        vibLoop;

  // to determine if change direction is up or down
  if (newHue > currHue) {
    hueDirection = 1.0;
  }
  else {
    hueDirection = -1.0;
  }
  if (newSat > currSat) {
    satDirection = 1.0;
  }
  else {
    satDirection = -1.0;
  }
  if (newVib > currVib) {
    vibDirection = 1.0;
  }
  else {
    vibDirection = -1.0;
  }

  //takes current values and determines amount to add or subtract depending on
  //difference from new values during each iteration updating both
  for (int i = 0; i < largerGap; i++) {
    hueLoop = currHue + (i * hueDirection) * hueInc;
    satLoop = currSat + (i * satDirection) * satInc;
    vibLoop = currVib + (i * vibDirection) * vibInc;
    if ( light == true) {
      bulb( hueLoop, satLoop, vibLoop);
      delay(20);
    }
    else {
    }
  }
}

void resetValues() {
  currHue = newHue;
  currSat = newSat;
  currVib = newVib;
}

void rainbow(int rate) {
  for (int i = 0; i < 255; i++) {
    bulb(i + currHue, currSat, currVib);
    delay(rate * 7);
  }
}
