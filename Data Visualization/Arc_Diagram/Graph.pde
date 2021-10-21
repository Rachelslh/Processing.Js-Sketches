
class Node implements Comparable<Node>{

    public int x, y, indice, abscissa;
    public float barycenter;
    public color fillColor, stroke;
    
    public Node(int x, int y, int indice, int abscissa, color fillColor, color stroke) {
      
      this.x = x;
      this.y = y;
      this.indice = indice;
      this.abscissa = abscissa;
      
      this.fillColor = fillColor;
      this.stroke = stroke;
    }
    
    public int compareTo(Node nd) {
      return (int) Math.signum(barycenter - nd.barycenter);
    }
}


class Edge {
  
  public Node from, to;
  
  public Edge( Node from, Node to) {
   
    this.from = from;
    this.to = to;
  }
}


class Graph {
  
  int nbNodes = 0, 
      nbEdges = 0;
  Node[] nodes;
  ArrayList<Edge> edges;
  HashMap<Node, ArrayList<Node>> neighbours;
  
  
  public Graph () {}
  
  public Graph (int nbNodes, Node[] nodes) {
    
    this.nbNodes = nbNodes;
    this.nodes = nodes;
    this.edges = new ArrayList();
    this.neighbours = new HashMap();
    
    for (Node node : nodes) {
      this.neighbours.put(node, new ArrayList<Node>(nbNodes));
    }
  }
  
  public float getBarycenter(Node node) {
    
    float barycenter = node.abscissa;
    ArrayList<Node> neighb = neighbours.get(node);
    int len = 1;
    
    for (Node nd : neighb) {
      barycenter += nd.abscissa;
      len += 1;
    }
    
    barycenter /= len;
    
    return barycenter;
  }
  
  public boolean isAllConnected() {
    
    for (Node nd : nodes) {
      
      if (neighbours.get(nd).isEmpty())
        return false;
    }
    
    return true;
  }
  
  public boolean sortNodes() {
    
    for (int i = 0; i < nbNodes; i++) {
     nodes[i].barycenter = getBarycenter(nodes[i]);
    }
    print("* Calculating Barycenters...\n");
    String s1 = printNodes();
    print("* Sorting Nodes...\n");
    java.util.Arrays.sort(nodes);
    String s2 = printNodes();
    
    if (s1.equals(s2))
      return false;
      
    return true;
  }
 
  public String printNodes() {
    
    String s = "";
    
    print("  |  ");
    for (int i = 0; i < nbNodes; i++) {
     print ("Nd " + nodes[i].indice + "   " + nodes[i].barycenter + "  |  ");
     s += nodes[i].indice;
    }
    print("\n\n");
    
    return s;
  }
  
}
