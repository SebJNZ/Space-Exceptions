public class PowerUp extends BaseEntity {
  private boolean remove = false; // Whether marked for removal
  
  public PowerUp(float x, float y) {
    this.x = x;
    this.y = y;
    velocity = 3;
  }
  
  // Draw the PowerUp
  public void draw() {
    // Green coloured elipse of size 15 wide and tall
    fill(0, 255, 0); 
    stroke(0, 255, 00);
    ellipse(x, y, 15, 15);
    
    y += velocity; // move the power up down by velocity
    if (y >= height) remove = true;  // If we have reached the bottom, mark it for removal
  }
  
  // Getters and setters for removal
  public boolean toBeRemoved() { return remove; }
  public void markRemoval() { remove = true; }
}
