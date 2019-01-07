class ColorMatrix {
  
  int w; //width
  color[] colors;
  
  ColorMatrix(color[] colors) {
    w = int(sqrt(colors.length));
    this.colors = new color[w*w];
    for (int i = 0; i < this.colors.length; i++) {
      this.colors[i] = colors[i];
    }
  }
  
  color get(int x, int y) {
    return colors[x + y * w];
  }
  
}
