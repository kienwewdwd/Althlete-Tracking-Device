#include <Arduino.h>
#include <TinyGPS++.h>
#include <SoftwareSerial.h>
#include <WebSocketsServer.h>  //import for websocket
#include <ArduinoJson.h>       //data Json
#include <math.h>
#include <CircularBuffer.h>
#include <vector>
std::vector<float> heartRateList;
std::vector<float> SpeedList;
// Pin of ECG
#define SAMPLE_RATE 125
#define BAUD_RATE 115200
#define INPUT_PIN A0
#define OUTPUT_PIN 13
#define DATA_LENGTH 16
#define led 0
#define led1 2

float ppgsignal = 0;

int button = 12;
int buttonPushCounter = 0;  // counter for the number of button presses
int buttonState = 0;        // current state of the button
int lastButtonState = 0;
int start_time = 0;


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
float current_BPM = 0.0;
float average_HR = 0.0;
float current_average_HR = 0.0;
float ECG_signal = 0.0;
float signal = 0.0;
float sensor_value = 0.0;
bool IgnoreReading = false;
bool FirstPulseDetected = false;
unsigned long FirstPulseTime = 0;
unsigned long SecondPulseTime = 0;
unsigned long PulseInterval = 0;
CircularBuffer<int, 30> buffer;

// Declare connecct Wifi from ESP8266
const char *ssid = "Athlete_tracking";    //Wifi SSID (Name)
const char *pass = "12345678";  //wifi password

// Format the WebSocket
WebSocketsServer webSocket = WebSocketsServer(1509);  //websocket init with port 81
unsigned long t_tick = 0;

StaticJsonDocument<2000> SensorDoc;

// GPS function
TinyGPSPlus gps;
SoftwareSerial gpsSerial(5, 4);  // RX, TX
double prevLat = 0.0;
double prevLng = 0.0;
unsigned long prevTime = 0;
double distance = 0.0;
double current_distance = 0.0;
bool isMoving = false;
double speedRunning = 0.0;
double current_speedRunning = 0.0;
double average_speed = 0.0;
double current_average_speed = 0.0;

//Time
double time_activity = 0;
double current_time_activity = 0;

void GPSdata();
void ECGdata();
void SensorEvent();
float ECGFilter();
bool Getpeak();

void setup() {
  Serial.begin(BAUD_RATE);
  gpsSerial.begin(9600);
  pinMode(button, INPUT);
  pinMode(led, OUTPUT);
  pinMode(led1, OUTPUT);


  // Set First value
  SensorDoc["distance"] = 0;
  SensorDoc["speedRunning"] = 0;
  SensorDoc["heartRate"] = 0;
  SensorDoc["Speed_Average"] = 0;
  SensorDoc["heartRate_Average"] = 0;
  SensorDoc["TimeAcitivity"] = 0;
  SensorDoc["ECGSignal"] = 0;


  Serial.println("Connecting to wifi");

  IPAddress apIP(192, 168, 99, 100);                           //Static IP for wifi gateway
  WiFi.softAPConfig(apIP, apIP, IPAddress(255, 255, 255, 0));  //set Static IP gateway on NodeMCU
  WiFi.softAP(ssid, pass);                                     //turn on WIFI

  webSocket.begin();                  //websocket Begin
  webSocket.onEvent(webSocketEvent);  //set Event for websocket
  Serial.println("Websocket is started");
}

void loop() {
  ECGdata();
  while (gpsSerial.available() > 0) {
    if (gps.encode(gpsSerial.read())) {
      GPSdata();
    }
  }
  webSocket.loop();
  if (millis() - t_tick > 3000) {
    ECG_signal = sensor_value;
    current_BPM = BPM;
    current_distance = distance;
    current_speedRunning = speedRunning;
    current_average_speed = 0;
    current_average_HR = 0;
    current_time_activity = time_activity;
    Serial.println("-----------");
    Serial.println("ECG: ");
    Serial.print(ECG_signal);
    Serial.println("current_BPM: ");
    Serial.print(current_BPM);
    Serial.println("current_speedRunning: ");
    Serial.print(current_speedRunning);
    Serial.println("current_distance: ");
    Serial.print(current_distance);
    Serial.println("current_average_HR: ");
    Serial.print(current_average_HR);
    Serial.println("current_average_speed: ");
    Serial.print(current_average_speed);
    Serial.println("current_time_activity: ");
    Serial.print(current_time_activity);


    Serial.println("-----------");

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

  // Check if a peak was detected
  if (peak) {
    digitalWrite(led1, HIGH); // set LED to high
  } else {
    digitalWrite(led1, LOW); // set LED to low
  }


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
      digitalWrite(led, LOW);
      break;
    case WStype_CONNECTED:
      {
        Serial.println("Websocket is connected");
        Serial.println(webSocket.remoteIP(num).toString());
        webSocket.sendTXT(num, "connected");
        digitalWrite(led, HIGH);

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
void ECGdata() {
  // Calculate elapsed time
  static unsigned long past = 0;
  unsigned long present = micros();
  unsigned long interval = present - past;
  past = present;

  // Run timer
  static long timer = 0;
  timer -= interval;

  // Sample
  if (timer < 0) {
    timer += 1000000 / SAMPLE_RATE;
    // Sample and Nomalize input data (-1 to 1)
    float sensor_value = analogRead(INPUT_PIN);
    float signal = ECGFilter(sensor_value) / 512;

    // Get peak
    peak = Getpeak(signal);
    // Print sensor_value and peak
    // Blink LED on peak
    digitalWrite(OUTPUT_PIN, peak);

    if (peak && IgnoreReading == false) {
      if (FirstPulseDetected == false) {
        FirstPulseTime = millis();
        FirstPulseDetected = true;
      }
      else {
        SecondPulseTime = millis();
        PulseInterval = SecondPulseTime - FirstPulseTime;
        buffer.unshift(PulseInterval);
        FirstPulseTime = SecondPulseTime;
      }
      IgnoreReading = true;
    }
    if (!peak) {
      IgnoreReading = false;
    }
    if (buffer.isFull()) {
      for (int i = 0 ; i < buffer.size(); i++) {
        avg += buffer[i];
      }
      BPM = (1.0 / avg) * 60.0 * 1000 * buffer.size();
      avg = 0;
      buffer.pop();
      if (BPM < 240) {
        heartRateList.push_back(BPM);
        float sum_heart_rate = 0;
        for (int a = 0; a < heartRateList.size(); a++) {
          sum_heart_rate += heartRateList[a];

        }
        float average_HR = sum_heart_rate / heartRateList.size();
        Serial.print("BPM Average ");
        Serial.println(average_HR);
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
  //  Calculte the average of speed
  SpeedList.push_back(speed);
  float sum_speed = 0;
  for (int j = 0; j , j < SpeedList.size(); j ++) {
    sum_speed += SpeedList[j];
  }
  float average_speed = sum_speed / SpeedList.size();
  Serial.print("Speed Average");
  Serial.println(average_speed);


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
  time_activity = (millis() / 1000) / 60;

  Serial.print("Time Activity: ");
  Serial.print(time_activity);
  Serial.println(" min");

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
  SensorDoc["heartRate"] = current_BPM;
  SensorDoc["distance"] = current_distance;
  SensorDoc["speedRunning"] = current_speedRunning;
  SensorDoc["Speed_Average"] = current_average_speed;
  SensorDoc["heartRate_Average"] = current_average_HR;
  SensorDoc["TimeAcitivity"] = current_time_activity;
  SensorDoc["ECGSignal"] = ECG_signal;

  char msg[255];
  serializeJson(SensorDoc, msg);
  webSocket.broadcastTXT(msg);
}
