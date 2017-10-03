import netP5.*;
import oscP5.*;
import processing.sound.*;

import http.requests.*;
import processing.video.*;
import java.awt.image.BufferedImage;

SoundFile[] songs;
OscP5 oscP5;
NetAddress myRemoteLocation;


//String MYAPIKEY;

byte[] data;
Capture cam;
int cameraWidth=640;
int cameraHeight=480;

int screenWidth; int screenHeight; int cameraXOff; int cameraYOff;

int thickBorder=20;
int bgColor=0;
int Rborder, Gborder, Bborder;
int R=0; int G=0; int B=0;
SoundFile angrysong;
SoundFile sadsong;
SoundFile happysong;
int isPlaying=-1;
boolean usingOSC=false;

void setup() {
  boolean fullsize=false ;  
  //fullScreen(); // if fullsize
  size(1280, 720); //else
  if(fullsize){    
    screenWidth=1920;
    screenHeight=1080;}
  else{
    screenWidth=1280;
    screenHeight=720;
    }
    
    
  cameraXOff=(screenWidth-cameraWidth)/2;
  cameraYOff=(screenHeight-cameraHeight)/2;
  if(usingOSC){ R=0; G=100; B=78;}
  else{R=0; G=0; B=0;}
  String[] cameras = Capture.list();
  
  angrysong=new SoundFile(this,SONGSPATH+"longrock.mp3");
  sadsong=new SoundFile(this,SONGSPATH+"sad.wav");
  happysong=new SoundFile(this,SONGSPATH+"happy.wav");
  
  oscP5 = new OscP5(this,12000);
  myRemoteLocation = new NetAddress("10.9.58.78",12000);
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    
    int idx=3;
    // The camera can be initialized directly using an 
    // element from the array returned by list():
    cam = new Capture(this, cameras[idx]);
    cam.start();     
  }
  background(R,G,B);
}

void draw() {
  if (cam.available() == true) {
    cam.read();
  }
  if(usingOSC){colorMode(HSB);}  
  background(R,G,B);
  colorMode(RGB);
  fill(Rborder,Gborder,Bborder);
  rect(cameraXOff-thickBorder,cameraYOff-thickBorder,cameraWidth+2*thickBorder, cameraHeight+2*thickBorder);
 
  image(cam, cameraXOff, cameraYOff);
  
}
void angrySentiment(){
  Rborder=200; Gborder=0; Bborder=0;
  if(usingOSC){R=0;} 
  else{R=200; G=0; B=0;}
  
  play(0); 
}
void happySentiment(){
  Rborder=0; Gborder=200; Bborder=0;
  if(usingOSC){R=120;} 
  else{R=0; G=200; B=0;}
  
  
  play(1); 
}
void sadSentiment(){
  Rborder=0; Gborder=0; Bborder=200;
  if(usingOSC){R=150;} 
  else{R=0; G=0; B=200;}
  
  
  play(2); 
}

void changeColor(String response){  
  response=response.replace("[","").replace("]","");
  if(response.length()==0){return;}
  JSONObject emotions=parseJSONObject(response).getJSONObject("scores");
  println(emotions);
 
  if(emotions.getFloat("anger")>0.4){
    angrySentiment();    
    return;
  }
  if(emotions.getFloat("happiness")>0.4){
    happySentiment();
    return;
  }
  if(emotions.getFloat("sadness")>0.3){
    sadSentiment();
    return;
  }
  R=0; G=0; B=0;
  
  
}
void photoTaken(){
  println("photo taken");
}

void save(){
 cam.save("temp.jpg");
 data=loadBytes("temp.jpg");
 photoTaken();
 post(); 
}
void keyReleased()
{
  println("pressed");
  if(key == ' '){ thread("save"); return;}
  if(key=='r'){thread("angrySentiment"); return;}
  if(key=='h'){thread("happySentiment"); return;}
  if(key=='s'){thread("sadSentiment"); return;}
    
 
} 



/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  
  println("x "+theOscMessage.get(0).floatValue()+", y "+theOscMessage.get(1).floatValue()+", z "+theOscMessage.get(2).floatValue());
  float rangemin=-.5;
  float rangemax=.5;
  int x=(int) map(theOscMessage.get(0).floatValue(),rangemin,rangemax,0,255);
  int y=(int) map(theOscMessage.get(1).floatValue(),rangemin,rangemax,0,255);
  int z=(int) map(theOscMessage.get(2).floatValue(),rangemin,rangemax,0,255);
  //R=min(max(x,0),255); 
  G=min(max(x,0),255); 
  B=min(max(z,0),255); 
}
void post(){
  PostRequest post = new PostRequest("https://westus.api.cognitive.microsoft.com/emotion/v1.0/recognize");
  post.addHeader("Ocp-Apim-Subscription-Key", MYAPIKEY);
  
  post.addHeader("Content-Type", "application/octet-stream");
  post.addData("application/octet-stream", data);
  
  
  post.send();
  println("Response Content: " + post.getContent());
  changeColor(post.getContent());
  println("Response Content-Length Header: " + post.getHeader("Content-Length"));
}
 //method: addHeader(name,value)