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
  
  public Vector2 getSum(Vector2 v2) {
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
  
  public Vector2 shrinkToGrid() {
    Vector2 r = this.shrink();
    return new Vector2((int) r.x,(int) r.y);
  }
  
  public Vector2 getDifference(Vector2 v2) {
    Vector2 r = this.copy();
    r.sub(v2);
    return r;
  }
  
  public Vector2 getNormalized() {
    Vector2 r = this.copy();
    r.normalize();
    return r;
  }
  
  //might be a workaround with the null shit
  
}

class Actor {
  
  private static final float MASS = 10;
  
  private Vector2 pos;
  private float speed;
  private float radius;
  
  private Pathfinder pathfinder;
  
  public Actor(Vector2 pos, float speed, float radius, Tile[][] grid) {
    this.pos = pos;
    this.speed = speed;
    this.radius = radius;
    pathfinder = new Pathfinder(grid);
  }
  
  public void setDestination(Vector2 d) {
    pathfinder.setDestination(d.shrink());
  }
  
  public void move() {
    
    if (pathfinder.reachedDestination(pos))
      return;
    
    if (pathfinder.reachedWaypoint(pos))
      pathfinder.calcMove(pos.shrink());
    Vector2 delta = pathfinder.waypoint.enlarge().getDifference(pos).getNormalized();
    delta.mult(speed);
    pos.add(delta);  
  }
  
  public Vector2 getRVOForce(Vector2 pos1) {
    float magnitude = MASS / sqrt(pos.dist(pos1));
    Vector2 r = pos.getDifference(pos1).getNormalized();
    r.mult(magnitude);
    return r;
  }
  
  public Vector2 getNetRVO(ArrayList<Actor> obstacles) {
    Vector2 r = new Vector2(0, 0);
    for (Actor obstacle : obstacles) {
      if (obstacle != this)
        r.add(obstacle.getRVOForce(pos));
    }
    return r;
  }
  
  public void render() {
    ellipse(pos.x, pos.y, radius, radius);
  }
  
}

class Tile {
  
  public static final int WIDTH = 20;
  
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
  
  private static final float WAY_THRESH = .1;
  private static final float DEST_THRESH = .5;
  
  private ArrayList<Vector2> moves;
  private Tile[][] grid;
  
  private Vector2 dest;
  public Vector2 waypoint;
  
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
  
  public boolean reachedWaypoint(Vector2 pos) {
    
    if (waypoint == null)
      return true;
    
    boolean r = pos.shrink().dist(waypoint) < WAY_THRESH;
    if (r)
      moves.add(waypoint);
    return r;
  }
  
  public boolean reachedDestination(Vector2 pos) {
    
    if (dest == null)
      return true;
      
    return pos.shrink().dist(dest) < DEST_THRESH; 
    
  }
  
  public Vector2 calcMove(Vector2 pos) {
    float lowScore = 999999999999999f;
    Vector2 nextMove = pos.copy();
    Vector2 n;
    for (int yStep = -1; yStep < 2; yStep++) {
      for (int xStep = -1; xStep < 2; xStep++) {
        n = pos.getSum(new Vector2(xStep, yStep));
        if (isPathable(n, grid) && ! hasMoved(n) && getScore(n, dest) < lowScore) {
          lowScore = getScore(n, dest);
          nextMove = n;
        }
      }
    }
    waypoint = nextMove;
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

boolean isPathable(int x, int y, Tile[][] grid) {
  return grid[x][y] == null;
}

boolean isPathable(Vector2 pos, Tile[][] grid) {
  return 0 < pos.x && pos.x < grid.length && 0 < pos.y && pos.y < grid[0].length && grid[(int) pos.x][(int) pos.y] == null;
}

Tile[][] grid;
ArrayList<Actor> units;

Actor dude, other;

void setup() {
  size(displayWidth, displayHeight);
  grid = new Tile[30][30];
  units = new ArrayList<Actor>();
  for (int x = 0; x < 30; x++) {
    for (int y = 0; y < 30; y++) {
      if (random(16) < 1) {
        grid[x][y] = new Tile(x, y, 1);
      }
    }
  }
  
  dude = new Actor(new Vector2(0, 0), 3, 10, grid);
  other = new Actor(new Vector2(3, 4), 3, 10, grid);
  dude.setDestination(new Vector2(Tile.WIDTH * random(30), Tile.WIDTH * random(30)));
  units.add(dude);
  units.add(other);

  println(dude.getNetRVO(units));

}

void draw() {
  ellipseMode(RADIUS);
  background(0);
  renderGrid();
  dude.move();
  dude.render();
}

void renderGrid() {
  for (int x = 0; x < 30; x++) {
    for (int y = 0; y < 30; y++) {
      if (! isPathable(x, y, grid))
        grid[x][y].render();
    }
  }
}

