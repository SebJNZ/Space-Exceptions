public class EnemyHandler {
  final byte[] shotLookupTable = {11, 6, 0, 4, 9, 3, 10, 0, 5, 2, 11, 4, 10, 8, 1, 7};
  private byte plungerPointer = 0;
  private byte squigglyPointer = 6;
  
  // For movement animation
  private int bottomRow;
  private int currentRow;
  
  private float movementSpeed = 10; // Speed of enemy rows moving
  private int framesBeforeAction = 20; // 20 Frames before movement
  private byte currentReloadDelay = 48; // Initial enemies bullet reload delay
  private int previousShotFrame = 0; // When we last shot
  
  private boolean waitForDrop = false; // Whether or not a row is waiting to drop or not
  // Stores dead enemies (so we can set them to null), enemies objects automatically put themselves in here.
  public HashSet<Enemy> deadEnemies = new HashSet<>();
  public HashSet<Projectile> enemyShots = new HashSet<>(); // Set of all shots so we can check and progress them.

  public EnemyHandler() {
    currentRow = bottomRow = enemies.length - 1;
  }

  // Used when the music is incresed (when ab enemy is killed), and a specific requirement is met.
  public void increaseSpeed() {
    framesBeforeAction--;
  }

  // Draw each of the enemies that are not null, and destroy dead enemies.
  public void drawEnemies() {
    for (int row = 0; row < enemies.length; row++) {
      for (int col = 0; col < enemies[row].length; col++) {
        if (enemies[row][col] != null) {
          if (deadEnemies.contains(enemies[row][col])) {
            enemies[row][col] = null;
          } else {
            enemies[row][col].draw();
          }
        }
      }
    }
  }
  
  // Move each of the enemies in the current row (staggered row changes over time)
  private void moveEnemy(float x, float y) {
    for (int col = 0; col < enemies[currentRow].length; col++)
      if (enemies[currentRow][col] != null)
        enemies[currentRow][col].moveEnemy(x, y);

    if (currentRow == 0) {
      currentRow = bottomRow;
    } else {
      currentRow--;
    }
  }
  
  // Checks whether all the enemies are going or not
  public boolean hasWon() {
    for (int row = 0; row < enemies.length; row++) {
      for (int col = 0; col < enemies[row].length; col++) {
        if (enemies[row][col] != null) { return false; }
      }
    }
    return true;
  }

  // Used to move each of the enemies down.
  private void moveAllEnemy(float x, float y) {
    for (int row = 0; row < enemies.length; row++)
      for (int col = 0; col < enemies[row].length; col++)
        if (enemies[row][col] != null) enemies[row][col].moveEnemy(x, y);
  }

  // Get's the left side of the enemies, so we know whether we are at the left side (so we can drop).  
  private float getLeftX() {
    float finalCol = 1000; // backup choice, this won't matter as win will be triggered anyway...
    for (int row = 0; row < enemies.length; row++)
      for (int col = 0; col < enemies[row].length; col++)
        if (enemies[row][col] != null && enemies[row][col].x < finalCol) finalCol = enemies[row][col].x;
    return finalCol;
  }

  // Get's the left side of the enemies, so we know whether we are at the right side (so we can drop).
  private float getRightX() {
    float finalCol = 0;
    
    // Loop through every enemy, and get the highest column, we can't just stop at the first occurance, as this row may have a ton missing, whereas the one above may have more to the right.
    for (int row = 0; row < enemies.length; row++)
      for (int col = 0; col < enemies[row].length; col++)
        if (enemies[row][col] != null && enemies[row][col].x + Enemy.SPRITE_WIDTH > finalCol)
          finalCol = enemies[row][col].x + Enemy.SPRITE_WIDTH;
          
    return finalCol;
  }
  
  // Checks each projectile against each player.
  private void checkEnemiesHit() {
    for (Projectile projectile : player.projectiles) {
      for (int row = 0; row < enemies.length; row++) {
        for (int col = 0; col < enemies[row].length; col++) {
          if (enemies[row][col] != null && enemies[row][col].checkIfHit(projectile)) {
            enemies[row][col].setDying();
            projectile.markAsRemove();
          }
        }
      }
    }
  }

  // Sets reload delay depending on how high the players score is (not cumulative between levels, resets to lowest at each level).
  private void setReloadDelay() {
    if (player.getCurrentScore() > 1700) {
      currentReloadDelay = 7;
    } else if (player.getCurrentScore() > 1400) {
      currentReloadDelay = 8;
    } else if (player.getCurrentScore() > 800) {
      currentReloadDelay = 11;
    } else if (player.getCurrentScore() > 200) {
      currentReloadDelay = 16;
    } else {
      currentReloadDelay = 48;
    }
  }
  
  // Returns the lowest enemy in a column, used for taunting, and shooting with the lowest enemies
  private Enemy getLowestEnemy(int col) {
    for (int row = enemies.length - 1; row >= 0; row--)
      if (enemies[row][col] != null) return enemies[row][col];
    return null;
  }
  
  // Get the closest enemy (for rolling shots) so the enemy can shoot at you (for increased difficulty).
  private Enemy getClosestEnemy() {
    float best = width; // Lowest difference in x
    int bestRow = -1; // Our best row and column.
    int bestCol = -1;
    
    for (int row = 0; row < enemies.length; row++) {
      for (int col = 0; col < enemies[row].length; col++) {
        if (enemies[row][col] == null) continue; // if it's null, skip it
        
        // Calculate the distance between the player and the enemy on the x axis
        float dx = Math.abs(enemies[row][col].x - player.x);
        if (dx < best) { // If there is a smaller distance, than it is closer to the enmy.
          best = dx; // store the best score.
          
          // set the indices for it
          bestRow = row;
          bestCol = col;
        }
      }
    }
    
    // Check whether this is the lowest shooter in this col or not, just incase somehow it isn't (such as the bottom row as moved, and the col above it hasn't.
    if (bestRow == -1 || bestCol == -1) { return null; }
    int targetRow = bestRow;
    for (int row = enemies.length - 1; row >= 0; row--) {
      if (enemies[row][bestCol] != null) {
        targetRow = row;
        break;
      }
    }
    
    
    return enemies[targetRow][bestCol];
  }
  
  // This used used to check if there are more than 8 enemies left, so that the UFO can spawn.
  public boolean moreThanEight() {
    byte counter = 0;
    for (int row = 0; row < enemies.length; row++)
      for (int col = 0; col < enemies[row].length; col++)
        if (enemies[row][col] != null && ++counter == 9) return true;
        
    return false;
  }
  
  // Checks whether the enemies can shoot, chooses a shot type, then chooses the enemy to shoot.
  private void enemyShoot() {   
    if (playFrameCount - currentReloadDelay >= previousShotFrame) {
      // Booleans so we know whether exist or not.
      boolean rollingExists = false;
      boolean plungerExists = false;
      boolean squigglyExists = false;
      
      // Get existance
      for (Projectile proj : enemyShots) {
        if (proj.getShotType() == 0) rollingExists = true;
        if (proj.getShotType() == 1) plungerExists = true;
        if (proj.getShotType() == 2) squigglyExists = true;
      }
      
      if (!plungerExists) {
        // Get the lowest enemy in the column. Make them shoot.
        Enemy enemy = getLowestEnemy(shotLookupTable[plungerPointer]);
        
        // Increment pointer
        if (++plungerPointer >= shotLookupTable.length) plungerPointer = 0;
        if (enemy == null) return;
        
        enemy.shoot((byte)1); // Shoot with type Plunger (1)
        
        previousShotFrame = playFrameCount;
      } else if (!squigglyExists) {
        // Get the lowest enemy in the column. Make them shoot.
        Enemy enemy = getLowestEnemy(shotLookupTable[squigglyPointer]);
        
        // Increment pointer
        if (++squigglyPointer >= shotLookupTable.length ) squigglyPointer = 0;
        if (enemy == null) return;
        
        enemy.shoot((byte)2); // Shoot with type Squiggly (1)
        
        previousShotFrame = playFrameCount;
      } else if (!rollingExists) {
        Enemy enemy = getClosestEnemy(); // Get the closest enemy
        
        if (enemy == null) return;
        
        enemy.shoot((byte)0); // Shoot with type Rolling
        
        previousShotFrame = playFrameCount;
      }
    }
  }
  
  // Trigger the taunts for the bottom enemies.
  public void triggerTaunts() {
    for (int col = 0; col < enemies[currentRow].length; col++) {
      Enemy e = getLowestEnemy(col);
      if (e != null) {
        e.setTaunt();
      }
    }
  }
  
  // Kill the player if they enemy goes below them.
  public boolean invaderOutOfBounds() {
    for (int row = 0; row < enemies.length; row++) {
      for (int col = 0; col < enemies[row].length; col++) {
        if (enemies[row][col] == null) continue;
        
        // Below the top of the enemy (which would lead to them touching.
        if (enemies[row][col].y+BaseEntity.SPRITE_HEIGHT >= player.y) { return true; }
      }
    }
    return false;
  }
  
  public void enemyHandler() {
    checkEnemiesHit(); // Check enemies that have possibly been hit

    drawEnemies(); // draw the enemies nwo
    
    setReloadDelay(); // Sets enemies reload delay each frame
    enemyShoot();     // Checks whether they need to shoot, and shoots.
    
    // If an invader is out of bounds (below the top of the player), then they have lost!
    if (invaderOutOfBounds()) {
      player.killPlayer();
    }
    
    // If there are enemy shots, check if tehy need to be removed, else move them
    if (!enemyShots.isEmpty()) {
      HashSet<Projectile> removeable = new HashSet<>(); // Set of the removeable ones
      for (Projectile proj : enemyShots) {
        if (proj == null || proj.toBeRemoved()) { 
          removeable.add(proj);  // Mark for removeal
        } else { 
          proj.moveProjectile(); 
        }
      }
      
      for (Projectile proj : removeable) 
        enemyShots.remove(proj); // remove them!
    }

    // There is a specific amount of frames between the enemies moving. Once we have reach the frames between each action, we can move an enemy row/
    if (playFrameCount % framesBeforeAction == 0) {
      // Check whether they are on the left or right side walls.
      if ((getLeftX() - movementSpeed <= 10.0 || getRightX() >= width+movementSpeed*2)) {
        // If we are the bottom row
        if (currentRow == bottomRow) {
          // If we have been waiting to drop (this stops them from getting out of line by dropping prematurally)
          if (waitForDrop) {
            // If we are all in line, then we can flip direction and drop
            movementSpeed = -movementSpeed;

            moveAllEnemy(0, -Enemy.SPRITE_HEIGHT);
            waitForDrop = false;
          } else {
            // We can drop!
            waitForDrop = true;
          }
        } else {
          // Else we can move the enemies until they are in line
          moveEnemy(movementSpeed, 0);
        }
      } else {
        // Move the enemies normally
        moveEnemy(movementSpeed, 0);
      }
    }
  }
}
