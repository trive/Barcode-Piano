// Barcode Piano - Arduino code
// by Marco, Hao-Ting, and Helle
// CIID 2011
// www.ciid.dk
// portfolio.marcotriverio.com


// #define is the same as "const int"
#define LED 13
#define SCANNER 3
#define LASER 6
#define WAITING_TIME 200
#define NOTES 7
#define BRICKS 10
#define MAX_ATTEMPTS 5
#define SONG_TIME 3900

// bricks resitors value
#define BRICK0 786
#define BRICK1 701
#define BRICK2 614
#define BRICK3 560
#define BRICK4 508
#define BRICK5 468
#define BRICK6 419
#define BRICK7 378
#define BRICK8 332
#define BRICK9 288
#define SPAN   20

// array containing the bricks
int bricks[NOTES];
int old_notes[NOTES];
int notes[NOTES];
int values[10];
int i;

/* Setup function */
void setup() {
  // scanner button is an input - triggers music
  pinMode(SCANNER, INPUT);

  // debug led
  pinMode(LED, OUTPUT);

  // scanner laser output
  pinMode(LASER, OUTPUT);

  // initialize array
  for(i=0; i<NOTES; i++) {
    bricks[i] = 0;
    old_notes[i] = 0;
    notes[i] = 0;
  }

  // initialize values array
  values[0] = BRICK0;
  values[1] = BRICK1;
  values[2] = BRICK2;
  values[3] = BRICK3;
  values[4] = BRICK4;
  values[5] = BRICK5;
  values[6] = BRICK6;
  values[7] = BRICK7;
  values[8] = BRICK8;
  values[9] = BRICK9;

  // start serial communication
  Serial.begin(9600);
}


/* Loop function */
void loop() {
  // read value from bottons
  boolean button = digitalRead(SCANNER);

  // if the button is pressed read bricks and
  // tell processing to play music
  if(button == HIGH) {
    digitalWrite(LASER, HIGH);
    int i = 0;

    // save old bricks
    for(i=0; i<NOTES; i++) {
      old_notes[i] = notes[i];
    }

    // detect bricks
    for(i=0; i<NOTES; i++) {
      notes[i] = detect_brick(i);
    }

    // turn light off
    delay(400);
    digitalWrite(LASER, LOW);  
    delay(600);


    // send the tune to processing
    Serial.print("H");
    for(i=0; i<NOTES; i++) {
      if(notes[i]<0) Serial.print("/");
      else Serial.print(notes[i]);
    }
    Serial.println("");

    // to avoid multiple clicks
    delay(SONG_TIME);

  }
  // if the button is not pressed just wait a little
  // bit and then start again
  else if (button == LOW) {
    delay(WAITING_TIME);
  }


}

int detect_brick(int pin) {
  int val1, val2, val3, val = 0;
  int counter = 0;
  do {
    val1 = analogRead(pin);
    val2 = analogRead(pin);
    val3 = analogRead(pin);
    val = (val1+val2+val3)/3;
    counter++;
  } 
  while((abs(val1-val2)>SPAN ||
    abs(val2-val3)>SPAN ||
    abs(val1-val3)>SPAN )
    && counter < MAX_ATTEMPTS);

  int j = 0;
  for(j=0; j<BRICKS; j++) {
    if(  val <= values[j] + SPAN
      &&
      val >= values[j] - SPAN )
      return j;
  }

  return -1;
}


