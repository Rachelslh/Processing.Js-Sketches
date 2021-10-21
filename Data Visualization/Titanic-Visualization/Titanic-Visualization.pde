

int[] compartiments = { 1, 2, 3 };
   
String[] classes = {
        "female", 
        "male", 
        "child"
      },
      categories = {"Survivers", "Victims"};

Table rawData;
IntDict surv_data = new IntDict(), vict_data = new IntDict();
int width = 1200, height = 800, totalP;
PFont f;
int[] colorsClass = {#984447, #B96467, #CC8E90}, 
      colorsComp = {#9C7A97, #BAA1B6, #D4C4D1},
      colorsBI = {#F6E4DF, #DB5461};

void initVars() {
  
  for (int comp : compartiments){
    for (String clas : classes){
      String key = comp + ' ' + clas;
      surv_data.set(key, 0);
      vict_data.set(key, 0);
    }
  }
} 


void setup() {
  size(1200, 800);
  f = createFont("Impact", 20);
  textFont(f);
  textAlign(CENTER);
  
  rawData = loadTable("Titanic.csv", "header");
  totalP = rawData.getRowCount();
  println(totalP + " total rows in the Titanic dataset");
  initVars();
  
  for (TableRow row : rawData.rows()) {

    int age = row.getInt("age");
    String sex = row.getString("sex");
    int survived = row.getInt("survived"); // if 0 : victim, otherwise : survivor
    int pclass = row.getInt("pclass");     // 1 -> first class and so on
    
    if (age < 18) sex = "child";
    String key = pclass + ' ' + sex;
    if (survived == 1)
      surv_data.set(key, surv_data.get(key) + 1);
    else
      vict_data.set(key, vict_data.get(key) + 1);
  }
  
  /*
  int all = 0;
  for (int comp : compartiments){
    for (String clas : classes){
      println("hi");
      String key = comp + ' ' + clas;
      println(surv_data.get(key), vict_data.get(key)); //<>//
      all += surv_data.get(key) + vict_data.get(key);
    }
  }
  println(all);
  */
}

void draw() {
  
  String key;
  float len1, len2, len3, add1 = 0, add2 = 0;
  int surv, vict, total = 0, size;
  
  len1 = compartiments.length;
  len2 = classes.length;
  len3 = len1 * len2;
  
  int x = width / 2, y = height / 2;
  float x1, y1; 
  
  background(0);
  
  stroke(255);
  strokeWeight(2);
  
  for (int i = 0; i < compartiments.length; i++) {
    for(int j = 0; j < classes.length; j++){
      
      key = compartiments[i] + ' ' + classes[j];
      
      surv = surv_data.get(key);
      vict = vict_data.get(key);
      total += vict;
      
      // survived arc
      size = surv * 100 / totalP;
      x1 = x + (400 + 20 * size) / 2 * cos(add2);
      y1 = y + (400 + 20 * size) / 2 * sin(add2);
      fill(colorsBI[0]);
      
      arc(x, y, 400 + 20 * size, 400 + 20 * size, add2, (PI / len3) + add2);
      line( x, y, x1, y1);
      
      ellipse(x1, y1 - 10, 50, 50);
      fill(0);
      text(surv, x1, y1);
      
      // victim arc
      size = vict * 100 / totalP;
      x1 = x + (400 + 20 * size) /2 * cos((PI / len3) + add2);
      y1 = y + (400 + 20 * size) / 2 * sin((PI / len3) + add2);
      fill(colorsBI[1]);
      
      arc(x, y, 400 + 20 * size, 400 + 20 * size, (PI / len3) + add2, 2 * (PI / len3) + add2);
      line( x, y, x1, y1);
      
      ellipse( x1, y1 - 10, 50, 50);
      fill(0);
      text(vict, x1, y1);

      //female, male, child arcs
      size = vict * 100 / totalP;
      x1 = x + ( 300 + size) / 2 * cos((2 * PI * j / len3) + add1);
      y1 =  y + ( 300 + size) / 2 * sin((2 * PI * j / len3) + add1);
      fill(colorsClass[j]);
      
      arc(x, y, 300 + size, 300 + size,  (2 * PI * j / len3) + add1, (2 * PI * (j + 1) / len3) + add1);
      line( x, y, x1, y1);
      
      add2 += 2 * PI / len3;
    }
    
    // comp arc
    size =  total * 100 / totalP;
    fill(colorsComp[i]);
    arc(x, y, size + 100, size + 100, 2 * PI * i / len1 , 2 * PI * (i + 1) / len1);
    line( x, y, x + 50 * cos(2 * PI * i / len1), y + 50 * sin(2 * PI * i / len1));
    
    add1 += 2 * PI / len1;
  }
  
  // Draw the first ellipse cuz it's overdrawn with another one
  surv = surv_data.get(compartiments[0] + ' ' + classes[0]);
  size = surv * 100 / totalP;
  x1 = x + (400 + 20 * size) / 2 * cos(0);
  y1 = y + (400 + 20 * size) / 2 * sin(0);
  fill(#F6E4DF);
  ellipse(x1, y1 - 10, 50, 50);
  fill(0);
  text(surv, x1, y1);
  
  colorCode();
  
  noLoop(); 
}

void colorCode(){
  
  for (int i = 0; i < compartiments.length; i++) {
      fill(colorsComp[i]);
      rect(50, i * 50 + 100, 50, 50, 5);
      text(compartiments[i] + " Class", 150, i * 50 + 130);
  }
  
  for(int i = 0; i < classes.length; i++){
      fill(colorsClass[i]);
      rect(50, i * 50 + 100 * compartiments.length, 50, 50, 5);
      text(classes[i], 150, i * 50 + 100 * compartiments.length + 30);
  }
  
  for(int i = 0; i < colorsBI.length; i++){
      fill(colorsBI[i]);
      rect(50, i * 50 + 100 * (compartiments.length + classes.length - 1), 50, 50, 5);
      text(categories[i], 150, i * 50 + 100 * (compartiments.length + classes.length - 1) + 30);
  }
  
}
