/*=============================================================
  Firmware für die PID-Temperatursteuerung einer
  Silikon Heizmatte, passend unter 96-Well Mikrotiter-Platten
  des Perkin Elmer LS55 Fluoreszenz Spektrometers.
  =============================================================*/

// http://hke-tec.com/produktubersicht/heizen/silikonheizelemente/
// - JH 2017 -

// Einige Libraries...
// http://playground.arduino.cc/Code/PIDLibrary
#include <PID_v1.h>
// http://playground.arduino.cc/Main/RunningAverage
#include <RunningAverage.h>

// ===========================100k NTC===========================
// http://garagelab.com/profiles/blogs/tutorial-using-ntc-thermistors-with-arduino
#define THERMISTORPIN A0                // Thermistor Input Pin
#define NOM_THERMISTOR 100000           // Nomineller Widerstand in Ohm 
#define NOM_TEMP 25                     // Nominelle Temperatur in °C  
#define SAMPLES 25                      // Samples
#define BCOEFFICIENT 3950               // Beta Wert für Thermistor
#define SERIESRESISTOR 10350            // Wert des Spannungsteilers in Ohm

float NTCtemp;                          // Measured NTC temperature value
int sampleArray[SAMPLES];
int i;

// =============================PID============================
#define SSRPin 8
#define LEDPin 11
#define MaxTemp 95     // TEMPERATURSICHERUNG !!
#define MinTemp 5

double Setpoint, Input, Output;
// http://en.wikipedia.org/wiki/PID_controller
// https://upload.wikimedia.org/wikipedia/commons/3/33/PID_Compensation_Animated.gif
double Kp = 15;
double Ki = 0.05;
double Kd = 500;
// PID mit Initialeinstellungen beladen
PID myPID(&Input, &Output, &Setpoint, Kp, Ki, Kd, DIRECT);
// Dauer eines SSR-Pulses
int WindowSize = 500;
unsigned long windowStartTime;

//============================TempAvg==========================
// Array usw. für Durchschnittstemperatur (fließendes Mittel)
RunningAverage tempRA(10);
int samples = 0;
float AvgTemp;

//============================TempSet==========================
// Variablen für Temperatureinstellung deklarieren
int temp, Now;
int TempSet = MinTemp;

//#################################################################################################################################

void setup(void) {

  Serial.begin(115200);                                  // Serialle Verbindung öffnen
  Serial.setTimeout(50);                                 // wichtig, sonst ca 1 Sekunde verzögert!

  analogReference(EXTERNAL);                             // Externe Spannungsreferenz -> 3.3V Rail an ARef

  pinMode(LEDPin, OUTPUT);                               // Status LED pin
  pinMode(SSRPin, OUTPUT);                               // SSR pin

  Setpoint = map(MinTemp, MinTemp, MaxTemp, 0, 1023);    // Sichere Starttemperatur festlegen -> Minimaltemperatur
  windowStartTime = millis();                            // StartTime definieren
  myPID.SetOutputLimits(0, WindowSize);                  // Pulse Fenster festlegen
  myPID.SetMode(AUTOMATIC);                              // start up PID

  tempRA.clear();                                        // Array zur Bestimmung des fließenden Mittels leeren

}

//#################################################################################################################################

void loop(void)
{
  // Temperatur aus dem RX Stream von GUI auslesen und ggf. weitergeben
  temp = Serial.parseInt();
  if (temp != 0) {
    if (temp > MaxTemp) {
      TempSet = MaxTemp;
    }
    else if (temp < MinTemp) {
      TempSet = MinTemp;
    }
    else {
      TempSet = temp;
    }
  }

  NTCtemp = ( ReadNTC() * 0.8778 ) + 1.9344;             // NTC auslesen & Temperatur korrigieren (kalibriert via IR-Thermometer: T_SURFACE = f(T_SET)

  tempRA.addValue(NTCtemp);                              // Aktuelle Temperatur in Array speichern
  AvgTemp = tempRA.getAverage();                         // Neues fließendes Mittel berechnen

  Input = map(NTCtemp, MinTemp, MaxTemp, 0, 1023);       // Aktuelle Leistung neu mappen
  Setpoint = map(TempSet, MinTemp, MaxTemp, 0, 1023);    // Solltemperatur neu mappen
  myPID.Compute();                                       // PID berechnen und in output-variable ablegen

  unsigned long now = millis();                          // Akutelle Laufzeit anfragen

  // http://playground.arduino.cc/Code/PIDLibraryRelayOutputExample
  // Fensterparameter bestimmen ...
  if (now - windowStartTime > WindowSize) {
    windowStartTime += WindowSize;
  }
  // ... und Heizleistung anpassen
  //            TEMPERATURSICHERUNG:   NTC OK?         Maximaltemperatur?    Minimaltemperatur?
  if (Output > now - windowStartTime && NTCtemp >= 0 && NTCtemp <= MaxTemp && TempSet != MinTemp) {
    digitalWrite(SSRPin, HIGH);
    digitalWrite(LEDPin, HIGH);
  }
  else {
    digitalWrite(SSRPin, LOW);
    digitalWrite(LEDPin, LOW);
    Output = 0;                                           // Falls Temperatursicherung ausgelöst -> Heizleistung weg!
  }

  Serial.println(AvgTemp);                                // Serieller Output für eigene GUI

}







