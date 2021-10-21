class Cell{
  
  int x, y, loc, Px, Py, cout = 0;
  
  Cell(int x, int y, int Px, int Py){
    this.x = x;
    this.y = y;
    this.Px = Px;
    this.Py = Py;
  }
  
  Cell searchDepart(int[][] mat, int value){
    for (int x = 0; x < 16; x++ ) {
      for (int y = 0; y < 16; y++ ) {
        if(mat[x][y] == value)
          return new Cell(x, y, 0, 0);
      }
    }
    return searchDepart(mat, 3);
  }
  
  void setCout(int cout){
    this.cout = cout;
  }
}
