/**
 * Constantes para todo o sistema
 */
static class Constant {

  //---------- configuração do sistema
  static final float MAX_SILENCE_DURATION = 30000;  // 30s
  
  //---------- configuração de cor
  static final int   HUE           = 360;
  static final int   SATURATION    = 100;
  static final int   BRIGHTNESS    = 100;
  static final float TRANSPARENCY  = 1.0;
  
  //---------- configuração de pincelada
  static final float DEFAULT_SIZE      = 35;
  static final float MIN_STROKE_RADIUS = DEFAULT_SIZE;
  static final float MAX_STROKE_LENGTH = DEFAULT_SIZE*4;
  //static final float MAX_NUM_STROKES   = 500;
  
  //---------- valores para considerar mudanças como significativas
  static final float FREQUENCY_CHANGE = 10.0;
  static final float AMPLITUDE_CHANGE =  8.0;

  //---------- faixas para conversão - valores mínimos e máximos
  static final float[] MIDI_FREQUENCY_RANGE = {28, 93};   // E1 - A6
  static final float[] AMPLITUDE_RANGE      = {-50, -10};
  
  // 22, 22, 22
  static final int[] HUE_RANGE_FOR_FREQUENCY = {
    227, 248, 
    315, 336, 
    40, 61
  };
  
  // 13, 15, 13
  static final int[] HUE_RANGE_FOR_AMPLITUDE = {
    203, 225,
    235, 249,
    347, 359
  };
  
  // 13, 15, 13
  static final int[] SATURATION_RANGE = { 
    46, 58,
    65, 79,
    87, 99
  };

  // 22, 22, 22
  static final int[] BRIGHTNESS_RANGE = {
    25, 46,
    50, 71, 
    78, 99
  };
  
  //---------- valores mínimos para mudanças na variação e no tamanho
  static final float INCREASE_VARIATION_FREQUENCY = 50;
  static final float STOP_VARIATION_FREQUENCY     = 90;
  static final float INCREASE_SIZE_AMPLITUDE      = -30.0;
  
  //---------- conversão de frequência - referência à nota A4
  static final float BASE_HZ   = 440;
  static final float BASE_MIDI = 69;
}
