// This #include statement was automatically added by the Particle IDE.
#include <HttpClient.h>

// This #include statement was automatically added by the Particle IDE.
#include <ArduinoJson.h>

// This #include statement was automatically added by the Particle IDE.
#include <ntp-time.h>

const int analogPinTemperatura = A1;
const int analogPinLux         = A3;
const int analogPinInfrared    = A5;

const float Vcc = 3.3;
const int analogResolution = 4095;

// Variables sensor temperatura
const float V0 = 0.5;
const float Tc = 0.01;

// Resistencia para divisor de tensión
const float R = 10000; // ohm

// Variables fotoreceptor
const float Rlux = 29000; // ohm
const float gamma_ = 0.9;

// Sensor infrarrojo
const int threshold_incendio = 200;
bool flag_infrarred = false;

// Servidor NTP
static char timeServer[] = "hora.usc.es";
NtpTime ntptime=NtpTime(10,timeServer);

// Servidor HTTP
HttpClient http;


void setup() {
	ntptime.start();
	Time.setTime(ntptime.now());

    Serial.begin(9600);
	while (!Serial);

	Serial.println("Device flashed!");

    Particle.variable("analogTemperature", analogRead(analogPinTemperatura));
    Particle.variable("analogLux", analogRead(analogPinLux));
    Particle.variable("analogInfrared", analogRead(analogPinInfrared));
}

float analogToVoltage(int analogValue) {return Vcc * analogValue / analogResolution;}
float pinToVoltage(int pin) {return analogToVoltage(analogRead(pin));}

String getIsoTimestamp() {
    char buffer[25];
    snprintf(buffer, sizeof(buffer), "%04d-%02d-%02dT%02d:%02d:%02dZ",
             Time.year(), Time.month(), Time.day(),
             Time.hour(), Time.minute(), Time.second());
    return String(buffer);
}

const char* bool2str(const bool b) {
    return b ? "true" : "false";
}


String createJSON(float temperatura, float lux, int infrared_analog, bool infrared_active_fire) {
    StaticJsonDocument<256> jsonDoc;

    JsonObject timeInstant = jsonDoc.createNestedObject("timeInstant");
    timeInstant["value"] = getIsoTimestamp();
    //
    JsonObject temp = jsonDoc.createNestedObject("temperature");
    temp["value"] = temperatura;
    //
    JsonObject luxObj = jsonDoc.createNestedObject("light");
    luxObj["value"] = lux;
    // //
    // JsonObject infrared_analog_json = jsonDoc.createNestedObject("infrared_analog");
    // infrared_analog_json["value"] = infrared_analog;

    JsonObject infrared_status = jsonDoc.createNestedObject("smoke");
    infrared_status["value"] = bool2str(infrared_active_fire);

    // Convert JSON to string
    char jsonString[512];
    serializeJson(jsonDoc, jsonString);
    
    Serial.print(jsonString);
    Serial.print("\n");
    return jsonString;
}

void sendJsonData(const String& jsonPayload) {
    http_header_t headers[] = {
        { "Content-Type", "application/json" },
        { "Accept", "application/json" },
        { nullptr, nullptr } // Terminate headers
    };
    
    http_request_t request;
    http_response_t response;

    request.hostname = "172.16.240.27";
    request.port = 2310;
    request.path = "/v2/entities/MotePrueba10_Final_Mote/attrs";
    request.body = jsonPayload;

    http.post(request, response, headers);

    Serial.printlnf("HTTP status: %d", response.status);
    Serial.println("Server response:");
    Serial.println(response.body);

    return;
}

void loop() {

	// Temperatura
	float voltageTemperatura = pinToVoltage(analogPinTemperatura);	
    float temperatura = (voltageTemperatura - V0) / Tc;
    
	//Serial.printlnf("Voltage Temperatura: %f", voltageTemperatura);
	//Serial.printlnf("Temperatura: %f", temperatura);
	//Particle.publish("Temperatura", String(temperatura), PRIVATE);
    
	// Lux
	float voltageLux = pinToVoltage(analogPinLux);
    float Ron = ((Vcc / voltageLux) * R) - R;
    float lux = pow(10, (log10(Rlux)-log10(Ron)) / gamma_ + 1 );

	//Serial.printlnf("Voltage Lux: %f", voltageLux);
	//Serial.printlnf("Luxes: %f", lux);
	//Particle.publish("Lux", String(lux), PRIVATE);

	// Infrarrojo
    int analogInfrared = analogRead(analogPinInfrared);
	Serial.printlnf("Infrared analog: %i", analogInfrared);

	if (analogInfrared > threshold_incendio && !flag_infrarred) {
        Serial.println("Se ha detectado un incendio!!!!!");
        flag_infrarred = true;
	} else if (analogInfrared < threshold_incendio && flag_infrarred) {
        Serial.println("Incendio apagado :D");
        flag_infrarred = false;
	}

    //Serial.println(Time.format(ntptime.now(), "%Y-%m-%d %H:%M:%S"));
    
    String json_payload = createJSON(temperatura, lux, analogInfrared, flag_infrarred);
    // sendJsonData(json_payload);

    delay(5000);
}
