//#include <Wire.h> //incluimos las librerias para manejar la pantalla lcd
#include <LiquidCrystal_I2C.h> 

LiquidCrystal_I2C lcd (0x27,16,2); // Creamos un objeto que indicara la direccion del lcd y sus dimensiones
int Calc;
volatile int rpmcount;

void setup() {
  Serial.begin(9600);  //baudrate
  lcd.init();
  lcd.backlight();
  lcd.clear();
  rpmcount=0;
  attachInterrupt(0, rpm, RISING);  //DIGITAL Pin 2: Interrupt 0
}

void rpm()   //measure the quantity of square wave
{
  rpmcount++;
}
void loop() {

  rpmcount=0;
  //sei();
  delay(1000);
  //cli();
  Calc = (rpmcount * 60 / 350);
  Serial.print(Calc);
  Serial.print(" L/min\r\n");
  lcd.backlight();
  lcd.setCursor(0, 0); // mostramos en la primera fila el caudal
  lcd.print("Caudal:");
  lcd.print(Calc);
  lcd.print(" L/min  ");
  lcd.setCursor(0, 1); //mostramos en la segunda fila la revoluciones por segundo
  lcd.print("Re.min:");
  lcd.print(rpmcount);
  lcd.print(" rpm  ");
  attachInterrupt(0, rpm, RISING);  //DIGITAL Pin 2: Interrupt 0
  
}
