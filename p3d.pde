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
  
  float tDown;
  float shift;
  
  float rotZBase;
  float rotZ;
  float dRotZ;
  
  float bodyHeight;
  float bodyLength;
  float bodyWidth;
  float bodyBottom;
  
  float tireX;
  float tireZ;
  float tireRadius;
  float tireGirth;
  
  float moveX;
  float moveY;
  float moveDist;
  
  float cameraDist;
  
  Car(float bottomZ) {
    stroke = 0;
    bodyColor = 200;
    tireColor = 100;
    
    tDown = 50;
    rotZBase = PI/2;
    rotZ = rotZBase;
    dRotZ = PI/60;
    shift = -50;
    
    tireX = 75;
    tireRadius = 30;
    tireGirth = 30;
    tireZ = bottomZ + tireRadius;
    
    bodyBottom = tireZ + 20;
    bodyHeight = 50;
    bodyLength = 150;
    bodyWidth = 75;
    
    pWidth = bodyWidth;
    pLength = bodyLength - 50;
    pHeight = 50;
    topWidth = 50;
    pBottom = bodyBottom + bodyHeight;
    
    moveX = 0;
    moveY = 0;
    moveDist = 10;
    
    cameraDist = 100;
  }
  
  void turnLeft() {
    rotZ -= dRotZ;
  }
  
  void turnRight() {
    rotZ += dRotZ;
  }
  
  void setTurn(float turnRads) {
    rotZ = rotZBase + turnRads;
  }
  
  void moveForward() {
    moveX += -moveDist * sin(rotZ + rotZBase);
    moveY += moveDist * cos(rotZ + rotZBase);
  }
  
  void moveBackward() {
    moveX -= -moveDist * sin(rotZ + rotZBase);
    moveY -= moveDist * cos(rotZ + rotZBase);
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
    rotateX(PI/2);
    translate(moveX, moveY, 0);
    rotateZ(rotZ);
    windows();
    body();
    tires();
    popMatrix();
  }
  
  /** Sets car position to be a little in front of camera. */
  void setToCamera(VirtualCamera cam) {
    moveX = cam.eyeY;
    moveY = cam.eyeX;
    rotZ = cam.eyeDir;
  }
  
}

class Ground {
  
  float level;
  
  Ground(float lev) {
    level = -lev;
  }
  
  void display() {
    pushMatrix();
    fill(0x66, 0xCD, 0x00);
    yRectangle(-1000, level, -1000, 2000, 2000);
    popMatrix();
  }
  
}

class VirtualCamera {
  
  float eyeX, eyeY, eyeZ, eyeDir;
  static final float MOVE_SPEED = 20;
  static final float TURN_SPEED = PI/50;
  float DIR_DIST = height/2 / tan(PI/6);
  
  public VirtualCamera(float x, float y, float z) {
    eyeX = x;
    eyeY = y;
    eyeZ = z;
    eyeDir = PI/2;
  }
  
  public void setCamera() {
    float cx = eyeX + DIR_DIST * cos(eyeDir);
    float cz = eyeZ + DIR_DIST * sin(eyeDir);
    camera(eyeX, eyeY, eyeZ, cx, eyeY, cz, 0, 1, 0);
  }
  
  public void forward() {
    eyeX += MOVE_SPEED * cos(eyeDir);
    eyeZ += MOVE_SPEED * sin(eyeDir);
  }
  
  public void backward() {
    eyeX -= MOVE_SPEED * cos(eyeDir);
    eyeZ -= MOVE_SPEED * sin(eyeDir);
  }
  
  public void turnLeft() {
    eyeDir -= TURN_SPEED;
  }
  
  public void turnRight() {
    eyeDir += TURN_SPEED;
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
    //car.setToCamera(vc);
  }
  vc.setCamera();
}