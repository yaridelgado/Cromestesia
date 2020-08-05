/**
 * Configura definições de cor e é responsável por converter dados em cor
 */
class ColorController {
  private color backgroundColor;
  private color actualColor;    // cor atual do sistema, usada nas pinceladas

  //---------- listas de conversão
  HashMap<Float, Integer> frequencyToHue, 
                          amplitudeToHue, 
                          amplitudeToSaturation, 
                          frequencyToBrightness;

  ColorController() {
    // cor padrão de fundo, cor inicial média
    this(color(0, 0, 0), color(248, 60, 70));
  }

  /**
   * Inicializa as variáveis da classe
   * Inicializa as listas de conversão, associando diferentes arrays de constantes
   *
   * @params  color  cor padrão do fundo da tela
   *          color  cor inicial do sistema
   */
  ColorController(color bg, color c) {
    colorMode(HSB, Constant.HUE, Constant.SATURATION, Constant.BRIGHTNESS, Constant.TRANSPARENCY);
    
    backgroundColor = bg;
    actualColor     = c;
    fill(actualColor);
    
    frequencyToHue = new HashMap();
    amplitudeToHue = new HashMap();
    amplitudeToSaturation = new HashMap();
    frequencyToBrightness = new HashMap();

    //============================================================= INICIALIZAÇÃO DAS CONSTANTES
    /**
     * Percorre as faixas de cor para relacioná-las às faixas de frequência
     * Define frequências chave para valores de cor
     */
    for (int m = 0; m < Constant.MIDI_FREQUENCY_RANGE.length; m+=2) {
      float i = Constant.MIDI_FREQUENCY_RANGE[m];
      for (int n = 0; n < Constant.HUE_RANGE_FOR_FREQUENCY.length; n+=2) {
        for (int j = Constant.HUE_RANGE_FOR_FREQUENCY[n]; i <= Constant.MIDI_FREQUENCY_RANGE[m+1] && j <= Constant.HUE_RANGE_FOR_FREQUENCY[n+1]; i+=1.0, j++) {
          frequencyToHue.put(i, j);
        }
      }
    }
    
    /**
     * Percorre as faixas de amplitude para relacioná-las às faixas de cor
     * Define amplitudes chave para valores de cor
     */
    for (int m = 0; m < Constant.AMPLITUDE_RANGE.length; m+=2) {
      float i = Constant.AMPLITUDE_RANGE[m];
      for (int n = 0; n < Constant.HUE_RANGE_FOR_AMPLITUDE.length; n+=2) {
        for (int j = Constant.HUE_RANGE_FOR_AMPLITUDE[n]; i <= Constant.AMPLITUDE_RANGE[m+1] && j <= Constant.HUE_RANGE_FOR_AMPLITUDE[n+1]; i+=1.0, j++) {
          amplitudeToHue.put(i, j);
        }
      }
    }

    /**
     * Percorre as faixas de amplitude para relacioná-las às faixas de saturação
     * Define amplitudes chave para valores de saturação
     */
    for (int m = 0; m < Constant.AMPLITUDE_RANGE.length; m+=2) {
      float i = Constant.AMPLITUDE_RANGE[m];
      for (int n = 0; n < Constant.SATURATION_RANGE.length; n+=2) {
        for (int j = Constant.SATURATION_RANGE[n]; i <= Constant.AMPLITUDE_RANGE[m+1] && j <= Constant.SATURATION_RANGE[n+1]; i+=1.0, j++) {
          amplitudeToSaturation.put(i, j);
        }
      }
    }

    /**
     * Percorre as faixas de brilho para relacioná-las às faixas de frequência
     * Define frequências chave para valores de brilho
     */
    for (int m = 0; m < Constant.MIDI_FREQUENCY_RANGE.length; m+=2) {
      float i = Constant.MIDI_FREQUENCY_RANGE[m];
      for (int n = 0; n < Constant.BRIGHTNESS_RANGE.length; n+=2) {
        for (int j = Constant.BRIGHTNESS_RANGE[n]; i <= Constant.MIDI_FREQUENCY_RANGE[m+1] && j <= Constant.BRIGHTNESS_RANGE[n+1]; i+=1.0, j++) {
          frequencyToBrightness.put(i, j);
        }
      }
    }
    //======================================================================================
  } 

  /**
   * @returns  color  cor de fundo
   */
  color getBackgroundColor() {
    return backgroundColor;
  }

  /**
   * @returns  color  cor atual
   */
  color getColor() {
    return actualColor;
  }

  /**
   * Altera tom, saturação ou valor com base na frequência e na amplitude recebidas
   *
   * @params   float    frequência recebida
   *           float    amplitude recebida
   * @returns  color    cor atual, após alterações
   */
  color changeColor(float frequency, float amplitude) {
    // lida com alterações de cor
    actualColor = changeHue(frequency, amplitude);
    
    // lida com alterações de saturação
    actualColor = changeSaturation(amplitude);
    
    // lida com alterações de brilho
    actualColor = changeBrightness(frequency);
    
    return actualColor;
  }

  /**
   * Altera apenas o tom; mantém saturação e brilho
   *
   * @params   float  frequência base
   *           float  amplitude base
   * @returns  color  cor alterada
   */
  private color changeHue(float frequency, float amplitude) {
    color c = actualColor;
    int actualHue = (int) hue(c), hue;
    int freqDiff = 0, ampDiff = 0;

    // verifica se a frequência é diferente e se resultaria em um tom de cor significativamente diferente
    if (frequencyToHue.containsKey(frequency) && frequencyToHue.get(frequency) != actualHue) {
      int fHue = frequencyToHue.get(frequency);
      freqDiff = actualHue > fHue ? actualHue - fHue : fHue - actualHue;

      if (frequencyToHue.containsValue(actualHue)) {
        int i = 0;
        while (i < Constant.HUE_RANGE_FOR_FREQUENCY.length-2) {
          if ((actualHue > Constant.HUE_RANGE_FOR_FREQUENCY[i+1]  && fHue <= Constant.HUE_RANGE_FOR_FREQUENCY[i+1]) ||  // frequência diminuiu
              (actualHue <= Constant.HUE_RANGE_FOR_FREQUENCY[i+1] && fHue > Constant.HUE_RANGE_FOR_FREQUENCY[i+1])) {   // frequência aumentou
            freqDiff -= Constant.HUE_RANGE_FOR_FREQUENCY[i+2] - Constant.HUE_RANGE_FOR_FREQUENCY[i+1];
          }
          i+=2;
        }
      } else {
        freqDiff = fHue;
      }
    }
    
    // verifica se a amplitude é diferente e se resultaria em um tom de cor significativamente diferente
    if (amplitudeToHue.containsKey(amplitude) && amplitudeToHue.get(amplitude) != actualHue) {
      int ampHue = amplitudeToHue.get(amplitude);
      ampDiff = actualHue > ampHue ? actualHue - ampHue : ampHue - actualHue;
      
      if (amplitudeToHue.containsValue(actualHue)) {
        int i = 0;
        while (i < Constant.HUE_RANGE_FOR_AMPLITUDE.length-2) {
          if ((actualHue > Constant.HUE_RANGE_FOR_AMPLITUDE[i+1]  && ampHue <= Constant.HUE_RANGE_FOR_AMPLITUDE[i+1]) ||  // amplitude diminuiu
              (actualHue <= Constant.HUE_RANGE_FOR_AMPLITUDE[i+1] && ampHue > Constant.HUE_RANGE_FOR_AMPLITUDE[i+1])) {   // amplitude aumentou
            ampDiff -= Constant.HUE_RANGE_FOR_AMPLITUDE[i+2] - Constant.HUE_RANGE_FOR_AMPLITUDE[i+1];
          }
          i+=2;
        }
      } else {
        ampDiff = ampHue;
      }
    } // se frequência e amplitude são as mesmas, cor não é alterada
    
    // verifica maior alteração de cor
    if (freqDiff >= ampDiff) {
      hue = frequencyToHue.get(frequency);
    } else {
      hue = amplitudeToHue.get(amplitude);
    }
    
    // altera a cor apenas se realmente houver mudança no tom 
    int s = (int) saturation(c);
    int b = (int) brightness(c);
    c = color(hue, s, b);
    
    return c;
  }



  /**
   * Altera apenas a saturação; mantém tom e brilho
   *
   * @params   float  amplitude base
   * @returns  color  cor alterada
   */
  private color changeSaturation(float amplitude) {
    color c = actualColor;
    
    if (amplitudeToSaturation.containsKey(amplitude)) {
      int sat = amplitudeToSaturation.get(amplitude);
      int actualSat = (int) hue(c);
      // altera a cor apenas se realmente houver mudança na saturação
      if (sat != actualSat) {
        int h = (int) hue(c);
        int b = (int) brightness(c);
        c = color(h, sat, b);
      }
    }

    return c;
  }

  /**
   * Altera apenas o brilho; mantém tom e saturação 
   *
   * @params   float  frequência base
   * @returns  color  cor alterada
   */
  private color changeBrightness(float frequency) {
    color c = actualColor;

    if (frequencyToBrightness.containsKey(frequency)) {
      int bright = frequencyToBrightness.get(frequency);
      int actualBright = (int) hue(c);
      // altera a cor apenas se realmente houver mudança no brilho
      if (bright != actualBright) {
        int h = (int) hue(c);
        int s = (int) saturation(c);
        c = color(h, s, bright);
      }
    }

    return c;
  }
}
