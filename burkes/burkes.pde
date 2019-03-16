// #############################################################################
// Exploring Dithering
// Project 3
// Title: Burkes
// Creator: Fi Graham
// #############################################################################

// #############################################################################
// Global Variables

// Environment Variables
boolean export = false;
String savePath = "burkes-bark-1.png";
PGraphics main; // main graphics for exporting at different size than working
int size = 1080; // final export size, includes boarder
int scale = 2; // working scale, divisor for export size
int border = 200;
int downSampleFactor = 4; // must be 1 or 2^something

// Color Variables
color primaryColor;
color secondaryColor;

// Image
PImage img;
String imagePath = "bark-1.jpg";

// #############################################################################
// Setup

// Setup Function
void setup() {  
  size(540, 540);
  setupEnviroment();
  setupColors();
  setupImage();
  processImage();
  drawToMain();
  image(main, 0, 0, width, height);
  if (export) {
    main.save(savePath);
  }
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
  img = loadImage(imagePath);
  // pre processing image
  img.resize(size/downSampleFactor, size/downSampleFactor);
  img.filter(GRAY);
}

// #############################################################################
// Image Processing

// Handles image processing
void processImage() {
  burkesAlgorithm(img, 1);
  changeColor(
    img,
    new ColorPair(color(255), primaryColor),
    new ColorPair(color(0), secondaryColor)
  );
  img = upSampleImage(img, downSampleFactor);
}

// Handles drawing image in main graphics
void drawToMain() {
  main.beginDraw();
  main.background(secondaryColor);
  main.image(img, border, border);
  main.endDraw();
}

// will replace first color in ColorPair with second color in ColorPair
void changeColor(PImage img, ColorPair... pairs) {
  img.loadPixels();
  for (int i = 0; i < img.pixels.length; i++) {
    for (ColorPair pair : pairs) {
      if (img.pixels[i] == pair.first) {
        img.pixels[i] = pair.second;
      }
    }
  }
  img.updatePixels();
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

// implyments burkes dithering alogrithim
void burkesAlgorithm(PImage img, int factor) {
  img.loadPixels();
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      color input = img.pixels[index(x, y, img.width)];
      color closest = closestColor(input, factor);
      img.pixels[index(x, y, img.width)] = closest;
      Error error = calculateError(input, closest);
      distributeError(img, error, index(x + 1, y    , img.width), 8 / 32.0);
      distributeError(img, error, index(x + 2, y    , img.width), 4 / 32.0);
      distributeError(img, error, index(x - 2, y + 1, img.width), 2 / 32.0);
      distributeError(img, error, index(x - 1, y + 1, img.width), 4 / 32.0);
      distributeError(img, error, index(x    , y + 1, img.width), 8 / 32.0);
      distributeError(img, error, index(x + 1, y + 1, img.width), 4 / 32.0);
      distributeError(img, error, index(x + 2, y + 1, img.width), 2 / 32.0);
    }
  }
  img.updatePixels();
}

// will quantize a color
color closestColor(color input, int factor) {
  return (
    color(
      closestColorHelper(red(input)  , factor), 
      closestColorHelper(green(input), factor), 
      closestColorHelper(blue(input) , factor)
    )
  );
}

// helps closestColor function
int closestColorHelper(float input, int factor) {
  return round(factor * input / 255) * (255 / factor);
}

// calculates error given two colors
Error calculateError(color input, color closest) {
  return (
    new Error(
      red(input)   - red(closest)  ,
      green(input) - green(closest),
      blue(input)  - blue(closest) 
    )
  );
}

// distributes error to pixel at specified index
void distributeError(PImage img, Error error, int index, float amount) {
  if (insideImage(img, index)) {
    color current = img.pixels[index];
    Error scaledError = new Error(error, amount);
    img.pixels[index] = addError(current, scaledError);
  }
}

// checks if index is inside image pixels array
boolean insideImage(PImage img, int index) {
  if (index >= 0 && index < img.width * img.height) {
    return true;
  }
  return false;
}

// adds error to a color
color addError(color c, Error error) {
  return (
    color(
      red(c)   + error.r,
      green(c) + error.g,
      blue(c)  + error.b
    )
  );
}
