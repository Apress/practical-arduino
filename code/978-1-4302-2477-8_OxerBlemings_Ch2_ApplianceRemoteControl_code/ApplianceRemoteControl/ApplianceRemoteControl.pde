/*
 * ApplianceRemoteControl
 *
 * Waits for control values to be sent via the serial connection and
 * pulses digital outputs to trigger the buttons on an appliance remote
 * control. Outputs are pulsed for 200ms to simulate manually pressing
 * a button.
 *
 * The number of outputs can be trivially varied to suit your needs.
 *
 * This sketch is a very simple and useful building block for any
 * project where you need to use an Arduino as an intermediary to link
 * together a host computer and a physical device for automated
 * control.
 *
 * Copyright 2009 Jonathan Oxer <jon@oxer.com.au>
 * Copyright 2009 Hugh Blemings <hugh@blemings.org>
 * http://www.practicalarduino.com/projects/appliance-remote-control
 */

// Use pins 5 through 12 as the digital outputs
int output1 = 5;
int output2 = 6;
int output3 = 7;
int output4 = 8;
int output5 = 9;
int output6 = 10;
int output7 = 11;
int output8 = 12;

int buttonPressTime = 250;   // Number of milliseconds to hold outputs on

/**
 * Initial configuration
 */
void setup()
{
  // Open the serial connection to listen for commands from the host
  Serial.begin(38400);

  // Set up the pins as outputs
  pinMode(output1, OUTPUT);
  pinMode(output2, OUTPUT);
  pinMode(output3, OUTPUT);
  pinMode(output4, OUTPUT);
  pinMode(output5, OUTPUT);
  pinMode(output6, OUTPUT);
  pinMode(output7, OUTPUT);
  pinMode(output8, OUTPUT);

  // Make sure the outputs are all set LOW initially
  digitalWrite(output1, LOW);
  digitalWrite(output2, LOW);
  digitalWrite(output3, LOW);
  digitalWrite(output4, LOW);
  digitalWrite(output5, LOW);
  digitalWrite(output6, LOW);
  digitalWrite(output7, LOW);
  digitalWrite(output8, LOW);
}

/**
 * Main program loop
 */
void loop()
{
  byte val;

  // Check if a value has been sent by the host
  if(Serial.available()) {
    val = Serial.read();

    if(val == '1') {
      // Pulse the 1st button
      digitalWrite(output1, HIGH);
      delay(buttonPressTime);
      digitalWrite(output1, LOW);
    } else if(val == '2') {
      // Pulse the 2nd button
      digitalWrite(output2, HIGH);
      delay(buttonPressTime);
      digitalWrite(output2, LOW);
    } else if(val == '3') {
      // Pulse the 3rd button
      digitalWrite(output3, HIGH);
      delay(buttonPressTime);
      digitalWrite(output3, LOW);
    } else if(val == '4') {
      // Pulse the 4th button
      digitalWrite(output4, HIGH);
      delay(buttonPressTime);
      digitalWrite(output4, LOW);
    } else if(val == '5') {
      // Pulse the 5th button
      digitalWrite(output5, HIGH);
      delay(buttonPressTime);
      digitalWrite(output5, LOW);
    } else if(val == '6') {
      // Pulse the 6th button
      digitalWrite(output6, HIGH);
      delay(buttonPressTime);
      digitalWrite(output6, LOW);
    } else if(val == '7') {
      // Pulse the 7th button
      digitalWrite(output7, HIGH);
      delay(buttonPressTime);
      digitalWrite(output7, LOW);
    } else if(val == '8') {
      // Pulse the 8th button
      digitalWrite(output8, HIGH);
      delay(buttonPressTime);
      digitalWrite(output8, LOW);
    }
  }
}
