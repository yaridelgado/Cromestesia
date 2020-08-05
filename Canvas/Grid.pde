/**
 * Coordena posição e distribuição das pinceladas na tela
 */
class Grid {

  // para controle de composição - vai dar tempo não...
  //float unityWidth, unityHeight;

  Grid() {
    //unityWidth  = width/120;
    //unityHeight = height/120;
  }

  /**
   * Determina posição da próxima stroke
   *
   * @params  Stroke  referência anterior
   *          color   cor da próxima pincelada
   *          float   taxa de incremento da distância em relação à pincelada referência
   *
   * @returns float[] coordenadas x e y iniciais da próxima pincelada
   *
   */
  float[] nextPosition(Stroke previous, color nextColor, float increaseRate) {
    float[] coordinates = new float[2];
    // valores inválidos para inicialização, permitindo a geração aleatória
    float x = -1.0, y = -1.0;

    // verifica se existe pincelada de referência
    if (previous != null) {
      float[] refPosition = previous.lastPosition();
      float hueDiff = abs(hue(previous.getColor()) - hue(nextColor));
      float distanceRadius = (Constant.MIN_STROKE_RADIUS + hueDiff) * increaseRate; 

      /**
       * Solução para escolher pontos aleatórios, proporcionalmente distribuídos, dentro de uma área circular
       * 
       * FOGERTY, Brandon. Random Points in a Circle: Exploiting the Area of a Circle
       * xdPixel, 23 de jun. de 2015
       * Disponível em: <http://xdpixel.com/random-points-in-a-circle/>
       * Acesso em: 30 de abr. de 2019
       */
      float distance = random(0, distanceRadius);
      float theta    = sqrt(random(0.0, 1.0)) * TWO_PI;

      x = distance * cos(theta) + refPosition[0];  // x de referência
      y = distance * sin(theta) + refPosition[1];  // y de referência
    }

    // gera coordenadas aleatórias caso os valores existam fora da tela
    // ou caso a pincelada de referência não exista
    if (x < 0 || x > width) {
      x = sqrt(random(0.0, 1.0)) * width;
    }

    if (y < 0 || y > height) {
      y = sqrt(random(0.0, 1.0)) * height;
    }

    coordinates[0] = x;
    coordinates[1] = y;
    return coordinates;
  }

  //float isFilled() {}
  //float searchForEmptyAreas() {}
  //float searchForCrowdedAreas() {}
  //float[] getPosOnEmptyArea() {}
  //float[] getPosOnCrowdedArea() {}
}
