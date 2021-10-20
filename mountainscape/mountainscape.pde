/** 
 *  Draw some mountains with Processing.
 *  [s] to export SVG.
 *  [p] to export PDF.
 *  [f] to toggle user interface.
 *  space to regenerate with random seed.
 *  [n] to regenerate with the same seed.
 *
 *  All values to be played with are in the tweakables function. The colors can be
 *  tweaked using Processing's tweak mode. The sketch must be restarted for changes to
 *  the input string to take effect.
 *  Run the sketch in Processing's tweak mode, then adjust the values in the tweakables function!
 * 
 *** Various colour profiles. ***
 *
 * --profile 1
 * private final color startColor = #F6B191;
 * private final color endColor = #CF4D11;
 * --profile 2
 * private final color startColor = #BFDAE6;
 * private final color endColor = #448EAE;
 * --profile 3
 * private final color startColor = #D1A7BE;
 * private final color endColor = #8D4A6F;
 * --profile 4
 * private final color startColor = #F673A1;
 * private final color endColor = #C20C4C;
 * --profile 5
 * private final color startColor = #D3CDA5;
 * private final color endColor = #908647;
 * --profile 6
 * private final color startColor = #FEE6B6;
 * private final color endColor = #F3A304;
 *
 * More colours.
 * --Monochrome
 * private final color startColor = #FFFFFF;
 * private final color endColor = #080808;
 * --Purple
 * private final color startColor = #FBD6FF;
 * private final color endColor = #000000;
 * --Red
 * private final color startColor = #FFBE9D;
 * private final color endColor = #AD0A0A;
 * --Blue
 * private final color startColor = #AAE8FF;
 * private final color endColor = #086386;
 * --Purple to Orange
 * private final color startColor = #D88ED8;
 * private final color endColor = #C17715;
 **/

import processing.pdf.*;
import processing.svg.*;

int SEED = -1;
String INPUT;
color STARTCOLOR;
color ENDCOLOR;

//CHANGE OR TWEAK THESE.
void tweakables() {
  //tweakable
  STARTCOLOR = color(#BFDAE6);
  ENDCOLOR = color(#448EAE);

  //untweakable
  INPUT = "sample input text";
}

boolean redraw = true;

void setup() {
  //size(942, 1454);

  //16 x 48
  //size(2400, 4800);

  //size(600, 1200);

  size(900, 1800);
  //8 x 12
  //size(2400, 3600);

  //5 x 7
  //size(1500, 2100);

  //Might need to change this depending on the system.
  smooth(8);
}

void draw() {
  if (redraw == true) {
    tweakables();
    redraw = false;
    createLandscape(-1);
  }
}

/**
 * Create landscape using a fixed or random seed. 
 * int seed should be -1 to generate a random seed. 
 **/
void createLandscape(int seed) {
  if (seed == -1) {
    seed = (int) random(100000);
    SEED = seed;
  }
  randomSeed(seed);
  LandScape l = new LandScape(INPUT, 7, STARTCOLOR, ENDCOLOR);
  l.generate();
}

/**
 * Check keypresses and respond.
 **/
void keyPressed() {
  if (key == ' ') {
    redraw = true;
  }
  if (key == 'n') {
    tweakables();
    createLandscape(SEED);
  }
  if (key == 's') {
    saveHighRes("SVG");
  }
  if (key == 'p') {
    saveHighRes("PDF");
  }
}

/*
 * Save an output file of the current generation to \output.
 * Filetype must be a string of either "SVG" or "PDF" (case sensitive).
 * Returns and does nothing if filetype isn't recognized.
 */
void saveHighRes(String fileType) {
  String renderer;
  if (fileType == "SVG") {
    renderer = SVG;
  } else if (fileType == "PDF") {
    renderer = PDF;
  } else {
    return;
  }
  PGraphics hires = createGraphics(
    width, 
    height, 
    JAVA2D);
  println("Saving high-resolution image...");
  hires.beginDraw();
  beginRecord(renderer, "output\\hires-" + SEED + "." + fileType);
  createLandscape(SEED);
  hires.endDraw();
  endRecord();
  println("Finished");
}
