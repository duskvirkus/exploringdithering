class Particle {

  PVector location;
  PVector velocity;
  PVector acceleration;

  color c; // color

  Particle(PVector location, color c) {
    this.location = new PVector(location.x, location.y);
    this.c = c;

    velocity = new PVector();
    acceleration = new PVector();
  }

  void update() {
    velocity.add(acceleration);
    location.add(velocity);
  }

  // assumes loadPixels and updatePixels is done outside of display()
  // for better performance
  void display(PImage img) {
    int locationIndex = int(location.x + location.y * img.width);
    if (locationIndex >= 0 && locationIndex < img.pixels.length) {
      img.pixels[locationIndex] = c;
    } else {
      println("WARN: Particle location was outside of the range of pixels within image");
    }
  }
}
