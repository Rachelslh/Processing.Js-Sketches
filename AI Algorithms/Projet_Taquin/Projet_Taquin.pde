import controlP5.*; 

//DIMENSIONS

final int MAX_X = 3; 
final int MAX_Y = 3;
final int PIXELS_PER_CELL = 90; 

//LOCATIONS

PVector R = new PVector( 0, 0 ); //CURRENT 

//COLORS

final int COLOUR_EMPTY    = #424242;
final int COLOUR_GRID1    = #d1c4e9;
final int COLOUR_GRID2    = #ef5350;
int       COLOUR_TEXT2    = #ffcdd2;

//FONT

final int FONT_SIZE1 = 30, FONT_SIZE2 = 25, FONT_SIZE3 = 14 ;

// MATRIX

int[][] mainM = { {3, 5, 4},
                  {1, 2, 7},
                  {8, 0, 6}
                }; 
int[][] target = { {1, 2, 3},
                   {8, 0, 4},
                   {7, 6, 5}
                 };     
                 
// LISTS

LinkedList<Matrix> list = new LinkedList();

// CURSORS

int i, j, e = -1, f, v = 0, time = 0, preI = -1, preJ = -1, init = 1;

// LABELS

Textlabel[][] mainT = new Textlabel[3][3], targetT = new Textlabel[3][3],  stepT = new Textlabel[3][3]; 
Textlabel main, tar, nbr, resultat, console; //<>//
Textarea output; 
               
// INTERFACE CONTROLLER

ControlP5 CP5;
ControlFont C_FONT1, C_FONT2, C_FONT3;
Button B;
RadioButton H;

//EXECUTION TIME

public static long DEB, FIN, ExecTime;

void setup() {
  
  fullScreen();
  //size(1200, 700);
  CP5 = new ControlP5(this);
  C_FONT1 = new ControlFont(createFont("Impact",FONT_SIZE1));
  C_FONT2 = new ControlFont(createFont("Impact",FONT_SIZE2));
  C_FONT3 = new ControlFont(createFont("Impact",FONT_SIZE3));
  CP5.setFont(C_FONT2);
  initializeLabels();
  labels(0, 1);
  labels(0, 2);
  labels(0, 3);
  addButtons();
  
}

void draw() {
  
  background( COLOUR_EMPTY );
  fill(#263238);
  noStroke();
  rect(2*width/3,0, width/3, height);
  stroke(#d1c4e9);
  line( 2*width/3, 0, 2*width/3,height );
  drawGrid( COLOUR_GRID1, new Point( width/15, height/8 ), new Point( width/15, MAX_Y * PIXELS_PER_CELL ), new Point( MAX_X * PIXELS_PER_CELL, height/8 ) );
  drawGrid( COLOUR_GRID1, new Point( width/3 , height/8 ), new Point( width/3 , MAX_Y * PIXELS_PER_CELL ), new Point( MAX_X * PIXELS_PER_CELL, height/8 ) );
  drawGrid( COLOUR_GRID2, new Point( width/3 , height/2 ), new Point( width/3 , MAX_Y * PIXELS_PER_CELL ), new Point( MAX_X * PIXELS_PER_CELL, height/2 ) );
  
  if( e >= 0 ) {
    for( int i = 0; i < MAX_X; i++ ) {
      for( int j = 0; j < MAX_Y; j++) {
        COLOUR_TEXT2 = #e6a19c;
        stepT[i][j].setValue(String.valueOf(list.get(e).matrix[i][j])).setColor(COLOUR_TEXT2);
      }
    }
    e--;
    delay(500);
  }
  else {
    nbr.setValue("Number of Visited Cells : "+ v);
    resultat.setValue("The Result Of The Algorithm \n With The Minimum  f       : "+f);
  }
  
}

void drawGrid( final int grid, Point p1, Point p2, Point p3 ) {
  
  int pixel_x, pixel_y;
  stroke( grid );
  for ( int x=0; x<=MAX_X; x++ ) {
    pixel_x = x * PIXELS_PER_CELL;
    line( p1.x + pixel_x, p1.y, p2.x + pixel_x, p2.y + p1.y );
  }
  for ( int y=0; y<=MAX_Y; y++ ) {
    pixel_y = y * PIXELS_PER_CELL;
    line( p1.x, p1.y + pixel_y, p3.x + p1.x, p3.y + pixel_y );
  }
  
}

void labels( int mode, int grid ) {
  
  switch( grid ) {
    
    case 1 :
    
    for(int i=0; i<MAX_X; i++){
      for(int j=0; j<MAX_Y; j++){
        if( mode == 0 )
          mainT[i][j] = CP5.addTextlabel("main "+String.valueOf(i)+","+String.valueOf(j), String.valueOf(mainM[i][j]), width/12 + 10 + 90*j , height/6 - 5 + 90*i).setColor(#ffebee).setFont(C_FONT1);
        else
          mainT[i][j].setValue(String.valueOf(mainM[i][j]));
      }
    }
    break;
  
    case 2 :
    
    for(int i=0; i<MAX_X; i++){
      for(int j=0; j<MAX_Y; j++){
        if( mode == 0 )
          targetT[i][j] = CP5.addTextlabel("target "+String.valueOf(i)+","+String.valueOf(j), String.valueOf(target[i][j]), width/3 + 30 + 90*j , height/6 - 5 + 90*i).setColor(#ffebee).setFont(C_FONT1);
        else
          targetT[i][j].setValue(String.valueOf(target[i][j]));
      }
    }
    break;
  
    case 3 : 
    
    for(int i=0; i<MAX_X; i++){
      for(int j=0; j<MAX_Y; j++){
        if( mode == 0 ) 
          stepT[i][j] = CP5.addTextlabel("step "+String.valueOf(i)+","+String.valueOf(j), String.valueOf(mainM[i][j]), width/3 + 30 + 90*j , height/2 + 25 + 90*i).setColor(#ffcdd2).setFont(C_FONT1);
        else {
          COLOUR_TEXT2 = #ffcdd2;
          stepT[i][j].setValue(String.valueOf(mainM[i][j])).setColor(COLOUR_TEXT2);;
        }
      }
    }
    break;
    
  }
  
}

void initializeLabels() {
  
  nbr = CP5.addTextlabel("nbr", "Number of Visited Cells : 0", width/15, height/2 + 70).setColor(#d7ccc8).setFont(C_FONT2);
  resultat = CP5.addTextlabel("resultat", "The Result Of The Algorithm \n With The Minimum  f       : 0", width/15 , height/2 + 115).setColor(#d7ccc8).setFont(C_FONT2);
  main = CP5.addTextlabel("main", "Initial Matrix", width/15 + 50 , height/8 - 50).setColor(#d1c4e9).setFont(C_FONT1);
  tar = CP5.addTextlabel("tar", "Target Matrix", width/3 + 50 , height/8 - 50).setColor(#d1c4e9).setFont(C_FONT1);
  output = CP5.addTextarea("output").setPosition(2*width/3 + 20, height/2 + 50)
      .setSize(width/3 - 50, height/2 - 100)
      .setLineHeight(14)
      .setColorBackground(color(#263238))
      .setColorForeground(color(#cfd8dc))
      .scroll(0)
      .setScrollBackground(#263238)
      .setFont(C_FONT3)
      .setColor(#b0bec5);
      
  CP5.addConsole(output);              
}

void addButtons() {
  
  CP5.addButton("Initialize").
   onClick(new CallbackListener() { 
      public void controlEvent(CallbackEvent theEvent) {
        init = 1;
        f = 0;
        e = -1;
        v = 0;
        i = -1;
        j = -1;
        time = 0;
        labels(1, 3);
        nbr.setValue("Number of Visited Cells : "+ v);
        resultat.setValue("The Result Of The Algorithm \n With The Minimum  f       : "+f);
        output.clear();
      }
    }
   ).
   setFont(C_FONT1).
   setColorActive(color(#e0e0e0)).
   setColorForeground(color(#616161)).
   setColorLabel(color(#ef5350)).
   setColorBackground(color(#424242)).
   setPosition( 3*width/4 + 15, height/8 ).
   setSize(188, 50);
  
  B = CP5.addButton("Execute A*").
   onClick(new CallbackListener() { 
      public void controlEvent(CallbackEvent theEvent) {
        init = 0;
        Matrix M = new Matrix( MAX_X, MAX_Y, new PVector(2,1), mainM, null );
        Matrix T = new Matrix( MAX_X, MAX_Y, new PVector(1,1), target, null );
        AStar A = new AStar( M, T, (int)H.getValue() );
        list = A.findPath();
        /*for( Matrix Ma : list){
          println(Ma.matrix[0][0]+" "+Ma.matrix[0][1]+" "+Ma.matrix[0][2]+" "+Ma.matrix[1][0]+" "+Ma.matrix[1][1]+" "+
          Ma.matrix[1][2]+" "+Ma.matrix[2][0]+" "+Ma.matrix[2][1]+" "+Ma.matrix[2][2]);
          println("F : "+Ma.countF());
        }*/
        ExecTime = FIN - DEB;
        println("Execution Time : "+ExecTime/1000+" seconds");
        f = list.getFirst().countF();
        e = list.size() - 1;
        v = A.closed.size();
      }
    }
   ).
   setFont(C_FONT1).
   setColorActive(color(#e0e0e0)).
   setColorForeground(color(#616161)).
   setColorLabel(color(#ef5350)).
   setColorBackground(color(#424242)).
   setPosition(3*width/4 + 15, height/8 + 170).
   setSize(188, 50);
  
   H = CP5.addRadioButton("H").setNoneSelectedAllowed(false).
   setItemsPerRow(1).
   setSpacingRow(10).
   addItem("Misplaced Parts", 0).
   addItem("Distance of Manhattan", 1).
   activate(0).
   setColorActive(color(#ff8a65)).
   setColorForeground(color(#bf360c)).
   setColorLabel(color(#fbe9e7)).
   setColorBackground(color(#424242)).
   setPosition( 3*width/4 + 15, height/8 + 85 ).
   setSize(20, 20);
   
   CP5.addButton("Exit").
   onClick(new CallbackListener() { 
      public void controlEvent(CallbackEvent theEvent) {
        exit();
      }
    }
   ).
   setFont(C_FONT1).
   setColorActive(color(#e0e0e0)).
   setColorForeground(color(#616161)).
   setColorLabel(color(#d32f2f)).
   setColorBackground(color(#424242)).
   setPosition(3*width/4 + 15, height/8 + 255).
   setSize(188, 50); 
}

void mousePressed(){

    j = (mouseX - 125) / 90;
    i = (mouseY - 100) / 90;
    time++;
    time = updateCoordinates(i , j, time);
}

int updateCoordinates(int i, int j, int t){
  
  if( init == 1 && ( (i >= 0 && i < 3) && (j >= 0 && j < 3) && mainM[i][j] > -1 ) ) {
    
    if( t == 1 ) {
      preI = i;
      preJ = j;
    }
    else if( t == 2 ) {
      int temp;
      temp = mainM[i][j];
      mainM[i][j] = mainM[preI][preJ];
      mainM[preI][preJ] = temp;
      t = 0;
      labels(1, 1);
    }
  }
  return t;
}

public class Point {
  
  int x, y;
  
  public Point( int x , int y) {
    this.x = x;
    this.y = y;
  }
}
