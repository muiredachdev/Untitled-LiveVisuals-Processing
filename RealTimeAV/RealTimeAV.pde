import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;


Minim minim;
AudioInput in;
FFT fft;

//for the EQ
int w;
int picCount = 0%2;
///////change eQ size
float circleSize = 150;
float amplitudeSensitivity;

//for the colourBAckground
PImage colBack;

//stuff for cube
PImage tex;
PImage mex;
float vol;
float rotateBox;
float cubeSize;
float cubeAdd;
float TRANSTIME;
//state stuff
float stateCount;

void setup() {
  TRANSTIME = 10000;
  size (1600, 800, P3D);
  tex = loadImage("WOB.jpeg");
  mex = loadImage("BOW.jpeg");
  colBack = loadImage("COLOUR.jpg");
  textureMode(NORMAL);

  minim = new Minim(this);
  in = minim.getLineIn(Minim.MONO, 1024);//check out
  fft = new FFT(in.bufferSize(), in.sampleRate());
  fft.logAverages(width/3, 90);//check out
  stroke(255);


  //initialization shit; -------------------

  //width of EQ bars
  w = width/fft.avgSize();

  //makes bars more sensitive
  amplitudeSensitivity = 9;
}

void draw()
{
  stateCount = frameCount%TRANSTIME;
  println(stateCount);
  int state = stateChanger(stateCount);
  background(0);
  fft.forward(in.mix);
  stroke(255);
  strokeWeight(w);

  if (state == 1 && state != 2 && state != 3)
  {
    cubeSize = 200;
    ///------CIRCLE EQUALISER



    pushMatrix();
    translate(width/2, height/2);
    rotate(PI/2);

    float radius=circleSize;
    float pump = 0;
    int numPoints=fft.avgSize();
    float blapAmmnt = 0.05;

    float angle=TWO_PI/(float)fft.avgSize();


    for (int i = 0; i < numPoints; i++)
    {

      float Blap = (constrain(fft.getAvg(i)*i*blapAmmnt, 1, width));

      for (int j = 0; j < numPoints/3; j ++)
      { 
        float LF = (constrain(fft.getAvg(i/4)*blapAmmnt, 1, width)); 
        if ( LF > 5)
        {
          pump += (0.6/i);
        }
      }


      float y1 = pump*sin(angle*i) + (radius*sin(angle*i));
      float x1 = pump*cos(angle*i) + (radius*cos(angle*i));
      float y2 = pump*sin(angle*i) + (radius*sin(angle*i) + sin(angle*i)*Blap);
      float x2 = pump*cos(angle*i) +(radius*cos(angle*i) +cos(angle*i)*Blap);

      if (Blap > 1)
      {      
        line(x1, y1, x2, y2);
      }
    }
    popMatrix();

    //-------UNTITLED CUBE
    pushMatrix();
    {
      noStroke();
      translate(width/2.0, height/2.0, -100);


      for (int q = 3; q < fft.avgSize (); q++)
      { 
        vol = -fft.getAvg(q);
        rotateBox += 0.0008*vol/100;
        rotateX(rotateBox);
        rotateY(rotateBox);
        scale(cubeSize + vol);
        if (vol < -10)
        {
          TexturedCube(colBack);
        } else
        {
          if (frameCount%1000 <= 1000/2)
          {
            TexturedCube(tex);
          } else {
            TexturedCube(mex);
          }
        }
      }
      rotateX(rotateBox);
    }
    popMatrix();
  }
  ////state 2
  else if (state == 2 && state != 1 && state != 3)
  {
    cubeSize = 0 + cubeAdd;
    //-------UNTITLED CUBE

    float zoomTime = TRANSTIME;
    //println(cubeSize);
    if (frameCount%zoomTime <= zoomTime/2)
    {
      cubeAdd += .2;
    }
    if (frameCount%zoomTime >= zoomTime/2)
    {
      cubeAdd -= 0.2;
    }

    pushMatrix();

    noStroke();
    translate(width/2.0, height/2.0, -100);


    for (int q = 3; q < fft.avgSize (); q++)
    { 
      vol = -fft.getAvg(q);
      rotateBox += 0.0008*vol/100;
      rotateX(rotateBox);
      rotateY(rotateBox);
      scale(cubeSize + vol);
      if (vol < -10)
      {
        TexturedCube(colBack);
      } else
      {
        if (frameCount%1000 <= 1000/2)
        {
          TexturedCube(tex);
        } else {
          TexturedCube(mex);
        }
      }
    }
    rotateX(rotateBox);
    popMatrix();
  }
  else if (state == 3 && state != 1 && state != 2)
  {
    
    cubeSize = 400;
    //-------UNTITLED CUBE
    noStroke();
    translate(width/2.0, height/2.0, -100);

    for (int q = 3; q < fft.avgSize (); q++)
    { 
      vol = -fft.getAvg(q);
      rotateBox += 0.0008*vol/100;
      rotateX(rotateBox);
      rotateY(rotateBox);
      scale(cubeSize + vol);
      if (vol < -10)
      {
        TexturedCube(colBack);
      } else
      {
        if (frameCount%1000 <= 1000/2)
        {
          TexturedCube(tex);
        } else {
          TexturedCube(mex);
        }
      }
    }
    rotateX(rotateBox);
  }
}



void TexturedCube(PImage tex) {
  beginShape(QUADS);
  texture(tex);

  float w = 1.26/2;
  float h = .37/2;
  float depth = .37/2;

  // Given one texture and six faces, we can easily set up the uv coordinates
  // such that four of the faces tile "perfectly" along either u or v, but the other
  // two faces cannot be so aligned.  This code tiles "along" u, "around" the X/Z faces
  // and fudges the Y faces - the Y faces are arbitrarily aligned such that a
  // rotation along the X axis will put the "top" of either texture at the "top"
  // of the screen, but is not otherwised aligned with the X/Z faces. (This
  // just affects what type of symmetry is required if you need seamless
  // tiling all the way around the cube)

  // +Z "front" face
  vertex(-w, -h, h, 0, 0);
  vertex( w, -h, h, 1, 0);
  vertex( w, h, h, 1, 1);
  vertex(-w, h, h, 0, 1);

  // -Z "back" face
  vertex( w, -h, -h, 0, 0);
  vertex(-w, -h, -h, 1, 0);
  vertex(-w, h, -h, 1, 1);
  vertex( w, h, -h, 0, 1);

  // +Y "bottom" face
  vertex(-w, h, h, 0, 0);
  vertex( w, h, h, 1, 0);
  vertex( w, h, -h, 1, 1);
  vertex(-w, h, -h, 0, 1);

  // -Y "top" face
  vertex(-w, -h, -h, 0, 0);
  vertex( w, -h, -h, 1, 0);
  vertex( w, -h, h, 1, 1);
  vertex(-w, -h, h, 0, 1);

  endShape();

  beginShape(QUADS);
  {
    if (frameCount%1000 <= 1000/2)
    {
      stroke(255);
      strokeWeight(2/cubeSize);
      fill(0);
    } else {
      stroke(0);
      strokeWeight(2/cubeSize);
      fill(255);
    }
  }
  // +X "right" face
  vertex( w, -h, h, 0, 0);
  vertex( w, -h, -h, 1, 0);
  vertex( w, h, -h, 1, 1);
  vertex( w, h, h, 0, 1);

  // -X "left" face
  vertex(-w, -h, -h, 0, 0);
  vertex(-w, -h, h, 1, 0);
  vertex(-w, h, h, 1, 1);
  vertex(-w, h, -h, 0, 1);
  endShape();
}


int stateChanger(float stateCounter)
{
  if (stateCounter <= TRANSTIME && stateCounter <= TRANSTIME/3.)
  {
    return 1;
  } else if (stateCounter > (TRANSTIME/3.) && stateCounter <= (2.*(TRANSTIME/3.)))
  {
    return 2;
  } else if (stateCounter > (2.*(TRANSTIME/3.)) && stateCounter <= TRANSTIME)
  {
    return 3;
  } else return 0;
}

