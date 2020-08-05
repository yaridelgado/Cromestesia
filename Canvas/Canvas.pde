/**
 * Principal
 * Controle da pintura como um todo
 * Inicia o programa, comanda as atualizações de tela e articula pinceladas e controllers
 */

//---------- biblioteca
import ddf.minim.*;
import ddf.minim.analysis.*;

//---------- recepção e análise de áudio
Minim       minim;
AudioInput  micListener;
FFT         fft;
AudioAnalyzer audioAnalyzer;

//---------- controle de cor, forma e composição
ColorController colorControl;
StrokeController strokeControl;
Grid paintingGrid;

//---------- variáveis de controle - pinceladas principais
Stroke previousStroke, actualStroke;
ArrayList<Stroke> strokes;
int strokesLength;

//---------- variáveis de controle - pinceladas secundárias
Stroke previousGenStroke, actualGenStroke;
ArrayList<Stroke> generatedFreqStrokes;

//---------- controle de tempo
float now;

void setup() {
  fullScreen();
  frameRate(120);

  colorControl  = new ColorController();
  strokeControl = new StrokeController();
  paintingGrid  = new Grid();
  background(colorControl.getBackgroundColor());  // (0,0,0)
  smooth();
  noStroke();

  strokes              = new ArrayList<Stroke>();
  generatedFreqStrokes = new ArrayList<Stroke>();
  strokesLength = 0;

  now  = 0;

  // inicializa microfone e muta saída de áudio
  minim = new Minim(this);
  micListener = minim.getLineIn();
  micListener.mute();
  
  fft = new FFT(micListener.mix.size(), micListener.sampleRate());
  audioAnalyzer = new AudioAnalyzer();

  // começa analizando o áudio
  audioAnalyzer.checkAmplitude();
  audioAnalyzer.checkFrequency();
  nextStroke(audioAnalyzer.getFrequency(), audioAnalyzer.getAmplitude());
}

void draw() {
  // verifica mudança significativa no valor de amplitude ou de frequência
  if (audioAnalyzer.checkAmplitude() || audioAnalyzer.checkFrequency()) {
    float frequency = audioAnalyzer.getFrequency();
    float amplitude = audioAnalyzer.getAmplitude();
    addPaintedStroke();                // adiciona pincelada anterior, que acabou de ser pintada
    nextStroke(frequency, amplitude);  // prepara próxima pincelada para iniciar

    ArrayList<Float> frequencies = audioAnalyzer.getFrequencies();
    generateFreqStrokes(frequencies, amplitude);  // pinceladas secundárias
    
    // reinicializa variável a cada pincelada criada
    now = millis();
  } else {
    // se nenhuma mudança é captada durante um tempo, tela é limpada
    float duration = millis() - now;
    if (duration >= Constant.MAX_SILENCE_DURATION) {
      restart();
    }
  }

  // pinta stroke principal e as secundárias atuais
  actualStroke.paint();
  for (Stroke gfs : generatedFreqStrokes) {
    gfs.paint();
  }
}

/**
 * Adiciona última pincelada à lista
 */
void addPaintedStroke() {
  if (actualStroke != null) {
    previousStroke = actualStroke;  // passa a outra variável por questão  de legibilidade

    float duration = millis() - now;
    previousStroke.setDuration(duration);

    // adicionar a pincelada à lista
    // permite que ela seja inteiramente pintada antes de começar a se mover
    strokes.add(previousStroke);
    strokesLength++;
  }
}

/**
 * Prepara valores para próxima pincelada a partir dos parâmetros e das pinceladas anteriores
 *
 * @params  float  frequência a partir da qual será criada
 *          float  amplitude a partir da qual será criada
 */
void nextStroke(float frequency, float amplitude) {
  color nextColor = colorControl.changeColor(frequency, amplitude);
  float nextSize  = strokeControl.getSize(amplitude);
  float incrSize  = nextSize * 0.025;  // valor incremental da distância em relação a outra stroke 
  float[] pos     = paintingGrid.nextPosition(previousStroke, nextColor, incrSize);
  
  float variation   = strokeControl.getVariation(frequency);
  float orientation = nextOrientation(previousStroke, nextColor, frequency, 0.004, 1.0);

  actualStroke    = new Stroke(nextColor, pos[0], pos[1], nextSize, variation, orientation, frequency, amplitude);
}

/**
 * Prepara valores para próxima pincelada secundária a partir dos parâmetros e das pinceladas anteriores
 *
 * @params  float  frequência a partir da qual será criada
 *          float  amplitude a partir da qual será criada
 *          float  tamanho de referência para alterações no tamanho desta
 *          float  taxa de variação para cálculo do tamanho
 */
void nextGenStroke(float frequency, float amplitude, float referenceSize, float variation) {
  float genAmp    = amplitude * (1 + variation);
  color nextColor = colorControl.changeColor(frequency, genAmp);
  
  float size      = referenceSize * variation;
  float nextSize  = constrain(size, referenceSize * 0.5, referenceSize * 0.8);
  float incrSize  = nextSize * 0.005;  // valor incremental da distância em relação a outra stroke
  float[] pos     = paintingGrid.nextPosition(previousGenStroke, nextColor, incrSize);
  
  actualGenStroke = new Stroke(nextColor, pos[0], pos[1], nextSize, variation, actualStroke.orientation, frequency, amplitude);
  actualGenStroke.setDecay(0.04);  // taxa de decaimento da transparência
  
  // altera velocidade desta com base na pincelada anterior
  if (previousGenStroke != null) {
    actualGenStroke.speed = previousGenStroke.speed;
    actualGenStroke.speed.setMag(previousGenStroke.speed.mag() * variation);
  } else {
    actualGenStroke.speed = actualStroke.speed;
    actualGenStroke.speed.setMag(actualStroke.speed.mag() * variation);
  }
}

/**
 * Determina direção da próxima stroke
 *
 * @params  Stroke referência anterior
 *          color  cor da próxima pincelada
 *          float  frequência a partir da qual será criada
 *          float  taxa de variação da orientação, com base na cor
 *          float  taxa de variação da variação da pincelada
 *
 * @returns float  orientação
 */
float nextOrientation(Stroke previous, color nextColor, float frequency, float changeRate, float varRate) {
  float orientation;
  
  if (previous != null) {
    float previousOrient = previous.orientation;
    float hueDiff = hue(previous.getColor()) - hue(nextColor);
    orientation = previousOrient - hueDiff * changeRate;
  } else {
    float variation = strokeControl.getVariation(frequency) * varRate; 
    orientation = random(-variation, variation);
  }
  
  return orientation;
}

/**
 * Controla criação de pinceladas secundárias a partir das frequências secundárias
 *
 * @params  float  frequências secundárias a partir das quais serão criadas
 *          float  amplitude a partir da qual será criada
 */
void generateFreqStrokes(ArrayList<Float> frequencies, Float amplitude) {
  // reset
  generatedFreqStrokes = new ArrayList<Stroke>();
  
  // cria uma pincelada para cada frequência
  for (Float freq : frequencies) {
    // determina pincelada de referência
    if (actualGenStroke == null) {
      previousGenStroke = actualStroke;
    } else {
      previousGenStroke = actualGenStroke;
    }
    
    float referenceSize = actualStroke.size;
    float variation = actualStroke.variation * 0.2;
    nextGenStroke(freq, amplitude, referenceSize, variation);
    
    // adiciona pincelada atual à lista automaticamente
    generatedFreqStrokes.add(actualGenStroke);
  }
}

//void generateConstantStrokes() {}

/**
 * Reinicia tela
 */
void restart() {
  //audioAnalyzer.stopListening();
  background(colorControl.getBackgroundColor());
}
