
public class AStar {
  
  Matrix startGame, endGame;
  LinkedList<Matrix> open, closed, path = null; 
  Matrix succ[] = new Matrix[4];
  int heuristic;
  
  //LOCATIONS to help us find the succeeders
  
  final PVector UP = new PVector( -1, 0 );
  final PVector LEFT  = new PVector( 0, -1 );
  final PVector DOWN = new PVector( +1, 0 );
  final PVector RIGHT  = new PVector( 0, +1 );
  
  /**
  * AStar()
  * This function is a constructor for this current class
  */
  public AStar( Matrix startGame, Matrix endGame, int heuristic ) {
    
    this.startGame = startGame;
    this.endGame = endGame;
    open = new LinkedList();
    closed = new LinkedList();
    this.heuristic = heuristic;
  }
  
  /**
  * findPath()
  * This function applies the algorithm of A* on the matrix 'startGame' in order to find the target matrix 'endGame'
  */
  public LinkedList<Matrix> findPath() {
    
    DEB =  millis();
    
    if(startGame.equalValues( endGame)) {
      
      path = new LinkedList();
      path.add( startGame ); path.add( endGame );
      FIN = millis();
      return path;
    }
    else {
      
      open.add(startGame);
      Matrix M = new Matrix(0, 0, null, null, null), temp1 = null, temp2 = null;
      int l;
      
      while( !open.isEmpty() ) {
        
        M = M.minF(open);
        open.remove(M);
        closed.add( M );
        l = sense( M );
        
        for( int d = 0; d < l; d++ ) {
          
          if(heuristic == 0) 
            succ[d].countHeu( endGame ); 
          else
            succ[d].countHeuManhattan( endGame );
          succ[d].cost = M.cost + 1;
         
          if( endGame.equalValues(succ[d]) ) {
            endGame = succ[d];
            FIN =  millis();
            return path = buildTheWay();
          }
          
          temp1 = containsMatrix( open, succ[d] );
          temp2 = containsMatrix( closed, succ[d] );
          
          if( temp1 == null )
            open.add( succ[d] );
          else if(temp1.countF() > succ[d].countF() ) 
            open.set( open.indexOf(temp1), succ[d]);
          else if( temp2 != null && succ[d].countF() < temp2.countF() ) {
            closed.remove(temp2);
            open.add(temp2);
          }
        }
      }
    }
    return null;
  }
  
  //------------------------------------------------------------------------------
  
  /**
  * containsMatrix()
  * This function returns the Matrix if it's contained in the list else it returns null
  */
  private Matrix containsMatrix( LinkedList<Matrix> list, Matrix M ) {
   
    for( int j = 0; j < list.size(); j++ ) {
      if( M.equalValues(list.get(j)))
        return list.get(j);
    }
    return null;
  }
  
  /**
  * buildTheWay()
  * This function returns the way from startGame to endGame
  */
  private LinkedList buildTheWay() {
   
    path = new LinkedList();
    Matrix P = endGame;
    int k = 0;
    path.add( endGame );
    closed.remove(endGame);
    
    while( !startGame.equalMat(P.pMatrix) && k < closed.size()) {
     
      if( closed.get(k).equalMat(P.pMatrix) ) {
        path.add( closed.get(k) );
        P = closed.get(k);
        closed.remove(P);
        k = -1;
      }
      k++;
    }
    path.add(startGame);
    return path;
  }
  
  /**
  * validCell()
  * This function returns true if the argument (x,y) coordinates are valid within 
  * matrix's coordinate system.
  */
  private boolean validCell( Matrix M, int x, int y ) {
    if (( x >= 0 ) && ( x < M.MAX_X ) && ( y >= 0 ) && ( y < startGame.MAX_Y )) 
      return( true );
    else
      return( false );
  }
  
  private int[][] cloneMatrixValues( Matrix M ) {
    
    int[][] M1 = new int[M.MAX_X][M.MAX_Y];
    for( int i = 0; i < M.MAX_X; i++ ) {
      for( int j = 0; j < M.MAX_Y; j++ ) {
        M1[i][j] = M.matrix[i][j];
      }
    }
    
    return M1;
  }

 /**
 * sense()
 * This function emulates the operation of searching for succeeders
 */
  private int sense( Matrix M ) {
    
    Matrix M1 = new Matrix(M.MAX_X, M.MAX_Y, M.R, cloneMatrixValues(M), M);
    int i = 0, cell_x, cell_y;
    
    // check the cell to the north of the Empty Cell
    cell_x = int( M.R.x + UP.x );
    cell_y = int( M.R.y + UP.y );
    
    if ( validCell( M, cell_x, cell_y )) {
      M1.matrix[int(M1.R.x)][int(M1.R.y)] = M1.matrix[cell_x][cell_y];
      M1.matrix[cell_x][cell_y] = 0;
      M1.R = new PVector( cell_x, cell_y );
      println("UP    : Matrix ["+(int)M1.R.x+"]  ["+(int)M1.R.y+"]");
      succ[i] = M1;
      i++;
      
    } 
     
    // check the cell to the west of the Empty Cell
    cell_x = int( M.R.x + LEFT.x );
    cell_y = int( M.R.y + LEFT.y );
    
    M1 = new Matrix(M.MAX_X, M.MAX_Y, M.R, cloneMatrixValues(M), M);
    if ( validCell( M, cell_x, cell_y )) {
      
      M1.matrix[int(M1.R.x)][int(M1.R.y)] = M1.matrix[cell_x][cell_y];
      M1.matrix[cell_x][cell_y] = 0;
      M1.R = new PVector( cell_x, cell_y );
      println("LEFT  : Matrix ["+(int)M1.R.x+"]  ["+(int)M1.R.y+"]");
      succ[i] = M1;
      i++;
      
    }
      
    // check the cell to the south of the Empty Cell
    cell_x = int( M.R.x + DOWN.x );
    cell_y = int( M.R.y + DOWN.y );
    
    M1 = new Matrix(M.MAX_X, M.MAX_Y, M.R, cloneMatrixValues(M), M);
    if ( validCell( M, cell_x, cell_y )) {
      
      M1.matrix[int(M1.R.x)][int(M1.R.y)] = M1.matrix[cell_x][cell_y];
      M1.matrix[cell_x][cell_y] = 0;
      M1.R = new PVector( cell_x, cell_y );
      println("DOWN  : Matrix ["+(int)M1.R.x+"]  ["+(int)M1.R.y+"]");
      succ[i] = M1;
      i++;
      
    }
      
    // check the cell to the east of the Empty Cell
    cell_x = int( M.R.x + RIGHT.x );
    cell_y = int( M.R.y + RIGHT.y );
    
    M1 = new Matrix(M.MAX_X, M.MAX_Y, M.R, cloneMatrixValues(M), M);
    if ( validCell( M, cell_x, cell_y )) {
      
      M1.matrix[int(M1.R.x)][int(M1.R.y)] = M1.matrix[cell_x][cell_y];
      M1.matrix[cell_x][cell_y] = 0;
      M1.R = new PVector( cell_x, cell_y );
      println("RIGHT : Matrix ["+(int)M1.R.x+"]  [" +(int)M1.R.y+"]");
      succ[i] = M1;
      i++;
      
    }
    
    return i;
  }
  
}
  
