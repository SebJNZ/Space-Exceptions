import java.util.HashSet;

/**
 * This is the base class for all entities that fire (or are a projectile) UFO not included.
 * It holds Position, and Velocity.
 * 
 * Resources used:
 * https://www.w3schools.com/java/java_inheritance.asp
 * 
 */
public static class BaseEntity {
  public float x, y;
  protected float velocity; // If we use Private, the subclasses cannot use this.
  
  // Sprite Dimensions
  final static int SPRITE_WIDTH = 72;
  final static int HALF_SPRITE_WIDTH = 36;
  final static int SPRITE_HEIGHT = 48;
  final static int HALF_SPRITE_HEIGHT = 24;
  final static int SPRITE_PADDING = 20; // Sprite Sheet's padding between players
  final static int HORIZONTAL_STEP = SPRITE_WIDTH + SPRITE_PADDING; // Step for each player
  final static int VERTICAL_STEP = SPRITE_HEIGHT + SPRITE_PADDING;
  
  protected HashSet<Projectile> projectiles = new HashSet<>(); // Objects projectiles

  /**
   * Draw the projectiles, and check whether they need to be removed
   */
  public void drawProjectiles() {
    HashSet<Projectile> removeable = new HashSet<>(); // Set of removeable Projectiles
    for (Projectile pro : projectiles) {
      if (pro.toBeRemoved()) { removeable.add(pro); }
      pro.draw();
      pro.move();
    }
    
    // Remove old projectiles.
    for (Projectile remProj : removeable) {
      projectiles.remove(remProj);
    }
  }
  
  // Draw a specific projectile
  public Projectile drawProjectile(Projectile proj) {
    proj.draw();
    proj.move();
    if (proj.toBeRemoved()) { return proj; }
    return null;
  }
}
