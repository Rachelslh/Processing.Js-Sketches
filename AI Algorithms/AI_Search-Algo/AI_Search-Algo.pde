import java.util.*;
import controlP5.*; 

int i,j, w, h;
float r,g,b;
int preI = 1, preJ = 6;
LinkedList<Cell> cheminAbsolu = null;
String[] modes = {"Parcours en Largeur" , "Parcours en Profondeur", "Parcours avec Coût Uniforme"}; 
MatToTree mt;
int MODE = -1;
Iterator<Cell> iterator ;
Cell c;
boolean sketchDone = false;
int [][]obst={{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
        {1,0,0,0,0,0,2,0,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,0,0,1,1,0,0,0,1},
        {1,1,0,0,1,0,0,1,0,0,0,0,0,0,0,1},
        {1,0,0,0,1,0,0,1,1,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,3,0,0,0,0,0,0,1,0,0,1},
        {1,0,0,0,1,0,0,0,0,0,0,0,1,0,0,1},
        {1,0,0,0,0,0,1,1,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,1,0,0,0,0,0,0,0,1,1,1},
        {1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}}; 
        
ControlP5 cp5;        
ArrayList<Toggle> toggleList = new ArrayList();
Textlabel l;

void setup() {
  
 size(700, 512);
 cp5 = new ControlP5(this);
 w=512;
 h=512;
 
 ControlFont cf = new ControlFont(createFont("Impact",12));
 l = cp5.addTextlabel("").setText("Aucune Recherche n'est Activée").setFont(cf).setPosition(520, 300);
 int d = 0, yb = 0;
 while(d < 3){
   final int dd = d;
   toggleList.add(cp5.addToggle(modes[d]).align(ControlP5.CENTER,ControlP5.CENTER,ControlP5.CENTER,ControlP5.CENTER).
   onClick(new CallbackListener() { 
      public void controlEvent(CallbackEvent theEvent) {
        Cell c = new Cell(0, 0, 0, 0);
        c = c.searchDepart(obst, 2);
        if(dd == 0) { toggleList.get(1).setState(false); toggleList.get(2).setState(false); }
        else if(dd == 1) { toggleList.get(0).setState(false); toggleList.get(2).setState(false); }
        else if(dd == 2) { toggleList.get(0).setState(false); toggleList.get(1).setState(false); }
        MODE = dd;
        l.setText(modes[dd] + " est Activé");
        mt = new MatToTree(obst,2,3,c.x,c.y,MODE);
        try {
          iterator = mt.preCells.iterator();
          sketchDone = false;
        }
        catch(NullPointerException e){ println("Target Is Already Reached !"); }
      }
    }
   ).
   setFont(cf).
   setColorActive(color(#8c1c13)).
   setColorForeground(color(0)).
   setColorLabel(color(#e5edeb)).
   setColorBackground((d == 0)? color(#870058) : (d == 1)? color(#f0544f) : color(#59cd90)).
   setPosition(512,yb).
   setSize(188, 50));
   
   yb += 50;
   d++;
 }
 
 cp5.addButton("Exit").
   onClick(new CallbackListener() { 
      public void controlEvent(CallbackEvent theEvent) {
        exit();
      }
    }
   ).
   setFont(cf).
   setColorActive(color(#FF0000)).
   setColorForeground(color(#ee4266)).
   setColorLabel(color(#e5edeb)).
   setColorBackground(color(#50514f)).
   setPosition(512,yb).
   setSize(188, 50);
   
   frameRate(20);
}

void draw() {
  PImage out=createImage(w,h,RGB);
  background(0);
  out.loadPixels();
  paintImage(out);
  out.updatePixels();
  out.save("im"+".bmp");
  image(out,0,0);
  
  if(!toggleList.get(0).getBooleanValue() && !toggleList.get(1).getBooleanValue() && !toggleList.get(2).getBooleanValue())  { 
    MODE = -1; 
    cheminAbsolu = null; 
    l.setText("Aucune Recherche n'est Activée"); 
  }
  
}

void paintImage(PImage out){
  
  if(cheminAbsolu != null && iterator.hasNext() && !sketchDone)
    c = iterator.next();
  else
    sketchDone = true;
  
  for (int x = 0; x < w; x++ ) {
    for (int y = 0; y < h; y++ ) {

      // Calculate the 1D pixel location
      int loc = x + y*w;
      i = y/32; j = x/32;
      int val = obst[i][j];
      if(cheminAbsolu != null && sketchDone){
        
        for(int k = 0; k < cheminAbsolu.size(); k++){
          if(cheminAbsolu.get(k).x == i && cheminAbsolu.get(k).y == j){
            val = 4;
            break;
          }
        }
      }
      switch (val)
      {
        case 0: r= 231; g=222; b=205; break;
        case 1: r= 10 ; g=18 ; b=42 ; break;
        case 2: r= 152; g=182; b=177; break;
        case 3: r= 14 ; g=71 ; b=73 ; break;
        //color of the way
        case 4: r= 106; g=102; b=163; break;
      }      
      
      color co = color(r, g, b);
      if(c != null && c.x == i && c.y == j){
        if(sketchDone){
          out.pixels[loc] = color (#645853);
          c = null;
        }else
          out.pixels[loc] = color (#645853);
      }
      else  
         out.pixels[loc] = co;
    }
  }
}

void mousePressed(){

    i = mouseY / 32;
    j = mouseX / 32;
    updateCoordinates(i , j);
}

void keyPressed(){
  
  if(key == CODED){
    
    if(keyCode == UP){
      updateCoordinates(preI-1 , preJ);
    }
    
    else if(keyCode == DOWN){
      updateCoordinates(preI+1 , preJ);
    }
    
    else if(keyCode == LEFT){
      updateCoordinates(preI , preJ-1);
    }
    
    else if(keyCode == RIGHT){
      updateCoordinates(preI , preJ+1);
    }
  } 
}

void updateCoordinates(int i, int j){
  
  if(i < 16 && j < 16 && (obst[i][j] == 0 || obst[i][j] == 3)){
         
    if(obst[preI][preJ] != 3)
      obst[preI][preJ] = 0;
    if(obst[i][j] != 3)
      obst[i][j] = 2;
    preI = i;
    preJ = j;
      
    if(MODE != -1){
      mt = new MatToTree(obst,2,3,i,j,MODE);
      try {
        iterator = mt.preCells.iterator();
        sketchDone = false;
      }
      catch(NullPointerException e) { println("Target Is Already Reached !"); }
    }
  }
}
