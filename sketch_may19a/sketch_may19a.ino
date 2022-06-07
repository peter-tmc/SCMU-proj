
#include <WiFi.h>

#include <Firebase_ESP_Client.h>
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"

#define WIFI_SSID "AndroidAP_8631"
#define WIFI_PASS "pedro123"

// Insert Firebase project API Key
#define API_KEY "AIzaSyA5olWcKmHHPbhxjftCPFJhFUfsLOXDA2Y"

// Insert RTDB URLefine the RTDB URL */
#define DATABASE_URL "https://scmu-45836-default-rtdb.europe-west1.firebasedatabase.app/" 


FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig configFb;

bool signupOK = false;

const int buzzer = 18; //buzzer to arduino pin 9
const int pressurePin = 35;
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

int pressVal = 0;
int nLedsActive = 3;
int lastPressVal = 0;
int dutyCycle = 0;

/*IPAddress local_IP(192, 168, 1, 184);
// Set your Gateway IP address
IPAddress gateway(192, 168, 66, 127);

IPAddress subnet(255, 255, 255, 0);
IPAddress primaryDNS(8, 8, 8, 8);   // optional
IPAddress secondaryDNS(8, 8, 4, 4); // optional
*/


unsigned long previousMillisLEDs = 0; 
const long intervalLED = 5; 
unsigned long previousMillisMoreLED = 0;
const long intervalMoreLEDs = 3000;
boolean increasingLED = false;

unsigned long previousMillisReadLight = 0;
const long intervalReadLight = 2000;

unsigned long previousMillisWifiReconn = 0;
unsigned long previousMillisWifi = 0; 
const long intervalWifi = 1000; 

unsigned long previousMillisSensors = 0;
const long intervalSensors = 1000;

unsigned long previousMillisPushButton = 0;
const long intervalPushButton = 100;

int buttonState = 0;
bool alarmOn = false;


void setup(){
  Serial.begin(115200);
  initLeds();
  pinMode(buttonPin, INPUT);
  delay(1000);
  //pinMode(buzzer, OUTPUT); // Set buzzer - pin 9 as an output
  initWifi();
  initFirebase();
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
 
  wifiControl(currentMillis);
  controlLight(currentMillis);
  sendSensorInfo(currentMillis);
 /*if(pressVal > 50) esta na cama*/
  delay(10);
}

void wifiControl(unsigned long currentMillis) {
  if ((WiFi.status() != WL_CONNECTED) && (currentMillis - previousMillisWifiReconn >= intervalWifi)) {
    Serial.print(millis());
    Serial.println("Reconnecting to WiFi...");
    WiFi.disconnect();
    WiFi.reconnect();
    previousMillisWifiReconn = currentMillis;
  }
  /*if(currentMillis - previousMillisWifi >= intervalWifi) {
   
    //processing incoming packet, must be called before reading the buffer
    int packetSize = udp.parsePacket();
    if (packetSize) {
      //receive response from server, it will be HELLO WORLD
      int len = udp.read(incomingPacket, 255);
      if (len > 0) {
        incomingPacket[len] = 0;
      }
      Serial.printf("UDP packet contents: %s\n", incomingPacket);
  
      // send back a reply, to the IP address and port we got the packet from
      udp.beginPacket(udp.remoteIP(), udp.remotePort());
      udp.write(replyPacket, sizeof(replyPacket));
      udp.endPacket();
      previousMillisWifi = currentMillis;
    }
  }*/
}
void  controlLight(unsigned long currentMillis) {
  if(alarmOn) {
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
 }
 else {
  ledcWrite(ledChannel, 0); 
  ledcWrite(ledChannel2, 0);
  ledcWrite(ledChannel3, 0);
 }
}

void sendSensorInfo(unsigned long currentMillis) {
  if (Firebase.ready() && signupOK && currentMillis - previousMillisSensors >= intervalSensors) {
    pressVal = analogRead(pressurePin);
    Firebase.RTDB.setInt(&fbdo, "sensors/pressure", pressVal);
    Firebase.RTDB.setInt(&fbdo, "sensors/light", analogRead(photoPin));
    previousMillisSensors = currentMillis;
  }
  
  if(Firebase.ready() && signupOK && currentMillis - previousMillisPushButton >= intervalPushButton) {
    if(Firebase.RTDB.getBool(&fbdo, "/alarm/isOn")) {
      alarmOn = fbdo.to<bool>();
    }
    if(alarmOn) {
      Firebase.RTDB.setInt(&fbdo, "alarm/button", digitalRead(buttonPin));
    }
    previousMillisPushButton = currentMillis;
  }
}

void initWifi() {
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASS);
  Serial.print("Connecting to ");
  Serial.print(WIFI_SSID);
  // Loop continuously while WiFi is not connected

  while (WiFi.status() != WL_CONNECTED) {
    Serial.print('.');
    delay(1000);
  }
   Serial.print("Connected! IP address: ");
  Serial.println(WiFi.localIP());
  /*udp.begin(localudpPort);
  Serial.printf("Now listening at IP %s, UDP port %d\n", WiFi.localIP().toString().c_str(), localudpPort);*/
}

void initFirebase() {
    /* Assign the api key (required) */
  configFb.api_key = API_KEY;

  /* Assign the RTDB URL (required) */
  configFb.database_url = DATABASE_URL;

  if (Firebase.signUp(&configFb, &auth, "", "")){
    Serial.println("ok");
    signupOK = true;
  }
  else{
    Serial.printf("%s\n", configFb.signer.signupError.message.c_str());
  }

  /* Assign the callback function for the long running token generation task */
  configFb.token_status_callback = tokenStatusCallback; //see addons/TokenHelper.h
  
  Firebase.begin(&configFb, &auth);
  Firebase.reconnectWiFi(true);
}

void initLeds() {
  ledcSetup(ledChannel, freq, resolution);
  ledcSetup(ledChannel2, freq, resolution);
  ledcSetup(ledChannel3, freq, resolution);
  ledcAttachPin(ledPin, ledChannel);
  ledcAttachPin(ledPin2, ledChannel2);
  ledcAttachPin(ledPin3, ledChannel3);
}
