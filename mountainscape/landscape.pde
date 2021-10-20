/** //<>//
 * The LandScape class implements a LandScape object.
 * The actual landscape is generated and written to the canvas
 * by calling generate, which is the only public class member.
 **/

public class LandScape { 

  private color startColor;
  private color endColor;
  private int maxDepth;
  private int alphaIndex = 0;
  private String input;
  
  //This is a dictionary of "height weights" for various characters.
  //If a character does not exist in this dictionary with a weight, 
  //the program will crash.
  private final FloatDict alphaWeights =  new FloatDict(new Object[][] {
    { "A", 0.125 }, 
    { "B", 0.25 }, 
    { "C", 0.375 }, 
    { "D", 0.5 }, 
    { "E", 0.625 }, 
    { "F", 0.75 }, 
    { "G", 0.875 }, 
    { "H", 1.00 }, 
    { "I", 1.125 }, 
    { "J", 1.25 }, 
    { "K", 1.375 }, 
    { "L", 1.5 }, 
    { "M", 1.625 }, 
    { "N", 1.75 }, 
    { "O", 1.875 }, 
    { "P", 2.00 }, 
    { "Q", 2.125 }, 
    { "R", 2.25 }, 
    { "S", 2.375 }, 
    { "T", 2.5 }, 
    { "U", 2.625 }, 
    { "V", 2.75 }, 
    { "W", 2.875 }, 
    { "X", 3.00 }, 
    { "Y", 3.00 }, 
    { "Z", 3.00 }, 
    { ".", 0.25 }, 
    { ",", 0.25 }, 
    { " ", 0.25 }, 
    { "'", 0.25 }, 
    }); 

  /**
   * Create an instance of Landscape
   * String input - the input string to generate mountains based on.
   * int maxDepth - the number of mountain layers to create. First layer is 
   *                always the background/sky.
   * color startColor - The beginning color (background/sky).
   * color endColor - The ending color (foreground/closest mountain layer).
   **/
  public LandScape(String input, int maxDepth, color startColor, color endColor) {
    this.input = input;
    this.maxDepth = maxDepth;
    this.startColor = startColor;
    this.endColor = endColor;
  }

  /**
   * Start generating the mountainscape.
   **/
  public void generate() {

    //Initialize background colour
    background(startColor);

    //Start at first character within input string.
    alphaIndex = 0;

    //Define first layer height.
    int y = height / 2;

    //Begin at second step to make first mountain layer a more distinct colour.
    for (int i = 0; i < this.maxDepth; i++) { 
      float inter = map(i + 2, 1, maxDepth, 0, 1);
      color c = lerpColor(startColor, endColor, inter);
      int[] r = new int[2];
      r[0] = 0;
      r[1] = y;
      // Not working as I'd like.
      //if (i == 5 || i == 7) {
      //  createCloud(r[1]);
      //}
      while (checkXBounds(r[0]) != false) {
        r = createMountain(r[0], r[1], y, c);
      }
      y = y + (y / 15);
    }
  }

  /**
   * Make a single mountain at x, y, of color c. Requires ref as a reference
   * base-y level.
   * Return an array with x,y coordinates of the last touched pixel.
   **/
  private int[] createMountain(int x, int y, int ref, color c) {
    //stroke(black);
    //strokeWeight(1);
    boolean up = true;
    int baseMaxHeight = height / 18;
    int currentHeight = 0;

    /**
     * Determine values from the current character in the input string.
     **/

    //If the current character is end of string, restart at beginning of string.
    if (alphaIndex > this.input.length() - 1) {
      print("completed string!\n");
      alphaIndex = 0;
    }

    //maxHeight is determined by reading input character by chracter.  
    String inputCharacter = Character.toString(Character.toUpperCase(this.input.charAt(alphaIndex)));
    print(inputCharacter);
    int maxHeight = (int) ((float) baseMaxHeight * (alphaWeights.get(inputCharacter) / 2));
    if (y > ref) {
      maxHeight += y - ref;
    }
    if (y < ref) {
      maxHeight -= ref - y;
    }
    int stopHeight = (int) ((float) maxHeight / alphaWeights.get(inputCharacter));
    alphaIndex++;

    //Make a mountain starting at x, y. 
    PShape m;
    m = createShape();
    m.beginShape();
    m.fill(c);
    m.noStroke();

    while (true) {
      m.vertex(x, y);
      /** 
       * Determine the x, y of the next vertex and increment the mountain length
       * or height, as required. 
       * Note: Current mountain height goes up as y coordinate goes down.
       **/

      //Sometimes, just go straight and do not increase or decrease
      //the mountain's height. This provides a jagged effect.  
      if ((int) random(0, 100) <= 40) {
        x++;
        continue;
      }

      //Walk up the mountain.
      if (up == true) {
        if (ref <= y || currentHeight < maxHeight) {
          currentHeight++;
          y -= 1;
        } else if (currentHeight >= maxHeight) {
          currentHeight--;
          y += 1;
          up = false;
        } else {
          print("should not be here\n");
          print("currentHeight: " + currentHeight + "\n");
          print("maxHeight: " + maxHeight + "\n");
        }
        //Walk down the mountain.
      } else {
        if (currentHeight <= stopHeight) {
          break;
        }
        currentHeight--;
        y += 1;
      }
      x++;
    }
    //Set ending vertices to bottom of canvas to fill out the mountains.
    m.vertex(x, height);
    m.vertex(0, height);

    //Close shape and write to canvas.
    m.endShape(CLOSE);
    shape(m, 0, 0);

    //Return endpoint.
    int[] r = new int[2];
    r[0] = x;
    r[1] = y;
    return r;
  }

  /**
   * Check if the next y pixel exceeds the bounds of the screen.
   **/
  private boolean checkYBounds(int y) {
    if (y + 1 > height) {
      return false;
    }
    return true;
  }

  /**
   * Check if the next x pixel exceeds the bounds of the screen.
   **/
  private boolean checkXBounds(int x) {
    if (x + 1 > width) {
      return false;
    }
    return true;
  }

  // This is commented because it doesn't work like I had hoped. This was intended
  // to be called in generate between mountain layers.
  //
  //private void createCloud(int ref) {
  //  noiseSeed(input.length());
  //  //noiseSeed(Integer.parseInt(String.valueOf(input)));
  //  //print(Integer.parseInt(String.valueOf(input)));


  //  //Create cylinder mask. 
  //  PGraphics fogMaskCyl = createGraphics(width, height);
  //  fogMaskCyl.beginDraw();
  //  for (int i = ref - 75; i <= fogMaskCyl.height; i++) {
  //    float inter = map(i, ref - 75, fogMaskCyl.height, 0, 1); 
  //    color c = lerpColor(color(0), color(255), inter);
  //    fogMaskCyl.stroke(c);
  //    fogMaskCyl.line(0, i, fogMaskCyl.width, i);
  //  }
  //  fogMaskCyl.endDraw();

  //  //Create radial mask.
  //  PGraphics fogMaskEll = createGraphics(width, height);
  //  fogMaskEll.beginDraw();
  //  int radius = 600;
  //  for (int r = radius; r > 0; r--) {
  //    float inter = map(r, 1, radius, 0, 1);
  //    color c = lerpColor(color(255), color(0), inter);
  //    //fogMaskEll.background(color(0));
  //    fogMaskEll.noStroke();
  //    fogMaskEll.fill(c);
  //    fogMaskEll.ellipse(map(alphaIndex, 1, input.length(), 1, width), ref, r, r);
  //  }
  //  fogMaskEll.endDraw();


  //  PGraphics fog = createGraphics(width, height);
  //  fog.beginDraw();
  //  float increment = 0.0045;
  //  fog.loadPixels();
  //  float xoff = 0.0; // Start xoff at 0
  //  //float detail = map(mouseX, 0, width, 0.1, 0.6);
  //  noiseDetail(4, 0.8);
  //  //float alpha;
  //  // For every x,y coordinate in a 2D space, calculate a noise value and produce a brightness value
  //  for (int x = 0; x < width; x++) {
  //    xoff += increment;   // Increment xoff 
  //    float yoff = 0.0;   // For every xoff, start yoff at 0
  //    for (int y = 0; y < height; y++) {
  //      yoff += increment; // Increment yoff

  //      // Calculate noise and scale by 255
  //      float bright = noise(xoff, yoff) * 255;

  //      // Try using this line instead
  //      //float bright = random(0,255);

  //      // Set each pixel onscreen to a grayscale value
  //      fog.pixels[x + y * width] = color(bright);
  //    }
  //  }
  //  fog.updatePixels();
  //  fog.endDraw();


  //  //blendMode(REPLACE);
  //  //PGraphics finalMask = createGraphics(width, height);
  //  //finalMask.beginDraw();
  //  //finalMask.blend(fogMaskCyl, 0, 0, width, height, 0, 0, width, height, LIGHTEST);
  //  //finalMask.blend(fogMaskEll, 0, 0, width, height, 0, 0, width, height, LIGHTEST);
  //  //finalMask.endDraw();
  //  ////blendMode(LIGHTEST);
  //  //fog.mask(finalMask);

  //  blendMode(LIGHTEST);
  //  fog.mask(fogMaskCyl);
  //  //fog.mask(fogMaskEll);
  //  //fog.mask(fogMaskEll);

  //  image(fog, 0, 0);
  //}
}
