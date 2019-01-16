class Particle {

  PVector location;
  PVector velocity;
  PVector acceleration;

  color c; // color
  float mass;

  Particle(PVector location, color c) {
    this.location = new PVector(location.x, location.y);
    this.c = c;

    velocity = new PVector();
    acceleration = new PVector();
    mass = 1;
  }

  void update() {
    velocity.add(acceleration);
    location.add(velocity);
    acceleration.mult(0);
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
  
  void applyForce(PVector force) {
    PVector f = new PVector(force.x, force.y);
    f.div(mass);
    acceleration.add(f);
  }
}
