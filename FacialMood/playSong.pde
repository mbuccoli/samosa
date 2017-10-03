
void stop(int i){
  if(i==0){angrysong.stop();}
  if(i==2){sadsong.stop();}
  if(i==1){happysong.stop();}
}

void loop(int i){
  if(i==0){angrysong.loop();}
  if(i==2){sadsong.loop();}
  if(i==1){happysong.loop();}

}

void play(int i){
  if(i!=-1){
    loop(i);
  }
  if(isPlaying!=-1){
    stop(isPlaying);
  }
  isPlaying=i;

}