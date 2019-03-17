// #############################################################################
// Exploring Dithering
// Project 5
// Title: Independent Particles
// Creator: Fi Graham
// #############################################################################
// Could use some refactoring and performance improvements.

// #############################################################################
// Global Variables

// Environment Variables
boolean export = false;
String savePath = "particles-fog-trees.png";
PGraphics main; // main graphics for exporting at different size than working
int size = 1080; // final export size, includes boarder
int scale = 2; // working scale, divisor for export size
int border = 200;
int downSampleFactor = 4; // must be 1 or 2^something

// Color Variables
color primaryColor;
color secondaryColor;

// Image
PImage original;
PImage img;
PImage changed;
String imagePath = "FogTrees.png";

// Particles
ParticleSystem particleSystem;
int particleSteps = 3;

// #############################################################################
// Setup

// Setup Function
void setup() {  
  size(540, 540);
  setupEnviroment();
  setupColors();
  setupImage();
  for (int i = 0; i < particleSteps; i++) {
    moveParticles();
    showParticles();
  }
  drawToMain();
  image(main, 0, 0, width, height);
  if (export) {
    main.save(savePath);
  }
  noLoop();
}

// sets up main graphics and size
void setupEnviroment() {
  // square format is assumed
  // create main graphics before border changes size variable
  main = createGraphics(size, size);
  // account for border in size
  size = size - border * 2;
}

// Sets up Color Varaibles
void setupColors() {
  primaryColor = color(255);
  secondaryColor = color(0, 0, 170);
}

// loads image and does some pre processing
void setupImage() {
  original = loadImage(imagePath);
  // pre processing image
  original.resize(size/downSampleFactor, size/downSampleFactor);
  original.filter(GRAY);
  img = original.get();
  particleSystem = new ParticleSystem(img, 0.91); // 0.91 for cctv-1.png - 0.87 for cctv-2.png - 0.81 for cctv-3.png
}

// #############################################################################
// Particles

void moveParticles() {
  particleSystem.update();
  particleSystem.applyErrorForces(original, img);
  showParticles();
}

// Handles image processing
void showParticles() {
  img = createImage(original.width, original.height, ARGB);
  particleSystem.display(img);
  changed = changeColor(
    img,
    new ColorPair(color(255), primaryColor),
    new ColorPair(color(0), secondaryColor)
  );
  changed = upSampleImage(changed, downSampleFactor);
}

// Handles drawing image in main graphics
void drawToMain() {
  main.beginDraw();
  main.background(secondaryColor);
  main.image(changed, border, border);
  main.endDraw();
}

// will replace first color in ColorPair with second color in ColorPair in new Image
PImage changeColor(PImage img, ColorPair... pairs) {
  PImage changed = img.get();
  img.loadPixels();
  changed.loadPixels();
  for (int i = 0; i < img.pixels.length; i++) {
    for (ColorPair pair : pairs) {
      if (img.pixels[i] == pair.first) {
        changed.pixels[i] = pair.second;
      }
    }
  }
  changed.updatePixels();
  return changed;
}

// scales an image up directly, nothing fancy
PImage upSampleImage(PImage in, int factor) {
  in.loadPixels();
  PImage out = createImage(in.width * factor, in.height * factor, ARGB);
  out.loadPixels();
  for (int x = 0; x < out.width; x++) {
    for (int y = 0; y < out.height; y++) {
      int indexIn = x/factor + y/factor * in.width;
      int indexOut = x + y * out.width;
      out.pixels[indexOut] = in.pixels[indexIn];
    }
  }
  out.updatePixels();
  return out;
}

// simple function to calculate index of 2d data in one 1d array
int index(int x, int y, int w) {
  return x + y * w;
}

color closestColor(float input, float amplification) {
  return color(round(input * amplification / 255) * 255);
}
