class MatToTree{
  
  int caseDepart, caseArrive;
  LinkedList<Cell> cells, preCells, cellsCout, chemin  = null;
  int i , j, initX, initY, mode, cout;
  boolean found = false;
  
  MatToTree(int[][] mat, int caseDepart, int caseArrive, int initX, int initY, int mode){
    this.caseDepart = caseDepart;
    this.caseArrive = caseArrive;
    this.mode = mode;
    i = initX;
    j = initY;
    this.initX = initX;
    this.initY = initY;
    
    if(mode == 0)
      println(cheminAbsolu = buildFile(mat));
    else if (mode == 1)
      println(cheminAbsolu = buildPile(mat));
    else if (mode == 2)
      println(cheminAbsolu = buildCoutUniforme(mat));
          
  }

  LinkedList buildFile(int[][] mat){
    
    if(mat[initX][initY] == 3) found = true;
    else {
      
      cells = new LinkedList();
      preCells = new LinkedList();
      Cell c = new Cell(initX, initY, 0, 0);
      cells.add(c);    
      preCells.add(c);  
    
      do{
      
        if(mat[i][j] == 3) found = true;
        else {
          tryCatch(mat, i, j-1 , i, j, "Left ");
          tryCatch(mat, i-1, j ,i ,j , "Up ");
          tryCatch(mat, i, j+1 ,i ,j , "Right ");
          tryCatch(mat, i+1, j ,i ,j , "Down ");
      
          println("Previous Head "+cells.get(0).x+"  "+cells.get(0).y);
          cells.remove(cells.get(0));
          i = cells.get(0).x;
          j = cells.get(0).y;
          println("Current Head "+i+"  "+j);
        }
      } while(cells.size() > 0 && !found);
    }
    if(found)
      return chemin = returnTheWay(mat, new Cell(i, j, (cells != null)? (cells.get(0).Px) : (-1), (cells != null) ? (cells.get(0).Py) : (-1)), chemin, preCells);
      
    return null;  
  }
  
  LinkedList buildPile(int[][] mat){
    
    if(mat[initX][initY] == 3) found = true;
    else {
      cells = new LinkedList();
      preCells = new LinkedList();
      Cell c = new Cell(initX, initY, 0, 0);
      cells.push(c);
      preCells.add(c);  
    
      while(cells.size() > 0 && !found){
     
        c = cells.pop();
        
        tryCatch(mat, i, j-1 ,i ,j , "Left ");
        tryCatch(mat, i-1, j ,i ,j , "Up ");
        tryCatch(mat, i, j+1 ,i ,j , "Right ");
        tryCatch(mat, i+1, j ,i ,j , "Down ");
      
        if(mat[i][j-1] == 3 || mat[i-1][j] == 3 || mat[i][j+1] == 3 || mat[i+1][j] == 3) found = true;
        
        println("Previous Head "+c.x+"  "+c.y);
        i = cells.getFirst().x;
        j = cells.getFirst().y;
        println("Current Head "+i+"  "+j);
      }
    }
    if(found)
      return chemin = returnTheWay(mat, new Cell(i, j, (cells != null)? (cells.get(0).Px) : (-1), (cells != null) ? (cells.get(0).Py) : (-1)), chemin, preCells);
      
    return null;  
  }
  
  LinkedList buildCoutUniforme(int[][] mat){
    Cell c = new Cell(initX, initY, 0, 0);
    
    if(mat[initX][initY] == 3) found = true;
    else {
      
      cellsCout = new LinkedList();
      preCells = new LinkedList();
      c.setCout(0);
      cellsCout.add(c);
      preCells.add(c);
    
      do{
      
        println("Previous Head "+cellsCout.get(0).x+"  "+cellsCout.get(0).y);
        for(Cell o : cellsCout){
          if(o.cout < c.cout)
            c = o;
        }
        cellsCout.remove(c);
        
        if(mat[c.x][c.y] == 3) found = true;
        else {
          cout = c.cout;
          tryCatch(mat, i, j-1 ,i ,j , "Left ");
          tryCatch(mat, i-1, j ,i ,j , "Up ");
          tryCatch(mat, i, j+1 ,i ,j , "Right ");
          tryCatch(mat, i+1, j ,i ,j , "Down ");
        
          if(cellsCout.size() > 0){
            c = cellsCout.get(0);
            i = cellsCout.get(0).x;
            j = cellsCout.get(0).y;
            println("Current Head "+i+"  "+j);
          }
        } 
      }while(cellsCout.size() > 0 && !found);
    }
    if(found){
      return chemin = returnTheWay(mat, c, chemin, preCells);}
    return null;
  }
  
  void tryCatch(int[][] mat, int i, int j,int Pi, int Pj, String str){
    
    try{
        if(mat[i][j] != 1) {
          Cell c = new Cell(i, j, Pi, Pj);
          if(!containsCell(c)) {
            c = addOrPush(mode, c);
            println(str+ c.x +" "+c.y);
          }  
        }
    }
    catch(IndexOutOfBoundsException e){
      e.printStackTrace();
    }
  }
  
  Cell addOrPush(int mode, Cell c){
    
    if(mode == 0)
      cells.add(c);
    else if(mode == 1)
      cells.push(c);
    else{
      c.setCout(cout + 1);
      cellsCout.add(c); 
    } 
    preCells.add(c);
    return c;
  }
  
  boolean containsCell(Cell c){
    
    for(int g = 0; g < preCells.size(); g++){
        if(preCells.get(g).x == c.x && preCells.get(g).y == c.y)
          return true;
    }
    return false;  
  }
  
  LinkedList returnTheWay(int mat[][], Cell c, LinkedList<Cell> chemin, LinkedList<Cell> preCells){
   
    if(mat[initX][initY] == 3) return null;
    chemin = new LinkedList();
    do{
      chemin.add(c);
      for(int k = 0; k < preCells.size() ; k++){
        Cell o = preCells.get(k);
        if(o.x == c.Px && o.y == c.Py){
          c = new Cell(o.x, o.y, o.Px, o.Py);
          break;
        }
      }
        
    } while(c.x != initX || c.y != initY);
      
    chemin.remove(chemin.get(0));
    return chemin; 
  }
 
}
