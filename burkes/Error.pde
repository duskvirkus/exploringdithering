// Error class to hold a color error
class Error {
  
  float r, g, b;
  
  Error(float r, float g, float b) {
    this.r = r;
    this.g = g;
    this.b = b;
  }
  
  // creates a new error that is scaled to input
  Error(Error e, float scaler) {
    this.r = e.r * scaler;
    this.g = e.g * scaler;
    this.b = e.b * scaler;
  }
  
}
