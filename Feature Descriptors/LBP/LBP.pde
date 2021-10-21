

LocalBinaryPatterns LBP;
Histogram HC;
PImage img, newImg;
HashMap<Integer, int[]> histList = new HashMap();
float minError = Integer.MAX_VALUE;


void setup() {
  fullScreen();
  background(0);
  img = loadImage("img.jpg");
  img.resize(img.width / 4, img.height / 4);
  img.filter(GRAY);
  
  LBP = new LocalBinaryPatterns(img, width, height);
  HC = new Histogram();
}


void draw() {
  PImage temp;
  int threshold = img.width / 2 + 10, sizeRegion = 32; // SizeRegion add 2 becuz of neighbours 
  int[] total_hist;
  
  println("Loading...");
  
  // Calculate LBP of the entire image
  newImg = LBP.defaultLBP();
  //LBP.circularLBP_81();
  
  total_hist = LBP.getHist();
  
  println("Image LBP Calculated.");
  
  // Calculate LBP per bock of 10 * 10
  for(int x = 0; x < img.width; x++) {
    for(int y = 0; y < img.height; y++) {
      
      if ( (x + sizeRegion - 1) < img.width && (y + sizeRegion - 1) < img.height) {  
        
        temp = img.get(x, y, sizeRegion, sizeRegion);
        LBP = new LocalBinaryPatterns(temp, sizeRegion, sizeRegion);
        LBP.defaultLBP();
        histList.put(x + y * img.width, LBP.getHist());
      }
    }
  }
  
  println("LBP Per Regions Calculated.");
  
  int i = HC.pickRandomRegion(histList);
  int j = HC.searchAlikeHist(histList, i);
  
  println("Loading LBP Comparison Results...");
  
  HC.colorRegion(img, i, sizeRegion, color(255, 0, 0));
  HC.colorRegion(img, j, sizeRegion, color(0, 0, 255));
  
  // Drawing
  image(img, width / 4 - (img.width / 2), 50);
  
  // LBP Image
  image(newImg, 3 * width / 4 - (img.width / 2), 53);
  HC.draw_histogram(total_hist, width / 4 + threshold, 3 * width / 4 - threshold, 50 + img.height, 50);
  
  HC.draw_histogram(histList.get(i), width / 4 - threshold, width / 4 + threshold, height - 50, img.height + 100);
  HC.draw_histogram(histList.get(j), 3 * width / 4 - threshold, 3 * width / 4 + threshold, height - 50, img.height + 100);
  
  textSize(15);
  text("Chosen Region", width / 4, height - 30);
  text("Predicted Region", 3 * width / 4, height - 30);
  text("MSE = " + minError, 3 * width / 4, height - 15);
  
  println("Completed.");
  
  noLoop();
}

class Histogram {
  
  int searchAlikeHist(HashMap<Integer, int[]> histList, int indice) {
    
    int[] hist = histList.get(indice), histTemp;
    HashMap<Integer, Float> histMSE = new HashMap();
    int Tindice = indice, temp = 0;
    float MSE = Integer.MAX_VALUE;
    
    // Calculate mean square error for each hist
    for (int key : histList.keySet()) {
      
      if (key != indice) {
        histTemp = histList.get(key);
        
        for (int j = 0; j < 256; j++) {
          temp += pow(hist[j] - histTemp[j], 2);
        }
        
        MSE = temp / 256;
        histMSE.put(key, MSE);
        
        if (MSE < minError) {
          minError = MSE;
          Tindice = key;
          println(minError);
        }
        
        temp = 0;
      }
    }
    return Tindice;
  }
  
  
  void draw_histogram(int[] hist, int x0, int x1, int y1, int y0) {
    
    int histMax = max(hist);
  
    stroke(255);
    for (int i = x0; i < x1; i++) {
      int which = int(map(i, x0, x1, 0, 255));
      int y = int(map(hist[which], 0, histMax, y1, y0));
      line(i, y1, i, y - 10);
    }
  }
  
  
  int pickRandomRegion(HashMap<Integer, int[]> histList) {
    
    ArrayList<Integer> a = new ArrayList(histList.keySet());
    int rand = (int) random(a.size());
    
    return a.get(rand);
  }
  
  
  void colorRegion(PImage img, int loc, int sizeRegion, color c) {
    
    int x = loc % img.width;
    int y = loc / img.width;
    
    img.loadPixels();
    
    for (int i = x; i < x + sizeRegion; i++){
      img.pixels[i + y * img.width] = c;
      img.pixels[i + (y + sizeRegion - 1) * img.width] = c;
    }
    
    for (int i = y; i < y + sizeRegion; i++){
      img.pixels[x + i * img.width] = c;
      img.pixels[(x + sizeRegion - 1) + (i * img.width)] = c;
    }
    
  }
  
}
