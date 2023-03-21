int ecg_pin = A0;
int threshold = 50;
int count = 0;
unsigned long instance1 = 0;
unsigned long interval = 0;
bool flag = false;
float sampling_frequency = 0.0;
float heart_rate = 0.0;
int Fs = 100;

void setup() {
  Serial.begin(9600);
  pinMode(14, INPUT); // Setup for leads off detection LO +
  pinMode(12, INPUT); // Setup for leads off detection LO -
}

void loop() {
  int ecg_value = analogRead(ecg_pin);
  ecg_value = map(ecg_value, 700, 1024, 0, 100); // to flatten the ecg values a bit
  
  if ((ecg_value > threshold) && (!flag)) {
    count++;  
    flag = true;
    if (count == 1) {
      instance1 = millis();
    } else if (count == 3) {
      unsigned long current_time = millis();
      interval = current_time - instance1;
      sampling_frequency = 1000.0 / (interval /2.0);
      int heart_rate = sampling_frequency * 60;
      Serial.print("Sampling frequency (Hz): ");
      Serial.println(sampling_frequency);
      Serial.print("interval): ");
      Serial.println(interval);
      Serial.print("Heart rate (BPM): ");
      Serial.println(heart_rate);
      count = 0;
    }
  } else if (ecg_value < threshold) {
    flag = false;
  }
//Serial.println(ecg_value);


}
