#include <Arduino.h>
#include <Adafruit_Sensor.h>
#include <DHT.h>
#include <ESP8266WebServer.h>
#include <ESP8266WiFi.h>
#include <Hash.h>

#define DHTTYPE    DHT11
#define DHTPIN 13

DHT dht(DHTPIN, DHTTYPE);
const char* ssid = "TURKSAT-KABLONET-81BB-2.4G";  // Wifi Name
const char* password = "67b052b4";  // Wifi Password

ESP8266WebServer server(80); // Web Server Object using Port 80

void setup() {
  Serial.begin(115200);
  dht.begin();
  delay(100);
  
  Serial.println(ssid);
  Serial.println(" Connecting");

  WiFi.begin(ssid, password); // Command for connecting Local Wifi

  //check connection
  while (WiFi.status() != WL_CONNECTED) {
  delay(1000);
  Serial.print("."); //loading until connection successful
  }
  Serial.println("");
  Serial.println("Connected..!");
  Serial.print("IP Address: ");  Serial.println(WiFi.localIP());

  server.on("/", handle_OnConnect);
  server.on("/tempAndHumidity", handle_tempAndHhumidity);
  server.onNotFound(handle_NotFound);

  server.begin();
  Serial.println("HTTP Sunucusu Başlatıldı");
}

void loop() {
  server.handleClient();
}

void handle_OnConnect() {
  server.send(200, "text/html"); 
}

void handle_tempAndHhumidity() {
  float newT = dht.readTemperature();
  float newH = dht.readHumidity();
  String temp = String(newT, 2);
  String humdty = String(newH, 2);

  String message = "{";
  message += "\"temperature\"";
  message += ": ";
  message += temp;
  message += ", ";
  message += "\"humidity\"";
  message += ": ";
  message += humdty;
  message += "}";
  server.send(200, "application/json", message); 
}

void handle_NotFound(){
  server.send(404, "text/plain", "Sayfa Bulunamadı");
}
