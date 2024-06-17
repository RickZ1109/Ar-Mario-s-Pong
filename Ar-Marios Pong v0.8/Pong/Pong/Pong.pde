import ddf.minim.*;

Minim minim;
AudioPlayer hitSound;
AudioPlayer scoreSound;
AudioPlayer powerUpSound;
AudioPlayer menuMusic;
AudioPlayer capaMusic;
AudioPlayer gameMusic;

int width = 800;
int height = 400;
int paddleWidth = 10;
int initialPaddleHeight = 100;
int initialPaddleSpeed = 5;
int ballSize = 20;
int initialBallSpeedX = 5;
int initialBallSpeedY = 5;
float ballSpeedX;
float ballSpeedY;

int paddleMargin = 20; 

// Posições das raquetes e bola
float ballX;
float ballY;
float ballSpeedXDir;
float ballSpeedYDir;

// Pontuação dos jogadores
int player1Score = 0;
int player2Score = 0;

// Variáveis de cronômetro
boolean gameStarted = false;
boolean ballReleased = false;
int countdown = 3;
int lastTime;

// Contador de colisões com as raquetes
int collisionCount = 0;
int collisionThreshold = 5; 

// Variável de pausa
boolean isPaused = false;

// Estados do jogo
String gameState = "capa"; // Estado inicial do jogo
boolean singlePlayer = false; // Jogar contra o bot
String previousGameState = "menu";

// Posições e dimensões do botão de pausa
int pauseButtonX = width - 30;
int pauseButtonY = height - 30;
int pauseButtonWidth = 15;
int pauseButtonHeight = 20;

// Arrays booleanos para verificar quais teclas estão pressionadas
boolean[] keys = new boolean[128]; 

// Variáveis para o quadrado vermelho
int squareSize = 40;
int squareX;
int squareY;
int squareLastTime;
int squareInterval = 10000; 

// Variáveis para o círculo azul
int circleSize = 40;
int circleX;
int circleY;
int circleLastTime;
int circleInterval = 10000; 

// Variáveis para o triângulo verde
int triangleSize = 40;
int triangleX;
int triangleY;
int triangleLastTime;
int triangleInterval = 10000; 

// Controle de power-ups
boolean showSquare = false;
boolean showCircle = false;
boolean showTriangle = false;
boolean powerUpActive = false;
int powerUpLastTime;
int powerUpInterval = 10000;
int effectStartTime;
int effectDuration = 5000; 

boolean leftPaddleLastHit = false; 
boolean sizeIncreased = false;
boolean frozenPaddle1 = false;
boolean frozenPaddle2 = false;
boolean speedIncreased = false;

// Variáveis para as imagens dos power-ups
PImage imgIncreaseSize;
PImage imgFreeze;
PImage imgIncreaseSpeed;

// Variáveis para as imagens de fundo, da bolinha e da capa
PImage backgroundMenu;
PImage backgroundGame;
PImage backgroundStory;
PImage backgroundCredits;
PImage ballImage;
PImage ballImage1;
PImage ballImage2;
PImage ballImage3;
PImage ballImage4;
PImage capaImage;

// Variáveis para a fonte personalizada
PFont gameFont;

String[] storyLines;
int storyIndex = 0;
boolean storyEnded = false;
String selectedDifficulty = "FÁCIL"; 

boolean storyClicked = false;

// Estrutura para as raquetes
class Paddle {
  float y;
  int height;
  int speed;
  color c;

  Paddle(float y) {
    this.y = y;
    this.height = initialPaddleHeight;
    this.speed = initialPaddleSpeed;
    this.c = color(255); 
  }
}

Paddle paddle1;
Paddle paddle2;

void setup() {
  size(800, 400);
  minim = new Minim(this);
  hitSound = minim.loadFile("hit.wav");
  scoreSound = minim.loadFile("score.wav");
  powerUpSound = minim.loadFile("powerup.wav");
  menuMusic = minim.loadFile("menu_music.mp3");
  capaMusic = minim.loadFile("capa_music.mp3");
  gameMusic = minim.loadFile("game_music.mp3");

  paddle1 = new Paddle(height / 2);
  paddle2 = new Paddle(height / 2);
  reset();
  lastTime = millis();
  squareLastTime = millis();
  circleLastTime = millis();
  triangleLastTime = millis();
  powerUpLastTime = millis();
  generatePowerUpPositions();
  
  // Carregar as imagens dos power-ups
  imgIncreaseSize = loadImage("increase_size.png");
  imgFreeze = loadImage("freeze.png");
  imgIncreaseSpeed = loadImage("increase_speed.png");

  // Carregar as imagens de fundo, da bolinha e da capa
  backgroundMenu = loadImage("background_menu.png");
  backgroundGame = loadImage("background_game.png");
  backgroundStory = loadImage("background_story.png");
  backgroundCredits = loadImage("background_credits.png");
  ballImage1 = loadImage("ball1.png");
  ballImage2 = loadImage("ball2.png");
  ballImage3 = loadImage("ball3.png");
  ballImage4 = loadImage("ball4.png"); 
  ballImage = ballImage1; 
  capaImage = loadImage("capa.png");

  // Carregar a fonte personalizada
  gameFont = createFont("game_font.ttf", 32); 

  // Inicializa a história
  storyLines = new String[] {
    "No Reino dos Cogumelos, em um tempo de paz e alegria",
    "Ar-Mario (Novo apelido dado a Mario)",
    "por se ter ficado Giga após ter derrotado Bowser centenas de vezes",
    "e seus amigos viviam em harmonia, aproveitando cada dia ao máximo.",
    "No entanto, essa paz foi interrompida quando Bowser",
    "o terrível rei dos Koopas, raptou a Princesa Peach mais uma vez.",
    "Mas, desta vez, ele tinha um desafio diferente em mente para Ar-Mario.",
    "Bowser, cansado de suas derrotas em batalhas físicas,",
    "decidiu desafiar Ar-Mario para um duelo de inteligência e habilidade: uma partida de Pong.",
    "Ele enviou uma mensagem, dizendo que se ele vencesse o jogo, a princesa seria libertada.",
    "Caso contrário, ela ficaria presa para sempre no castelo de Bowser.",
    "Ar-Mario, determinado a salvar Peach, aceitou o desafio.",
    "Ele viajou até o castelo de Bowser, passando por inúmeros obstáculos e inimigos.",
    "Finalmente, ele chegou à sala de jogos,",
    "onde Bowser estava esperando ao lado de uma velha máquina de Pong.",
    "Bem-vindo, Ar-Mario! rugiu Bowser com um sorriso malicioso.",
    "Vamos ver se você é tão bom com um joystick quanto é com seus saltos"
  };
}

void draw() {
  textFont(gameFont); 
  if (gameState.equals("capa")) {
    drawCapa();
  } else if (gameState.equals("menu")) {
    drawMenu();
  } else if (gameState.equals("playing") || gameState.equals("story")) {
    if (isPaused) {
      drawPausedScreen();
    } else if (gameState.equals("playing")) {
      drawGame();
    } else {
      drawStory();
    }
    drawPauseButton(); 
  } else if (gameState.equals("singlePlayerSubmenu") || gameState.equals("multiPlayerSubmenu")) {
    drawBallSelectionMenu();
  } else if (gameState.equals("credits")) {
    drawCredits();
  }
}

void drawCapa() {
  if (!capaMusic.isPlaying()) {
    capaMusic.loop();
  }
  background(capaImage); 
  fill(0); 
  textSize(17);
  textAlign(CENTER, CENTER);
  text("PLAY GAME", width / 1.5 - 25, height / 1.5 - 5);
}

void drawMenu() {
  if (!menuMusic.isPlaying()) {
    capaMusic.pause();
    menuMusic.loop();
  }
  background(backgroundMenu); 
  fill(0); 
  textSize(16);
  textAlign(CENTER, CENTER);
  text("1 PLAYER", width / 2, height / 2 - 60);
  text("2 PLAYERS", width / 2, height / 2 - 20);
  text("STORY", width / 2, height / 2 + 16);
  text("CREDITS", width / 2, height / 2 + 55);
}

void drawPausedScreen() {
  fill(0);
  textSize(16);
  textAlign(CENTER, CENTER);
  text("PAUSE", width / 2, height / 2);
  text("Precione M para voltar a tela inicial", width / 2, height / 2 +30);
}

void drawPauseButton() {
  fill(255, 255, 255, 150); 
  noStroke();
  rect(pauseButtonX, pauseButtonY, pauseButtonWidth / 2, pauseButtonHeight); // Barra esquerda
  rect(pauseButtonX + pauseButtonWidth / 2 + 5, pauseButtonY, pauseButtonWidth / 2, pauseButtonHeight); // Barra direita
}

void drawGame() {
  if (capaMusic.isPlaying()) {
    capaMusic.pause();
  }
  if (menuMusic.isPlaying()) {
    menuMusic.pause();
  }
  if (!gameMusic.isPlaying()) {
    gameMusic.loop();
  }
  background(backgroundGame); 

  // Verifica se algum jogador atingiu 10 pontos
  if (player1Score >= 10 || player2Score >= 10) {
    gameMusic.pause();
    player1Score = 0;
    player2Score = 0;
    gameState = "menu";
    return;
  }

  // Movimento das raquetes
  if (keys['W'] && !frozenPaddle1) {
    paddle1.y -= leftPaddleLastHit && speedIncreased ? paddle1.speed * 1.2 : paddle1.speed;
  }
  if (keys['S'] && !frozenPaddle1) {
    paddle1.y += leftPaddleLastHit && speedIncreased ? paddle1.speed * 1.2 : paddle1.speed;
  }

  if (singlePlayer) {
    // Movimento do bot
    if (paddle2.y < ballY) {
      paddle2.y += paddle2.speed;
    } else {
      paddle2.y -= paddle2.speed;
    }
  } else {
    if (keys[UP] && !frozenPaddle2) {
      paddle2.y -= !leftPaddleLastHit && speedIncreased ? paddle2.speed * 1.2 : paddle2.speed;
    }
    if (keys[DOWN] && !frozenPaddle2) {
      paddle2.y += !leftPaddleLastHit && speedIncreased ? paddle2.speed * 1.2 : paddle2.speed;
    }
  }

  // Limites das raquetes
  paddle1.y = constrain(paddle1.y, paddle1.height / 2, height - paddle1.height / 2);
  paddle2.y = constrain(paddle2.y, paddle2.height / 2, height - paddle2.height / 2);

  // Desenha as raquetes
  fill(paddle1.c);
  rect(paddleMargin, paddle1.y - paddle1.height / 2, paddleWidth, paddle1.height);

  fill(paddle2.c);
  rect(width - paddleWidth - paddleMargin, paddle2.y - paddle2.height / 2, paddleWidth, paddle2.height);

  // Exibe a pontuação dos jogadores
  fill(255);
  textSize(32);
  text(player1Score, width / 4, 50);
  text(player2Score, width * 3 / 4, 50);

  // Lógica de cronômetro para soltar a bola
  if (!ballReleased) {
    fill(255);
    textSize(32);
    textAlign(CENTER, CENTER);
    text(countdown, width / 2, height / 2);

    if (millis() - lastTime >= 1000) {
      countdown--;
      lastTime = millis();
    }

    if (countdown < 0) {
      ballReleased = true;
      countdown = 3;
    }

    return;
  }

  // Movimento da bola
  ballX += ballSpeedX * ballSpeedXDir;
  ballY += ballSpeedY * ballSpeedYDir;

  // Verifica colisão com as raquetes
  if (ballX - ballSize / 2 <= paddleMargin + paddleWidth) {
    if (ballY >= paddle1.y - paddle1.height / 2 && ballY <= paddle1.y + paddle1.height / 2) {
        ballX = paddleMargin + paddleWidth + ballSize / 2; 
        ballSpeedXDir *= -1;
        collisionCount++;
        leftPaddleLastHit = true;
        if (!hitSound.isPlaying()) {
            hitSound.rewind();
            hitSound.play();
        }

        // Aumenta a velocidade da bola
        ballSpeedX += 0.5; 
        ballSpeedY += 0.5; 
    }
  }

  if (ballX + ballSize / 2 >= width - paddleMargin - paddleWidth) {
    if (ballY >= paddle2.y - paddle2.height / 2 && ballY <= paddle2.y + paddle2.height / 2) {
        ballX = width - paddleMargin - paddleWidth - ballSize / 2; 
        ballSpeedXDir *= -1;
        collisionCount++;
        leftPaddleLastHit = false;
        if (!hitSound.isPlaying()) {
            hitSound.rewind();
            hitSound.play();
        }

        // Aumenta a velocidade da bola
        ballSpeedX += 0.5; 
        ballSpeedY += 0.5; 
    }
  }

  // Verifica colisão com as paredes superior e inferior
  if (ballY - ballSize / 2 <= 0 || ballY + ballSize / 2 >= height) {
    ballSpeedYDir *= -1;
  }

  // Verifica se a bola saiu das bordas (pontuação)
  if (ballX - ballSize / 2 < 0) {
    player2Score++;
    if (!scoreSound.isPlaying()) {
      scoreSound.rewind();
      scoreSound.play();
    }
    reset();
    return;
  }

  if (ballX + ballSize / 2 > width) {
    player1Score++;
    if (!scoreSound.isPlaying()) {
      scoreSound.rewind();
      scoreSound.play();
    }
    reset();
    return;
  }

  // Desenha a bola
  image(ballImage, ballX - ballSize / 2, ballY - ballSize / 2, ballSize, ballSize);

  // Verifica e desenha power-ups
  if (millis() - powerUpLastTime >= powerUpInterval && !powerUpActive) {
    int randomPowerUp = int(random(3));
    if (randomPowerUp == 0) {
      showSquare = true;
    } else if (randomPowerUp == 1) {
      showCircle = true;
    } else {
      showTriangle = true;
    }
    powerUpLastTime = millis();
  }

  if (showSquare) {
    image(imgIncreaseSize, squareX - squareSize / 2, squareY - squareSize / 2, squareSize, squareSize);
    if (ballX >= squareX - squareSize / 2 && ballX <= squareX + squareSize / 2 &&
        ballY >= squareY - squareSize / 2 && ballY <= squareY + squareSize / 2) {
      showSquare = false;
      powerUpActive = true;
      effectStartTime = millis();
      if (leftPaddleLastHit) {
        paddle1.height *= 1.5;
      } else {
        paddle2.height *= 1.5;
      }
      sizeIncreased = true;
      if (!powerUpSound.isPlaying()) {
        powerUpSound.rewind();
        powerUpSound.play();
      }
    }
  }

  if (showCircle) {
    image(imgFreeze, circleX - circleSize / 2, circleY - circleSize / 2, circleSize, circleSize);
    if (ballX >= circleX - circleSize / 2 && ballX <= circleX + circleSize / 2 &&
        ballY >= circleY - circleSize / 2 && ballY <= circleY + circleSize / 2) {
      showCircle = false;
      powerUpActive = true;
      effectStartTime = millis();
      if (leftPaddleLastHit) {
        frozenPaddle2 = true;
      } else {
        frozenPaddle1 = true;
      }
      if (!powerUpSound.isPlaying()) {
        powerUpSound.rewind();
        powerUpSound.play();
      }
    }
  }

  if (showTriangle) {
    image(imgIncreaseSpeed, triangleX - triangleSize / 2, triangleY - triangleSize / 2, triangleSize, triangleSize);
    if (ballX >= triangleX - triangleSize / 2 && ballX <= triangleX + triangleSize / 2 &&
        ballY >= triangleY - triangleSize / 2 && ballY <= triangleY + triangleSize / 2) {
      showTriangle = false;
      powerUpActive = true;
      effectStartTime = millis();
      speedIncreased = true;
      if (!powerUpSound.isPlaying()) {
        powerUpSound.rewind();
        powerUpSound.play();
      }
    }
  }

  // Verifica se o efeito do power-up deve ser desativado
  if (powerUpActive && millis() - effectStartTime >= effectDuration) {
    powerUpActive = false;
    if (sizeIncreased) {
      paddle1.height = initialPaddleHeight;
      paddle2.height = initialPaddleHeight;
      sizeIncreased = false;
    }
    if (frozenPaddle1) {
      frozenPaddle1 = false;
    }
    if (frozenPaddle2) {
      frozenPaddle2 = false;
    }
    if (speedIncreased) {
      speedIncreased = false;
    }
    generatePowerUpPositions(); 
  }
}

void drawStory() {
  background(backgroundStory); 
  fill(0);
  textSize(14);
  textAlign(CENTER, CENTER);
  
  String currentLine = storyLines[storyIndex];
  float maxWidth = width - 50; 
  String[] words = currentLine.split(" ");
  String line = "";
  float lineHeight = textAscent() + textDescent() + 5;
  float y = height / 2 - (lineHeight * words.length) / 2; 

  for (String word : words) {
    if (textWidth(line + word) > maxWidth) {
      text(line, width / 2, y);
      line = word + " ";
      y += lineHeight;
    } else {
      line += word + " ";
    }
  }
  text(line, width / 2, y);

  storyClicked = false; 
}

void drawBallSelectionMenu() {
  background(backgroundMenu); 
  fill(0);
  textSize(16);
  textAlign(CENTER, CENTER);
  text("SELECIONE A BOLA", width / 2, height / 4);
  text("CASCO VERDE", width / 2, height / 2 - 60);
  text("CASCO VERM.", width / 2, height / 2 - 20);
  text("CASCO AZUL", width / 2, height / 2 + 16);
  text("MARIO BALL", width / 2, height / 2 + 55);
}

void drawCredits() {
  background(backgroundCredits); 
  fill(0);
  textSize(16);
  textAlign(CENTER, CENTER);

}

void reset() {
  ballX = width / 2;
  ballY = height / 2;
  
  // Reiniciar velocidade inicial da bola
  ballSpeedX = initialBallSpeedX;
  ballSpeedY = initialBallSpeedY;

  // Reiniciar direções aleatórias para a bola
  ballSpeedXDir = random(1) > 0.5 ? 1 : -1;
  ballSpeedYDir = random(1) > 0.5 ? 1 : -1;

  ballReleased = false;
  collisionCount = 0;
}

void generatePowerUpPositions() {
  squareX = int(random(100, width - 100));
  squareY = int(random(50, height - 50));
  circleX = int(random(100, width - 100));
  circleY = int(random(50, height - 50));
  triangleX = int(random(100, width - 100));
  triangleY = int(random(50, height - 50));
}

void keyPressed() {
  keys[keyCode] = true; 

  if (key == ' ') {
    if (gameState.equals("capa")) {
      gameState = "menu";
    }
  } else if (gameState.equals("credits")) {
    gameState = "menu";
  } else if (key == 'M' || key == 'm') {
    gameState = "menu"; 
    isPaused = false; 
    gameMusic.pause(); 
    menuMusic.loop(); 
  }
}

void keyReleased() {
  keys[keyCode] = false; 

  if (key == 'P' || key == 'p') {
    isPaused = !isPaused;
  }
}

void mousePressed() {
  if (gameState.equals("menu")) {
    if (mouseX > width / 2 - 60 && mouseX < width / 2 + 60) {
      if (mouseY > height / 2 - 80 && mouseY < height / 2 - 60) {
        // Modo single player
        singlePlayer = true;
        previousGameState = "menu";
        gameState = "singlePlayerSubmenu";
      } else if (mouseY > height / 2 - 40 && mouseY < height / 2 - 20) {
        // Modo multiplayer
        singlePlayer = false;
        previousGameState = "menu";
        gameState = "multiPlayerSubmenu";
      } else if (mouseY > height / 2 && mouseY < height / 2 + 20) {
        // Modo história
        gameState = "story";
        storyIndex = 0;
      } else if (mouseY > height / 2 + 40 && mouseY < height / 2 + 60) {
        // Tela de créditos
        gameState = "credits";
      }
    }
  } else if (gameState.equals("story")) {
    if (!storyClicked) {
      storyIndex++;
      if (storyIndex >= storyLines.length) {
        gameState = "playing";
        storyIndex = 0;
      }
      storyClicked = true; // Marca que o mouse foi clicado
    }
  } else if (gameState.equals("singlePlayerSubmenu") || gameState.equals("multiPlayerSubmenu")) {
    if (mouseX > width / 2 - 50 && mouseX < width / 2 + 50) {
      if (mouseY > height / 2 - 80 && mouseY < height / 2 - 60) {
        // Selecionar bola 1
        ballImage = ballImage1;
        gameState = "difficultySelection";
      } else if (mouseY > height / 2 - 40 && mouseY < height / 2 - 20) {
        // Selecionar bola 2
        ballImage = ballImage2;
        gameState = "difficultySelection";
      } else if (mouseY > height / 2 && mouseY < height / 2 + 20) {
        // Selecionar bola 3
        ballImage = ballImage3;
        gameState = "difficultySelection";
      } else if (mouseY > height / 2 + 40 && mouseY < height / 2 + 60) {
        // Selecionar bola 4
        ballImage = ballImage4;
        gameState = "difficultySelection";
      }
    }
  } else if (gameState.equals("difficultySelection")) {
    if (mouseX > width / 2 - 50 && mouseX < width / 2 + 50) {
      if (mouseY > height / 2 - 80 && mouseY < height / 2 - 60) {
        selectedDifficulty = ".";
        gameState = "playing";
      } else if (mouseY > height / 2 - 40 && mouseY < height / 2 - 20) {
        selectedDifficulty = ".";
        gameState = "playing";
      } else if (mouseY > height / 2 && mouseY < height / 2 + 20) {
        selectedDifficulty = ".";
        gameState = "playing";
      } else if (mouseY > height / 2 + 40 && mouseY < height / 2 + 60) {
        selectedDifficulty = ".";
        gameState = "playing";
      }
    }
  } else if (mouseX >= pauseButtonX && mouseX <= pauseButtonX + pauseButtonWidth &&
             mouseY >= pauseButtonY && mouseY <= pauseButtonY + pauseButtonHeight) {
    isPaused = !isPaused;
  }
}
