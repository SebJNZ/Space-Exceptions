public class GUI {
  double time = 0; // Timer for count down
  int stage = 3; // Current Second
  PImage logo = loadImage("Images/logo.png"); // Logo
  
  // Draws the lives and score during the game
  public void draw() {
    // White
    fill(255);
    stroke(255);
    
    // Draw Score
    textSize(50);
    textAlign(LEFT);
    
    text("Score: " + player.getTotalScore(), 15, 50);
    
    // Draw Lives (ships)
    int SPRITE_WIDTH = BaseEntity.SPRITE_WIDTH;
    int SPRITE_HEIGHT = BaseEntity.SPRITE_HEIGHT;
    int SPRITE_PADDING = BaseEntity.SPRITE_PADDING;
    int VERTICAL_STEP = BaseEntity.VERTICAL_STEP;
    int HORIZONTAL_STEP = BaseEntity.HORIZONTAL_STEP;
    int chosenSprite = player.getSprite();
    
    for (int i = 0; i < player.getLives(); i++) {
      image(playerSprite, (i*(SPRITE_WIDTH+SPRITE_PADDING))+20, height-70, SPRITE_WIDTH, SPRITE_HEIGHT, SPRITE_PADDING, SPRITE_PADDING+(VERTICAL_STEP*chosenSprite), HORIZONTAL_STEP, VERTICAL_STEP+(VERTICAL_STEP*chosenSprite));
    }
    textAlign(CENTER); // Set back to centering
  } 
  
  // Draws the level up screen for different levels
  public void drawLevelUp() {
    textSize(50);
    fill(255);
    stroke(255);
    text("LEVEL UP!", halfScreenWidth, halfScreenHeight - 30);
    if (nextState == GameState.LEVEL_TWO) {
      text("LEVEL 2", halfScreenWidth, halfScreenHeight+30);
    } else if (nextState == GameState.LEVEL_THREE) {
      text("LEVEL 3", halfScreenWidth, halfScreenHeight+30);
    }
  }
  
  // Counts down from 3.
  private void countDown() {
    if (time == 0) { time = millis(); } // Initial time stter
    if (millis() - time > 3000) {  // If we have reached the bottom of the time (second 3), return to menu.
      time = 0;
      gameState = GameState.MENU; 
    }
    else if (millis() - time > 2000) { stage = 1; } // second 2
    else if (millis() - time > 1000) { stage = 2; } // second 1
    else { stage = 3; }
    text(stage, halfScreenWidth, halfScreenHeight+90); // Draw the second
  }
  
  
  // displays the death screen
  public void deathScreen() {
    // Red rectangle
    fill(100, 0, 0, 70);
    stroke(0, 0, 0, 255); // Invisible stroke
    rect(0, 0, width, height);
    textSize(50);
    fill(255);
    stroke(255);
    // Draw the text
    text("You died...",  halfScreenWidth, halfScreenHeight - 30);
    text("Total Score: " + player.getTotalScore(), halfScreenWidth, halfScreenHeight+30);
    // Draw The countdown and count it down
    countDown();
  }
  
  //displays the winning screen
  public void winScreen() {
    textSize(50);
    fill(255);
    stroke(255);
    // Write text
    text("You won!!! Good work.",  halfScreenWidth, halfScreenHeight - 30);
    text("Total Score: " + player.getTotalScore(), halfScreenWidth, halfScreenHeight+30);
    countDown(); // Count down
  }
  
  // Draws the 'Space Exceptions' logo in the center of the screen, around 1/4 of the way down. 
  public void drawLogo() {
    imageMode(CENTER);
    image(logo, halfScreenWidth, quarterScreenHeight);
    imageMode(CORNER);
  }
}
