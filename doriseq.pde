import android.media.*;
import android.media.MediaPlayer.OnCompletionListener;
import android.content.res.*;

MultiTouch[] mt;
int maxTouchEvents = 5;
float epsilon = 0.5;

int interval = 10;

int frames = 16;
int fpb = 9;

boolean[][] on = new boolean[4][frames];
int[][] wait = new int[4][frames];

void setup() {
  size(480, 800);
  colorMode(HSB, 100);
  ellipseMode(CENTER);
  smooth();
  

  // multi touch initialize  
  mt = new MultiTouch[maxTouchEvents];
  for(int i=0; i < maxTouchEvents; i++) {
    mt[i] = new MultiTouch();
  }
  
  for(int i=0; i<4; i++) {
    for(int j=0; j<frames; j++) {
      on[i][j] = false;
    } 
  }
}

String[] filenames = new String[]{"do.mp3", "dori.mp3", "ran.mp3", "do2.mp3"};

void draw() {  
  background(0);
  noStroke();
  
  int beat = frameCount%(frames*fpb)/fpb;
  if(frameCount%(frames*fpb)%fpb == 0) {
    for(int i=0; i<4; i++) {
      if(on[i][beat]) {
        String filename = filenames[i];

        try {
          MediaPlayer snd = new MediaPlayer();
          AssetManager assets = this.getAssets();
          AssetFileDescriptor fd = assets.openFd(filename);
          snd.setDataSource(fd.getFileDescriptor(), fd.getStartOffset(), fd.getLength());
          snd.prepare();
          snd.setOnCompletionListener(new OnCompletionListener(){
            public void onCompletion(MediaPlayer mp){
              println("release");
              mp.release();
            }
          });
          snd.start();
        } 
        catch (IllegalArgumentException e) {
          e.printStackTrace();
        } 
        catch (IllegalStateException e) {
          e.printStackTrace();
        } catch (IOException e) {
          e.printStackTrace();
        }
      }
    }
  }
  
  for(int i=0; i<4; i++) {
    for(int j=0; j<frames; j++) {
      int bright = 40;
      if (beat==j || on[i][j]) {
        bright = 60;
        if (beat==j && on[i][j]) {
          bright = 100;
        }
      }
      fill(25*i, 100, bright);
      rect(i*120, j*(800/frames), 120, 100);      
    }
  }
  
  if (mousePressed == true) {
    for (int i=0; i<maxTouchEvents; i++) {
      if(mt[i].touched) {
        int x = int(mt[i].motionX/120);
        int y = int(mt[i].motionY/(800/frames));
        if(wait[x][y] == 0) {
          on[x][y] = !on[x][y];
          wait[x][y] = 10;
        }
      }
    }
    
    for(int i=0; i<4; i++) {
      for(int j=0; j<frames; j++) {
        if(wait[i][j]>0) wait[i][j]--;
      }
    }
  }
}

// Multi-touch processing

public boolean surfaceTouchEvent(MotionEvent me) {
  int pointers = me.getPointerCount();
  for(int i=0; i < maxTouchEvents; i++) {
    mt[i].touched = false;
  }
  for(int i=0; i < maxTouchEvents; i++) {
    if(i < pointers) {
      mt[i].update(me, i);
    }
    else {
      mt[i].update();
    }
  }

  return super.surfaceTouchEvent(me);
}

// Multi-Touch management class
class MultiTouch {
  float motionX, motionY;
  float pmotionX, pmotionY;
  float size, psize;
  int id;
  boolean touched = false;

  void update(MotionEvent me, int index) {
    pmotionX = motionX;
    pmotionY = motionY;
    psize = size; 

    motionX = me.getX(index);
    motionY = me.getY(index);
    size = me.getSize(index);

    id = me.getPointerId(index);
    touched = true;
  }

  void update() {
    pmotionX = motionX;
    pmotionY = motionY;
    psize = size;
    touched = false;
  }
}
