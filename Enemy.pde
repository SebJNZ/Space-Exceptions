public class Enemy extends BaseEntity {
  private PImage enemySpriteSheet; // Sprite Sheet (reference to a singular object)
  private EnemyState state; // Enemies state
  
  int currentFrame; // Current Frame of sprite animation
  int enemySprite; // Enemy's Current State (from enemy type)
  int initialSprite; // Enemy Type
  int value; // How much the enemy is worth
  
  color bulletColor = color(255, 255, 255); // Colour of the bullet
  
  public Enemy(float x, float y, PImage spriteSheet, int spriteType) {
    this.x = x;
    this.y = y;
    
    // State is flying
    state = EnemyState.FLYING;
    // There are three type of sprite for each character, so we multiply by 3
    initialSprite = enemySprite = spriteType * 3; // Choose a sprite: 0, 1, or 2. Then select the normal mode
    
    // Set value and bullet colour depending on type
    if (spriteType == 0) {
      value = 30;
      bulletColor = color(180, 255, 255);
    } else if (spriteType == 1) {
      value = 20;
      bulletColor = color(180, 255, 150);
    } else {
      value = 10;
      bulletColor = color(199, 179, 254);
    }
    
    // Get a reference to the sprite sheet, so we don't have to load it a million times, just once!
    this.enemySpriteSheet = spriteSheet;
    currentFrame = 1; // Current frame of the animation
  }
  
  // Draw the enemy
  public void draw() {  
     //   Sprite Sheet,     x , y, Displayed Width  Displayed Height,         Start of Sprite (X),                     Start of Sprite (Y),                   End of Sprite (X),                      End of Sprite (Y)
    image(enemySpriteSheet, x, y, SPRITE_WIDTH, SPRITE_HEIGHT, SPRITE_PADDING+((currentFrame-1)*HORIZONTAL_STEP), enemySprite*VERTICAL_STEP+SPRITE_PADDING, currentFrame*(HORIZONTAL_STEP), enemySprite*VERTICAL_STEP+VERTICAL_STEP);
  }
  
  // Change the frame
  public void changeFrame() {
    if (currentFrame == 2) { 
      if (state == EnemyState.DYING) {
        // Set enemy for removal, rather than flipping a flag, we can make it more efficient with a set, instead of looping through everyone
        handler.deadEnemies.add(this);
      }
      // If they are taunting, we set it back to their normal animation
      if (state == EnemyState.TAUNTING) {
        state = EnemyState.FLYING;
        enemySprite = initialSprite;
      }
      currentFrame = 1; 
    } else { 
      // Increment frame
      currentFrame++;
    }
  }
  
  /**
   * Move the enemy by a specific distance, and increment the frame
   */
  public void moveEnemy(float x, float y) {
    this.x -= x;
    this.y -= y;
    
    changeFrame();
  }
  
  // Sets the enemy into taunt mode, occurs when the player get's hit
  public void setTaunt() {
    if (state == EnemyState.DYING) return; // If they are dying, we don't want to stop that
    enemySprite += 2; // Move sprite pointer
    currentFrame = 1; // Set to start of animation
    state = EnemyState.TAUNTING; // Set state
  }
  
  // Sets the enemy as dying
  public void setDying() {
    if (state == EnemyState.DYING) return;
    player.incrementScore(value); // Add to the score
    music.increaseSpeed(10); // Increment the music speed
    enemySprite = initialSprite+1; // Get the death sprite (incase they are in taunting mode)
    state = EnemyState.DYING;
    enemyDie.play(); // Play death sound
    
    // Create 15 particles!
    
    // Get bullet colours, and cast them
    int r = (int) red(bulletColor);
    int g = (int) green(bulletColor);
    int b = (int) blue(bulletColor);
    for (int i = 0; i < 15; i++) {
      // Create and add to global set
      globalParticles.add(new Particle(x + SPRITE_WIDTH/2, y + SPRITE_HEIGHT/2, r, g, b));
    }
  }
  
  /**
   * Shoot a bullet if the enemy is not dead
   */
  public void shoot(byte projectileType) {
    if (state == EnemyState.DYING) { return; }
    projectiles.add(new Projectile(x, y+SPRITE_HEIGHT, bulletColor, projectileType, this));
  }
  
  // Check if a projectile has hit the enemy
  public boolean checkIfHit(Projectile projectile) {
    if ((projectile.x >= x && projectile.x <= x+SPRITE_WIDTH) && (projectile.y >= y && projectile.y <= y+SPRITE_HEIGHT)) {
      return true;
    }
    return false;
  }

}
