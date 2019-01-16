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
    if (currentIndex() >= 0 && currentIndex() < img.pixels.length) { // check index
      img.pixels[currentIndex()] = c;
    }
  }
  
  void applyForce(PVector force) {
    PVector f = new PVector(force.x, force.y);
    f.div(mass);
    acceleration.add(f);
  }
  
  int currentIndex() {
    return int(location.x + location.y * img.width);
  }
  
}
