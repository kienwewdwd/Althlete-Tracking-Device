#include <Arduino.h>
#include <TinyGPS++.h>
#include <SoftwareSerial.h>
#include <WebSocketsServer.h>  //import for websocket
#include <ArduinoJson.h>       //data Json
#include <math.h>
#include <CircularBuffer.h>

// Pin of ECG
#define SAMPLE_RATE 125
#define BAUD_RATE 115200
#define INPUT_PIN A0
#define OUTPUT_PIN 13
#define DATA_LENGTH 16

// Heart rate function
int threshold = 100;
int count = 0;
unsigned long instance1 = 0;
unsigned long interval = 0;
bool flag = false;
float sampling_frequency = 0.0;
float heart_rate = 0.0;
int avg = 0;
int data_index = 0;
bool peak = false;
int reading = 0;
float BPM = 0.0;
bool IgnoreReading = false;
bool FirstPulseDetected = false;
unsigned long FirstPulseTime = 0;
unsigned long SecondPulseTime = 0;
unsigned long PulseInterval = 0;
CircularBuffer<int, 30> buffer;

// Declare connecct Wifi from ESP8266
const char *ssid = "esp8266";    //Wifi SSID (Name)
const char *pass = "123456789";  //wifi password

// Format the WebSocket
WebSocketsServer webSocket = WebSocketsServer(81);  //websocket init with port 81
unsigned long t_tick = 0;

StaticJsonDocument<1000> SensorDoc;

// GPS function
TinyGPSPlus gps;
SoftwareSerial gpsSerial(5, 4);  // RX, TX
double prevLat = 0.0;
double prevLng = 0.0;
unsigned long prevTime = 0;
double distance = 0.0;
bool isMoving = false;
double speedRunning = 0.0;


void GPSdata();
void ECGdata();
void SensorEvent();
float ECGFilter();
bool Getpeak();

void setup() {
  Serial.begin(9600);
  gpsSerial.begin(9600);
  pinMode(14, INPUT);  // Setup for leads off detection LO +
  pinMode(12, INPUT);  // Setup for leads off detection LO -

  // Set First value
  SensorDoc["distance"] = 0;
  SensorDoc["speedRunning"] = 0;
  SensorDoc["heartRate"] = 0;

  Serial.println("Connecting to wifi");

  IPAddress apIP(192, 168, 99, 100);                           //Static IP for wifi gateway
  WiFi.softAPConfig(apIP, apIP, IPAddress(255, 255, 255, 0));  //set Static IP gateway on NodeMCU
  WiFi.softAP(ssid, pass);                                     //turn on WIFI

  webSocket.begin();                  //websocket Begin
  webSocket.onEvent(webSocketEvent);  //set Event for websocket
  Serial.println("Websocket is started");
}

void loop() {
  webSocket.loop();

  if (millis() - t_tick > 1) {
    ECGdata();
    while (gpsSerial.available() > 0) {
      if (gps.encode(gpsSerial.read())) {
        GPSdata();
      }
    }
    SensorEvent();
    t_tick = millis();
  }
}


bool Getpeak(float new_sample) {
  // Buffers for data, mean, and standard deviation
  static float data_buffer[DATA_LENGTH];
  static float mean_buffer[DATA_LENGTH];
  static float standard_deviation_buffer[DATA_LENGTH];

  // Check for peak
  if (new_sample - mean_buffer[data_index] > (DATA_LENGTH / 2) * standard_deviation_buffer[data_index]) {
    data_buffer[data_index] = new_sample + data_buffer[data_index];
    peak = true;
  } else {
    data_buffer[data_index] = new_sample;
    peak = false;
  }

  // Calculate mean
  float sum = 0.0, mean, standard_deviation = 0.0;
  for (int i = 0; i < DATA_LENGTH; ++i) {
    sum += data_buffer[(data_index + i) % DATA_LENGTH];
  }
  mean = sum / DATA_LENGTH;

  // Calculate standard deviation
  for (int i = 0; i < DATA_LENGTH; ++i) {
    standard_deviation += pow(data_buffer[(i) % DATA_LENGTH] - mean, 2);
  }

  // Update mean buffer
  mean_buffer[data_index] = mean;

  // Update standard deviation buffer
  standard_deviation_buffer[data_index] = sqrt(standard_deviation / DATA_LENGTH);

  // Update data_index
  data_index = (data_index + 1) % DATA_LENGTH;

  // Return peak
  return peak;
}

float ECGFilter(float input) {
  float output = input;
  {
    static float z1, z2;  // filter section state
    float x = output - -0.95391350 * z1 - 0.25311356 * z2;
    output = 0.00735282 * x + 0.01470564 * z1 + 0.00735282 * z2;
    z2 = z1;
    z1 = x;
  }
  {
    static float z1, z2;  // filter section state
    float x = output - -1.20596630 * z1 - 0.60558332 * z2;
    output = 1.00000000 * x + 2.00000000 * z1 + 1.00000000 * z2;
    z2 = z1;
    z1 = x;
  }
  {
    static float z1, z2;  // filter section state
    float x = output - -1.97690645 * z1 - 0.97706395 * z2;
    output = 1.00000000 * x + -2.00000000 * z1 + 1.00000000 * z2;
    z2 = z1;
    z1 = x;
  }
  {
    static float z1, z2;  // filter section state
    float x = output - -1.99071687 * z1 - 0.99086813 * z2;
    output = 1.00000000 * x + -2.00000000 * z1 + 1.00000000 * z2;
    z2 = z1;
    z1 = x;
  }
  return output;
}


void webSocketEvent(uint8_t num, WStype_t type, uint8_t *payload, size_t length) {
  //webscket event method
  String cmd = "";
  switch (type) {
    case WStype_DISCONNECTED:
      Serial.println("Websocket is disconnected");
      break;
    case WStype_CONNECTED:
      {
        Serial.println("Websocket is connected");
        Serial.println(webSocket.remoteIP(num).toString());
        webSocket.sendTXT(num, "connected");
      }
      break;
    case WStype_TEXT:
      cmd = "";
      for (int i = 0; i < length; i++) {
        cmd = cmd + (char)payload[i];
      }  //merging payload to single string
      Serial.print("Data from flutter:");
      Serial.println(cmd);
      break;
    case WStype_FRAGMENT_TEXT_START:
      break;
    case WStype_FRAGMENT_BIN_START:
      break;
    case WStype_BIN:
      hexdump(payload, length);
      break;
    default:
      break;
  }
}
void ECGdata(){
   // Calculate elapsed time
  static unsigned long past = 0;
  unsigned long present = micros();
  unsigned long interval = present - past;
  past = present;

  // Run timer
  static long timer = 0;
  timer -= interval;

  // Sample
  if(timer < 0){
    timer += 1000000 / SAMPLE_RATE;
    // Sample and Nomalize input data (-1 to 1)
    float sensor_value = analogRead(INPUT_PIN);
    float signal = ECGFilter(sensor_value)/512;

    // Get peak
    peak = Getpeak(signal);
    // Print sensor_value and peak
    // Blink LED on peak
    digitalWrite(OUTPUT_PIN, peak);

    if(peak && IgnoreReading == false){
        if(FirstPulseDetected == false){
          FirstPulseTime = millis();
          FirstPulseDetected = true;
        }
        else{
          SecondPulseTime = millis();
          PulseInterval = SecondPulseTime - FirstPulseTime;
          buffer.unshift(PulseInterval);
          FirstPulseTime = SecondPulseTime;
        }
        IgnoreReading = true;
      }
      if(!peak){
        IgnoreReading = false;
      }  
      if (buffer.isFull()){
        for(int i = 0 ;i < buffer.size(); i++){
          avg+=buffer[i];
        }
        BPM = (1.0/avg) * 60.0 * 1000 * buffer.size();
        avg = 0;
        buffer.pop();
        if (BPM < 240){
          Serial.print("BPM ");
          Serial.println(BPM);
          Serial.flush();
        }
      }  
  }
}

void GPSdata() {

  double lat = gps.location.lat();
  double lng = gps.location.lng();
  double speed = gps.speed.kmph();
  speedRunning = speed;

  if (gps.speed.isValid() && speed > 2) {
    isMoving = true;
  } else {
    isMoving = false;
  }

  if (isMoving && prevLat != 0.0 && prevLng != 0.0) {
    double dLat = (lat - prevLat) * 111194.93;                          // distance in meters
    double dLng = (lng - prevLng) * 111194.93 * cos(lat * PI / 180.0);  // distance in meters
    distance += sqrt(dLat * dLat + dLng * dLng);                        // distance in meters
  }

  Serial.print("Distance: ");
  Serial.print(distance);
  Serial.println(" meters");

  Serial.print("Speed: ");
  Serial.print(speed);
  Serial.println(" km/h");

  prevLat = lat;
  prevLng = lng;
}

void SensorEvent() {
  SensorDoc["heartRate"] = BPM;
  SensorDoc["distance"] = distance;
  SensorDoc["speedRunning"] = speedRunning;
  char msg[255];
  serializeJson(SensorDoc, msg);
  webSocket.broadcastTXT(msg);
}
