import java.util.Collections;
import controlP5.*;


// iMGS

PImage img, cropped_img, res_cropped_img, filtered_img;

// HOG INSTANCE

HOG_descriptor HOG;

// DRAWING CLASS INSTANCE

Drawing draw;

// DIMENSIONS AND LOCATIONS

static int offsetX, offsetY, x, y;
int blocSize, cellSize, angleDegree;

// BOOLEAN 

boolean locked = false, newInstance = false, withinBoundaries = false;

// INTERFACE CONTROLLER

ControlP5 cp5;
RadioButton R1, R2, R3;
PFont font;
ControlFont C_FONT;

//FONT

final int FONT_SIZE1 = 15, FONT_SIZE2 = 22, FONT_SIZE3 = 10;

// FUNCTIONS

void setup() {
  background(0);
  fullScreen();
  cp5 = new ControlP5(this);
  
  img = loadImage("img.jpg");
  img.resize(img.width / 4, img.height / 4); //img.width / 4, img.height / 4
  img.filter(GRAY);
  
  font = createFont("impact", FONT_SIZE2);
  
  C_FONT = new ControlFont(font);
  
  textFont(font);
  cp5.setFont(C_FONT);
  
  x = - width;
  y = - height;
  offsetX = (width / 3 + 100) / 2 - img.width / 2;
  offsetY = 50;
  
  draw = new Drawing();
  draw.parameters();
  
  //String[] fontList = PFont.list();
  //printArray(fontList);
}


void draw() {
  
  blocSize = int(R1.getValue());
  //blocSize = int(R2.getValue());
  cellSize = int(R2.getValue());
  angleDegree = int(R3.getValue());
  
  draw.basic_drawing();
  
  if (!newInstance && withinBoundaries) {
    
    draw.draw_rect(x, y, 0, 0, blocSize);
    
    for (int x1 = 0; x1 < cropped_img.width; x1 += cellSize) {
      for (int y1 = 0; y1 < cropped_img.height; y1 += cellSize) {
         draw.draw_rect(x1, y1, x, y, cellSize);
      }
    }
    text("Processed Block", offsetX, height - 230);
    image(res_cropped_img, offsetX, height - 150);
    
    text("Histogram", offsetX + img.width - 60, height - 230);
    draw.draw_histogram(HOG.histList.get(0).get(0).getHashMap(), offsetX + img.width - 17 * (Histogram.binsN + 1), 20, height - 50, height - 200);
  }
  
}


void mousePressed() {
 
 if ( (mouseX >= offsetX && mouseX + blocSize < img.width + offsetX) && (mouseY >= offsetY && mouseY + blocSize < img.height + offsetY) ) { // Check if mouseClick is within boundaries of the image 
   
   x = mouseX;
   y = mouseY;
   
   locked = true; 
   newInstance = true;
   withinBoundaries = true;
  } 
  else  
    withinBoundaries = false;
}


void mouseReleased() {
  
 if (locked == true) {
   
   newInstance = false;
   
   HOG = new HOG_descriptor(blocSize, cellSize, 9, angleDegree);
   
   cropped_img = img.get(x - offsetX, y - offsetY, blocSize, blocSize);
   res_cropped_img = img.get(x - offsetX, y - offsetY, blocSize, blocSize);
   res_cropped_img.resize(100, 100);
   
   filtered_img = HOG.extract_features_HOG(cropped_img);
   
   locked = false;
  }
}


class Drawing {
  
  void parameters() {
    
    R1 = cp5.addRadioButton("BlockSize").setPosition(width / 3 + 200, height / 2 + 50).setSize(20, 20).setSpacingRow(10)
    .setNoneSelectedAllowed(false)
    
    .addItem("64 * 64", 64)
    .addItem("32 * 32", 32)
    .addItem("16 * 16", 16)
    
    .setColorActive(color(#73683B))
    .setColorForeground(color(#A79776))
    .setColorLabel(color(#fbe9e7))
    .setColorBackground(color(#424242))
    .setFont(C_FONT)
    
    
    
    .activate(0);
    
    R2 = cp5.addRadioButton("CellSize").setPosition(2 * width / 3, height / 2 + 50).setSize(20, 20).setSpacingRow(10) // 2 * width / 3 - 100
    .setNoneSelectedAllowed(false)
    
    //.addItem("12 * 12", 8)
    .addItem("8 * 8", 8)
    .addItem("4 * 4", 4)
    
    .setColorActive(color(#73683B))
    .setColorForeground(color(#A79776))
    .setColorLabel(color(#fbe9e7))
    .setColorBackground(color(#424242))
    .setFont(C_FONT)
    
    .activate(0);
    
    R3 = cp5.addRadioButton("AngleDegree").setPosition(width - 200, height / 2 + 50).setSize(20, 20).setSpacingRow(10) // width - 300
    .setNoneSelectedAllowed(false)
    
    .addItem("180", 180)
    .addItem("360", 360)
    
    .setColorActive(color(#73683B))
    .setColorForeground(color(#A79776))
    .setColorLabel(color(#fbe9e7))
    .setColorBackground(color(#424242))
    .setFont(C_FONT)
    
    .activate(0);
  }
  
  
  void basic_drawing() {
    
    background(0);
    image(img, offsetX, offsetY);
    
    fill(#191610);
    noStroke();
    rect(width / 3 + 100, 0, 2 * width / 3, height);
    
    strokeWeight(3);
    stroke(#A79776);
    line(width / 3 + 100, 0, width / 3 + 100, height);
    
    fill(#A79776);
    
    textSize(FONT_SIZE2);
    text("Parameters", 2 * width / 3, 250);
    
    textSize(FONT_SIZE1);
    text("Block Size", width / 3 + 200, height / 2);
     
    text("Cell Size", 2 * width / 3, height / 2); //2 * width / 3 - 100
    
    text("Angle", width - 200, height / 2); // width - 300
  }
  
 void draw_histogram(HashMap<Integer, Float> hist, int offsetX, int x0, int y1, int y0) {
    
    float histMax = Collections.max(hist.values()); // Max magnitude
    int i = 1, j = 0;
  
    stroke(0);
    fill (#C7BEA9);
    textSize(FONT_SIZE3);
    
    for (Map.Entry entry : hist.entrySet()) {
      
      int y = int(map((float)entry.getValue(), 0, histMax, y1, y0));
      rect(i * x0 + offsetX, y, 10, y1 - y);
      text(j, i * x0 + offsetX, y1 + 15);
      
      i ++;
      j += Histogram.intervalLength;
    }
  }
  
  
  void draw_rect(int x, int y, int offsetX, int offsetY, int size) {
    
    stroke(#887A59);
    //stroke(201, 3, 78);
    noFill();
    rect(x + offsetX, y + offsetY, size, size);
  }
  
}
