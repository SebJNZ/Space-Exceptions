public class Button {
  private final PImage button; // Button image
  
  // Buttons Location Parameters
  private final float LEFT;
  private final float RIGHT;
  private final float TOP;
  private final float BOTTOM;
  
  // Center of the button
  private final float MIDDLE_X;
  private final float MIDDLE_Y;
  
  // For Sprite Sheets made buttons only
  private int chosenSprite;
  private int currentFrame;
  private int originalFrame;
  
  // Destination when you click the button
  GameState destinationState;
  
  // Defines each of the Button parameters
  public Button(float x, float y, PImage button, GameState destination) {
    MIDDLE_X = x;
    MIDDLE_Y = y;
    this.button = button;
    destinationState = destination;
    LEFT = x - (button.width / 2);
    RIGHT = x + (button.width / 2);
    TOP = y - (button.height / 2);
    BOTTOM = y + (button.height / 2);
  }
  
  // If we have a sprite sheet for this, we need to use this constructor
  public Button(float x, float y, PImage spriteSheet, GameState destination, int chosenSprite) {
    MIDDLE_X = x;
    MIDDLE_Y = y;
    destinationState = destination;
    button = spriteSheet;
    originalFrame = chosenSprite;
    this.chosenSprite = chosenSprite*2;
    currentFrame = 1;
    LEFT = x - BaseEntity.HALF_SPRITE_WIDTH;
    RIGHT = x + BaseEntity.HALF_SPRITE_WIDTH;
    BOTTOM = y + BaseEntity.HALF_SPRITE_HEIGHT;
    TOP = y - BaseEntity.HALF_SPRITE_HEIGHT;
  }
  
  // Draw the button
  public void draw() {
    imageMode(CENTER);
    image(button, MIDDLE_X, MIDDLE_Y);
    imageMode(CORNER);
  }
  
  // Draw the spriteSheet buttons
  public void drawSpriteSheet() {
    image(button, LEFT, TOP, BaseEntity.SPRITE_WIDTH, BaseEntity.SPRITE_HEIGHT, BaseEntity.SPRITE_PADDING+((currentFrame-1)*BaseEntity.HORIZONTAL_STEP), 
      BaseEntity.SPRITE_PADDING+(BaseEntity.VERTICAL_STEP*chosenSprite), BaseEntity.HORIZONTAL_STEP*currentFrame, BaseEntity.VERTICAL_STEP+(BaseEntity.VERTICAL_STEP*chosenSprite));
  }
  
  // Check where the mouse is compared to the button, if it is near it, then we have clicked it!
  public void isClicked() {
    if ((mouseX >= LEFT && mouseX <= RIGHT) && (mouseY >= TOP && mouseY <= BOTTOM)) {
      gameState = destinationState; // Sets our state
      // If we clicked a specific character
      if (gameState == GameState.LEVEL_ONE) {
        spriteChoice = originalFrame; // Set the sprite choice
        time = millis(); // Sets the start of the game
        buildEnemies(); // Builds the enemies
        handler = new EnemyHandler(); // Creates a new game handler
        reset(); // Creates and the characters
      }
    }
  }
}
