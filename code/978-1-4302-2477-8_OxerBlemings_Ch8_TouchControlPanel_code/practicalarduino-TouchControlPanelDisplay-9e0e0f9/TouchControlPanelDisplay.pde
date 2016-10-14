/**
 * Touch Control Panel Display
 * Copyright 2009 Jonathan Oxer <jon@oxer.com.au>
 * Copyright 2009 Hugh Blemings <hugh@blemings.org>
 *
 * NOTE: This program is for Processing, NOT Arduino! It runs on your
 * computer while the Arduino itself runs the "ReadTouchscreen" example
 * program that is included with the TouchScreen library.
 *
 * Changes the state of virtual buttons depending on input from a
 * Nintendo DS touch screen attached to an Arduino and sending X and Y
 * data via the serial port in the format X,Y, such as: 223,43.
 *
 *  www.practicalarduino.com/projects/touch-control-panel
 */

import processing.serial.*;
Serial myPort;

/**
 * Set up the screen for display and connect to serial port
 */
void setup()
{
  // Set the screen size
  size( 800, 600 );
  background( 153 );

  fill( 218, 165, 32 );
  rect(550, 50, 200, 500);

  // Connect to the serial port to receive touch screen values
  //println(Serial.list());  // Check what ports are available
  myPort = new Serial(this, Serial.list()[0], 38400);
  myPort.bufferUntil('\n');
}


/**
 * Main program loop
 */
void draw() {
  // Nothing to do in the main loop because updates are trigged by data
  // from the serial connection handled by serialEvent()
}


/**
 * Handle serial events to receive X and Y data from the touchscreen
 */
void serialEvent( Serial myPort )
{
  // Receive the X and Y data as a string from the serial port
  String inString = myPort.readStringUntil( '\n' );

  // Only process the string if we have actual data
  if( inString != null )
  {
    // Trim off any whitespace
    inString = trim( inString );
    // Split apart the X and Y values from the received data
    int[] coords = int( split( inString, ',' ) );

    if((coords[0] > 696) && (coords[0] < 866) && (coords[1] > 546) && (coords[1] < 831)) {
      fill( 127, 255, 0 );
      rect(50, 50, 200, 200);
    } else {
      fill( 0, 100, 0 );
      rect(50, 50, 200, 200);
    }
    if((coords[0] > 696) && (coords[0] < 866) && (coords[1] > 208) && (coords[1] < 476)) {
      fill( 255, 0, 0 );
      rect(50, 350, 200, 200);
    } else {
      fill( 178, 34, 34 );
      rect(50, 350, 200, 200);
    }
    if((coords[0] > 420) && (coords[0] < 577) && (coords[1] > 540) && (coords[1] < 866)) {
      fill( 127, 255, 0 );
      rect(300, 50, 200, 200);
    } else {
      fill( 0, 100, 0 );
      rect(300, 50, 200, 200);
    }
    if((coords[0] > 420) && (coords[0] < 577) && (coords[1] > 208) && (coords[1] < 476)) {
      fill( 255, 0, 0 );
      rect(300, 350, 200, 200);
    } else {
      fill( 178, 34, 34 );
      rect(300, 350, 200, 200);
    }
    if((coords[0] > 139) && (coords[0] < 327) && (coords[1] > 208) && (coords[1] < 866)) {
      fill( 218, 165, 32 );
      rect(550, 50, 200, 500);
      fill( 255, 215, 0 );
      rect(550, 550 - map(coords[1], 208, 866, 0, 500), 200, map(coords[1], 208, 866, 0, 500));
    }
  }
}
