void xRectangle(float x, float y, float z, float ylen, float zlen) {
  beginShape();
  vertex(x, y, z);
  vertex(x, y+ylen, z);
  vertex(x, y+ylen, z+zlen);
  vertex(x, y, z+zlen);
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
  
  float tDown;
  float shift;
  
  float rotZ;
  float dRotZ;
  
  float bodyHeight;
  float bodyLength;
  float bodyWidth;
  
  float tireX;
  float tireZ;
  float tireRadius;
  float tireGirth;
  
  Car() {
    stroke = 0;
    bodyColor = 200;
    tireColor = 100;
    pWidth = 75;
    pLength = 100;
    pHeight = 25;
    topWidth = 50;
    tDown = 50;
    rotZ = PI/2;
    dRotZ = PI/60;
    shift = -50;
    bodyHeight = 50;
    bodyLength = pLength+50;
    bodyWidth = pWidth;
    tireX = 75;
    tireRadius = 30;
    tireGirth = 30;
    tireZ = -pHeight - bodyHeight - tireRadius + 20;
  }
  
  void turnLeft() {
    rotZ -= dRotZ;
  }
  
  void turnRight() {
    rotZ += dRotZ;
  }
  
  void windows() {
    fill(127, 127);
    stroke(stroke);

    beginShape();
    vertex(-pLength, -pWidth, -pHeight);
    vertex(pLength, -pWidth, -pHeight);
    vertex(topWidth, -topWidth, pHeight);
    vertex(-topWidth, -topWidth, pHeight);
    endShape();
    
    beginShape();
    vertex(pLength, -pWidth, -pHeight);
    vertex(pLength,  pWidth, -pHeight);
    vertex(topWidth, topWidth, pHeight);
    vertex(topWidth, -topWidth, pHeight);
    endShape();
    
    beginShape();
    vertex(pLength, pWidth, -pHeight);
    vertex(-pLength, pWidth, -pHeight);
    vertex(-topWidth, topWidth, pHeight);
    vertex(topWidth, topWidth, pHeight);
    endShape();
    
    beginShape();
    vertex(-pLength,  pWidth, -pHeight);
    vertex(-pLength, -pWidth, -pHeight);
    vertex(-topWidth, -topWidth, pHeight);
    vertex(-topWidth, topWidth, pHeight);
    endShape();
    
    zRectangle(-topWidth, -topWidth, pHeight, topWidth*2, topWidth*2);
  }
  
  void body() {
    fill(bodyColor);
    rectangularPrism(-bodyLength, -bodyWidth, -pHeight-bodyHeight, 
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
    translate(0, tDown, 0);
    rotateX(PI/2);
    rotateZ(rotZ);
    translate(shift, 0, 0);
    windows();
    body();
    tires();
  }
  
}

Car car;

void setup() {
  frameRate(40);
  size(640,360,P3D);
  car = new Car();
}

void draw() {
  background(0);
  translate(width/2, height/2, -100);
  car.display();
  if (keyPressed) {
    if (keyCode == LEFT) {
      car.turnLeft();
    }
    else if (keyCode == RIGHT) {
      car.turnRight();
    }
  }
}