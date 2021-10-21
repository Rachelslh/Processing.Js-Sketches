import java.awt.geom.*;

public class LocalBinaryPatterns {
  
  PImage img, newImg;
  int width, height;
  int R = 1, P = 8, size = 3;
  int[] hist = new int[int(pow(2, P))];
  
  public int[] getHist() {
    return this.hist;
  }
  
  public LocalBinaryPatterns(PImage img, int width, int height) {
    this.img = img;
    this.width = width;
    this.height = height;
    newImg = createImage(img.width - 2, img.height - 2, RGB);
  }

  PImage defaultLBP() {
    
    int v, c = 0;
    int [][] chunk;
    int[] neighbours = new int[P];
    
    for(int x = 1; x < img.width - 1; x++) {
      for(int y = 1; y < img.height - 1; y++) {
        v = img.get(x, y);
        
        chunk = get_chunk(x, y, size);
        neighbours = get_neighbours_ordered(chunk, P, size, 0);
        c = compute_LBP_value(neighbours, v);
        newImg.pixels[(x - 1) + (y - 1) * (img.width - 2)] = color(c);
        hist[c]++;
      }
    }
    
    return newImg;
  }
  
  
  PImage circularLBP_81() {
    
    int cx = 1, cy = 1, v, c = 0;
    float Theta, val;
    int[][] chunk;
    int[] neighbours = new int[P];
    // Array of neighbours coordinates
    Point2D.Float[] coord = new Point2D.Float[P];
    
    
    //Reinitilize the capacity of hist if i ever decide to program for a bigger P and Radius
    hist = new int[int(pow(2, P))];
    
    for(int x = 1; x < img.width - 1; x++) {
      for(int y = 1; y < img.height - 1; y++) {
        
        v = img.get(x, y);
        
        chunk = get_chunk(x, y, size);
        neighbours = get_neighbours_ordered(chunk, P, size, 1);
        
        // Find coordinates of each neighbour
        for (int i = 0; i < P; i++){
          coord[i] = new Point2D.Float();
          coord[i].x = cx - R * sin(2 * PI * i / P);
          coord[i].y = cy + R * cos(2 * PI * i / P);
          
          // round to 4 digits after comma
          coord[i].x = float(nf(coord[i].x, 0, 4));
          coord[i].y = float(nf(coord[i].y, 0, 4));
          
          // Verify if fractional part == 0, otherwise the point needs interpolation
          float x_fract = coord[i].x - int(floor(coord[i].x));
          float y_fract = coord[i].y - int(floor(coord[i].y));
          //println(x_fract, y_fract);
          if (x_fract != 0 || y_fract != 0) {
            //interP.add(i);
            Theta = 2 * PI * i / P;
            Points points = unit_square_81(Theta, v, neighbours);
            val = bilinear_interpolation(coord[i], points);
            neighbours[i] = int(val);
          }
        }
        
        /* Interpolate needed points
        for (int i = 0; i < interP.size(); i++) {
          
          indice = interP.get(i);//println(indice);
          Theta = 2 * PI * indice / P;
          Points points = unit_square_81(Theta, v, neighbours);
          val = bilinear_interpolation(coord[indice], points);
          neighbours[indice] = int(val);
        }
        */
        // Calulate LBP value
        c = compute_LBP_value(neighbours, v);
        
        newImg.pixels[(x - 1) + (y - 1) * (img.width - 2)] = color(c);
        hist[c]++;
      }
      
    }
    
    return newImg;
  }
  
  
  int[][] get_chunk(int x, int y, int size) {
    //println("chunk");
    int[][] chunk = new int[size][size];
    
    for (int i = 0; i < size; i++) {
     
      chunk[i][0] = img.get(x - 1 + i, y - 1);
      chunk[i][1] = img.get(x - 1 + i, y);
      chunk[i][2] = img.get(x - 1 + i, y + 1);
      //println(chunk[i][0], chunk[i][1], chunk[i][2]);
    }
    
    return chunk;
  }
  
  
  int[] get_neighbours_ordered(int[][] chunk, int P, int size, int counterClockWise) {
    //println("neighbours");
    int[] neighbours = new int[P];
    int x, y;
    
    x = 2;
    y = 1;
    
    for (int i = 0; i < P; i++) {
      
      neighbours[i] = chunk[x][y];
      //println(neighbours[i]);
      switch(counterClockWise) {
        
        case 0:  
          if (x == size - 1 && y < size - 1)
            y ++;
          else if (x > 0 && y == size - 1)
            x --;
          else if (x == 0 && y > 0)
            y --;
          else if (x < size - 1 && y == 0)
            x ++;
            
          break;
            
        case 1:
          if (x == size - 1 && y > 0)
            y --;
          else if (x > 0 && y == 0)
            x --;
          else if (x == 0 && y < size - 1)
            y ++;
          else if (x < size - 1 && y == size - 1)
            x ++;
            
          break;
      }
      
    }
    
    return neighbours;
  }
  
  
  int compute_LBP_value(int[] neighbours, int v) {
    
    int c = 0;
    
    for(int i = 0; i < neighbours.length; i++) {
      
      if (neighbours[i] >= v) // It's 1, Otherwise 0
        c += pow(2, i);
    }
    //println("LBP value", c);
    return c;
  }
  
  Points unit_square_81(float Theta, int v, int[] neighbours) {
    
    int Q11 = 0, Q12 = 0, Q21 = 0, Q22 = 0;
    int x1, x2, y1, y2;
    
    x1 = 0;
    y1 = 0;
    
    x2 = 1;
    y2 = 1;
    
    if (Theta >= 0 && Theta <= PI / 2) {
      Q11 = v;
      Q12 = neighbours[2];
      Q21 = neighbours[0];
      Q22 = neighbours[1];
      
    } else if (Theta > PI / 2 && Theta <= PI) {
      
      Q11 = neighbours[4];
      Q12 = neighbours[3];
      Q21 = v;
      Q22 = neighbours[2];
      
    } else if (Theta > PI && Theta <= 3 * PI / 2) {
      
      Q11 = neighbours[5];
      Q12 = neighbours[4];
      Q21 = neighbours[6];
      Q22 = v;
      
    } else if (Theta > 3 * PI / 2 && Theta <= 2 * PI) {
      
      Q11 = neighbours[6];
      Q12 = v;
      Q21 = neighbours[7];
      Q22 = neighbours[0];
      
    }
    
    return new Points(Q11, Q12, Q21, Q22, x1, y1, x2, y2);
    
  }
  
  float bilinear_interpolation(Point2D.Float p, Points points) {
    
    int Q11 = points.Q11, Q12 = points.Q12, Q21 = points.Q21, Q22 = points.Q22;
    int x1 = points.x1, x2 = points.x2, y1 = points.y1, y2 = points.y2;
    float x = p.x, y = p.y;
    
    return (Q11 * (x2 - x) * (y2 - y) + Q21 * (x - x1) * (y2 - y) + Q12 * (x2 - x) * (y - y1) + Q22 * (x - x1) * (y - y1)) / ((x2 - x1) * (y2 - y1));
  }
 
}

class Points {
  int Q11, Q12, Q21, Q22;
  int x1, x2, y1, y2;
  
  Points(int Q11, int Q12, int Q21, int Q22, int x1, int y1, int x2, int y2) {
    this.Q11 = Q11;
    this.Q12 = Q12;
    this.Q21 = Q21;
    this.Q22 = Q22;
    
    this.x1 = x1;
    this.y1 = y1;
    
    this.x2 = x2;
    this.y2 = y2;
  }
  
}
