/**
 * Converte dados recebidos em tamanho e variação (de tamanho, velocidade ou curvatura)
 */
class StrokeController {

  // taxa de variação do tamanho
  float changeSizeRate;

  StrokeController() {
    changeSizeRate = Constant.DEFAULT_SIZE * 0.025;
  }

  /**
   * Determina o tamanho da pincelada
   * Quanto menor a amplitude, maior o tamanho
   *
   * @params  float  amplitude com base na qual será criada
   * @returns float  tamanho
   */
  float getSize(float amplitude) {
    float size = Constant.DEFAULT_SIZE;
    if (amplitude <= Constant.INCREASE_SIZE_AMPLITUDE) {
      float change = (Constant.INCREASE_SIZE_AMPLITUDE - amplitude) * changeSizeRate;
      size += change;
    }
    return size;
  }

  /**
   * Determina o valor da variação passado à pincelada
   * Quanto maior a frequência, maior a variação
   *
   * @params  float  frequência com base na qual será criada
   * @returns float  variação
   */
  float getVariation(float frequency) {
    float variation = Constant.DEFAULT_SIZE/20;  // valor base

    if (frequency >= Constant.INCREASE_VARIATION_FREQUENCY && frequency < Constant.STOP_VARIATION_FREQUENCY) {
      variation += frequency/200;
    } else if (frequency >= Constant.STOP_VARIATION_FREQUENCY) {
      variation += Constant.STOP_VARIATION_FREQUENCY/300;
    }

    return variation;
  }
}
