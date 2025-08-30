// #include <Arduino.h>

// // ====== 4 Traffic Modules (ESP32) ======
// // Normal cycle: N -> S -> E -> W with yellow handover

// struct LanePins {
//   int R, Y, G;
// };

// // Pin mapping
// LanePins N = {23, 22, 21};
// LanePins S = {27, 26, 25};
// LanePins E = {19, 18, 5};
// LanePins W = {33, 32, 14};

// // Timings (ms)
// const unsigned long GREEN_MS   = 5000;  // green duration
// const unsigned long YELLOW_MS  = 2000;  // yellow handover

// enum Phase { N_GREEN, N_Y2S, S_GREEN, S_Y2E, E_GREEN, E_Y2W, W_GREEN, W_Y2N };
// Phase currentPhase = N_GREEN;

// unsigned long phaseStart = 0;

// void setupLane(const LanePins& L) {
//   pinMode(L.R, OUTPUT);
//   pinMode(L.Y, OUTPUT);
//   pinMode(L.G, OUTPUT);
// }

// void allOff() {
//   digitalWrite(N.R, LOW); digitalWrite(N.Y, LOW); digitalWrite(N.G, LOW);
//   digitalWrite(S.R, LOW); digitalWrite(S.Y, LOW); digitalWrite(S.G, LOW);
//   digitalWrite(E.R, LOW); digitalWrite(E.Y, LOW); digitalWrite(E.G, LOW);
//   digitalWrite(W.R, LOW); digitalWrite(W.Y, LOW); digitalWrite(W.G, LOW);
// }

// void red(const LanePins& L)    { digitalWrite(L.R, HIGH); digitalWrite(L.Y, LOW);  digitalWrite(L.G, LOW); }
// void yellow(const LanePins& L) { digitalWrite(L.R, LOW);  digitalWrite(L.Y, HIGH); digitalWrite(L.G, LOW); }
// void green(const LanePins& L)  { digitalWrite(L.R, LOW);  digitalWrite(L.Y, LOW);  digitalWrite(L.G, HIGH); }

// void setup() {
//   Serial.begin(115200);

//   setupLane(N);
//   setupLane(S);
//   setupLane(E);
//   setupLane(W);

//   phaseStart = millis();
// }

// void loop() {
//   unsigned long now = millis();
//   unsigned long elapsed = now - phaseStart;

//   allOff(); // reset before setting

//   switch (currentPhase) {
//     case N_GREEN:
//       green(N); red(S); red(E); red(W);
//       if (elapsed > GREEN_MS) { currentPhase = N_Y2S; phaseStart = now; }
//       break;

//     case N_Y2S:
//       yellow(N); yellow(S); red(E); red(W);
//       if (elapsed > YELLOW_MS) { currentPhase = S_GREEN; phaseStart = now; }
//       break;

//     case S_GREEN:
//       green(S); red(N); red(E); red(W);
//       if (elapsed > GREEN_MS) { currentPhase = S_Y2E; phaseStart = now; }
//       break;

//     case S_Y2E:
//       yellow(S); yellow(E); red(N); red(W);
//       if (elapsed > YELLOW_MS) { currentPhase = E_GREEN; phaseStart = now; }
//       break;

//     case E_GREEN:
//       green(E); red(N); red(S); red(W);
//       if (elapsed > GREEN_MS) { currentPhase = E_Y2W; phaseStart = now; }
//       break;

//     case E_Y2W:
//       yellow(E); yellow(W); red(N); red(S);
//       if (elapsed > YELLOW_MS) { currentPhase = W_GREEN; phaseStart = now; }
//       break;

//     case W_GREEN:
//       green(W); red(N); red(S); red(E);
//       if (elapsed > GREEN_MS) { currentPhase = W_Y2N; phaseStart = now; }
//       break;

//     case W_Y2N:
//       yellow(W); yellow(N); red(S); red(E);
//       if (elapsed > YELLOW_MS) { currentPhase = N_GREEN; phaseStart = now; }
//       break;
//   }

//   delay(5);
// }


#include <Arduino.h>
#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"

// ====== WiFi & Firebase Config ======
#define WIFI_SSID "Unity"
#define WIFI_PASSWORD "Adobechannel100231"

// Replace with your Firebase project config
#define API_KEY "AIzaSyCCJVHqXyW5Zs3QHsACyrEC17VPHacAS4o"
#define DATABASE_URL "https://ambugo-ac78d-default-rtdb.asia-southeast1.firebasedatabase.app/"


FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

// ---------------- TRAFFIC LIGHT PINS ----------------
struct LanePins { int R, Y, G; };

// Pin mapping
LanePins N = {23, 22, 21};
LanePins S = {27, 26, 25};
LanePins E = {19, 18, 5};
LanePins W = {33, 32, 14};

// Timings (ms)
const unsigned long GREEN_MS  = 5000;
const unsigned long YELLOW_MS = 2000;

// Traffic Phases
enum Phase { N_GREEN, N_Y2S, S_GREEN, S_Y2E, E_GREEN, E_Y2W, W_GREEN, W_Y2N };
Phase currentPhase = N_GREEN;
unsigned long phaseStart = 0;

// Emergency flag
bool emergencyActive = false;

// ---------------- HELPERS ----------------
void setupLane(const LanePins& L){
  pinMode(L.R, OUTPUT);
  pinMode(L.Y, OUTPUT);
  pinMode(L.G, OUTPUT);
}

void allOff(){
  digitalWrite(N.R, LOW); digitalWrite(N.Y, LOW); digitalWrite(N.G, LOW);
  digitalWrite(S.R, LOW); digitalWrite(S.Y, LOW); digitalWrite(S.G, LOW);
  digitalWrite(E.R, LOW); digitalWrite(E.Y, LOW); digitalWrite(E.G, LOW);
  digitalWrite(W.R, LOW); digitalWrite(W.Y, LOW); digitalWrite(W.G, LOW);
}

void red(const LanePins& L)    { digitalWrite(L.R, HIGH); digitalWrite(L.Y, LOW);  digitalWrite(L.G, LOW); }
void yellow(const LanePins& L) { digitalWrite(L.R, LOW);  digitalWrite(L.Y, HIGH); digitalWrite(L.G, LOW); }
void green(const LanePins& L)  { digitalWrite(L.R, LOW);  digitalWrite(L.Y, LOW);  digitalWrite(L.G, HIGH); }

// ---------------- SETUP ----------------
 bool signupOK=false;
void setup() {
  Serial.begin(115200);

  // Setup lanes
  setupLane(N); setupLane(S); setupLane(E); setupLane(W);
  allOff();

  /// Connect WiFi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(300);
  }
  Serial.println("\n✅ WiFi Connected");

  // Configure Firebase
  config.api_key=API_KEY;
  config.database_url = DATABASE_URL;
  if (Firebase.signUp(&config, &auth, "", "")){
    Serial.println("signUp OK");
    signupOK = true;

   } else {

    Serial.printf("%s\n", config.signer.signupError.message.c_str());
  }

  config.token_status_callback=tokenStatusCallback;
  Firebase.begin(&config, &auth);  // no token needed
  Firebase.reconnectWiFi(true);
  Serial.println("🚀 Firebase ready!");
}

// ---------------- LOOP ----------------
void loop() {
  unsigned long now = millis();

  // -------- Check Emergency from Firebase every 1s --------
  static unsigned long lastCheck = 0;
  if (now - lastCheck > 1000) {
    lastCheck = now;
    if (Firebase.RTDB.getJSON(&fbdo, "emergencies")) {
  FirebaseJson &json = fbdo.jsonObject();
  size_t len = json.iteratorBegin();
  String key, value;
  int type;

  emergencyActive = false;  // reset before checking

  for (size_t i = 0; i < len; i++) {
    json.iteratorGet(i, type, key, value);

    // Each ambulance has a path like: AMB-001/status
    if (key.endsWith("/status") && value == "active") {
      emergencyActive = true;  // at least one ambulance active
      break; // no need to check further
    }
  }

  json.iteratorEnd();
  
  if (emergencyActive) {
    Serial.println("🚨 Emergency detected from an ambulance!");
  } else {
    Serial.println("✅ No active emergencies.");
  }

} else {
  Serial.print("⚠️ Firebase read error: ");
  Serial.println(fbdo.errorReason());
} 
  

  // -------- Emergency Active: North Lane Green Only --------
  if (emergencyActive) {
    allOff();
    green(N);
    red(S); red(E); red(W);
    return; // stay in emergency mode until cleared
  }

  // -------- Normal Traffic Cycle --------
  unsigned long elapsed = now - phaseStart;

  switch (currentPhase) {
    case N_GREEN:
      allOff(); green(N); red(S); red(E); red(W);
      if (elapsed > GREEN_MS) { currentPhase = N_Y2S; phaseStart = now; }
      break;

    case N_Y2S:
      allOff(); yellow(N); yellow(S); red(E); red(W);
      if (elapsed > YELLOW_MS) { currentPhase = S_GREEN; phaseStart = now; }
      break;

    case S_GREEN:
      allOff(); green(S); red(N); red(E); red(W);
      if (elapsed > GREEN_MS) { currentPhase = S_Y2E; phaseStart = now; }
      break;

    case S_Y2E:
      allOff(); yellow(S); yellow(E); red(N); red(W);
      if (elapsed > YELLOW_MS) { currentPhase = E_GREEN; phaseStart = now; }
      break;

    case E_GREEN:
      allOff(); green(E); red(N); red(S); red(W);
      if (elapsed > GREEN_MS) { currentPhase = E_Y2W; phaseStart = now; }
      break;

    case E_Y2W:
      allOff(); yellow(E); yellow(W); red(N); red(S);
      if (elapsed > YELLOW_MS) { currentPhase = W_GREEN; phaseStart = now; }
      break;

    case W_GREEN:
      allOff(); green(W); red(N); red(S); red(E);
      if (elapsed > GREEN_MS) { currentPhase = W_Y2N; phaseStart = now; }
      break;

    case W_Y2N:
      allOff(); yellow(W); yellow(N); red(S); red(E);
      if (elapsed > YELLOW_MS) { currentPhase = N_GREEN; phaseStart = now; }
      break;
  }

  delay(10); // keep loop stable
}