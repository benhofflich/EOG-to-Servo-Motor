#include <Servo.h>
int sensorValueH=0;
float voltageH;
int servoPin = 3;
Servo Servo1;
void setup() {
  // initialize serial communication at 9600 bits per second:
  Serial.begin(9600);
  Servo1.attach(servoPin);
}
void loop() {
  // read the input on analog pin 0:
  sensorValueH = analogRead(A0);
  // Convert the analog reading (which goes from 0 - 1023)
  // to a voltage (0 - 5V):
  voltageH = sensorValueH * (5.0 / 1023.0);
  //When doing floating point arithmetic, be sure and include .0 after
  // the number to be clear that you are using a float not an integer. 
  // If you don’t, the numbers may be rounded off to integers and 
  // can produce strange results.
  //
  // print out the value you read:
  Serial.print("Horizontal: "); Serial.print(voltageH); Serial.println(" ");
  delay(1);
}
