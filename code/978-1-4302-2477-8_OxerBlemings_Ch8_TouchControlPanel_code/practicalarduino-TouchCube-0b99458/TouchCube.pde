/**
 * TouchCube
 *
 * NOTE: This program runs under Processing, not Arduino! It's designed
 * to run on your host computer attached to an Arduino that is running
 * the TouchscreenCoordinates program to send it the X/Y coordinates.
 *
 * Renders a 3D cube and moves the camera position based on input from a
 * Nintendo DS touch screen attached to an Arduino and sending X and Y
 * data via the serial port in the format X,Y, such as: 223,43.
 *
 * If the value is out of range the values are not updated so that if
 * the stylus is lifted off the touch screen the cube will hold its
 * position.
 *
 * Copyright 2009 Jonathan Oxer <jon@oxer.com.au>
 * Copyright 2009 Hugh Blemings <hugh@blemings.org>
 * http://www.practicalarduino.com/projects/touch-control-panel
 */

import processing.serial.*;
Serial myPort;

int touchX;        // The X coordinate value received from the serial port
int touchY;        // The Y coordinate value received from the serial port
float xPos = 512;    // Current camera X-axis position
float yPos = 512;    // Current camera Y-axis position


/**
 * Set up the screen for display and connect to serial port
 */
void setup()
{
  // Set the screen size
  size( 800, 600, P3D );
  // Set the fill colour to orange
  fill( 204, 104, 0 );

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
    int[] coordinates = int( split( inString, ',' ) );

    // Fetch the X coordinate (first value) but only process if in range
    touchX = coordinates[0];
    if( touchX > 20 && touchX < 900 ) {
      // Scale the X value to the screen width
      xPos = map( touchX, 0, 1023, 0, width );
    }

    // Fetch the Y coordinate (second value) but only process if in range
    touchY = int( coordinates[1] );
    if( touchY > 20 && touchY < 900 ) {
      // Scale the Y value to the screen height
      yPos = map( touchY, 0, 1023, 0, height );
    }

    // Set up the display lighting and background colour
    lights();
    background( 51 );

    // Change position of the camera based on touch position
    camera( xPos, yPos, 100.0, // eyeX, eyeY, eyeZ
         0.0, 0.0, 0.0,            // centerX, centerY, centerZ
         0.0, 1.0, 0.0 );          // upX, upY, upZ

    noStroke();
    box( 150 );
    stroke( 255 );
    line( -100, 0, 0, 100, 0, 0 );
    line( 0, -100, 0, 0, 100, 0 );
    line( 0, 0, -100, 0, 0, 100 );
  }
}
