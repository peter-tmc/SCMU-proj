#include "time.h"
#include "BluetoothSerial.h"
//#include "Clock.h"
#if !defined(CONFIG_BT_ENABLED) || !defined(CONFIG_BLUEDROID_ENABLED)
#error Bluetooth is not enabled! Please run `make menuconfig` to and enable it
#endif

const int buzzer = 18; //buzzer to arduino pin 9
const int pressurePin = 34;
const int ledPin = 18;
const int ledPin2 = 19;
const int ledPin3 = 21;
const int freq = 5000;
const int ledChannel = 0;
const int ledChannel2 = 1; 
const int ledChannel3 = 2;
const int resolution = 8;
const int photoPin = 27;
const int buttonPin =  25;
int photoThreshold = 500; //default

int lightVal;
int pressVal = 0;
int nLedsActive = 3;
int lastPressVal = 0;
int dutyCycle = 0;

unsigned long previousMillisLEDs = 0; 
const long intervalLED = 5; 
unsigned long previousMillisMoreLED = 0;
const long intervalMoreLEDs = 3000;
unsigned long previousMillisReadLight = 0;
const long intervalReadLight = 2000;
boolean increasingLED = false;
unsigned long previousMillisBT = 0;
unsigned long previousMillisBTSensors = 0;

int buttonState = 0;
boolean alarmOn = false;


BluetoothSerial SerialBT;

void setup(){
  Serial.begin(115200);
  ledcSetup(ledChannel, freq, resolution);
  ledcSetup(ledChannel2, freq, resolution);
  ledcSetup(ledChannel3, freq, resolution);
  ledcAttachPin(ledPin, ledChannel);
  ledcAttachPin(ledPin2, ledChannel2);
  ledcAttachPin(ledPin3, ledChannel3);
  pinMode(buttonPin, INPUT);
  SerialBT.begin();
  Serial.println("Bluetooth Started! Ready to pair...");
  delay(1000);
  //pinMode(buzzer, OUTPUT); // Set buzzer - pin 9 as an output
  
}

void loop(){
 
  /*tone(buzzer, 2000); // Send 1KHz sound signal...
  delay(1000);        // ...for 1 sec
  noTone(buzzer);     // Stop sound...
  delay(1000);        // ...for 1sec*/
  
  
  /*lastPressVal = pressVal;
  pressVal = analogRead(pressurePin);
  Serial.println(pressVal);
  if(pressVal > 50 && lastPressVal == 0)
    nLedsActive++;
  delay(500);*/
  unsigned long currentMillis = millis();
 
  
    
  controlBT(currentMillis);
  if(alarmOn) controlLight(currentMillis);
 /*if(pressVal > 50) esta na cama*/
}

void  controlLight(unsigned long currentMillis) {
   if(currentMillis - previousMillisMoreLED >= intervalMoreLEDs) {
    nLedsActive++;
    previousMillisMoreLED = currentMillis;
    //Serial.println(analogRead(photoPin));
    //Serial.println(gettimeofday())
  }
  
  if(nLedsActive > 3)
    nLedsActive = 1;
    
  //turn off leds
  if(nLedsActive < 1) ledcWrite(ledChannel, 0); 
  if(nLedsActive < 2) ledcWrite(ledChannel2, 0);
  if(nLedsActive < 3) ledcWrite(ledChannel3, 0);
  
  if(nLedsActive > 0 && currentMillis - previousMillisLEDs >= intervalLED) {
    if(increasingLED) dutyCycle++;
    else dutyCycle--;
    
    if(dutyCycle >= 255)
      increasingLED = false;
    else if(dutyCycle <= 0) increasingLED = true;
    
    ledcWrite(ledChannel, dutyCycle);
    if(nLedsActive > 1) {ledcWrite(ledChannel2, dutyCycle);}
    if(nLedsActive > 2) {ledcWrite(ledChannel3, dutyCycle);}
    previousMillisLEDs = currentMillis; 
  }
  //}
}

void controlBT(unsigned long currentMillis) {
  if(currentMillis - previousMillisBT >= 2) {
    if (Serial.available())
    {
      SerialBT.write(Serial.read());
    }
    if (SerialBT.available())
    {
      String msg = SerialBT.readString();
      if(msg != NULL) {
        msg.trim();
        Serial.println(msg);
        if (msg.equals("sndSensInfo")) {
          sendSensorInfo();
        }
        else if(msg.equals("alarmOn")) {
          alarmOn = true;
        }
        else if(msg.equals("alarmOff")) {
          alarmOn = false;
        }
      }
    }
    previousMillisBT = currentMillis;
  }

  /*if(currentMillis - previousMillisBTSensors >= 10000) {
    Serial.println("here111111111111");
    pressVal = analogRead(pressurePin);
    String txtSendSensors = pressVal + String(",") + analogRead(photoPin);
    uint8_t buf[txtSendSensors.length()];
    memcpy(buf, txtSendSensors.c_str(), txtSendSensors.length());
    
    //SerialBT.write(buf, txtSendSensors.length());
    SerialBT.println(txtSendSensors);
    previousMillisBTSensors = currentMillis;
    Serial.println("here222222222222222");
  }*/

  /*if(currentMillis - previousMillisBT >= 2000 && buttonState == HIGH) {
    String a = "esp32 uwu";
    uint8_t buf[a.length()];
    memcpy(buf,a.c_str(),a.length());
    buttonState = digitalRead(buttonPin);
    if (SerialBT.available())
    {
      SerialBT.write(buf, a.length());
    }
  }*/
}

void sendSensorInfo() {
  pressVal = analogRead(pressurePin);
  String txtSendSensors = pressVal + String(",") + analogRead(photoPin);
  uint8_t buf[txtSendSensors.length()];
  memcpy(buf, txtSendSensors.c_str(), txtSendSensors.length());
  
  SerialBT.println(txtSendSensors);
}
