/** //<>//
 * Um movimento com unidade de cor, textura e comportamento 
 */
class Stroke {

  //---------- movimento
  PVector position, 
          speed, 
          acceleration;
  float   initialX, initialY;
  float   orientation;
  
  //---------- cor e textura
  color   strokeColor;
  float   transparency;
  float   tDecay;
  
  //---------- tamanho
  float   size;
  float   variation;
  float   strokeLength;
  
  //---------- parâmetros
  float   frequency, amplitude, duration;

  /**
   * Construtor completo
   *
   * @params  color  cor da pincelada   
   *          float  coordenada x inicial 
   *          float  coordenada y inicial
   *          float  largura da pincelada - tamanho dos círculos
   *          float  taxa de variação no tamanho e movimento
   *          float  orientação do movimento
   *          float  frequência a partir da qual foi criada
   *          float  amplitude a partir da qual foi criada
   */
  Stroke(color c, float x, float y, float s, float var, float orient, float freq, float amp) {
    strokeColor = c;
    transparency = 1;
    tDecay = 0.03;

    initialX = x;
    initialY = y;
    position = new PVector(x, y);
    size = s;

    frequency = freq;
    amplitude = amp;     
    strokeLength = 0;
    
    variation = var;
    orientation = orient;
    speed = new PVector(cos(orientation), sin(orientation));

    float mult = (Constant.AMPLITUDE_RANGE[1] - amplitude)/10000;
    mult = constrain(mult, 0.001, 0.004);
    float xacc = random(-frequency, frequency) * mult;
    float yacc = random(-frequency, frequency) * mult;
    acceleration = new PVector(xacc, yacc);
  }

  /**
   * @returns  color  cor da pincelada
   */
  color getColor() {
    return strokeColor;
  }

  /**
   * @returns  float  coordenada x atual
   */
  float getX() {
    return position.x;
  }

  /**
   * @returns  float  coordenada y atual
   */
  float getY() {
    return position.y;
  }

  /**
   * @returns  float[]  coordenadas iniciais
   */
  float[] firstPosition() {
    float[] pos = {initialX, initialY};
    return pos;
  }
  
  /**
   * @returns  float[]  últimas coordenadas
   */
  float[] lastPosition() {
    float[] pos = {getX(), getY()};
    return pos;
  }
  
  /**
   * @returns  float  comprimento máximo que a pincelada pode assumir
   */
  float maxLength() {
    return Constant.MAX_STROKE_LENGTH - frequency/2;
  }

  /**
   * Define taxa de decaimento da transparência
   *
   * @params float  taxa de decaimento
   */
  void setDecay(float decay) {
    tDecay = decay;
  }
  
  /**
   * Recebe duração da pintura
   * - não serve pra nada, por enquanto, por motivos de tempo...
   *
   * @params float  duração
   */
  void setDuration(float dur) {
    duration = dur;
  }

  /**
   * Pinta stroke enquanto o programa roda, uma unidade por vez
   */
  void paint() {
    // não permite que a pincelada ultrapasse um tamanho máximo
    if (strokeLength < maxLength()) {
      speed.add(acceleration);
      position.add(speed);
  
      // altera tamanho e transparência para próxima unidade
      transparency -= tDecay;
      size += (variation/10);
      createPoint(strokeColor, transparency, getX(), getY(), size);
      splash();
      strokeLength++;
    }
  }

  /**
   * Gera respingos aleatórios, criando alguma textura 
   */  
  void splash() {
    float t = transparency * random(0.6);
    float distanceRadius = size * (variation*0.6);
    float distance = random(size/5, distanceRadius);
    float theta    = sqrt(random(0.0, 1.0)) * TWO_PI;
    float x = distance * cos(theta) + getX();  // coordenada x de referência
    float y = distance * sin(theta) + getY();  // coordenada y de referência
    float s = size * random(0.4);
    
    createPoint(strokeColor, t, x, y, s);
  }

  /**
   * Cria a unidade: o círculo com cor, transparência, posição e tamanho pré determinados
   *
   * @params  color  cor
   *          float  transparência da cor
   *          float  coordenada x do ponto
   *          float  coordenada y do ponto
   *          float  tamanho
   */
  void createPoint(color c, float t, float x, float y, float s) {
    fill(c, t);
    ellipse(x, y, s, s);
  }
}
