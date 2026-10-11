double transitionStart; // Start of level up transition
GameState nextState; // Next state after winning, and levelling up.

// Load all the audio files (for setup())
public void loadAudio() {
  playerShoot = new SoundFile(this, "Audio/Player/shoot.wav");
  playerDie = new SoundFile(this, "Audio/Player/explosion.wav");
  enemyDie = new SoundFile(this, "Audio/Enemies/invaderkilled.wav");
  ufoEntrance = new SoundFile(this, "Audio/UFO/spawn.wav");
  ufoDie = new SoundFile(this, "Audio/UFO/die.wav");
  music = new Music(this);
}

// Build a 2D Array of enemies depending on the levels
public void buildEnemies() {
  int[][] level; // Temporarily store a copy of the level so we can buold it.
  if (gameState == GameState.LEVEL_ONE)        { level = levelOne; }
  else if (gameState == GameState.LEVEL_TWO)   { level = levelTwo; }
  else if (gameState == GameState.LEVEL_THREE) { level = levelThree; }
  else { return; } // handle 'level may not be defined' error....
  
  // Create enemies
  enemies = new Enemy[level.length][level[0].length]; // Sets enemy 2D array size to the length of the level's 2D Array.
  
  // Start Coordinates for building enemies
  int startX = 98;
  int startY = 100;
  
  // Loop through each enemy slot
  for (int row = 0; row < enemies.length; row++) {
    for (int col = 0; col < enemies[row].length; col++) {
      float spawnX = startX + (col * Enemy.HORIZONTAL_STEP); // Calculate it's X coordinate
      float spawnY = startY + (row * Enemy.VERTICAL_STEP); // Calculate it's Y coordinate

      enemies[row][col] = new Enemy(spawnX, spawnY, enemySprite, level[row][col]); // Create it passing in the type from the level's information
    }
  }
}

// Increments the UFO Pointer as you shoot.
public void moveUFOPointer() {
  if (ufo != null && ufo.isDying()) return; // If it's dying, then we don't want to change your points!
  
  if (ufoPointer == ufoPointsLogic.length - 1) ufoPointer = 0; // Reset
  else ufoPointer++; // Increment
}

// Maybe move this elsewhere...
public void checkShieldsHit() {
  // Check player projectiles
  for (Projectile p : globalProjectiles) {
    for (int shield = 0; shield < 4; shield++) {
      // this checks whether they are in the bounds of the sheield, 
      // doesn't necessarily mean it's actualy touching
      shields[shield].touching(p); // Check if the projectile is touching the shield or not
    }
  }
  
  // Check enemy projectiles 
  for (Projectile p : handler.enemyShots) {
    for (int shield = 0; shield < 4; shield++) {
      shields[shield].touching(p);
    }
  }
}

// Check darw all the shields.
public void drawShields() {
  for (int shield = 0; shield < 4; shield++) {
    shields[shield].draw();
  }
}

// Reset the shields, creating them with even axis's
public void setupShields() {
  float yPos = height * 0.625;
  shields[0] = new Shield(width * 0.13125, yPos); // 168px at 1280 width
  shields[1] = new Shield(width * 0.34844, yPos); // 446px at 1280 width
  shields[2] = new Shield(width * 0.56563, yPos); // 724px at 1280 width
  shields[3] = new Shield(width * 0.78281, yPos); // 1002px at 1280 width
}

// Check whether the UFO is hit or not
public boolean checkOnUFO() {
  for (Projectile p : globalProjectiles) {
    if (ufo.checkIfHit(p)) { return true; }
  }
  return false;
}

// Handle the User dying
public void handleDead() {
  // Empty Out Projectiles
  handler.enemyShots = new HashSet<>(); // Reset/Remove the Enemies shots
  globalProjectiles = new HashSet<>(); // Reset/Remove the Players shots
  player.projectiles = new HashSet<>(); // Reset/Remove the players projectile projectiles.
  handler.drawEnemies(); // Draw the enemies.
  
  if (player.isCompletelyDead()) { // If the death animation has ended
    player.decreaseLives(); // Decrease lives
    if (player.getLives() > 0) { // If they can still be lives, bring them back to life.
      player.revive();
    } else {
      gameState = GameState.DEATH_SCREEN; // Otherwise, display the death screen.
    }
  } else {
    player.deathAnimation(); // Start death animation
    player.draw(); // Draw the player dying.
  }
}

// Starts the levelUp() transition to next level.
public void levelUp() {
  transitionStart = millis();
  displayLevelUp();
}

public void displayLevelUp() {
  if (millis() - transitionStart < 4000) { // If we haven't finished the transition, keep drawing
    gui.drawLevelUp();
  } else {
    setupNextLevel(); // Progress to next level.
  }
}

// Resets the world, used when you press the start button
public void reset() {  
  ufo = null; // Removes UFO
  setupShields(); // Reset the shields
  player = new Player(halfScreenWidth - BaseEntity.SPRITE_WIDTH/2, quarterScreenHeight * 3.25, playerSprite, spriteChoice);
  music.reset(); // Reset the delay between each note
  globalParticles = new HashSet<>(); // Reset the Global Particles.
  powerUpHasDropped = false;
}

// Set up the next level
public void setupNextLevel() {
  // Carry Score
  player.carryScore(); // Set score to 0, and save the original score (still added the total, but means you don't start the level with max difficulty),
  
  gameState = nextState; // Moves to the next level
  
  buildEnemies(); // Re-build the enemies by the definition of the new level
  handler = new EnemyHandler(); // Create the new handler as we have reset the enemies
  ufo = null; // Remove the UFO
  setupShields(); // ReBuild shields (me being nice to the marker - makes game easier).
  music.reset(); // Reset the music
  globalParticles = new HashSet<>(); // Remove any particles.
}

// Checkes Whether the enemies and Players bullets are touching
public void bulletchecker() {
  cleanUp(); // Remove old bullets
  
  for (Projectile myProj : globalProjectiles) {
    for (Projectile enemyProj : handler.enemyShots) {
      if (myProj.equals(enemyProj)) { continue; } // If, somehow they are the same...
      
      // If they are touching, mark them for removal by the garbage collector.
      if (myProj.isTouching(enemyProj)) {
        myProj.remove = true;
        enemyProj.remove = true;
      }
    } 
  }
  
}
 
// Cleans up old projectiles
public void cleanUp() {
  HashSet<Projectile> removeable = new HashSet<>();
    
  // If they are empty, or need to be removed, we remove them from the globalProjetiles.
  for (Projectile proj : globalProjectiles) {
    if (proj == null || proj.toBeRemoved()) { 
      removeable.add(proj); 
    }
  }
  
  // Get rid of them.
  for (Projectile proj : removeable) {
    globalProjectiles.remove(proj);
  }
}

// Handle the shooting for the player.
public void handleShooting() {
  if (shoot) { // If they have pressed the space bar
    player.shoot(); // Shoot
    // If we have the audio, play the shoot sound
    if (playerShoot != null) {
      playerShoot.play();
    }
    shoot = false; // Sets shooting to false so it doesn't repeat.
    moveUFOPointer(); // Move the UFO pointer for score.
  }
  // Move them left if they have pressed the < or a
  if (moveLeft) {
    player.moveLeft();
  }
  
  // Move them right if they have pressed the > or d
  if (moveRight) {
    player.moveRight();
  }
}

// Check each of the game states, and draw what is needed.
public boolean checkStates() {
  // Home Menu
  if (gameState == GameState.MENU) {    
    startButton.draw(); // draw the buttons
    time = millis(); // Reset the counter.
    gui.drawLogo(); // Draw the logo
    return true; // skip processing everything else.
  }
  
  // Player select menu
  if (gameState == GameState.PLAYER_SELECT) {
    // Draw the container for the sprites
    imageMode(CENTER);
    image(playerSelect, halfScreenWidth, halfScreenHeight);
    imageMode(CORNER);
    
    // Draw each of the sprites.
    for (int sprite = 0; sprite < 3; sprite++) {
      playerSpriteChoices[sprite].drawSpriteSheet();
    } 
    return true;
  }
  
  // Death screen
  if (gameState == GameState.DEATH_SCREEN) {
    handler.drawEnemies(); // Draw the Enemies
    gui.deathScreen(); // Display the Death screen on top
    return true;
  }
  
  // Win Screen
  if (gameState == GameState.WON) {
    gui.winScreen();
    return true;
  }
  
  // Level up screen
  if (gameState == GameState.LEVEL_TRANSITION) {
    displayLevelUp();
    return true;
  }
  
  // Has won, then we need to handle transitions
  if (handler.hasWon()) {
    drawShields(); 
    gui.draw();
    
    // Move to next level, or if in level 3, move to win screen.
    if (gameState == GameState.LEVEL_ONE) { nextState = GameState.LEVEL_TWO; }
    if (gameState == GameState.LEVEL_TWO) { nextState = GameState.LEVEL_THREE; }
    if (gameState == GameState.LEVEL_THREE) { 
      gameState = GameState.WON;
      return true;
    }
    
    // Move to the next transition.
    gameState = GameState.LEVEL_TRANSITION;
    levelUp(); // Level up screen
    return true;
  }
  
  return false;
}

// Check whether the player has been hit or not, or dead, and draw them.
public boolean playerHandler() {
  for (Projectile proj : handler.enemyShots) {
    player.hit(proj);
  }
  
  if (player.isDead()) {
    handleDead();
    return true;
  }
  
  player.draw();
  return false;
}

// Draw the UFO, and handle whether it drops a power up
public void drawUFO() {
  if (ufo != null) {
    if (ufo.toBeRemoved()) {  // If they have reached the end of teh screenns, or reached end of death screen, remove them
      ufo = null;
    } else {
      if (checkOnUFO()) {
        ufo.draw(); // We must check then draw, else we will have issues...
        
        // Check whether we can drop a power up or not. 3/10 chance.
        if (!ufo.checked() && !powerUpHasDropped && random(0, 100) < 30) {
          activePowerUp = new PowerUp(ufo.getX() + ufo.spriteObjectWidth/2, ufo.getY() + ufo.spriteObjectHeight/2);
          powerUpHasDropped = true; // No longer can they get a power up
        }
        ufo.mark(); // Mark them as having been checked if they can drop, else it will keep checking if it can drop a powerup
      } else {
        ufo.draw();
        ufo.move();
      }
    }
  }
}

// Check if there has been 25.6 seconds since the last ufo
public void checkIfUFOCanSpawn() {
  if (millis() - time >= 25600) { // Spawn UFO every 25.6 seconds
    time = millis();
    if (ufo != null) {
      return;
    } else if (handler.moreThanEight()) { // Only spawn if there are more than eight enemies
      ufo = new UFO(ufoSprite);
      ufoEntrance.play();
    }
  }
}

// Draw each of the particles
public void drawParticles() {
  HashSet<Particle> removeable = new HashSet<>();
  
  for (Particle p : globalParticles) {
    if(p.drawAndCheck()) {removeable.add(p);} // if we need to remove them, and get rid of them.
  }
  
  for (Particle p : removeable) {
    globalParticles.remove(p);
  }
}

// Draw the power ups
public void drawPowerUps() {
  if (activePowerUp != null) { // If it's there, then draw it
    activePowerUp.draw();
    
    player.touching(activePowerUp); // if we are touching it, we need to power ourselves up, and remove it.
    
    if (activePowerUp.toBeRemoved()) { activePowerUp = null; }
  }
}

// Shake the screen if we get hit
public void tryShake() {
  // Shake the screen
  if (shakeOn) {
    if (shake == 0) shake = 5;
    shake = -shake;
    translate(shake, 0);
    if (millis() - shakeStart >= 1000) { shakeOn = false; }
  }
}
