class ParticleSystem {

  ArrayList<Particle> particles = new ArrayList<Particle>();

  ParticleSystem(PImage img, float amplification) {
    img.loadPixels();
    for (int y = 0; y < img.height; y++) {
      for (int x = 0; x < img.width; x++) {
        float input = brightness(img.pixels[index(x, y, img.width)]);
        color closest = closestColor(input, amplification);
        Particle p = new Particle(new PVector(x, y), closest);
        particles.add(p);
      }
    }
  }

  void update() {
    for (Particle p : particles) {
      p.update();
    }
  }

  void display(PImage img) {
    img.loadPixels(); 
      for (Particle p : particles) {
      p.display(img);
    }
    img.updatePixels();
  }

  // assumed source and current are the same resolution
  void applyErrorForces(PImage source, PImage current) {
    for (int i = 0; i < source.pixels.length; i++) {
      float error = brightness(source.pixels[i]) - brightness(current.pixels[i]);
      // error = abs(error);
      for (Particle p : particles) {
        if (p.currentIndex() == i) {
          PVector v = PVector.random2D();
          v.mult(error * 0.00001);
          p.applyForce(v);
        }
      }
    }
  }
}
