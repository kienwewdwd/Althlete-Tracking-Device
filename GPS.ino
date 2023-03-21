#include <Arduino.h>
#include <TinyGPS++.h>
#include <SoftwareSerial.h>

TinyGPSPlus gps;
SoftwareSerial gpsSerial(4, 5); // RX, TX
char buffer[100];

void printData() 
{
    if (gps.location.isUpdated()) {
        double lat = gps.location.lat();
        double lng = gps.location.lng();

        double altitude = gps.altitude.meters();

        int year = gps.date.year();
        int month = gps.date.month();
        int day = gps.date.day();

        int hour = gps.time.hour()+7;
        int minute = gps.time.minute();
        int second = gps.time.second();

        double speed = gps.speed.kmph(); // Get speed in km/h

        snprintf(buffer, sizeof(buffer),
                 "Latitude: %.8f, Longitude: %.8f, Altitude: %.2f m, "
                 "Speed: %.2f km/h, Date/Time: %d-%02d-%02d %02d:%02d:%02d",
                 lat, lng, altitude, speed, year, month, day, hour, minute, second);

        Serial.println(buffer);
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
