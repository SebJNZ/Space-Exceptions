public class UFO {
  private float x, velocity;
  private float y = 50; 
  
  // Sprite Dimensions
  private final byte padding = 40;
  private final int spriteObjectWidth = 192;
  private final int spriteObjectHeight = 84;
  
  // Dying or to be destory parameters
  private boolean dying = false;
  private boolean destroy = false;
  
  // Time of death
  private float deathTime = 0;
  
  // Current animation frame
  private int frame = 0;
  
  // Whether we have already checked for power up drops.
  private boolean checkedForPowerUp = false;
  
  PImage spriteSheet; // Sprite sheet
  
  public UFO(PImage spriteSheet) {
    this.spriteSheet = spriteSheet;
    
    // Choose whtehr to come from left or right
    if ((int)random(0, 2) == 0) { 
      velocity = 5;
      x = -spriteObjectWidth;
    } else { 
      velocity = -5;
      x = width;
    }
  }
  
  // Check wetherh to be removed or not (to the sides, or been marked as destroy)
  public boolean toBeRemoved() {
    if (destroy || (velocity > 0 && x > width) || (velocity < 0 && x < 0-spriteObjectWidth)) { return true; }
    return false;
  }
  
  // Draw it
  public void draw() {      
    if (frame == 3) {  // Death frame 3, we need to remove it
      destroy = true;
      player.incrementScore(ufoPointsLogic[ufoPointer]); // Add points to the player
    }
    
    // Get sprite width and start of the current x coordinate in teh spritesheet
    int frameWidth = padding + spriteObjectWidth + padding;
    int startX = padding + (frame * frameWidth);
    
    //   Sprite Sheet, x , y, Displayed Width  Displayed Height, Start of Sprite (X), Start of Sprite (Y), End of Sprite (X), End of Sprite (Y)
    image(spriteSheet, x, y, spriteObjectWidth, spriteObjectHeight, startX, padding, startX+spriteObjectWidth, padding+spriteObjectHeight);    
    
    // If tehy are dying display it
    if (dying) {
      if (millis() - deathTime >= 600) {
        frame++;
        deathTime += 600;
      }
    }
  }
  
  public boolean isDying() { return dying; }
  
  public float getX() { return this.x; }
  public float getY() { return this.y; }
  
  public void move() { if(!dying) x += velocity;  }
  
  // Check if a projectile has hit them, if it has, will set the UFO up for dying animation
  public boolean checkIfHit(Projectile projectile) {
    if (dying) return true;
    if ((projectile.x >= x && projectile.y >= y) && 
        (projectile.x+projectile.OBJECT_WIDTH <= x+spriteObjectWidth 
        && projectile.y+projectile.OBJECT_HEIGHT <= y+spriteObjectHeight)) {
      dying = true;
      deathTime = millis();
      frame = 1;
      ufoDie.play();
      return true;
    }  
    return false;
  }
  
  // Mark it as checked for power up
  public void mark() { checkedForPowerUp = true; }
  
  // Has it been checked for power up?
  public boolean checked() { return checkedForPowerUp; }
}
