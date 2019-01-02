// Exploration of Dithering
// Project 1
// Title: Floyd Steinberg
// Creator: Fi Graham

// Graphics Variables
PGraphics main; // main graphics for exporting at differt size than working
int size = 1080; // final export size
int scale = 2; // working scale, devisor for export size

// Color Variables
color primaryColor;
color secondaryColor;

// Setup Function
void setup() {
  // square format is assumed
  // would be size(size / scale, size / scale) if size accepted varibles
  size(540, 540);
  main = createGraphics(size, size);
  setupColors();
}


// Sets up Color Varaibles
void setupColors() {
  primaryColor = color(255);
  secondaryColor = color(0, 0, 170);
}

// Draw Function
void draw() {
  drawMain();
  image(main, 0, 0, width, height);
}

// Handles drawing everything in main graphics
void drawMain() {
  main.beginDraw();
  main.background(secondaryColor);
  
  main.endDraw();
}
