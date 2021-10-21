import java.util.Map;


public class HOG_descriptor {
 
  private PVector vertical_kernel, horizontal_kernel;
  private int blocSize, cellSize, regionSize;
  private int blocCounter = 0;
  private HashMap<Integer, ArrayList<Histogram>> histList;
  
 
  public HOG_descriptor(int rectSize, int blocSize, int classN, float maxAngle) {
    
    vertical_kernel = new PVector(-1, 0, 1);
    horizontal_kernel = new PVector(-1, 0, 1); // transpose
    this.blocSize = rectSize;
    this.cellSize = blocSize;
    regionSize = 3; // 3 * 3
    
    Histogram.binsN = classN;
    Histogram.maxAngle = maxAngle;
    
    histList = new HashMap();
    
    println("HOG Descriptor Initialized");
  }
  
  
  public PImage extract_features_HOG(PImage img) {
    
    PImage Block;
    ArrayList<Histogram> histsPerBloc; // Contains all histograms of each cell/bloc
    int w, h;
    
    w = img.width;
    h = img.height;
    
    for(int x = 0; x < w; x += int(blocSize / 2)) {
      for (int y = 0; y < h; y += int(blocSize / 2)) {
        
        if ( (x + blocSize <= w) && (y + blocSize <= h) ) {
          Block = img.get(x, y, blocSize, blocSize);
          histsPerBloc = HOG_per_cell(Block);
          histList.put(blocCounter, histsPerBloc);
          // Normalize Block
          //normalize();
          blocCounter ++;
          
          println("  HOG features extracted for block N " + blocCounter + " at point ( " + x + ", " + y + " ).");
        }
        else 
          break;
      }
    }
    
      return img;
  }
  
  
  private ArrayList<Histogram> HOG_per_cell(PImage bloc) {
    
    PImage cell;
    ArrayList<Histogram> histsPerBlock = new ArrayList();
    Histogram hist;
    
    for (int x = 0; x < bloc.width; x += cellSize) {
      for (int y = 0; y < bloc.height; y += cellSize) {
        
        cell = bloc.get(x, y, cellSize, cellSize);
        hist = HOG_per_region(cell);
        histsPerBlock.add(hist);
      }
    }
    
    return histsPerBlock;
  }
  
  
  private Histogram HOG_per_region(PImage cell) {
    
    PImage region;
    PVector gradient;
    float magnitude, orientation;
    Histogram hist = new Histogram();
    HashMap<Integer, Float> hm = hist.getHashMap();
    
    for (int x = 0; x < cell.width; x += regionSize) {
      for (int y = 0; y < cell.height; y += regionSize) {
        
        region = cell.get(x, y, regionSize, regionSize);
        gradient = estimate_gradient(region);
        magnitude = estimate_magnitude(gradient);
        orientation = estimate_orientation(gradient);
        
        hm = hist.update_histogram(hm, orientation, magnitude); // hist.update_histogram2(hm, orientation);
      }
    }
    
    return hist;
  }
  
  
  private void normalize() {
  
    ArrayList<Histogram> a = histList.get(blocCounter);
    float k = 0;
    Histogram h;
    
    for (int i = 0; i < pow(blocSize / cellSize, 2); i++) {
      
      h = a.get(i);
      for (Map.Entry entry : h.getHashMap().entrySet()) {
        k += pow((float) entry.getValue(), 2);
      }
    }
    
    k = sqrt(k);
    
    for (int i = 0; i < pow(blocSize / cellSize, 2); i++) {
      
      h = a.get(i);
      for (Map.Entry entry : h.getHashMap().entrySet()) {
        h.getHashMap().put( (int)entry.getKey(), (float) entry.getValue() / k );
      }
    }
    
    println ("Block normalized");
  }
  
  
  // Estimate gradient of  3 * 3 region
  private PVector estimate_gradient(PImage region) {
    
    PVector V, H;
    PVector gradient = new PVector();
    
    H = new PVector(region.get(0, 1), region.get(1,1), region.get(2, 1));
    V = new PVector(region.get(1, 0), region.get(1,1), region.get(1, 2));
    
    gradient.x = H.dot(horizontal_kernel);
    gradient.y = V.dot(vertical_kernel);
    
    return gradient;
  }
  
  
  private float estimate_magnitude(PVector gradient) {
    
    return sqrt(pow(gradient.x, 2) + pow(gradient.y, 2));
  }
  
  
  private float estimate_orientation(PVector gradient) {
    
    return atan(gradient.y / gradient.x);
  }
  
}



static class Histogram {
  
  private HashMap<Integer, Float> hashMap;
  public static float maxAngle;
  public static int binsN = 9, intervalLength;
 
  
  public Histogram() {
    
    intervalLength = int(maxAngle / binsN);
    
    hashMap = new HashMap();
    
    for (int i = 0; i < binsN; i++) {
      hashMap.put(i * intervalLength, 0f);
    }
  }
  
  
  HashMap<Integer, Float> getHashMap() {
   
    return hashMap;
  }
  
  // orientation and magnitude -based method
  HashMap<Integer, Float> update_histogram(HashMap<Integer, Float> hm, float orientation, float magnitude) {
    
    float diff1, diff2, contrib1, contrib2;
    int keyHM;
    
    orientation = degrees(orientation);
    if (orientation < 0)
      orientation += 360;
    
    for(int i = 1; i < Histogram.binsN; i++) {
      
      keyHM = i * Histogram.intervalLength;
        
      if (orientation < keyHM) {
      
        // assign magnitude
        diff1 = abs(keyHM - orientation);
        diff2 = abs(keyHM - Histogram.intervalLength - orientation);
            
        contrib1 = abs(keyHM - orientation) / Histogram.intervalLength;
        contrib2 = abs(keyHM - Histogram.intervalLength - orientation) / Histogram.intervalLength;
            
        if (diff2 > diff1) { // See which bin is closer
          hm.put(keyHM, hm.get(keyHM) + max(contrib1, contrib2) * magnitude);
          hm.put(keyHM - Histogram.intervalLength, hm.get(keyHM - Histogram.intervalLength) + min(contrib1, contrib2) * magnitude);
        } else {
          hm.put(keyHM, hm.get(keyHM) + min(contrib1, contrib2) * magnitude);
          hm.put(keyHM - Histogram.intervalLength, hm.get(keyHM - Histogram.intervalLength) + max(contrib1, contrib2) * magnitude);
        }
        break;    
      }
    }
    return hm;
  }
  
  // Orientation-based method
  HashMap<Integer, Float> update_histogram2(HashMap<Integer, Float> hm, float orientation) {
    
    int keyHM;
    
    orientation = degrees(orientation);
    if (orientation < 0)
      orientation += 360;
    
    for(int i = 0; i < Histogram.binsN; i++) {
      keyHM = i * Histogram.intervalLength;
      if (orientation < keyHM + Histogram.intervalLength) {
        hm.put(keyHM, hm.get(keyHM) + 1);
        break;
      }
    }
    
    return hm;
  }
  
}
