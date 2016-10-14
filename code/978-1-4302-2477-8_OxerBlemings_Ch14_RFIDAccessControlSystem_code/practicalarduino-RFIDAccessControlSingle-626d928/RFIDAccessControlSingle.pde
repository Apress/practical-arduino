/**
 * RFID Access Control Single
 *
 * This project implements a single stand-alone RFID access control
 * system that can operate independently of a host computer or any
 * other device. It uses either an ID-12 RFID reader module from ID
 * Innovations or an RDM630 RFID reader module from Seeed Studio to
 * scan for 125KHz RFID tags, and when a recognised tag is identified
 * it toggles an output for a configurable duration, typically 2
 * seconds. The output can then be used to control a relay to trip an
 * electric striker plate to release a door lock.
 *
 * Because this project is intended to provide a minimal working system
 * it does not have any provision for database updates to be managed
 * externally from a host, so updates to the accepted cards must be
 * made by changing the values in the code, recompiling the program,
 * and re-uploading it to the Arduino. It does however report card
 * readings (both successful and unsuccessful) via the serial
 * connection so you can monitor the system using a connected computer.
 *
 * Some of this code was inspired by Tom Igoe's excellent RFID tutorial
 * which is detailed on his blog at:
 *   http://www.tigoe.net/pcomp/code/category/PHP/347
 * And also from the ID-12 example code on the Arduino Playground at:
 *   http://www.arduino.cc/playground/Code/ID12
 *
 * Copyright Jonathan Oxer <jon@oxer.com.au>
 * http://www.practicalarduino.com/projects/medium/rfid-access-control
 */

// Set up the serial connection to the RFID reader module. In order to
// keep the Arduino TX and RX pins free for communication with a host,
// the sketch uses the SoftwareSerial library to implement serial
// communications on other pins.
#include <SoftwareSerial.h>

// The RFID module's TX pin needs to be connected to the Arduino. Module
// RX doesn't need to be connected to anything since we won't send
// commands to it, but SoftwareSerial requires us to define a pin for
// TX anyway so you can either connect module RX to Arduino TX or just
// leave them disconnected.

// If you have built the circuit exactly as described in Practical
// Arduino, use pins D2 / D3:
#define rxPin 2
#define txPin 3
// If you are using the Freetronics RFID Lock Shield, use pins D4 / D5:
/* #define rxPin 4 */
/* #define txPin 5 */

// Create a software serial object for the connection to the RFID module
SoftwareSerial rfid = SoftwareSerial( rxPin, txPin );

// Set up outputs for the strike plate and status LEDs.
// If you have built the circuit exactly as described in Practical
// Arduino, use pins D12 and D13:
#define strikePlate 12
#define ledPin 13
// If you are using the Freetronics RFID Lock Shield, use pins D6 / D7:
/* #define strikePlate 6 */
/* #define ledPin 7 */

// Specify how long the strike plate should be held open.
#define unlockSeconds 2

// The tag database consists of two parts. The first part is an array of
// tag values with each tag taking up 5 bytes. The second is a list of
// names with one name for each tag (ie: group of 5 bytes).
char* allowedTags[] = {
  "0104F5B523",         // Tag 1
  "04146E8BDD",         // Tag 2
  "0413BBBF23",         // Tag 3
};

// List of names to associate with the matching tag IDs
char* tagName[] = {
  "Jonathan Oxer",      // Tag 1
  "Hugh Blemings",      // Tag 2
  "Dexter D Dog",       // Tag 3
};

// Check the number of tags defined
int numberOfTags = sizeof(allowedTags)/sizeof(allowedTags[0]);

int incomingByte = 0;    // To store incoming serial data

/**
 * Setup
 */
void setup() {
  pinMode(ledPin, OUTPUT);
  digitalWrite(ledPin, LOW);
  pinMode(strikePlate, OUTPUT);
  digitalWrite(strikePlate, LOW);

  Serial.begin(38400);   // Serial port for connection to host
  rfid.begin(9600);      // Serial port for connection to RFID module

  Serial.println("RFID reader starting up");
}

/**
 * Loop
 */
void loop() {
  byte i         = 0;
  byte val       = 0;
  byte checksum  = 0;
  byte bytesRead = 0;
  byte tempByte  = 0;
  byte tagBytes[6];    // "Unique" tags are only 5 bytes but we need an extra byte for the checksum
  char tagValue[10];

  // Read from the RFID module. Because this connection uses SoftwareSerial
  // there is no equivalent to the Serial.available() function, so at this
  // point the program blocks while waiting for a value from the module
  if((val = rfid.read()) == 2) {        // Check for header
    bytesRead = 0;
    while (bytesRead < 12) {            // Read 10 digit code + 2 digit checksum
      val = rfid.read();

      // Append the first 10 bytes (0 to 9) to the raw tag value
      if (bytesRead < 10)
      {
        tagValue[bytesRead] = val;
      }

      // Check if this is a header or stop byte before the 10 digit reading is complete
      if((val == 0x0D)||(val == 0x0A)||(val == 0x03)||(val == 0x02)) {
        break;                          // Stop reading
      }

      // Ascii/Hex conversion:
      if ((val >= '0') && (val <= '9')) {
        val = val - '0';
      }
      else if ((val >= 'A') && (val <= 'F')) {
        val = 10 + val - 'A';
      }

      // Every two hex-digits, add a byte to the code:
      if (bytesRead & 1 == 1) {
        // Make space for this hex-digit by shifting the previous digit 4 bits to the left
        tagBytes[bytesRead >> 1] = (val | (tempByte << 4));

        if (bytesRead >> 1 != 5) {                // If we're at the checksum byte,
          checksum ^= tagBytes[bytesRead >> 1];   // Calculate the checksum... (XOR)
        };
      } else {
        tempByte = val;                           // Store the first hex digit first
      };

      bytesRead++;                                // Ready to read next digit
    }

    // Send the result to the host connected via USB
    if (bytesRead == 12) {                        // 12 digit read is complete
      tagValue[10] = '\0';                        // Null-terminate the string

      Serial.print("Tag read: ");
      for (i=0; i<5; i++) {
        // Add a leading 0 to pad out values below 16
        if (tagBytes[i] < 16) {
          Serial.print("0");
        }
        Serial.print(tagBytes[i], HEX);
      }
      Serial.println();

      Serial.print("Checksum: ");
      Serial.print(tagBytes[5], HEX);
      Serial.println(tagBytes[5] == checksum ? " -- passed." : " -- error.");

      // Show the raw tag value
      //Serial.print("VALUE: ");
      //Serial.println(tagValue);

      // Search the tag database for this particular tag
      int tagId = findTag( tagValue );

      // Only fire the strike plate if this tag was found in the database
      if( tagId > 0 )
      {
        Serial.print("Authorized tag ID ");
        Serial.print(tagId);
        Serial.print(": unlocking for ");
        Serial.println(tagName[tagId - 1]);   // Get the name for this tag from the database
        unlock();                             // Fire the strike plate to open the lock
      } else {
        Serial.println("Tag not authorized");
      }
      Serial.println();     // Blank separator line in output
    }

    bytesRead = 0;
  }
}

/**
 * Fire the relay to activate the strike plate for the configured
 * number of seconds.
 */
void unlock() {
  digitalWrite(ledPin, HIGH);
  digitalWrite(strikePlate, HIGH);
  delay(unlockSeconds * 1000);
  digitalWrite(strikePlate, LOW);
  digitalWrite(ledPin, LOW);
}

/**
 * Search for a specific tag in the database
 */
int findTag( char tagValue[10] ) {
  for (int thisCard = 0; thisCard < numberOfTags; thisCard++) {
    // Check if the tag value matches this row in the tag database
    if(strcmp(tagValue, allowedTags[thisCard]) == 0)
    {
      // The row in the database starts at 0, so add 1 to the result so
      // that the card ID starts from 1 instead (0 represents "no match")
      return(thisCard + 1);
    }
  }
  // If we don't find the tag return a tag ID of 0 to show there was no match
  return(0);
}
