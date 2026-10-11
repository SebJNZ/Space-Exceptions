public class Shield {
  private final byte PIXEL_SIZE = 5;
  private final byte SHIELD_WIDTH = 22;
  private final byte SHIELD_HEIGHT = 16;
  private final float SHIELD_RIGHT;
  private final float SHIELD_BOTTOM;
  private final float X;
  private final float Y;
  
  // Exact original layout from Space Invaders:
  private byte[][] blocks = {
    {0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0},
    {0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0},
    {0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0},
    {0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0},
    {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
    {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
    {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
    {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
    {1,1,1,1,1,1,1,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1},
    {1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1},
    {1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1},
    {1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1},
    {1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1},
    {1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1},
    {1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1},
    {1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1}
  };
  
  public Shield(float x, float y) {
    X = x;
    Y = y;
    SHIELD_RIGHT = x + PIXEL_SIZE * SHIELD_WIDTH;
    SHIELD_BOTTOM = y + PIXEL_SIZE * SHIELD_HEIGHT;
  }
  
  // Draw each square of the blocks
  public void draw() {
    for (int row = 0; row < SHIELD_HEIGHT; row++) {
      for (int col = 0; col < SHIELD_WIDTH; col++) {
        if (blocks[row][col] != 0) rect(X + col * PIXEL_SIZE, Y + row * PIXEL_SIZE, PIXEL_SIZE, PIXEL_SIZE);
      }
    }
  }
  
  /**
    * This method is called when a projectile is within shield bounds.
    * Once it is, we must check whether it hit any of the blocks.
    * If it does, then we must remove the squares it's touching, and a few around it (from impact)
    */
  public void checkAndDestroy(Projectile projectile) {
    float projX = projectile.x; //<>//
    float projY = projectile.y;
    
    // Checks whether a projectike is touching any of the blocks inside the shield
    for (int row = 0; row < SHIELD_HEIGHT; row++) {
      for (int col = 0; col < SHIELD_WIDTH; col++) {
        if (blocks[row][col] == 1) {
          float blockX = X+col*PIXEL_SIZE;
          float blockY = Y+row*PIXEL_SIZE; //<>//
        
          if (projX < blockX + PIXEL_SIZE && 
              projX + projectile.OBJECT_WIDTH > blockX && 
              projY < blockY + PIXEL_SIZE && 
              projY + projectile.OBJECT_HEIGHT > blockY) {
            projectile.markAsRemove();
            blocks[row][col] = 0;
          }
        }
      }
    }
  }
  
  /**
   * This does a initial check (whether in bounds), 
   * so that best case we don't have to process every single square.
   * 
   */
  public void touching(Projectile projectile) {
    if ((projectile.x >= X && projectile.x <= SHIELD_RIGHT) && (projectile.y >= Y && projectile.y <= SHIELD_BOTTOM)) { //<>//
      checkAndDestroy(projectile); //<>//
    }
  }
}
