# Virgil
Lanturn style GPS-based immersive storytelling project

Virgil is an immersive storytelling project that is bridging the worlds of digital storytelling and pervasive games.

Overview:
A player walks along a preset trail guided by a physical lanturn that emits RGB colored lights and sound/story (via headphone jack) to the user. As they walk along they are guided by story and environment that creates an engulfing realistic experience.

Technical Overview:
Arduino compatible board (adafruit Metro mini adafruit.com/product/2590) reads data from a gps unit (adafruit ultimate GPS adafruit.com/product/746) and sends that over serial to a connected raspberry pi zero or pi3+( raspberrypi.org/products/raspberry-pi-3-model-b/). The raspberry pi uses processing or python to interpret the serial data, analyze preset coordinates and play corresponding sounds out of the headphone port (on a piZero use a PhatDac shop.pimoroni.com/products/phat-dac) and send RGB data out to the arduino accordingly.

Initial Testing:
Rail Trail path with 5 waypoints for triggering different sounds

__Board Communication and Processing/Processes Information:__
Arduino compatible outputs via serial two datatypes:
  -"No Fix"   --this happens if the GPS unit cannot get a fix on the location and you are "lost"
  -"lattitude, longitude"  -- GPS coordinates in GOOGLE MAPS COMPATIBLE format with 4 decimal precision i.e. "-74.8762"

Arduino board reads serial input as a string and parses data
  - "Hue, Saturation, Vibrance, FadeRate, PulseRate, RainbowRate"
  - Rate Changes all in millisecond measurements
  - 0 for Rate Changes causes instant change or is ommitted
      HUE: Color chosen along spectrum..................0-255
      SATURATION: Amount of color.......................0-255
      Vibrance: Brightness of LEDs (higher is brighter) 0-255
      FadeRate: How Fast a fade happens between colors..0-infinite (recommend < 10)
      PulseRate: How fast a color pulses while constant.0-infinite (recommend < 10)
      RainbowRate: Rainbow color chase rate.............0-infinite (recommend < 10)
   -EXAMPLE "255,100,255,2000,1000,0" will take 2 seconds to fade into a pale red light at maximum brightness that pulses once per second
 
Raspberry Pi:
Processing or Python sketch (haven't had complete success with either, exploring additional options until one is possible)
        -recieves GPS data from arduino as string
        -converts GPS corrdinates to floats
        -compares current float coordinates with existing array of predetermined coordinates
        -sends corresponding RGB data back to arduino depending on location
        -plays audio associated with location/event out of headphone jack (or phatDAC in case of raspi0)
