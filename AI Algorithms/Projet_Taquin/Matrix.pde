import java.util.*;

public class Matrix {
  
  int MAX_X, MAX_Y, H = 0, cost = 0;
  PVector R;  //The Empty Cell's coordinates inside the matrix
  int[][] matrix;
  Matrix pMatrix;
  
  public Matrix( int MAX_X, int MAX_Y, PVector R, int[][] matrix, Matrix pMatrix ) {
    
    this.MAX_X = MAX_X;
    this.MAX_Y = MAX_Y;
    this.R = R;
    this.matrix = matrix;
    this.pMatrix = pMatrix;
  }
  
  public int countF() {
    return H + cost;
  }
  
  public boolean equalValues( Matrix M2 ) {
    
    for( int i = 0; i<MAX_X; i++ ) {
      for( int j = 0; j<MAX_Y; j++ ) {
        if(this.matrix[i][j] != M2.matrix[i][j])
          return false;
      }
    }
    return true;
  }
  
  public boolean equalMat( Matrix M2 ) {
    
    if( this.countF() != M2.countF() ) return false;
    
    for( int i = 0; i<MAX_X; i++ ) {
      for( int j = 0; j<MAX_Y; j++ ) {
        if(this.matrix[i][j] != M2.matrix[i][j])
          return false;
      }
    }
    return true;
  }
  
  
  public int countHeu( Matrix target ) {
  
    for( int i = 0; i<MAX_X; i++ ) {
      for( int j = 0; j<MAX_Y; j++ ) {
        if(this.matrix[i][j] != target.matrix[i][j])
          H += 1;
      }
    }
    return H - 1;
  }
  
  public int[] getCoordinatesInTarget( int value ) {
  
    int[] tab = null;
    
    for( int i = 0; i<MAX_X; i++ ) {
      for( int j = 0; j<MAX_Y; j++ ) {
        if(this.matrix[i][j] == value) {
          tab = new int[2];
          tab[0] = i;
          tab[1] = j;
          return tab;
        }
      }
    }
    return null;
  }
  
  public int countHeuManhattan( Matrix target ) {
    
    int tab[];
    
    for( int i = 0; i<MAX_X; i++ ) {
      for( int j = 0; j<MAX_Y; j++ ) {
        tab = target.getCoordinatesInTarget(this.matrix[i][j]);
        H += (( i > tab[0] ) ? ( i - tab[0] ) : ( tab[0] - i )) + (( j > tab[1] ) ? ( j - tab[1] ) : ( tab[1] - j ));
      }
    }
    return H;
  }
  
  public Matrix minF( LinkedList<Matrix> list ) {
    
    int min = list.getFirst().countF();
    Matrix MIN = list.getFirst();
    for( Matrix MM : list ) {
      if( MM.countF() < min ) {
        min = MM.countF();
        MIN = MM;
      }
    }
    
    return MIN;
  }
  
}

class sortByCountF implements Comparator<Matrix> {
  
    public int compare(Matrix a, Matrix b) 
    { 
        return a.countF() - b.countF(); 
    } 
} 
