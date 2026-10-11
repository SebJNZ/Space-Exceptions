public class Projectile extends BaseEntity {
  public final int OBJECT_WIDTH = 7;
  public final int OBJECT_HEIGHT = 20;
  public final int HALF_OBJECT_WIDTH = OBJECT_WIDTH / 2;
  private byte type = -1;
  private boolean remove = false;
  private Enemy parent;
  
  private color objectColor;
  
  // Universal Settings
  public void setSettings(float x, float y, color objectColor) {
    this.x = x + HALF_SPRITE_WIDTH - HALF_OBJECT_WIDTH;
    this.y = y - 20;
    this.objectColor = objectColor;
  }
  
  // Player Projectile
  public Projectile(float x, float y, color objectColor) {
    setSettings(x, y, objectColor);
    velocity = 10;
    
    globalProjectiles.add(this);
  }
  
  // Enemy Projectile
  public Projectile(float x, float y, color objectColor, byte type, Enemy enemy) {
    setSettings(x, y, objectColor);
    velocity = -7; // around 70% of player's bullet speed
    
    handler.enemyShots.add(this);
    this.type = type; // Set the type of bullet (for enemy bullet type checking) - can only have one type of bullet on screen at once.
    parent = enemy;
  }
  
  // Draw the projectile
  public void draw() {
    fill(objectColor);
    stroke(objectColor);
    
    rect(x, y, OBJECT_WIDTH, OBJECT_HEIGHT);
    
    if (y <= -20 || y >= height) markAsRemove();
  }
  
  // Mark it to be rmeoved
  public void markAsRemove() { remove = true; }
  
  // Move it
  public void move() {
    y -= velocity;
  }
  
  // Check if to be removed
  public boolean toBeRemoved() { return remove; }
  
  // Get the type of shot (squiggly, plunger or rolling)
  public byte getShotType() { return type; }
  
  // Move where this projectile (tells teh parent to mvoe it)
  public void moveProjectile() { parent.drawProjectile(this); }
  
  // If we are checking another projectile, return true.
  public boolean isTouching(Projectile other) {
    if ((other.x <= x+OBJECT_WIDTH && other.x+OBJECT_WIDTH >= x) && (other.y <= y+OBJECT_HEIGHT && other.y+OBJECT_HEIGHT >= y)) {
      return true;
    }
    return false;
  }
}
