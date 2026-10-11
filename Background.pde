public class Background {
  PImage image; // Background image
  
  // Constructor that loads the image, and resizes it for the window 
  public Background(String imageLocation) {
    image = loadImage(imageLocation);
    image.resize(width, height);
  }
  
  // Draw the background
  public void draw() {
    image(image, 0, 0); 
  }
}
