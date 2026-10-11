public class Music {
  private SoundFile[] ticks; // array of notes
  
  private int currentTick = 0; // Ppinter to which note we are on
  private int delay = 1000; // Delay between each note
  private long lastPlayTime; // Last time it was played.
  
  // Load each audio track
  public Music(PApplet sketch) {
    ticks = new SoundFile[4]; // Array of notes
    ticks[0] = new SoundFile(sketch, "Audio/Music/fastinvader1.wav");
    ticks[1] = new SoundFile(sketch, "Audio/Music/fastinvader2.wav");
    ticks[2] = new SoundFile(sketch, "Audio/Music/fastinvader3.wav");
    ticks[3] = new SoundFile(sketch, "Audio/Music/fastinvader4.wav");
    lastPlayTime = millis(); // Mark the start of the music.
  }
  
  // Play the notes if we have reached the delay between them
  public void play() {
    long currentTime = millis();
      
    if (currentTime - lastPlayTime >= delay) {
      ticks[currentTick].play();
        
      currentTick = (currentTick+1) % 4; // wrap back around
      
      lastPlayTime = currentTime;
    }
  }
  
  // Increase the speed as enemies die
  public void increaseSpeed(int offset) {
    int newDelay = delay - offset;
    delay = Math.max(newDelay, 100); // Stop decreasing at 100ms
    if (delay != 100 && delay % 50 == 0) { handler.increaseSpeed(); } // Increase the enemies speed as well!
  }
  
  // Reset the delay back to 1 second between notes.
  public void reset() {
    delay = 1000;
  }
}
