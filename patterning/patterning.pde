// Exploration of Dithering
// Project 3
// Title: Patterning
// Creator: Fi Graham

// Enviroment Variables
boolean export = false;
String savePath = "floyd-steinburg-cctv.png";
PGraphics main; // main graphics for exporting at differt size than working
int size = 1080; // final export size, includes boarder
int scale = 2; // working scale, devisor for export size
int border = 200;
int downSampleFactor = 4; // must be 1 or 2^something

// Color Variables
color primaryColor;
color secondaryColor;

// Image
PImage img;
String imagePath = "CCTV.png";

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

// Handles image processing
void processImage() {
  patterningDither(img, color(0));
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

void patterningDither(PImage img, color borderColor) {
  int scale = 3; // TODO improve so this can be changed
  img.loadPixels();
  PImage scaled = scaleDown(img, scale);
  scaled.loadPixels();
  ArrayList<ColorMatrix> matrixes = getColorMatrixes();
  for (int y = 0; y < scaled.height; y++) {
    for (int x = 0; x < scaled.width; x++) {
      float brightness = brightness(scaled.pixels[index(x, y, scaled.width)]);
      int closest = closestMatrix(brightness, matrixes.size());
      for (int j = 0; j < scale; j++) {
        for (int i = 0; i < scale; i++) {
          img.pixels[index(x * scale + i, y * scale + j, img.width)] = matrixes.get(closest).get(i, j);
        }
      }
    }
  }
  for (int y = scaled.height * scale; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      img.pixels[index(x, y, img.width)] = borderColor;
    }
  }
  for (int x = scaled.width * scale; x < img.width; x++) {
    for (int y = 0; y < img.height; y++) {
      img.pixels[index(x, y, img.width)] = borderColor;
    }
  }
  img.updatePixels();
}

PImage scaleDown(PImage img, int factor) {
  PImage output = img.copy();
  output.resize(img.width/factor, img.height/factor);
  return output;
}

// TODO improve with generating matrix using an alogrithm
ArrayList<ColorMatrix> getColorMatrixes() {
  ArrayList<ColorMatrix> matrixes = new ArrayList<ColorMatrix>();
  color b = color(0);
  color w = color(255);
  matrixes.add(new ColorMatrix(new color[]
  {b,b,b,
   b,b,b,
   b,b,b}));
  matrixes.add(new ColorMatrix(new color[]
  {b,b,b,
   b,b,b,
   b,b,w}));
  matrixes.add(new ColorMatrix(new color[]
  {w,b,b,
   b,b,b,
   b,b,w}));
  matrixes.add(new ColorMatrix(new color[]
  {w,b,b,
   b,b,b,
   w,b,w}));
  matrixes.add(new ColorMatrix(new color[]
  {w,b,b,
   w,b,b,
   w,b,w}));
  matrixes.add(new ColorMatrix(new color[]
  {w,b,b,
   w,b,b,
   w,w,w}));
  matrixes.add(new ColorMatrix(new color[]
  {w,b,w,
   w,b,b,
   w,w,w}));
  matrixes.add(new ColorMatrix(new color[]
  {w,w,w,
   w,b,b,
   w,w,w}));
  matrixes.add(new ColorMatrix(new color[]
  {w,w,w,
   w,b,w,
   w,w,w}));
  matrixes.add(new ColorMatrix(new color[]
  {w,w,w,
   w,w,w,
   w,w,w}));
  return matrixes;
}

int closestMatrix(float input, int numberOfMatrixes) {
  float step = 255 / numberOfMatrixes;
  return int(input/step);
}
