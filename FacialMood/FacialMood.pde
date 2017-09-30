import http.requests.*;
import processing.video.*;
import java.awt.image.BufferedImage;
  
byte[] data;
Capture cam;
int cameraWidth=640;
int cameraHeight=480;
int cameraXOff=(1280-cameraWidth)/2;
int cameraYOff=(720-cameraHeight)/2;
int bgColor=0;

void post(){
  PostRequest post = new PostRequest("https://westus.api.cognitive.microsoft.com/emotion/v1.0/recognize");
  
  post.addHeader("Ocp-Apim-Subscription-Key", YOUR_KEY);
  
  post.addHeader("Content-Type", "application/octet-stream");
  post.addData("application/octet-stream", data);
  
  
  post.send();
  
  println("Response Content: " + post.getContent());
  changeColor(post.getContent());
  println("Response Content-Length Header: " + post.getHeader("Content-Length"));
}
void setup() {
  size(1280, 720);

  String[] cameras = Capture.list();
  
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    /*
    for (int i = 0; i < cameras.length; i++) {
      println(i);
      println(cameras[i]);
    }*/
    int idx=3;
    // The camera can be initialized directly using an 
    // element from the array returned by list():
    cam = new Capture(this, cameras[idx]);
    cam.start();     
  }
  background(bgColor);
}

void draw() {
  if (cam.available() == true) {
    cam.read();
  }
  
  
  //
  image(cam, cameraXOff, cameraYOff);
  // The following does the same, and is faster when just drawing the image
  // without any additional resizing, transformations, or tint.
  //set(0, 0, cam);
}

void changeColor(String response){
  
  response=response.replace("[","").replace("]","");
  if(response.length()==0){return;}
  JSONObject emotions=parseJSONObject(response).getJSONObject("scores");
  println(emotions);
  if(emotions.getFloat("anger")>0.4){
    background(200,0,0);
    return;
  }
  if(emotions.getFloat("happiness")>0.4){
    background(0,200,0);
    return;
  }
  if(emotions.getFloat("sadness")>0.4){
    background(0,0,200);
    return;
  }
  background(0);
  
}

void keyReleased()
{
  if(key != ' ') return;
 cam.save("temp.jpg");
 data=loadBytes("temp.jpg");
 println("photo taken");
 post();
} 

 //method: addHeader(name,value)