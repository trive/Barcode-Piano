// Barcode Piano - Processing code
// by Marco, Hao-Ting, and Helle
// CIID 2011
// www.ciid.dk
// portfolio.marcotriverio.com

import processing.serial.*;

import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

int TONE_TIME = 400;


Serial myPort;  // Create object from Serial class
int val;      // Data received from the serial port
int i=0;
int started = 0;
int ready = 0;

int[] notes;                // array to store the 7 notes to 
AudioPlayer[] players;      // 10 players for 10 possible notes
Minim minim;                //This uses the awesome MP3 library

int last, now;

void setup() 
{
  myPort = new Serial(this, Serial.list()[0], 9600);
  myPort.bufferUntil('\n'); 

  minim = new Minim(this);
  players = new AudioPlayer[10];
  notes = new int[7];

  // load songs
  players[0] = minim.loadFile("c.mp3");
  players[1] = minim.loadFile("d.mp3");
  players[2] = minim.loadFile("e.mp3");
  players[3] = minim.loadFile("f.mp3");
  players[4] = minim.loadFile("g.mp3");
  players[5] = minim.loadFile("a.mp3");
  players[6] = minim.loadFile("b.mp3");
  players[7] = minim.loadFile("c+.mp3");
  players[8] = minim.loadFile("d+.mp3");
  players[9] = minim.loadFile("e+.mp3");

}

void draw()
{
  // create array
  int i = 0;
  
  while ( ready == 0) { 
    // wait for data to arrive    
    while(myPort.available() <= 0);
    
    val = myPort.read();         // read it and store it in val
    println("Received [" + i + "]: " + val);

    if(started == 0 && val != 72) continue;
    else if(started == 0 && val == 72) {
      started = 1;
      println("STARTING!");
      continue;
    }
    else if (started == 1) {

      if(val >= 47 && val <= 57) {
        if (i>=7) {
          println("TOO MANY NOTES! - ignoring some");
          break; 
        }
        if(val == 47) {
          println("COULD NOT DETECT BRICK #" + i); 
          val = 48;
        }
        notes[i] = val - 48;
        println(notes[i]);
        i++;
        continue;
      }
      else if((val == 10 && i>=7)) {
        println("Finished reading");
        i = 0;
        started = 0;
        ready = 1;
        continue;
      }
      else if(val == 72) { //sudden reset
        println("STARTING AGAIN");
        i = 0;
        started = 1;
        ready = 0;
        continue;     
      }
      else if(val < 48 || val > 57) {
        println("Ignoring an unknown character");
        continue;
      }
    }
  }

  ready = 0;

  // print barcode received
  print("Barcode: ");
  for(i=0; i<7; i++) {
    print(notes[i] + " ");
  }
  println("");

  // play 7 tones
  println("Playing music...");
  for(i=0; i<7; i++) {
    players[notes[i]].play();
    players[notes[i]].rewind();
    real_delay(TONE_TIME);
  }
  
  //just to be sure
  i = 0;
  started = 0;
  ready = 0;

}

void stop()
{
  // always close Minim audio classes when you are done with them
  players[0].close();
  minim.stop();

  super.stop();
}

void real_delay(int d) {
  last = millis();
  do {
    now = millis();
    int i = 0;
  } 
  while(now-last < d);

}





