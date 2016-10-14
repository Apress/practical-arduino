/**
 * OnlineThermometer
 *
 * Reads values from DS18B20 1-wire temperature sensors and displays
 * the current readings in a web page. This version is designed to work
 * with Ethernet shields based on the Wiznet W5100 chipset, including
 * the official Arduino Ethernet shield and also the Freetronics
 * Ethernet shield with PoE support:
 *     www.freetronics.com/ethernet-shield
 *
 * This sketch requires the "Webduino" library, available from:
 *     code.google.com/p/webduino
 *
 * Copyright 2009-2010 Jonathan Oxer <jon@oxer.com.au>
 *     www.practicalarduino.com/projects/online-thermometer
 *     www.freetronics.com/pages/online-thermometer
 */

#include <SPI.h>
#include <Ethernet.h>
#include <WebServer.h>

// No-cost stream operator as described at 
// http://sundial.org/arduino/?page_id=119
template<class T>
inline Print &operator <<(Print &obj, T arg)
{ obj.print(arg); return obj; }

// Modify the following lines to suit your local network configuration.
// The MAC and IP address have to be unique on your LAN:
static uint8_t mac[] = { 0xDE, 0xAD, 0xBE, 0xEE, 0xEE, 0xEF };
static uint8_t ip[] = { 192, 168, 1, 124 };
static uint8_t myPort = 80; // Listen port for tcp/www (range 1-254)

/* This creates an instance of the webserver.  By specifying a prefix
 * of "/", all pages will be at the root of the server. */
#define PREFIX ""
WebServer webserver( PREFIX, myPort );

// Specify data pins for connected DS18B20 temperature sensors
#define SENSOR_A  14
#define SENSOR_B  15
#define SENSOR_C  16
#define SENSOR_D  17
#define SENSOR_E  18
#define SENSOR_F  19

// Function prototypes to trick the Arduino pre-processor into
// allowing call-by-reference
void sendTemperatureValues( WebServer &server);
void sendAboutPage( WebServer &server);
void sendFormButtons( WebServer &server);

/**
 * Default page to return to browser
 */
void valuesCmd(WebServer &server, WebServer::ConnectionType type, char *url_tail, bool tail_complete)
{
  server.httpSuccess();
  sendTemperatureValues( server );
  sendFormButtons( server );
}

/**
 * Default page to return to browser
 */
void aboutCmd(WebServer &server, WebServer::ConnectionType type, char *url_tail, bool tail_complete)
{
  server.httpSuccess();
  sendAboutPage( server );
  sendFormButtons( server );
}

/**
 * Configure Ethernet shield
 */
void setup(){
  Serial.begin(38400);

  Ethernet.begin(mac, ip);
  webserver.begin();
  
  webserver.setDefaultCommand( &valuesCmd );
  webserver.addCommand( "values", &valuesCmd );
  webserver.addCommand( "about", &aboutCmd );

  // Set up the data pins for communication with DS18B20 sensors
  digitalWrite(SENSOR_A, LOW);
  pinMode(SENSOR_A, INPUT);
  digitalWrite(SENSOR_B, LOW);
  pinMode(SENSOR_B, INPUT);
  digitalWrite(SENSOR_C, LOW);
  pinMode(SENSOR_C, INPUT);
  digitalWrite(SENSOR_D, LOW);
  pinMode(SENSOR_D, INPUT);
  digitalWrite(SENSOR_E, LOW);
  pinMode(SENSOR_E, INPUT);
}

/**
 * Main program loop
 */
void loop(){
  webserver.processConnection();
}

/**
 * Send the HTML for the "about" page
 */
void sendAboutPage( WebServer &server )
{
  server.print("<h1>Online Thermometer v1.0 (Wiznet version)</h1>");
  server.print("As featured in Practical Arduino.<br />");
  server.print("See <a href=\"http://practicalarduino.com\">practicalarduino.com</a> for more info.");
}

/**
 * Send the HTML for the navigation buttons
 */
void sendFormButtons( WebServer &server )
{
  // Display a form button to update the display
  server << "<p><form METHOD='POST' action='" PREFIX "/values'>";
  server.println("<input type=submit value=\"Data\">");
  server.println("</form></p>");
  
  // Display a form button to access the "about" page
  server << "<p><form METHOD=POST action='" PREFIX "/about'>";
  server.println("<input type=submit value=\"About\">");
  server.println("</form>");
}

/**
 * Get temperature values from connected sensors and generate the HTML
 */
void sendTemperatureValues( WebServer &server )
{
  char temp_string_a[10];
  char temp_string_b[10];
  char temp_string_c[10];
  char temp_string_d[10];
  char temp_string_e[10];
  char temp_string_f[10];
  
  getCurrentTemp(SENSOR_A, temp_string_a);
  getCurrentTemp(SENSOR_B, temp_string_b);
  getCurrentTemp(SENSOR_C, temp_string_c);
  getCurrentTemp(SENSOR_D, temp_string_d);
  getCurrentTemp(SENSOR_E, temp_string_e);
  getCurrentTemp(SENSOR_F, temp_string_f);
  
  server.print("Sensor A:");
  server.print(temp_string_a);
  server.print("<br />");
  server.print("Sensor B:");
  server.print(temp_string_b);
  server.print("<br />");
  server.print("Sensor C:");
  server.print(temp_string_c);
  server.print("<br />");
  server.print("Sensor D:");
  server.print(temp_string_d);
  server.print("<br />");
  server.print("Sensor E:");
  server.print(temp_string_e);
  server.print("<br />");
  server.print("Sensor F:");
  server.print(temp_string_f);
  server.print("<br />");
}

/**
 * Reset the 1-wire bus
 */
void OneWireReset (int Pin) // reset.  Should improve to act as a presence pulse
{
  digitalWrite (Pin, LOW);
  pinMode (Pin, OUTPUT);        // bring low for 500 us
  delayMicroseconds (500);
  pinMode (Pin, INPUT);
  delayMicroseconds (500);
}

/**
 * Send data to a 1-wire device
 */
void OneWireOutByte (int Pin, byte d) // output byte d (least sig bit first).
{
  byte n;

  for (n=8; n!=0; n--)
  {
    if ((d & 0x01) == 1)  // test least sig bit
    {
      digitalWrite (Pin, LOW);
      pinMode (Pin, OUTPUT);
      delayMicroseconds (5);
      pinMode (Pin, INPUT);
      delayMicroseconds (60);
    }
    else
    {
      digitalWrite (Pin, LOW);
      pinMode (Pin, OUTPUT);
      delayMicroseconds (60);
      pinMode (Pin, INPUT);
    }

    d = d>>1; // now the next bit is in the least sig bit position.
  }
}

/**
 * Read data from a 1-wire device
 */
byte OneWireInByte (int Pin) // read byte, least sig byte first
{
  byte d, n, b;

  for (n=0; n<8; n++)
  {
    digitalWrite (Pin, LOW);
    pinMode (Pin, OUTPUT);
    delayMicroseconds (5);
    pinMode (Pin, INPUT);
    delayMicroseconds (5);
    b = digitalRead (Pin);
    delayMicroseconds (50);
    d = (d >> 1) | (b<<7); // shift d to right and insert b in most sig bit position
  }
  return (d);
}


/**
 * Read temperature from a DS18B20.
 * int sensorPin: Arduino digital I/O pin connected to sensor
 * char *temp: global array to be populated with current reading
 */
void getCurrentTemp (int sensorPin, char *temp)
{
  int HighByte, LowByte, TReading, Tc_100, sign, whole, fract;

  OneWireReset (sensorPin);
  OneWireOutByte (sensorPin, 0xcc);
  OneWireOutByte (sensorPin, 0x44); // Perform temperature conversion, strong pullup for one sec

  OneWireReset (sensorPin);
  OneWireOutByte (sensorPin, 0xcc);
  OneWireOutByte (sensorPin, 0xbe);

  LowByte = OneWireInByte (sensorPin);
  HighByte = OneWireInByte (sensorPin);
  TReading = (HighByte << 8) + LowByte;
  sign = TReading & 0x8000;  // test most sig bit
  if (sign) // negative
  {
    TReading = (TReading ^ 0xffff) + 1; // 2's complement
  }
  Tc_100 = (6 * TReading) + TReading / 4;    // multiply by (100 * 0.0625) or 6.25

  whole = Tc_100 / 100;  // separate off the whole and fractional portions
  fract = Tc_100 % 100;

  if (sign) {
    temp[0] = '-';
  } else {
    temp[0] = '+';
  }

  if (whole/100 == 0) {
    temp[1] = ' ';
  } else {
    temp[1] = whole/100+'0';
  }

  temp[2] = (whole-(whole/100)*100)/10 +'0' ;
  temp[3] = whole-(whole/10)*10 +'0';
  temp[4] = '.';
  temp[5] = fract/10 +'0';
  temp[6] = fract-(fract/10)*10 +'0';
  temp[7] = '\0';
}
