public class Player extends BaseEntity {
  private PImage playerSprite; // Sprite Image
  private PlayerState state; // State
  private int chosenSprite; // Chosen sprite
  private int originalSprite; // Original Sprite key
  private int currentFrame; // Current Frame of animation
  private long deathFrame; // Time they die
  private boolean frameLock; // lock them from moving
  private int lives;
  private long score = 0; // Using a long incase someone manages to get a score greater than 
  private long previousScore = 0; // This is the score saves previous levels scores, if we included it, you would start at max difficulty... still displayed though.
  private float initialX; // initiali position
  private boolean doubleShot = false; // Power up
  
  
  public Player(float x, float y, PImage spriteSheet, int chosenSprite) {
    this.x = initialX = x;
    this.y = y;
    playerSprite = spriteSheet;
    originalSprite = this.chosenSprite = chosenSprite * 2;
    currentFrame = 1;
    velocity = 5;
    state = PlayerState.FLYING;
    lives = 3;
  }
  
  // Draw the player
  public void draw() {
    //   Sprite Sheet,  x , y, Displayed Width  Displayed Height,         Start of Sprite (X),                     Start of Sprite (Y),                         End of Sprite (X),                 End of Sprite (Y)
    image(playerSprite, x, y, SPRITE_WIDTH, SPRITE_HEIGHT, SPRITE_PADDING+((currentFrame-1)*HORIZONTAL_STEP), SPRITE_PADDING+(VERTICAL_STEP*chosenSprite), HORIZONTAL_STEP*currentFrame, VERTICAL_STEP+(VERTICAL_STEP*chosenSprite));
  }
  
  // Change the frame (unless locked) every 60 frames.
  public void changeFrame() {
    if (frameLock) {return;}
    if (playFrameCount % 60 == 0) {
      if (currentFrame == 2) { 
        currentFrame = 1; 
      } else { 
        currentFrame++;
      }
    }
  }
  
  // Move them to the left by the velocity
  public void moveLeft() {
    if (x-velocity >= 0) x -= velocity;
  }
  
  // Move them to the right by the velocty.
  public void moveRight() {
    if (x+SPRITE_WIDTH+velocity <= width) x += velocity;
  }
  
  // Create a projectile (or two if Power Up)
  public void shoot() {
    if (doubleShot) {
      projectiles.add(new Projectile(x-20, y, color(255, 255, 255)));
      projectiles.add(new Projectile(x+20, y, color(255, 255, 255)));
    } else {
      projectiles.add(new Projectile(x, y, color(255, 255, 255)));
    }
  }
  
  // Check whether they can shoot or not (if there are not projectiles)
  public boolean canShoot() {
    return projectiles.isEmpty();
  }
  
  // Start the death cycle
  public void startDeath() {
    state = PlayerState.DYING;
    playerDie.play(); // Play sound
    currentFrame = 1;
    chosenSprite++;
    frameLock = true; // Lock frame
    shakeOn = true; // Shake the screen
    shakeStart = millis(); // Mark start of shaking
    handler.triggerTaunts(); // Make the enemies taunt you
  }
  
  // Draw the death animation
  public void deathAnimation() {
    long time = millis(); // Current time
    // 120 frames between action
    if (time - deathFrame >= 1000) {
      state = PlayerState.DEAD;
    } else if (time - deathFrame >= 500 && currentFrame == 1) {
      currentFrame++;
    } 
  }
  
  // If they are dead
  public boolean isDead() {
    if (state == PlayerState.FLYING) { return false; }
    return true;
  }
  
  // Strictly dead (not dying)
  public boolean isCompletelyDead() {
    if (state == PlayerState.DYING) { return false; }
    return true;
  }
  
  // Check if they have been hit my a projectile, mark it as remove, start the death animation
  public void hit(Projectile proj) {
    float projX = proj.x;
    float projY = proj.y;
    if (projX < x + SPRITE_WIDTH && projX + proj.OBJECT_WIDTH > x && 
          projY < y + SPRITE_HEIGHT &&  projY + proj.OBJECT_HEIGHT > y) {
      proj.markAsRemove();
      startDeath();
      deathFrame = millis();
    }
  }
  
  // Check if they are toyching a power up, if they are, then enable double shot!
  public void touching(PowerUp pow) {
    if (pow.x >= x && pow.x <= player.x + SPRITE_WIDTH && pow.y >= y && pow.y < player.y + SPRITE_HEIGHT) {
      doubleShot = true;
      pow.markRemoval();
    }
  }
  
  // Bring them back to life! Resets state to flying, resets back to flying sprite (of first animation frame)
  public void revive() {
    chosenSprite = originalSprite;
    currentFrame = 1;
    state = PlayerState.FLYING;
  }
  
  // Get the sprite frame
  public int getSprite() { return originalSprite; }
  
  // Get the amount of lives we have left
  public int getLives() { return lives; }
  
  
  // Decrement lives
  public void decreaseLives() { lives--; }
  
  // Get the current and total scores.
  public long getCurrentScore() { return score; }
  public long getTotalScore() { return previousScore+score; }
  
  // Carry the score (so you don't start a level at max difficulty!)
  public void carryScore() {
    previousScore += score;
    score = 0;
  }
  
  // Increment the score by a specific amount.
  public void incrementScore(int amount) { score += amount;  }
  
  // Reset back to initial x position
  public void resetPosition() { x = initialX; }
  
  // Enables the double shot!
  public void enableDoubleShot() { doubleShot = true; }
  
  // Kill the player (if the enemies are below the top of the player)
  public void killPlayer() {
    lives = 1;
    startDeath();
  }
}
