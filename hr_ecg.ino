/*

 * VARIABLES

 * count: variable to hold count of rr peaks detected in 30 seconds

 * flag: variable that prevents multiple rr peak detections in a single heartbeat

 * hr: HeartRate (initialized to 72)

 * hrv: Heart Rate variability (takes 10-15 seconds to stabilize)

 * instance1: instance when heart beat first time

 * interval: interval between second beat and first beat

 * timer: variable to hold the time after which hr is calculated

 * value: raw sensor value of output pin

 */

long instance1 = 0, timer;

double hrv = 0, hr = 72, interval = 0;

int value = 0, count = 0;

bool flag = 0;

#define shutdown_pin 13 

#define threshold 85 // to identify R peak

#define timer_value 15000 // 15 seconds timer to calculate hr


void setup() {

  Serial.begin(9600);

  pinMode(14, INPUT); // Setup for leads off detection LO +

  pinMode(12, INPUT); // Setup for leads off detection LO -

}

void loop() { 

  if ((digitalRead(14) == 1) || (digitalRead(12) == 1)) {

    Serial.println("leads off!");

    digitalWrite(shutdown_pin, LOW); //standby mode

    instance1 = micros();

    timer = millis();

  }

  else {

    digitalWrite(shutdown_pin, HIGH); //normal mode

    value = analogRead(A0);

    value = map(value, 700, 1024, 0, 100); //to flatten the ecg values a bit

    if ((value > threshold) && (!flag)) {

      count++;  

      Serial.println("in");

      flag = 1;

      interval = micros() - instance1; //RR interval

      instance1 = micros(); 

    }

    else if ((value < threshold)) {

      flag = 0;

    }

    if ((millis() - timer) > timer_value) {

      hr = count * 4;

      timer = millis();

      count = 0; 

    }

    hrv = hr / 60 - interval / 1000000;

    Serial.print(hr);

    Serial.print(",");

    Serial.print(hrv);

    Serial.print(",");

    Serial.println(value);

  
    delay(1);

  }

}
