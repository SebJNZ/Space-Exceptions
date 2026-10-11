public class Particle {
  private float x, y; // Co-ordinate
  private final float xVelocity, yVelocity; // Unique velocities for each direction
  private final int objectWidth = 5; // Width
  private final int objectHeight = 10; // Height
  private float angle; // Angle
  private float spinRate; // Spin Rate
  
  // RGB and Alpha channel (rgb stays same), alpha changes
  private int r, g, b, a;
  
  // Create the object (constructor)
  public Particle(float x, float y, int r, int g, int b) {
    this.x = x;
    this.y = y;
    
    // Random Directions!
    xVelocity = random(-3, 3);
    yVelocity = random(-3, 3);
    
    // Random angle and speed of spinning
    angle = random(TWO_PI); // between -1 and ~1
    spinRate = random(-0.2, 0.2);
    
    // Set colour and make it fully visible (alpha 255)
    this.r = r;
    this.g = g;
    this.b = b;
    a = 255;
  }
  
  // Draw and check whether they need to be rmeoved or not
  public boolean drawAndCheck() {
    // Set colour
    stroke(r, g, b, a);
    fill(r, g, b, a);
    
    // Push matrix so we can return.
    pushMatrix();
    translate(x, y);
    rotate(angle);
    
    rect(0, 0, objectWidth, objectHeight);
    popMatrix();
    
    // Change angle, velocity, and translucenty
    angle += spinRate; 
    x += xVelocity;
    y += yVelocity;
    a -= 5;
    
    return a <= 0;
  }
}
