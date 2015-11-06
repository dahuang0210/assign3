/** 
 Assignment 1
 Author:          Bao Yuchen
 Student Number:  103254021
 Update:          2015/11/05
 */

final int MOUSE_LEFT = 37, MOUSE_RIGHT = 39, MOUSE_MID = 3;

private enum ObjType {  
  FIGHTER, ENEMY, TREASURE, BACKGROUND, TITLE, NOTHING;
}
private enum resType {
  hp, end1, end2, bg1, bg2, st1, st2, enemy, fighter, treasure;
}

private HashMap<resType, PImage> resourcesMap = null;

private GamePlayScene gameMain = null;

private void addImage(resType Key, String resName) {
  if (! resourcesMap.containsKey(Key)) {
    PImage newRes = loadImage(resName);
    resourcesMap.put(Key, newRes);
  }
}
/**
 * to load pictures
 */
private void loadResources() {
  resourcesMap = new HashMap();
  addImage(resType.hp, "img/hp.png");
  addImage(resType.end1, "img/end1.png");
  addImage(resType.end2, "img/end2.png");
  addImage(resType.bg1, "img/bg1.png");
  addImage(resType.bg2, "img/bg2.png");
  addImage(resType.st1, "img/start1.png");
  addImage(resType.st2, "img/start2.png");
  addImage(resType.enemy, "img/enemy.png");
  addImage(resType.fighter, "img/fighter.png");
  addImage(resType.treasure, "img/treasure.png");
}


/**
 * to initialize system
 */
void setup () {
  size(640, 480) ;
  loadResources();
  gameMain = new GamePlayScene();
}


void draw() {
  gameMain.drawFrame();
}

//-------------------------- override listener method --------------------------

void mouseMoved() {
  gameMain.mouseMovedFun(mouseX, mouseY);
}

void mousePressed() {
  gameMain.mousePressedFun(mouseButton);
}

void mouseReleased() {
  gameMain.mouseReleasedFun(mouseButton);
}

/**
 * when key pressed
 */
void keyPressed() {
  gameMain.keyPressedFun(keyCode);
}

/**
 * when key released
 */
void keyReleased() {
  gameMain.keyReleasedFun(keyCode);
}

//****************************************************************************************************************
//****************************************************************************************************************

//================================================================================================================
//================================================================================================================

interface MouseListener {
  public void mouseReleasedFun(int keyCode1) ;
  public void mousePressedFun(int keyCode1) ;
  public void mouseMovedFun(int x, int y);
}

//================================================================================================================
//================================================================================================================

interface KeyPressListener {
  public void keyReleasedFun(int keyCode1) ;
  public void keyPressedFun(int keyCode1) ;
}

//================================================================================================================
//================================================================================================================

interface ScreenChangeListener {
  public void startGame() ;
  public void endGame(int level) ;
  public void restartGame() ;
}

//================================================================================================================
//================================================================================================================

interface GameDataChanged {
  public void addHP(int val);
  public void subHP(int val);
  public void enemyMoveOut(Enemy target);
}

//****************************************************************************************************************
//****************************************************************************************************************

//================================================================================================================
//================================================================================================================

class GamePlayScene implements ScreenChangeListener {

  DrawingOBJ drawingObj = null;
  KeyPressListener keyListener = null;
  MouseListener mouseListener = null;

  public GamePlayScene() {

    restartGame();
  }

  public void drawFrame() {
    if (drawingObj != null) {
      drawingObj.drawFrame();
    }
  }

  public void mouseMovedFun(int x, int y) {
    if (mouseListener != null) {
      mouseListener.mouseMovedFun(x, y);
    }
  }

  public void mousePressedFun(int code) {
    if (mouseListener != null) {
      mouseListener.mousePressedFun(code);
    }
  }

  public void mouseReleasedFun(int code) {
    if (mouseListener != null) {
      mouseListener.mouseReleasedFun(code);
    }
  }

  /**
   * when key pressed
   */
  public void keyPressedFun(int code) {
    if  (keyListener != null ) {
      keyListener.keyPressedFun(code);
    }
  }

  /**
   * when key released
   */
  public void keyReleasedFun(int code) {
    if  (keyListener != null ) {
      keyListener.keyReleasedFun(code);
    }
  }

  //--------------------------- handled by listener ---------------------------

  public void endGame(int level) {
    onScreenChange();
    GameEnd newScreen = new GameEnd(this);
    newScreen.level = level;
    drawingObj = newScreen;
    mouseListener = newScreen;
  }

  public void startGame() {
    onScreenChange();
    OnGaming newScreen = new OnGaming(this);
    drawingObj = newScreen;
    keyListener = newScreen;
  }

  public void restartGame() {
    onScreenChange();
    GameStart newScreen = new GameStart(this);
    drawingObj = newScreen;
    mouseListener = newScreen;
  }

  //--------------------------- private method ---------------------------

  private void onScreenChange() {
    drawingObj = null;
    keyListener = null;
    mouseListener = null;
  }
}

//================================================================================================================
//================================================================================================================

abstract class DrawingOBJ {
  public ObjType classID = ObjType.NOTHING;
  public int objWidth, objHeight;
  public int x, y;
  public int zOrder;
  private PImage img = null;
  private boolean isDrawSelf = true;

  public DrawingOBJ(int objWidth, int objHeight, PImage image, ObjType classID) {
    this.objWidth = objWidth;
    this.objHeight = objHeight;
    this.classID = classID;
    img = image;
    x = 0;
    y = 0;
    zOrder = 0;
  }

  public void setIsDrawSelf(boolean isDrawSelf) {
    this.isDrawSelf = isDrawSelf;
  }

  public void drawFrame() {
    doGameLogic();
    SpecialDraw();
    if (isDrawSelf) {
      int half_height = objHeight>>1;
      int half_width = objWidth>>1;
      image(img, x - half_width, y - half_height);
    }
  }

  boolean isPointHitArea(int px, int py, int x, int y, int r, int b) {
    return ((px > x) && (px < r) && (py > y) && (py < b));
  }

  public boolean isHitOBJ(DrawingOBJ obj) {
    int xOffset = objWidth >> 1, yOffset = objHeight >> 1 ;
    int xOffset1 = obj.objWidth >> 1, yOffset1 = obj.objHeight >>1;
    int left = x - xOffset, right = x + xOffset;
    int top = y + yOffset, bottom = y - yOffset;
    int tl = obj.x - xOffset1, tr = obj.x + xOffset1;
    int tt = obj.y + yOffset1, tb = obj.y - yOffset1;
    if ((left< tr) && (right > tl)) {
      if ((bottom < tt)&&(top > tb)) {
        return true;
      }
    }
    return false;
  }

  public void drawStrokeText(String str, color textColor, color strokeColor, int textx, int texty, int strokeWidth) {
    fill(strokeColor);
    text(str, textx-strokeWidth, texty);
    text(str, textx+strokeWidth, texty);
    text(str, textx, texty-strokeWidth);
    text(str, textx, texty+strokeWidth);
    text(str, textx-strokeWidth, texty-strokeWidth);
    text(str, textx-strokeWidth, texty+strokeWidth);
    text(str, textx+strokeWidth, texty-strokeWidth);
    text(str, textx+strokeWidth, texty+strokeWidth);
    fill(textColor);
    text(str, textx, texty);
  }

  abstract public void SpecialDraw();
  abstract public void doGameLogic();
}

//================================================================================================================
//================================================================================================================

class Fighter extends DrawingOBJ implements KeyPressListener {

  public int hp;
  public boolean healing;

  private ArrayList<Integer> xKeyStack, yKeyStack;                    // sequence of key pressed
  private int xKeyPressedTime=1, yKeyPressedTime=1;                   // how long did user pressed a key

  private color hpColor = #ffffff;
  private int healRange;
  public Fighter() {
    super(50, 50, resourcesMap.get(resType.fighter), ObjType.FIGHTER);
    xKeyStack = new ArrayList();
    yKeyStack = new ArrayList();
    x = 600;
    y = 240;
    healing = false;
    healRange = 0;
  }

  public void setHP(int hp) {
    if (this.hp < hp) {
      healing = true;
    }
    this.hp = hp;
  }

  public void SpecialDraw() {
    float hpVal = hp;
    stroke(hpColor);
    fill(hpColor);
    ellipse(x, y, 45 + floor(hpVal/4f), 50);
    if (healing) {
      healRange +=10;
      ellipse(x, y, healRange, healRange);
      if (healRange >= 90) {
        healing = false;
      }
    } else if (healRange > 30) {
      healRange -= 5;
      ellipse(x, y, healRange, healRange);
    }
  }

  public void doGameLogic() {
    refreshKeyState();
    float hpVal = hp;
    if (hp>66) {
      int val = floor((hpVal - 66f) / 33f * 255f);
      hpColor = color(val, 255, val);
    } else if (hp>33) {
      int val = 255 - floor((hpVal - 33f) / 33f * 255f);
      hpColor = color(val, 255, 0);
    } else {
      int val = floor(hpVal / 33f * 255f);
      hpColor = color(255, val, 0);
    }
  }

  private void refreshKeyState() {
    if (xKeyStack.size()>0) {
      xKeyPressedTime ++;
      if (xKeyPressedTime>20) {
        xKeyPressedTime = 20;
      }
      switch(xKeyStack.get(xKeyStack.size()-1)) {
      case LEFT:
        x-=xKeyPressedTime>>1;
        break;
      case RIGHT:
        x+=xKeyPressedTime>>1;
      }
      int offset = objWidth >> 1;
      if (x < offset) {
        x = offset;
      } else if (x > (640 - offset)) {
        x = 640 - offset;
      }
    }
    if (yKeyStack.size()>0) {
      yKeyPressedTime ++; 
      if (yKeyPressedTime > 20) {
        yKeyPressedTime = 20;
      }
      switch(yKeyStack.get(yKeyStack.size()-1)) {
      case UP:
        y -= yKeyPressedTime >> 1;
        break;          
      case DOWN:
        y += yKeyPressedTime >> 1;
      }
      int offset = objHeight >> 1;
      if (y < offset) {
        y = offset;
      } else if (y > (480 - offset)) {
        y = 480 - offset;
      }
    }
  }

  /**
   * when key released
   */
  public void keyReleasedFun(int keyCode1) {
    if (keyCode1 == LEFT || keyCode1 == RIGHT) {
      xKeyPressedTime = 1;
      for (int i=0; i<xKeyStack.size(); i++) {
        if (xKeyStack.get(i)==keyCode1) {
          xKeyStack.remove(i);
          break;
        }
      }
    }
    if (keyCode1 == UP||keyCode1 == DOWN) {
      yKeyPressedTime = 1;
      for (int i=0; i<yKeyStack.size(); i++) {
        if (yKeyStack.get(i)==keyCode1) {
          yKeyStack.remove(i);
          break;
        }
      }
    }
  }

  /**
   * when key pressed
   */
  public void keyPressedFun(int keyCode1) {
    if (keyCode1 == LEFT || keyCode1 == RIGHT) {
      if (xKeyStack.size()==0 || xKeyStack.get(xKeyStack.size()-1)-keyCode1 != 0) {
        xKeyStack.add(keyCode1);
      }
    }
    if (keyCode1 == UP||keyCode1 == DOWN) {
      if (yKeyStack.size()==0 || yKeyStack.get(yKeyStack.size()-1)-keyCode1 != 0) {
        yKeyStack.add(keyCode1);
      }
    }
  }
}

//================================================================================================================
//================================================================================================================

class Treasure extends DrawingOBJ {

  private Fighter target = null;
  private GameDataChanged listener;

  public Treasure(Fighter target, GameDataChanged listener) {
    super(40, 40, resourcesMap.get(resType.treasure), ObjType.TREASURE);
    this.listener = listener;
    this.target = target;
    randomTreasure();
  }

  public void SpecialDraw() {
  }

  public void doGameLogic() {
    if (target != null) {
      if (isHitOBJ(target)) {
        if (listener != null) {
          listener.addHP(10);
        }
        randomTreasure();
      }
    }
  }

  /**
   * to random an treasure
   */
  public void randomTreasure() {
    // x is from 20 to 620
    // y is from 20 to 460
    do {
      x = floor(random(600)+20);
      y = floor(random(440)+20);
    } while (isHitOBJ(target));
  }
}

//================================================================================================================
//================================================================================================================

class Enemy extends DrawingOBJ {

  public boolean isInTeam;
  private Fighter target = null;
  private GameDataChanged listener;
  private float angle = 0;
  private int eSpeed, hitCount;

  public Enemy(Fighter target, GameDataChanged listener, int level) {
    super(60, 60, resourcesMap.get(resType.enemy), ObjType.ENEMY);
    setIsDrawSelf(false);
    this.listener = listener;
    this.target = target;
    isInTeam = false;
    randomEnemy(true);
    eSpeed = floor(eSpeed * (level/50f+1));  
    hitCount = 0;
  }

  public void SpecialDraw() {
    if (hitCount-- >1) {
      drawHit();
      return;
    } else if (hitCount ==1) {
      listener.enemyMoveOut(this);
      return;
    }
    pushMatrix();
    int half_height = objHeight>>1;
    int half_width = objWidth>>1;
    translate(x, y );
    rotate(angle);
    image(super.img, -half_width, -half_height);
    popMatrix();
  }

  public void doGameLogic() {
    if (hitCount>0) {
      return;
    }
    angle = 0;
    if (x < -objWidth) {
      // wait 100 times, show warning and speed 
      float temp = (- objWidth - x);
      if (temp < 100) {
        int tSize = floor(20 * (1 - (- objWidth - x) / 100f) + 5);
        textAlign(LEFT);
        textSize(16);
        // draw different color with different speed
        if (eSpeed > 10) {
          // 10 - 20 yellow to red
          drawStrokeText("" + eSpeed, color(255, 255 - floor((eSpeed-10)/10f * 255), 0), #ffffff, 25, y+ 8, 1);
        } else {
          // 1 - 10 green to yellow
          drawStrokeText("" + eSpeed, color(floor((eSpeed)/10f * 255), 255, 0), #ffffff, 25, y+ 8, 1);
        }
        textSize(tSize);
        drawStrokeText("!", #ff0000, #ffffff, 10, y + (tSize >> 1), 1);
      }
      x += 1;
    } else {
      // normal moves
      x += eSpeed;
      if ((!isInTeam)&&(x<target.x)) {
        int yMove = (target.y-y)>>6;// (fightY-eY)/2^6 fast calculate
        if (yMove>10) {
          yMove =10;
        }
        y += yMove;
        angle = atan(float(yMove)/eSpeed);
      }
    }
    if (listener != null) {
      if (x>= 640) {
        listener.enemyMoveOut(this);
      }
    }
    if (this.isHitOBJ(target)) {
      if (listener != null) {
        listener.subHP(20);
      }
      x = 640+objWidth;
      y = 480+objHeight;
      drawHit();
      hitCount = 3;
    }
  }

  private void drawHit() {
    stroke(#ff0000);
    fill(#ff0000);
    rect(0, 0, 640, 480);
  }

  private void randomEnemy(boolean isAvoidFighter) {
    x = -100 - objWidth;
    eSpeed = floor(random(1, 5));
    do {
      y = floor(random(0, 450));
      // if need avoid fighter and enemy is in fighter line then random again
    } while (isAvoidFighter && isInTargetLine(target));
  }

  private boolean isInTargetLine(Fighter obj) {
    int yOffset = objHeight >> 1 ;
    int yOffset1 = obj.objHeight >>1;
    int top = y + yOffset, bottom = y - yOffset;
    int tt = obj.y + yOffset1, tb = obj.y - yOffset1;
    if ((bottom < tt)&&(top > tb)) {
      return true;
    }
    return false;
  }
}

//================================================================================================================
//================================================================================================================

class GameTitle extends DrawingOBJ {

  public int hp = 0, level = 0;

  public GameTitle() {
    super(0, 0, resourcesMap.get(resType.hp), ObjType.TITLE);
    x = 10;
    y = 10;
  }

  public void SpecialDraw() {
    textSize(15);
    textAlign(CENTER);
    drawStrokeText(hp + "", #ffffff, #000000, x + 112, y + 17, 1);
    drawLV();
  }

  public void doGameLogic() {
    if (hp< 0 ) {
      hp = 0;
    } else if (hp>100) {
      hp = 100;
    }
    color hpColor ;
    float hpVal = hp;
    int curhp = floor(194f * hp / 100f);
    if (hp > 50) {
      int val = 255 - floor((hpVal - 50f) / 50f * 255f);
      hpColor = color(val, 255, 0);
    } else {
      int val = floor(hpVal / 50f * 255f);
      hpColor = color(255, val, 0);
    }
    drawHPBar(hpColor, curhp);
  }

  private void drawHPBar(color barColor, int barWidth) {
    stroke(barColor);
    fill(barColor);
    rect( x + 12, y + 4, barWidth, 16);
  }

  /**
   * to draw the value of level
   */
  private void drawLV() {
    textSize(15);
    textAlign(RIGHT);
    drawStrokeText("Level:"+level, #ffffff, #000000, 620, 20, 1);
  }
}

//================================================================================================================
//================================================================================================================

class OnGaming extends DrawingOBJ implements KeyPressListener, GameDataChanged {

  public int level, hp;

  private int bg2x = 640, speed = 5, cnt =0, teamCnt, teamId;
  private boolean listChange;
  private ArrayList<DrawingOBJ>  drawingArray;
  private Fighter fighter = null;
  private GameTitle title = null;
  private ScreenChangeListener listener;


  public OnGaming(ScreenChangeListener listener) {
    super(0, 0, resourcesMap.get(resType.bg1), ObjType.BACKGROUND);
    this.listener = listener;
    listChange = false;
    drawingArray = new ArrayList();

    hp = 20;
    level = 0;
    teamId = 0;

    fighter = new Fighter();
    fighter.setHP(hp) ;
    fighter.zOrder = 1;

    drawingArray.add(fighter);

    title = new GameTitle();
    title.hp = hp;
    title.zOrder = 3;
    drawingArray.add(title);

    randomTeam();
    Treasure t = new Treasure(fighter, this);
    t.zOrder = 2;
    drawingArray.add(t);
  }

  public void SpecialDraw() {
    cnt = drawingArray.size();
    for (int i = 0; i < cnt; i++) {
      for (int j = i+1; j < cnt; j++) {
        if (drawingArray.get(i).zOrder > drawingArray.get(j).zOrder) {
          DrawingOBJ temp = drawingArray.get(i);
          drawingArray.set(i,drawingArray.get(j));
          drawingArray.set(j,temp);
        }
      }
    }
    for (int i = 0; i < cnt; i++) {
      drawingArray.get(i).drawFrame();
      if (listChange) {
        listChange = false;
        cnt = drawingArray.size();
        i--;
      }
    }
  }

  public void doGameLogic() {
    doBackgroundLogic();
    if (hp <= 0) {
      listener.endGame(level);
    }
  }

  private void randomTeam() {

    int yy;
    int s = floor(random(1, 5));
    if (teamId==0) {
      yy= floor(random(420)+30);
      teamCnt = 5;
      for (int i =0; i<5; i++) {
        Enemy hehe = new Enemy(fighter, this, level);
        hehe.x = hehe.x - 40*i;
        hehe.y = yy;
        hehe.eSpeed = s;
        hehe.isInTeam = true;
        drawingArray.add(hehe);
      }
    } else if (teamId==1) {
      yy= floor(random(260)+30);
      teamCnt = 5;
      for (int i =0; i<5; i++) {
        Enemy hehe = new Enemy(fighter, this, level);
        hehe.x = hehe.x - 40*i;
        hehe.y = yy+50*i;
        hehe.eSpeed = s;
        hehe.isInTeam = true;
        drawingArray.add(hehe);
      }
    } else {
      yy= floor(random(240)+120);
      teamCnt = 8;
      Enemy hehe = new Enemy(fighter, this, level);
      hehe.x = hehe.x;
      hehe.y = yy;
      hehe.eSpeed = s;
      hehe.isInTeam = true;
      drawingArray.add(hehe);

      hehe = new Enemy(fighter, this, level);
      hehe.x = hehe.x-40;
      hehe.y = yy-50;
      hehe.eSpeed = s;
      hehe.isInTeam = true;
      drawingArray.add(hehe);

      hehe = new Enemy(fighter, this, level);
      hehe.x = hehe.x-40;
      hehe.y = yy+50;
      hehe.eSpeed = s;
      hehe.isInTeam = true;
      drawingArray.add(hehe);

      hehe = new Enemy(fighter, this, level);
      hehe.x = hehe.x-80;
      hehe.y = yy-80;
      hehe.eSpeed = s;
      hehe.isInTeam = true;
      drawingArray.add(hehe);

      hehe = new Enemy(fighter, this, level);
      hehe.x = hehe.x-80;
      hehe.y = yy+80;
      hehe.eSpeed = s;
      hehe.isInTeam = true;
      drawingArray.add(hehe);

      hehe = new Enemy(fighter, this, level);
      hehe.x = hehe.x-120;
      hehe.y = yy-40;
      hehe.eSpeed = s;
      hehe.isInTeam = true;
      drawingArray.add(hehe);

      hehe = new Enemy(fighter, this, level);
      hehe.x = hehe.x-120;
      hehe.y = yy+40;
      hehe.eSpeed = s;
      hehe.isInTeam = true;
      drawingArray.add(hehe);

      hehe = new Enemy(fighter, this, level);
      hehe.x = hehe.x-160;
      hehe.y = yy;
      hehe.eSpeed = s;
      hehe.isInTeam = true;
      drawingArray.add(hehe);
    }
    teamId++;
    if (teamId>2) {
      teamId = 0;
    }
  }

  private void doBackgroundLogic() {
    x = moveBG(x);
    bg2x = moveBG(bg2x);
    image(resourcesMap.get(resType.bg2), bg2x, y);
  }

  private int moveBG(int curX) {
    // the more level the more quick background moves
    int speedOffset = level/10;
    int maxOffset = speed<<1;
    if (speedOffset> maxOffset) {
      speedOffset = maxOffset;
    }
    curX +=640 + speed + speedOffset;
    curX %= 1280;
    curX -= 640;
    return curX;
  }


  /**
   * when key released
   */
  public void keyReleasedFun(int keyCode1) {
    fighter.keyReleasedFun(keyCode1);
  }

  /**
   * when key pressed
   */
  public void keyPressedFun(int keyCode1) {
    fighter.keyPressedFun(keyCode1);
  }


  public void addHP(int val) {
    hp += val;
    level++;
    if (hp > 100) {
      hp = 100;
    }
    syncInfo();
  }

  public void subHP(int val) {
    hp -= val;
    if (hp < 0) {
      hp = 0;
    }
    syncInfo();
  }

  public void enemyMoveOut(Enemy target) {
    drawingArray.remove(target);
    if (--teamCnt==0) {
      randomTeam();
    }
    //drawingArray.add(new Enemy(fighter, this, level));
    listChange = true;
  }

  public void drawFrame() {
    doGameLogic();
    int half_height = objHeight>>1;
    int half_width = objWidth>>1;
    image(super.img, x - half_width, y - half_height);    
    SpecialDraw();
  }

  private void syncInfo() {
    title.hp = hp;
    title.level= level;
    fighter.setHP(hp);
  }
}

//================================================================================================================
//================================================================================================================

class GameStart extends DrawingOBJ implements MouseListener {

  private boolean isOnButton, isPressButton;
  private ScreenChangeListener listener = null;

  public GameStart(ScreenChangeListener listener) {
    super(0, 0, resourcesMap.get(resType.st2), ObjType.TITLE);
    this.listener = listener;
  }

  public void SpecialDraw() {
    if (isOnButton && (! isPressButton)) {
      image(resourcesMap.get(resType.st1), 0, 0);
    }
  }

  public void doGameLogic() {
    if (isOnButton && (! isPressButton)) {
      setIsDrawSelf(false);
    } else {
      setIsDrawSelf(true);
    }
  }


  public void mouseReleasedFun(int keyCode1) {
    if (keyCode1 == MOUSE_LEFT) {
      isPressButton = false;
      if (listener != null) {
        listener.startGame();
      }
    }
  }
  public void mousePressedFun(int keyCode1) {
    if (keyCode1 == MOUSE_LEFT) {
      isPressButton = true;
    }
  }
  public void mouseMovedFun(int x, int y) {
    isOnButton =  isPointHitArea(x, y, 210, 380, 450, 410);
  }
}


//================================================================================================================
//================================================================================================================

class GameEnd extends DrawingOBJ implements MouseListener {

  public int level = 0;
  private boolean isOnButton, isPressButton;
  private ScreenChangeListener listener = null;

  public GameEnd(ScreenChangeListener listener) {
    super(0, 0, resourcesMap.get(resType.end2), ObjType.TITLE);
    this.listener = listener;
    isOnButton = false;
    isPressButton = false;
  }

  public void SpecialDraw() {
    if (isOnButton && (! isPressButton)) {
      image(resourcesMap.get(resType.end1), 0, 0);
    }
    textAlign(CENTER);
    textSize(30);
    drawStrokeText("Final Level:"+level, #ffffff, #ff0000, 320, 220, 2);
  }

  public void doGameLogic() {
    if (isOnButton && (! isPressButton)) {
      setIsDrawSelf(false);
    } else {
      setIsDrawSelf(true);
    }
  }

  public void drawFrame() {
    doGameLogic();
    image(resourcesMap.get(resType.end2), 0, 0);
    SpecialDraw();
  }

  public void mouseReleasedFun(int keyCode1) {
    if (keyCode1 == MOUSE_LEFT) {
      isPressButton = false;
      listener.restartGame();
    }
  }
  public void mousePressedFun(int keyCode1) {
    if (keyCode1 == MOUSE_LEFT) {
      isPressButton = true;
    }
  }
  public void mouseMovedFun(int x, int y) {
    isOnButton =  isPointHitArea(x, y, 210, 310, 435, 345);
  }
}
