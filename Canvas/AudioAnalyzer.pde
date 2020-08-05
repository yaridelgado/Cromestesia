/** //<>// //<>//
 * Responsável pela leitura e análise do áudio capturado
 */
class AudioAnalyzer {

  // últimos valores captados, servem como atuais
  private float   lastFrequency;
  private float   lastAmplitude;

  AudioAnalyzer() {
    // inicializadas com o valor mínimo lido de cada um
    lastFrequency = Constant.MIDI_FREQUENCY_RANGE[0];
    lastAmplitude = Constant.AMPLITUDE_RANGE[0];
    fft.logAverages(43, 1);
    
    startListening();
  }

  /**
   * Habilita captura de áudio
   */
  void startListening() {
    micListener.enableMonitoring();
  }

  /**
   * Interrompe captura de áudio
   */
  void stopListening() {
    micListener.close();
  }

  /**
   * @returns float  última amplitude lida e gravada
   */
  float getAmplitude() {
    return lastAmplitude;
  }

  /**
   * @returns float  última frequência lida e gravada
   */
  float getFrequency() {
    return lastFrequency;
  }

  /**
   * Converte o nível do áudio capturado em amplitude
   *
   * @params  float  nível
   * @returns float  amplitude
   */
  float calcAmplitude(float level) {
    return round(20 * Math.log10(level));
  }
  
  /**
   * Verifica se houve variação significativa na amplitude
   *
   * @returns boolean  true  - houve alteração
   *                   false - não houve
   */
  boolean checkAmplitude() {
    boolean changed = false;
    float   level   = micListener.mix.level();

    // varifica alterações
    // altera amplitude, se necessário
    if (level > 0.004 && level < 0.6) {
      float previousAmplitude = lastAmplitude;
      lastAmplitude = calcAmplitude(level);
      // verifica se é significativa a mudança
      if (abs(lastAmplitude - previousAmplitude) > Constant.AMPLITUDE_CHANGE) {
        changed = true;
      }
    } // else changed = false

    return changed;
  }

  /**
   * Verifica se houve variação significativa na frequência
   *
   * @returns boolean  true  - houve alteração
   *                   false - não houve
   */
  boolean checkFrequency() {
    boolean changed = false;
    float frequency = fftToFrequency(fft);
    float midi = frequencyToMidi(frequency);

    // varifica alterações
    // altera frequência, se necessário
    if (midi >= Constant.MIDI_FREQUENCY_RANGE[0] && midi <= Constant.MIDI_FREQUENCY_RANGE[Constant.MIDI_FREQUENCY_RANGE.length-1]) {
      float previousMidi = lastFrequency;
      lastFrequency = midi;
      // verifica se é significativa a mudança
      if (abs(midi - previousMidi) > Constant.FREQUENCY_CHANGE) {
        changed = true;
      }
    } // else changed = false

    return changed;
  }

  /**
   * Seleciona a "frequência principal" do espectro recebido
   *
   * @params  FFT    espectro de frequências do áudio lido
   * @returns float  frequência principal
   */
  float fftToFrequency(FFT fft) {
    int maxInd = 0;
    float maxAmp = 0.0;
    
    // transformações no espectro  - suavização
    fft.window(FourierTransform.HAMMING);
    fft.forward(micListener.mix);
    
    // busca banda de maior amplitude
    for (int i = 0; i < fft.timeSize(); i++) {
      if (fft.getBand(i) > maxAmp) {
        maxAmp = fft.getBand(i);
        maxInd = i;
      }
    }
    float frequency = fft.getBand(maxInd) * micListener.sampleRate() / fft.timeSize();

    return frequency;
  }

  /**
   * Organiza frequência(s) secundária(s) considerável(is)
   *
   * @returns ArrayList<Float>  frequência(s) secundária(s)
   */
  ArrayList<Float> getFrequencies() {
    ArrayList<Float> frequencies = new ArrayList<Float>();
    
    // calcula amplitude média do espectro
    float avg = fft.calcAvg(fft.getAverageCenterFrequency(0), fft.getAverageCenterFrequency(8));
    avg = calcAmplitude(avg);
    
    // organiza frequência(s) de amplitude maior ou igual à média
    for (int j = 1; j < 9; j++) {
      int band = (int) fft.getAverageCenterFrequency(j);
      float freq = fft.getBand(band);
      float midi = frequencyToMidi(freq);
      if (freq > avg && (midi >= Constant.MIDI_FREQUENCY_RANGE[0] && midi <= Constant.MIDI_FREQUENCY_RANGE[1])) {
        frequencies.add(midi);
      }
      
    }
    return frequencies;
  }

  /**
   * Converte a frequência em Hz para a frequência em MIDI
   * Necessário porque os valores de cor estão relacionados às frequências em MIDI
   *
   * @params  float  frequência em Hz
   * @returns float  frequência em MIDI
   */
  float frequencyToMidi(float frequency) {
    float midi;
    midi = 12 * Math.log2( frequency / Constant.BASE_HZ ) + Constant.BASE_MIDI;
    return abs(round(midi));
  }

  /**
   * Converte a frequência em MIDI para a frequência em Hz
   *
   * @params  float  frequência em MIDI
   * @returns float  frequência em Hz
   */
  float midiToFrequency(float midi) {
    float frequency;
    frequency = pow(2, midi - Constant.BASE_MIDI) * Constant.BASE_HZ;
    return frequency;
  }
}
