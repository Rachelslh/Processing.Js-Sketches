import controlP5.*;

// DRAW INSTANCE
Draw draw;
// GRAPH

Graph graph;
Node focusedNode, fromNode, toNode;
int nbNodes, radius = 30;

boolean drawLastSavedArcDiagram = false;

// INTERFACE CONTROLLER

ControlP5 cp5;
Numberbox NB;
Toggle TG1, TG2;
Textarea output;
PFont font;
ControlFont C_FONT;

PVector startDrag = new PVector(0, 0), endDrag = new PVector(0, 0);
PVector MIN, MAX;

// FONT

final int FONT_SIZE1 = 15;

// COLORS
final color FOCUSED = #73683B, 
            STANDARD = #566b75, 
            STROKE_FOCUSED = #73683B, 
            STROKE_STANDARD = #566b75;

// FUNCTIONS

void setup () {
  
  background(0);
  fullScreen();
  cp5 = new ControlP5(this);
  
  font = createFont("impact", FONT_SIZE1);
  C_FONT = new ControlFont(font);
  textFont(font);
  textAlign(CENTER);
  cp5.setFont(C_FONT);
  
  strokeWeight(5);
  
  draw = new Draw();
  graph = new Graph();
 
 MIN = new PVector(100, 100);
 MAX = new PVector (width / 3, height  - 100);
 
 draw.setInterface();
}

void draw() {
  background(0);
  
  if (graph.nbNodes > 0) {
    draw.updateGraph();
    focusedNode = draw.focusNode();
    draw.drawArcDiagram(new PVector(width / 2 + 160, height / 2 - 100));
  }
  
  if (TG1.getState() && graph.isAllConnected()) {
    if (!drawLastSavedArcDiagram && graph.sortNodes()) {
      draw.drawArcDiagram(new PVector(width / 2 + 160, height / 2 - 100));
      delay(500);
    }
    else {
      TG1.setValue(false);
      drawLastSavedArcDiagram = true;
    }      
  }
}


void mousePressed() {
    
  if (!TG2.getState()) {
    
    int px = mouseX,
        py = mouseY;
    
    if ( focusedNode != null && draw.withinBoundaries(px, py)) {
      fromNode = focusedNode;
      startDrag.set(px, py);
    }
  }
}

void mouseReleased() {
 
  if (!TG2.getState()) {
    
    int px = mouseX,
        py = mouseY;
    
    if (focusedNode != null && focusedNode != fromNode && draw.withinBoundaries(px, py)) {
      
      toNode = focusedNode;
      endDrag.set(px, py);
      
      Edge edge = new Edge(fromNode, toNode);
      graph.edges.add(edge);
      graph.nbEdges += 1;
      graph.neighbours.get(fromNode).add(toNode); // ADD neighbour
      graph.neighbours.get(toNode).add(fromNode);
      draw.drawEdge(edge);
    }
  }
}

void mouseDragged() {
  
  draw.drag();
}

class Draw {
  
  void setInterface() {
   
    NB = cp5.addNumberbox("Number Of Nodes").setPosition(width / 3 + 100, height / 3).setSize(60, 30)
            .setRange(0, 10)
            .setDirection(Controller.HORIZONTAL)
            
            .setColorActive(color(#73683B))
            .setColorForeground(color(#A79776))
            .setColorLabel(color(#fbe9e7))
            .setColorBackground(color(#424242))
            .setFont(C_FONT);
            
    NB.addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if(theEvent.getAction()==ControlP5.ACTION_RELEASE) {
          nbNodes = int(NB.getValue());
          draw.createGraph();
        }
      }
    });
    
    // Done Editing Graph       
     TG1 = cp5.addToggle("Execute").setPosition(width / 3 + 100, height / 3 - 100).setSize(60, 30)
            .setValue(false)
             
            .setColorActive(color(#73683B))
            .setColorForeground(color(#A79776))
            .setColorLabel(color(#fbe9e7))
            .setColorBackground(color(#424242))
            .setFont(C_FONT);       
            
    // Edit Node or Edges : if set to true : Nodes
    TG2 = cp5.addToggle("Lock Nodes Or Edges").setPosition(width / 3 + 100, height / 3 + 100).setSize(60, 30)
            .setValue(true)
             
            .setColorActive(color(#73683B))
            .setColorForeground(color(#A79776))
            .setColorLabel(color(#fbe9e7))
            .setColorBackground(color(#424242))
            .setFont(C_FONT);
         
    output = cp5.addTextarea("Console").setPosition(width/2 + 100, height/2)
      .setSize(width/2 - 150, height/2 - 100)
      .setLineHeight(14)
      .setColorBackground(color(#263238))
      .setColorForeground(color(#cfd8dc))
      .scroll(0)
      .setScrollBackground(#263238)
      .setFont(C_FONT)
      .setColor(#b0bec5);
      
  cp5.addConsole(output);        
     
 }

 void createGraph() {
   
   Node[] nodes = new Node[nbNodes];
   
   for (int i = 0; i < nbNodes; i++) {
     
     nodes[i] = new Node(int(random(MIN.x, MAX.x)), int(random(MIN.y, MAX.y)), i, i, STANDARD, STROKE_STANDARD);
     this.drawNode(nodes[i], i);
   }
   
   graph = new Graph(nbNodes, nodes);
   
   drawLastSavedArcDiagram = false;
   output.clear();
 }
 
 void drawNode(Node node, int indice){
   
   stroke(node.stroke);
   fill(node.fillColor);
   text(str(indice), node.x - radius, node.y - radius + 2);
   ellipse(node.x, node.y, radius, radius);
 }
 
 void drawEdge(Edge edge) {
   
   fill(STANDARD);
   line(edge.from.x, edge.from.y, edge.to.x, edge.to.y);
 }
 
 void updateGraph() {
   
   for (int i = 0; i < graph.nbEdges; i++) {
     drawEdge(graph.edges.get(i));
   }
   
   for (int i = 0; i < nbNodes; i++) {
     drawNode(graph.nodes[i], graph.nodes[i].indice);
   }
 }


 Node focusNode() {
   
  int px = mouseX, py = mouseY;
  float distX, distY, dist;
  
  this.resetFillColors();
  
  for (int i = 0; i < nbNodes; i++) {
    distX = px - graph.nodes[i].x;
    distY = py - graph.nodes[i].y;
    
    dist = sqrt(pow(distX, 2) + pow(distY, 2));
    
    if (dist < radius){
     graph.nodes[i].stroke = STROKE_FOCUSED;
     graph.nodes[i].fillColor = FOCUSED;
     return graph.nodes[i];
    }
  }
  
  return null;
 }
 
 void drag() {
   
   int px = mouseX, py = mouseY;
   boolean isInBounds = this.withinBoundaries(px, py);
   
   if (focusedNode != null && isInBounds) {
     
     if (TG2.getState()) {  
       
      focusedNode.x = px;
      focusedNode.y = py;
      
     } else {
       
      // DRAG EDGES
      endDrag.set(px, py);
      line(startDrag.x, startDrag.y, endDrag.x, endDrag.y);
     }
   }
 }
 
 public void drawArcDiagram(PVector start) {
   
   Node from, to;
   float x, h, w;
   
   strokeWeight(1.5);
   noFill();
   //stroke(0,150, 255);
   
   float offset = map(nbNodes, 0, 10, -100, -50);
   offset = - offset;
   
   // Base
   line(start.x, start.y, start.x + ( (nbNodes - 1) * offset), start.y);
   
   for (int i = 0; i < nbNodes; i++) {
     graph.nodes[i].abscissa = i;
     point(start.x + (i * offset), start.y);
     text (str(graph.nodes[i].indice), start.x + (i * offset), start.y + 50);
   }
   
   for (int i = 0; i < graph.nbEdges; i++) {
     from = graph.edges.get(i).from;
     to = graph.edges.get(i).to;
     
     //print ("from " +from.indice + " " + from.abscissa + " to " +to.indice + " " + to.abscissa);
     x = from.abscissa * offset;
     
     if (from.abscissa < to.abscissa) {
       w = (to.abscissa * offset) - x;
       h = map(w, offset, (nbNodes - 1) * offset, start.y - 100, start.y);
       arc(start.x + x + w/2, start.y, w, h, -PI, 0); 
     }
     else {
       w = x - (to.abscissa * offset);
       h = map(w, offset, (nbNodes - 1) * offset, start.y - 100, start.y);
       arc(start.x + (to.abscissa * offset) + w/2, start.y, w, h, -PI, 0); 
     }
   }
 }
 
 public void resetFillColors() {
    
    for (Node node : graph.nodes) {
     node.fillColor = STANDARD;
     node.stroke = STROKE_STANDARD;
    }
 }
 
 public boolean withinBoundaries(int px, int py) {
   
   if (px >= MIN.x && px <= MAX.x && py >= MIN.y && py <= MAX.y)
     return true;
     
   return false;
 }
}
