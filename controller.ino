/** 
 * Code for Arduino controller in UinoCart.
 * Based on the MPU-6050 example eketch by JohnChi.
 * Annemaayke Ammerlaan and Matthew Weidman
 */

#include<Wire.h>
const int MPU_addr=0x68;  // I2C address of the MPU-6050
int16_t AcX,AcY,AcZ,Tmp,GyX,GyY,GyZ;
const int LeftButton = 3;
const int MiddleButton = 5;
const int RightButton = 11; 
const int Buzzer = 7;


void setup(){
  Wire.begin();
  Wire.beginTransmission(MPU_addr);
  Wire.write(0x6B);  // PWR_MGMT_1 register
  Wire.write(0);     // set to zero (wakes up the MPU-6050)
  Wire.endTransmission(true);
  Serial.begin(9600);
  pinMode (LeftButton, INPUT);
  pinMode (MiddleButton, INPUT);
  pinMode (RightButton, INPUT);
  pinMode (Buzzer, OUTPUT);
}

void loop(){
  Wire.beginTransmission(MPU_addr);
  Wire.write(0x3B);  // starting with register 0x3B (ACCEL_XOUT_H)
  Wire.endTransmission(false);
  Wire.requestFrom(MPU_addr,14,true);  // request a total of 14 registers
  AcX=Wire.read()<<8|Wire.read();  // 0x3B (ACCEL_XOUT_H) & 0x3C (ACCEL_XOUT_L)    
  AcY=Wire.read()<<8|Wire.read();  // 0x3D (ACCEL_YOUT_H) & 0x3E (ACCEL_YOUT_L)
  AcZ=Wire.read()<<8|Wire.read();  // 0x3F (ACCEL_ZOUT_H) & 0x40 (ACCEL_ZOUT_L)
  Serial.print(AcY);
  Serial.print(" ");
  if (digitalRead(LeftButton) == HIGH)
    Serial.print("1 ");
  else Serial.print("0 ");
  if (digitalRead(MiddleButton) == HIGH)
    Serial.print("1 ");
  else Serial.print("0 ");
  if (digitalRead(RightButton) == HIGH) {
    Serial.print("1 "); 
    tone(Buzzer, 1760, 10);
    delay (20);
    tone(Buzzer, 880, 10);
    delay (20);
    tone(Buzzer, 440, 10);
  }
  else {Serial.print("0 ");
    delay(50);
  }
  Serial.println ();
  delay(50);
}