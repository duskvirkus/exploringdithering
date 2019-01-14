// Exploration of Dithering
// Project 3
// Title: Patterning
// Creator: Fi Graham

// Enviroment Variables
boolean export = false;
String savePath = "patterning-chair.png";
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
String imagePath = "chair.png";

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
  patterningDither(img, 3, color(0));
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

// applies patterning dither
void patterningDither(PImage img, int scale, color borderColor) {
  img.loadPixels();
  PImage scaled = scaleDown(img, scale);
  scaled.loadPixels();
  ArrayList<ColorMatrix> matrixes = generateColorMatrixes(scale);
  for (int y = 0; y < scaled.height; y++) {
    for (int x = 0; x < scaled.width; x++) {
      float brightness = brightness(scaled.pixels[index(x, y, scaled.width)]);
      int closest = closestMatrix(brightness, matrixes.size());
      for (int j = 0; j < scale; j++) {
        for (int i = 0; i < scale; i++) {
          img.pixels[index(x * scale + i, y * scale + j, img.width)] = 
          matrixes.get(closest).get(i, j);
        }
      }
    }
  }
  // removes unused pixels
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

// returns a smaller copy of the image
PImage scaleDown(PImage img, int factor) {
  PImage output = img.copy();
  output.resize(img.width/factor, img.height/factor);
  return output;
}

// creates color matrixes for patterning
ArrayList<ColorMatrix> generateColorMatrixes(int size) {
  ArrayList<ColorMatrix> matrixes = new ArrayList<ColorMatrix>();
  color w = color(255);
  color b = color(0);
  color[] colors = new color[size * size];
  for (int i = 0; i < colors.length; i++) {
    colors[i] = w; // start with all white pixels;
  }
  matrixes.add(new ColorMatrix(colors.clone())); // all white matrix
  int[] indexes = getIndexes(size);
  for (int i = 0; i < indexes.length; i++) {
    colors[indexes[i]] = b;
    matrixes.add(new ColorMatrix(colors.clone()));
  }
  return matrixes;
}

// returns indexes in order of growing from the top left corner in L shape
int[] getIndexes(int size) {
  int[] indexes = new int[size * size];
  int i = 0;
  int currentSize = 1;
  while (currentSize <= size) {
    for (int y = 0; y < currentSize - 1; y++) {
      indexes[i] = index(currentSize - 1, y, size);
      i++;
    }
    for (int x = 0; x < currentSize; x++) {
      indexes[i] = index(x, currentSize - 1, size);
      i++;
    }
    currentSize++;
  }
  return indexes;
}

// helper to find cloest matrix given a color input
int closestMatrix(float input, int numberOfMatrixes) {
  return int(map(input, 0, 255, 0, numberOfMatrixes -1));
}
