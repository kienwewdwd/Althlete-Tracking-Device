#include <Arduino.h>
#include <TinyGPS++.h>
#include <SoftwareSerial.h>

TinyGPSPlus gps;
SoftwareSerial gpsSerial(4, 5); // RX, TX
char buffer[200];

double prevLat = 0.0;
double prevLng = 0.0;
unsigned long prevTime = 0;
double distance = 0.0;

void printData() 
{
    if (gps.location.isUpdated()) {
        double lat = gps.location.lat();
        double lng = gps.location.lng();

        double altitude = gps.altitude.meters();

        int year = gps.date.year();
        int month = gps.date.month();
        int day = gps.date.day();

        int hour = gps.time.hour();
        int minute = gps.time.minute();
        int second = gps.time.second();

        double currentspeed = gps.speed.kmph(); // Get speed in km/h

        snprintf(buffer, sizeof(buffer),
                 "Latitude: %.8f, Longitude: %.8f, Altitude: %.2f m, "
                 "Date/Time: %d-%02d-%02d %02d:%02d:%02d, CurrentSpeed: %.f km/h",
                 lat, lng, altitude, year, month, day, hour, minute, second, currentspeed);

        if(prevLat != 0.0 && prevLng != 0.0) {
            double dLat = (lat - prevLat) * 111194.93; // distance in meters
            double dLng = (lng - prevLng) * 111194.93 * cos(lat * PI / 180.0); // distance in meters
            distance += sqrt(dLat * dLat + dLng * dLng); // distance in meters
            double deltaTime = (gps.time.value() - prevTime) / 1000.0; // time in seconds
            double speed = distance / deltaTime * 3.6; // speed in km/h
            snprintf(buffer + strlen(buffer), sizeof(buffer) - strlen(buffer),
                     ", Distance: %.2f m, Speed: %.2f km/h", distance, speed);
        }

        Serial.println(buffer);

        prevLat = lat;
        prevLng = lng;
        prevTime = gps.time.value();
    }
}

void setup() 
{
    Serial.begin(9600);
    gpsSerial.begin(9600);
}

void loop() 
{
    while (gpsSerial.available() > 0) {
        if (gps.encode(gpsSerial.read())) {
            printData();


            // Check speed threshold
            double speed = gps.speed.kmph();
            if (speed >= 30) { // Example threshold of 30 km/h
                // Do something when speed is above threshold
            }
        
        }
    }
}
