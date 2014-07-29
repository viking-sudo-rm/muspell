class Vector2 extends PVector {
    
  public Vector2(float x, float y) {
    super(x, y);
  }
  
  public Vector2(int x, int y) {
    super(x, y);
  }
    
  public Vector2 copy() {
    return new Vector2(x, y);
  }
  
  public Vector2 add(Vector2 v2) {
    return new Vector2(x + v2.x, y + v2.y);
  }
  
  public Vector2 enlarge() {
    Vector2 r = this.copy();
    r.mult(Tile.WIDTH);
    return r;
  }
  
  public Vector2 shrink() {
    Vector2 r = this.copy();
    r.mult(1f / Tile.WIDTH);
    return r;
  }
  
}

class Actor {
  
  private Vector2 pos;
  private Pathfinder pathfinder;
  
  public Actor(Vector2 pos) {
    this.pos = pos;
    pathfinder = new Pathfinder(
  }
  
  public void setDestination(Vector2 d) {
    pathfinder.setDestination(d);
  }
  
  public void move() {
    println(pos.shrink());
    pos = pathfinder.getMove(pos.shrink());
  }
  
  public void render() {
    rect(pos.x, pos.y, 4, 4);
  }
  
}

class Tile {
  
  public static final int WIDTH = 32;
  
  private Vector2 pos;
  private int material;
  
  public Tile(int x, int y, int material) {
    pos = new Vector2(x, y);
    this.material = material;
  }
  
  //TODO: pass localization parameters
  public void render() {
    rect(pos.x * WIDTH, pos.y * WIDTH, WIDTH, WIDTH);
  }
  
}

class Pathfinder {
  
  private ArrayList<Vector2> moves;
  private Tile[][] grid;
  
  private Vector2 dest;
  
  public Pathfinder(Tile[][] grid) {
      moves = new ArrayList<Vector2>();
      this.grid = grid;
  }
  
  private void setDestination(Vector2 d) {
    dest = d;
  }
  
  private boolean hasMoved(Vector2 pos) {
    for (Vector2 move : moves) {
      if (move.equals(pos))
        return true;
    }
    return false;
  }
  
  public void clearMoves() {
    moves = new ArrayList<Vector2>();
  }
  
  public Vector2 getMove(Vector2 pos) {
    float lowScore = 999999999999999f;
    Vector2 nextMove = pos.copy();
    Vector2 n;
    for (int yStep = -1; yStep < 2; yStep++) {
      for (int xStep = -1; xStep < 2; xStep++) {
        n = pos.add(new Vector2(xStep, yStep));
        if (isPathable(n) && ! hasMoved(n) && getScore(n, dest) < lowScore) {
          lowScore = getScore(n, dest);
          nextMove = n;
        }
      }
    }
    return nextMove;
  }
  
  //TODO: add a terrain modifier?
  private float getScore(Vector2 pos, Vector2 dest) {
    return getDistance(pos, dest) + getHeuristic(pos, dest);
  }
  
  private float getDistance(Vector2 pos, Vector2 dest) {
    return pos.dist(dest);
  }
  
  private float getHeuristic(Vector2 pos, Vector2 dest) {
    return abs(dest.x - pos.x) + abs(dest.y - pos.y);
  }
  
}

boolean isPathable(int x, int y) {
  return grid[x][y] == null;
}

boolean isPathable(Vector2 pos) {
  return 0 < pos.x && pos.x < grid.length && 0 < pos.y && pos.y < grid[0].length && grid[(int) pos.x][(int) pos.y] == null;
}

Tile[][] grid;

Actor dude;

void setup() {
  size(displayWidth, displayHeight);
  grid = new Tile[30][30];
  for (int x = 0; x < 30; x++) {
    for (int y = 0; y < 30; y++) {
      if (random(20) < 1) {
        grid[x][y] = new Tile(x, y, 1);
      }
    }
  }
  
  dude = new Actor(new Vector2(0, 0));
 
 renderGrid();

}

void draw() {
  dude.move();
  dude.render();
}

void renderGrid() {
  for (int x = 0; x < 30; x++) {
    for (int y = 0; y < 30; y++) {
      if (! isPathable(x, y))
        grid[x][y].render();
    }
  }
}

