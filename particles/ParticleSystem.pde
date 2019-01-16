class ParticleSystem {
  
  ArrayList<Particle> particles = new ArrayList<Particle>();
  
  ParticleSystem() {
    
  }
  
  void display(PImage img) {
    img.loadPixels();
    for (Particle p : particles) {
      p.display(img);
    }
    img.updatePixels();
  }
  
}
