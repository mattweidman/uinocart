import java.util.LinkedList;
import processing.serial.*;

void xRectangle(float x, float y, float z, float ylen, float zlen) {
  beginShape();
  vertex(x, y, z);
  vertex(x, y+ylen, z);
  vertex(x, y+ylen, z+zlen);
  vertex(x, y, z+zlen);
  vertex(x, y, z);
  endShape();
}

void yRectangle(float x, float y, float z, float xlen, float zlen) {
  beginShape();
  vertex(x, y, z);
  vertex(x+xlen, y, z);
  vertex(x+xlen, y, z+zlen);
  vertex(x, y, z+zlen);
  endShape();
}

void zRectangle(float x, float y, float z, float xlen, float ylen) {
  beginShape();
  vertex(x, y, z);
  vertex(x+xlen, y, z);
  vertex(x+xlen, y+ylen, z);
  vertex(x, y+ylen, z);
  endShape();
}

void rectangularPrism(float x, float y, float z, float xlen, float ylen, float zlen) {
  xRectangle(x, y, z, ylen, zlen);
  xRectangle(x+xlen, y, z, ylen, zlen);
  yRectangle(x, y, z, xlen, zlen);
  yRectangle(x, y+ylen, z, xlen, zlen);
  zRectangle(x, y, z, xlen, ylen);
  zRectangle(x, y, z+zlen, xlen, ylen);
}

void yCircle(float cx, float y, float cz, float r, int subdivs) {
  float angle = 360 / subdivs;
  beginShape();
  for (int i=0; i<=subdivs; i++) {
    float dx = cos(radians(i*angle)) * r;
    float dz = sin(radians(i*angle)) * r;
    vertex(cx+dx, y, cz+dz);
  }
  endShape();
}

void yCylinder(float cx, float ymin, float cz, float r, float h, int subdivs) {
  yCircle(cx, ymin, cz, r, subdivs);
  yCircle(cx, ymin+h, cz, r, subdivs);
  
  noStroke();
  beginShape(TRIANGLE_STRIP);
  float angle = 360 / subdivs;
  for (int i=0; i<=subdivs; i++) {
    float dx = cos(radians(i*angle)) * r;
    float dz = sin(radians(i*angle)) * r;
    vertex(cx+dx, ymin, cz+dz);
    vertex(cx+dx, ymin+h, cz+dz);
  }
  endShape();
}

class Car {
  
  float stroke;
  float tireColor;
  float bodyColor;
  
  float pWidth;
  float pLength;
  float pHeight;
  float topWidth;
  float pBottom;
  
  float rotZ;
  
  float bodyHeight;
  float bodyLength;
  float bodyWidth;
  float bodyBottom;
  
  float tireX;
  float tireZ;
  float tireRadius;
  float tireGirth;
  
  float moveX;
  float moveZ;
  
  Car(float bottomZ) {
    // colors
    stroke = 0;
    bodyColor = 200;
    tireColor = 100;
    
    // rotation
    rotZ = PI/2;
    
    // tires
    tireX = 75;
    tireRadius = 30;
    tireGirth = 30;
    tireZ = bottomZ + tireRadius;
    
    // body
    bodyBottom = tireZ + 20;
    bodyHeight = 50;
    bodyLength = 150;
    bodyWidth = 75;
    
    // windows
    pWidth = bodyWidth;
    pLength = bodyLength - 50;
    pHeight = 50;
    topWidth = 50;
    pBottom = bodyBottom + bodyHeight;
    
    // displacement
    moveX = 0;
    moveZ = 0;
  }
  
  void windows() {
    fill(127, 127);
    stroke(stroke);

    beginShape();
    vertex(-pLength, -pWidth, pBottom);
    vertex(pLength, -pWidth, pBottom);
    vertex(topWidth, -topWidth, pBottom + pHeight);
    vertex(-topWidth, -topWidth, pBottom + pHeight);
    endShape();
    
    beginShape();
    vertex(pLength, -pWidth, pBottom);
    vertex(pLength,  pWidth, pBottom);
    vertex(topWidth, topWidth, pBottom + pHeight);
    vertex(topWidth, -topWidth, pBottom + pHeight);
    endShape();
    
    beginShape();
    vertex(pLength, pWidth, pBottom);
    vertex(-pLength, pWidth, pBottom);
    vertex(-topWidth, topWidth, pBottom + pHeight);
    vertex(topWidth, topWidth, pBottom + pHeight);
    endShape();
    
    beginShape();
    vertex(-pLength,  pWidth, pBottom);
    vertex(-pLength, -pWidth, pBottom);
    vertex(-topWidth, -topWidth, pBottom + pHeight);
    vertex(-topWidth, topWidth, pBottom + pHeight);
    endShape();
    
    zRectangle(-topWidth, -topWidth, pBottom + pHeight, topWidth*2, topWidth*2);
  }
  
  void body() {
    fill(bodyColor);
    rectangularPrism(-bodyLength, -bodyWidth, bodyBottom, 
      bodyLength*2, bodyWidth*2, bodyHeight);
  }
  
  void tires() {
    fill(tireColor);
    stroke(stroke);
    yCylinder(tireX, -bodyWidth+1, tireZ, tireRadius, tireGirth, 20);
    stroke(stroke);
    yCylinder(tireX, bodyWidth-1-tireGirth, tireZ, tireRadius, tireGirth, 20);
    stroke(stroke);
    yCylinder(-tireX, -bodyWidth+1, tireZ, tireRadius, tireGirth, 20);
    stroke(stroke);
    yCylinder(-tireX, bodyWidth-1-tireGirth, tireZ, tireRadius, tireGirth, 20);
  }
  
  void display() {
    pushMatrix();
    translate(moveX, 0, moveZ);
    rotateX(PI/2);
    rotateZ(rotZ);
    windows();
    body();
    tires();
    popMatrix();
  }
  
  /** Sets car position to be a little in front of camera. */
  void setToCamera(VirtualCamera cam) {
    moveX = cam.centerX - 320;
    moveZ = cam.centerZ;
    rotZ = cam.getCarDir();
  }
  
}

class Ground {
  
  float level;
  float gwidth = 2000;
  PImage img;
  
  Ground(float lev) {
    level = -lev;
    img = loadImage("checkerboard.png");
  }
  
  void display() {
    float x = -gwidth/2, y = level, z = -gwidth/2, xlen = gwidth, zlen = gwidth;
    beginShape();
    texture(img);
    //fill(0x66, 0xCD, 0x00);
    vertex(x, y, z, 0, 0);
    vertex(x+xlen, y, z, 0, 2000);
    vertex(x+xlen, y, z+zlen, 2000, 2000);
    vertex(x, y, z+zlen, 2000, 0);
    endShape();
  }
  
}

class VirtualCamera {
  
  // x, y, z coordinates of center of car, where camera is pointing
  float centerX, centerY, centerZ;
  
  // Last directions that eye was pointing. A queue is used instead
  // of a single value so that the camera lags behind the car, so
  // you can see all of the car.
  LinkedList<Float> eyeDirs;
  int numEyeDirs = 7;
  int numRestingFrames = 0;
  
  // speed of moving forward or backward
  static final float MOVE_SPEED = 40;
  
  // speed of turning left or right
  static final float TURN_SPEED = PI/40;
  
  // distance from camera to car
  float EYE_DIST = 500;
  
  public VirtualCamera(float x, float y, float z) {
    centerX = x;
    centerY = y;
    centerZ = z;
    
    eyeDirs = new LinkedList();
    for (int i=0; i<numEyeDirs; i++) {
      eyeDirs.add(PI/2);
    }
  }
  
  public void setCamera() {
    float eyeDir = eyeDirs.getFirst();
    float rx = cos(eyeDir);
    float rz = sin(eyeDir);
    float cx = centerX + EYE_DIST * rx;
    float cz = centerZ + EYE_DIST * rz;
    float eyeX = centerX - EYE_DIST * rx;
    float eyeZ = centerZ - EYE_DIST * rz;
    camera(eyeX, centerY, eyeZ - 100, cx, centerY, cz, 0, 1, 0);
  }
  
  public void forward() {
    float eyeDir = getCarDir();
    centerX += MOVE_SPEED * cos(eyeDir);
    centerZ += MOVE_SPEED * sin(eyeDir);
  }
  
  public void backward() {
    float eyeDir = getCarDir();
    centerX -= MOVE_SPEED * cos(eyeDir);
    centerZ -= MOVE_SPEED * sin(eyeDir);
  }
  
  public void turnLeft() {
    float prevEyeDir = eyeDirs.getLast();
    eyeDirs.removeFirst();
    eyeDirs.addLast(prevEyeDir - TURN_SPEED);
    numRestingFrames = 0;
  }
  
  public void turnRight() {
    float prevEyeDir = eyeDirs.getLast();
    eyeDirs.removeFirst();
    eyeDirs.addLast(prevEyeDir + TURN_SPEED);
    numRestingFrames = 0;
  }
  
  public float getCarDir() {
    return eyeDirs.getLast();
  }
  
  /** Keep the queue flipping after car stops turning.  */
  public void adjustWhileResting() {
    if (numRestingFrames < numEyeDirs) {
      float prevEyeDir = eyeDirs.getLast();
      eyeDirs.removeFirst();
      eyeDirs.addLast(prevEyeDir);
      numRestingFrames += 1;
    }
  }
  
}

class ControllerData {
  
  int accy;
  boolean leftButton, midButton, rightButton;
  
  ControllerData(String s) {
    String[] parts = split(s, ' ');
    accy = int(parts[0]);
    leftButton = parts[1] == "1";
    midButton = parts[2] == "1";
    rightButton = parts[3] == "1";
  }
  
  int getAccy() {
    return accy;
  }
  
  boolean leftButtonOn() {
    return leftButton;
  }
  
  boolean midButtonOn() {
    return midButton;
  }
  
  boolean rightButtonOn() {
    return rightButton;
  }
  
}

Car car;
Ground ground;
VirtualCamera vc;

Serial port;

int turnThreshold = 1000;

void setup() {
  frameRate(40);
  size(640,360,P3D);
  float groundLevel = -150;
  car = new Car(groundLevel);
  ground = new Ground(groundLevel);
  vc = new VirtualCamera(width/2, height/2, 0);
  //port = new Serial(this, "COM3", 9600);
}

void draw() {
  background(0x7ec0ee);
  translate(width/2, height/2, -100);
  ground.display();
  car.display();
  /* if (0 < port.available()) {
    String readVal = port.readStringUntil('\n');
    if (readVal != null) {
      try {
        ControllerData cd = new ControllerData(readVal);
        float turnRads = - cd.getAccy() / 10000.0;
        car.setTurn(turnRads);
      } catch (IndexOutOfBoundsException ioobe) {}
    }
  } */
  /* if (keyPressed) {
    if (keyCode == LEFT) {
      car.turnLeft();
    } else if (keyCode == RIGHT) {
      car.turnRight();
    } else if (keyCode == UP) {
      car.moveForward();
    } else if (keyCode == DOWN) {
      car.moveBackward();
    }
    //car.setCamera();
  } */
  if (keyPressed) {
    if (keyCode == LEFT) {
      vc.turnLeft();
    }
    if (keyCode == RIGHT) {
      vc.turnRight();
    }
    if (keyCode == UP) {
      vc.forward();
    }
    if (keyCode == DOWN) {
      vc.backward();
    }
    if (!(keyCode == LEFT || keyCode == RIGHT)) {
      vc.adjustWhileResting();
    }
    car.setToCamera(vc);
  } else {
    vc.adjustWhileResting();
  }
  vc.setCamera();
}