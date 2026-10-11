import processing.sound.*;

// Create Objects
Background background;
Player player;
EnemyHandler handler;
Shield[] shields = new Shield[4]; // 4 shields
HashSet<Projectile> globalProjectiles; // Store memory addresses as this is a reference type, as they already exist.
HashSet<Particle> globalParticles; // Death Particles, has it's own garbage collector
UFO ufo = null; // Means that the UFO hasn't spawned (created when spawned, then set to null when gone)

Enemy[][] enemies; // 2D Array of Enemies
GameState gameState; // Our Current GameState

// Buttons (Start, and Ships to choose from) and GUI 
Button startButton;
Button[] playerSpriteChoices;
GUI gui;

// Sound Files and Music Object
SoundFile playerShoot, playerDie, enemyDie, ufoEntrance, ufoDie;
Music music;

// PowerUp currently dropped
PowerUp activePowerUp = null; 
boolean powerUpHasDropped = false;

int shake = 0;
boolean shakeOn = false;
long shakeStart;

// Must define these here due to Processing's weird static shenanigans. Allows us to pass by reference, rather than load and store manually in every Enemy/Player object.
PImage playerSelect, enemySprite, playerSprite, ufoSprite;

// Key States (defined here for smooth movement with frame drawing)
boolean moveLeft = false;
boolean moveRight = false;
boolean shoot = false;

// Enemies Current State Descriptor
public enum EnemyState {
  FLYING,
  DYING,
  TAUNTING
}

// Players Current State Descriptor
public enum PlayerState {
  FLYING,
  DYING,
  DEAD
}

// Games Current State Descriptor
public enum GameState {
  MENU,
  PLAYER_SELECT,
  DEATH_SCREEN,
  LEVEL_ONE,
  LEVEL_TWO,
  LEVEL_THREE,
  LEVEL_TRANSITION,
  WON
}

// Level templates
final int[][] levelOne = {
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, // Squid - 30 points
  {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, // Crab - 20 Points
  {2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2} // Octopus - 10 Points
};

final int[][] levelTwo = {
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, // Squid - 30 points
  {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, // Crab - 20 Points
  {2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2}, // Octopus - 10 Points
  {2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2}
};

final int[][] levelThree = {
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, // Squid - 30 points
  {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, // Crab - 20 Points
  {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
  {2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2}, // Octopus - 10 Points
  {2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2}
};

// This is how we calculate the points, when you shoot, the pointer moves along, say you shoot 5 times
// and hit the ufo, you will get 100 point, it looks back over and over.
int[] ufoPointsLogic = {100, 50, 50, 100, 150, 100, 100, 50, 300, 100, 100, 100, 50, 150, 100}; // Original Logic from the original game.
int ufoPointer = 0;

// Counts the total frames since you choose your character, and start the game.
int playFrameCount = 0; // Using a custom counter so we don't run into weird sprite changes.
int time = 0; // Used to calculate when the UFO spawns in
int spriteChoice = 0; // The user's choice of Player Sprite

// Pre-calculatable variables, means we don't have to keep dividing width / 2, height / 2, etc.
float halfScreenWidth, halfScreenHeight, quarterScreenHeight;

void settings() {
  size(1280, 960);
}

void setup() {
  println("Running Setup...\nCalculating Parameters...");
  
  halfScreenWidth = width / 2;
  halfScreenHeight = height / 2;
  quarterScreenHeight = height / 4;
  
  println("Calculated\nLoading Images...");
  background = new Background("Images/background.jpg"); // Create Background Object
  
  playerSelect = loadImage("Images/player_selection_menu.png"); // Load Player Selection menu image
  playerSprite = loadImage("Images/players.png"); // Load Player Sprite Sheet
  enemySprite = loadImage("Images/enemies.png"); // Load Enemy Sprite Sheet
  ufoSprite = loadImage("Images/ufo.png"); // Load UFO Sprite sheet
  PImage startImage = loadImage("Images/start.png"); // Loads start button image
  println("Loaded");
  
  // Set all text to be drawn in the center
  textAlign(CENTER);
  
  println("Setting up projectiles, Player, Buttons, and Shields");
  setupShields(); // Create shield objects

  globalProjectiles = new HashSet<Projectile>(); // Players projectiles
  
  gameState = GameState.MENU; // Sets Starting state to menu
  
  // Create Start Button
  startButton = new Button(halfScreenWidth, halfScreenHeight, startImage, GameState.PLAYER_SELECT);

  // Player Ships Choices
  playerSpriteChoices = new Button[3];
  
  playerSpriteChoices[0] = new Button(halfScreenWidth-300, halfScreenHeight, playerSprite, GameState.LEVEL_ONE, 0);
  playerSpriteChoices[1] = new Button(halfScreenWidth, halfScreenHeight, playerSprite, GameState.LEVEL_ONE, 1);
  playerSpriteChoices[2] = new Button(halfScreenWidth+300, halfScreenHeight, playerSprite, GameState.LEVEL_ONE, 2);
  
  gui = new GUI(); // Create new GUI object.
  
  println("Done.");
  
  println("Loading audio...");
  
  try {
    loadAudio(); // Load Audio Objects
    println("Audio Loaded Successfully!");
  } catch (Exception e) {
    println("Unable to load audio...: " + e.getMessage());
  }
  
  println("Finished Setup");
}

void draw() {  
  background.draw(); // Draw the background
  if (checkStates()) { return; } // Catch different states (Menu, Choosing Sprite, Dead, Dying, level up), so we don't draw main game
  
  // Default colour white:
  fill(255, 255, 255);
  stroke(255, 255, 255);
  playFrameCount++;
  
  gui.draw(); // Draw GUI
  music.play(); // Play the SoundTrack
  bulletchecker(); // Check if bullets are touching each other, and clean up old ones
  
  tryShake(); // Shake screen if we get hit
  
  drawShields();
  // Draws Player, checks if hit, and if dead.
  if (playerHandler()) { return; }
  handler.enemyHandler(); // Draws Enemy, and Handles animation changes, and movement changes.
  drawUFO();
  
  checkShieldsHit();
  player.drawProjectiles();
  player.changeFrame();
  handleShooting();
  
  drawPowerUps();
  drawParticles();
  
  checkIfUFOCanSpawn();
}

/**
 * This method is for when you either press the Space Bar, LEFT/RIGHT A/D keys, and tells the draw method
 * to move the character if needbe.
 */
void keyPressed() {
  if (key == CODED) {
    if (keyCode == RIGHT) moveRight = true;
    if (keyCode == LEFT) moveLeft = true;
  } else {
    if (key == 'd') moveRight = true;
    if (key == 'a') moveLeft = true;
    // Check if the player can shoot or not, to stop shooting at death, and in weird situations...
    if (key == ' ' && shoot == false && player.canShoot()) {
      shoot = true;
    }
  }
}

/**
 * Handles the release of keys to stop you from moving
 */
void keyReleased() {
  if (key == CODED) {
    if (keyCode == RIGHT) moveRight = false;
    if (keyCode == LEFT) moveLeft = false;
  } else {
    if (key == 'd') moveRight = false;
    if (key == 'a') moveLeft = false;
  }
}

/**
 * Handles GUI interaction
 */
void mouseClicked() {
  // Menu has the start button
  if (gameState == GameState.MENU) { 
    startButton.isClicked(); 
  } else if (gameState == GameState.PLAYER_SELECT) {
    // If we are in the Player selection screen, check if any of them were clicked.
    for (int sprite = 0; sprite < 3; sprite++) {
      playerSpriteChoices[sprite].isClicked();
    } 
  }
}
