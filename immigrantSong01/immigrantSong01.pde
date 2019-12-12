/**
 *
 * immigrantSong 01
 * -----------------
 * dual vista:  
 *   first person: pixelate view of maps videos
 *   map:  map and info 
 */

import processing.video.*;

int numPixelsWide, numPixelsHigh;
int blockSize = 10;
Movie mov;
color movColors[];

final int nPoints = 167;
PVector[] points = new PVector[nPoints];
boolean showMap = false;
//PVector offset = new PVector(133, 8);
PVector offset = new PVector(8, 8);
PImage mapImg;
int r;
PFont font1, font2;

float energy, water, tempe, cansa, iniTime, t0;
int indexLoc, indexMov;
PVector actPos, destPos; 
boolean endRoad;
boolean isAlive;
float incx=0.003;
float incy=0.003;

String testId;
PImage hi;

void setup() {
  size(1280,720);
  numPixelsWide = width / blockSize;
  numPixelsHigh = height / blockSize;
  movColors = new color[numPixelsWide * numPixelsHigh];
  noStroke();
  mapImg = loadImage("W:/W/2019/1909_migrar/reporte_02/mapa_zapotitlan_axochiapan-r01_reduc_neg.jpg");
  hi = loadImage("red512_mini.png");
  font1 = createFont("pixelmix_bold.ttf", 24);
  font2 = createFont("pixelmix_bold.ttf", 18);
  textFont(font1);
  setPoints();
  println(nPoints, numPixelsWide, numPixelsHigh);

  // start game
  testId = hex((int)random(0xffff),4);
  indexMov = 1 + int(random(4));
  if (indexMov==1) mov = new Movie(this, "W:/W/2019/1909_migrar/reporte_02/zapotitlanOAX_axochiapanMOR_720_30_S1.mp4");
  else if (indexMov==2) mov = new Movie(this, "W:/W/2019/1909_migrar/reporte_02/zapotitlanOAX_axochiapanMOR_720_30_S2.mp4");
  else if (indexMov==3) mov = new Movie(this, "W:/W/2019/1909_migrar/reporte_02/zapotitlanOAX_axochiapanMOR_720_30_S3.mp4");
  else if (indexMov==4) mov = new Movie(this, "W:/W/2019/1909_migrar/reporte_02/zapotitlanOAX_axochiapanMOR_720_30_S4.mp4");
  indexLoc = int(nPoints/4)*(indexMov-1);
  mov.play();
  energy = 100;
  water = 100;
  tempe = 36.0;
  cansa = 0;
  iniTime = 0;
  endRoad = false;
  isAlive = true;
  actPos = new PVector(points[indexLoc].x, points[indexLoc].y);
  destPos = new PVector(points[indexLoc+1].x, points[indexLoc+1].y);
  println("Segmento número:", indexMov, "Loc index:",indexLoc, "Coordinates:", actPos.x, actPos.y);
  //  
}



void draw() {
  // if avalible, update frame
  if (mov.available() == true) {
    mov.read();
    mov.loadPixels();
    int count = 0;
    for (int j = 0; j < numPixelsHigh; j++) {
      for (int i = 0; i < numPixelsWide; i++) {
        movColors[count] = mov.get(i*blockSize, j*blockSize);
        count++;
      }
    }
  }
  
  if (energy<=0){
    isAlive=false;
    mov.pause();
  }
  // update position and locations
  if (dist(actPos.x, actPos.y, destPos.x, destPos.y)<0.01){
    if (indexLoc<(nPoints-2) && !endRoad){
      indexLoc++;
      actPos = new PVector(points[indexLoc].x, points[indexLoc].y);
      destPos = new PVector(points[indexLoc+1].x, points[indexLoc+1].y);
      energy-=random(5);
    } else {
      actPos = new PVector(points[indexLoc].x, points[indexLoc].y);
      destPos = new PVector(points[indexLoc].x, points[indexLoc].y);
      endRoad = true;
      mov.pause();
    }
  } else {
    actPos.x = lerp(actPos.x, destPos.x, incx);
    actPos.y = lerp(actPos.y, destPos.y, incy);
  }
  

  
  // show map
  if (showMap==true){
    background(0);
    image(mapImg, offset.x, offset.y);
    stroke(0,255,0);
    fill(0,255,0, 127);
    for (int i=0; i<nPoints; i++){
      r = 10;
      rect(points[i].x+offset.x-r/2, points[i].y+offset.y-r/2, r,r);
    }
    strokeWeight(3);
    fill(0,255,0, 32);
    rect(offset.x, offset.y, mapImg.width, mapImg.height);
    rect(offset.x+mapImg.width, offset.y, 250, mapImg.height);

    // draw actPos
    noFill();
    strokeWeight(1);
    r = int(frameCount/2)%30;
    rect(offset.x+actPos.x-r/2, offset.y+actPos.y-r/2, r, r);

    stroke(0,255,0, 64);
    line(offset.x+actPos.x, offset.y, offset.x+actPos.x, offset.y+mapImg.height);
    line(offset.x, offset.y+actPos.y, offset.x+mapImg.width, offset.y+actPos.y);
    // text
    stroke(0,255,0, 255);
    fill(0,255,0, 255);
    textFont(font1);
    text("ID: "+testId, 1080, 100);
    textFont(font2);
    text("Energia: ", 1040, 260);
    int inen = int(energy/25);
    tint(0,255,0);
    for (int i=0; i<inen; i++){
      image(hi, 1140+28*i, 280, 32, 32);
    }
    tint(255);
    text("Status: ", 1040, 340);
    if (isAlive) text("A Salvo", 1140, 380);
    else text("Peligro", 1140, 380);
    text("Tiempo: ", 1040, 420);
    text(millis(), 1140, 460);    
    text("Sig Checkpoint: ", 1040, 500);
    text(dist(actPos.x, actPos.y, destPos.x, destPos.y), 1140, 540);
    
  } 
  // show first person
  else {
    //background(255);
    noStroke();
    for (int j = 0; j < numPixelsHigh; j++) {
      for (int i = 0; i < numPixelsWide; i++) {
        fill(movColors[j*numPixelsWide + i], 127);
        rect(i*blockSize, j*blockSize, blockSize, blockSize);
      }
    }
    noStroke();
    fill(25, 202);
    rect(0, 520, 210, 210);
    stroke(255);
    fill(255);
    textFont(font2);
    text("[+]: "+energy, 25, 560);
    text("[-]: "+tempe, 25, 590);
    text("[t]: "+millis(), 25, 620);
    textFont(font2);
    text("[x]: "+actPos.x, 25, 680);
    text("[y]: "+actPos.y, 25, 710);

  }
}


void keyPressed(){
  if (key=='m'){
    showMap =!showMap;
  }
}



void setPoints(){
  points[0]  = new PVector(921, 670);
  points[1]  = new PVector(921, 670);
  points[2]  = new PVector(916, 664);
  points[3]  = new PVector(915, 662);
  points[4]  = new PVector(911, 660);
  points[5]  = new PVector(904, 657);
  points[6]  = new PVector(895, 654);
  points[7]  = new PVector(890, 649);
  points[8]  = new PVector(886, 649);
  points[9]  = new PVector(880, 641);
  points[10]  = new PVector(875, 634);
  points[11]  = new PVector(869, 624);
  points[12]  = new PVector(869, 618);
  points[13]  = new PVector(875, 611);
  points[14]  = new PVector(876, 603);
  points[15]  = new PVector(873, 596);
  points[16]  = new PVector(874, 592);
  points[17]  = new PVector(869, 585);
  points[18]  = new PVector(860, 577);
  points[19]  = new PVector(856, 569);
  points[20]  = new PVector(852, 559);
  points[21]  = new PVector(849, 551);
  points[22]  = new PVector(847, 541);
  points[23]  = new PVector(849, 531);
  points[24]  = new PVector(848, 521);
  points[25]  = new PVector(841, 516);
  points[26]  = new PVector(834, 505);
  points[27]  = new PVector(830, 497);
  points[28]  = new PVector(826, 491);
  points[29]  = new PVector(817, 485);
  points[30]  = new PVector(812, 478);
  points[31]  = new PVector(805, 470);
  points[32]  = new PVector(796, 464);
  points[33]  = new PVector(791, 458);
  points[34]  = new PVector(788, 446);
  points[35]  = new PVector(788, 446);
  points[36]  = new PVector(783, 439);
  points[37]  = new PVector(774, 433);
  points[38]  = new PVector(770, 424);
  points[39]  = new PVector(760, 426);
  points[40]  = new PVector(748, 431);
  points[41]  = new PVector(742, 423);
  points[42]  = new PVector(734, 419);
  points[43]  = new PVector(727, 414);
  points[44]  = new PVector(721, 409);
  points[45]  = new PVector(721, 399);
  points[46]  = new PVector(718, 395);
  points[47]  = new PVector(716, 393);
  points[48]  = new PVector(713, 392);
  points[49]  = new PVector(710, 388);
  points[50]  = new PVector(704, 387);
  points[51]  = new PVector(699, 396);
  points[52]  = new PVector(690, 402);
  points[53]  = new PVector(681, 396);
  points[54]  = new PVector(674, 386);
  points[55]  = new PVector(673, 376);
  points[56]  = new PVector(665, 370);
  points[57]  = new PVector(662, 362);
  points[58]  = new PVector(656, 360);
  points[59]  = new PVector(651, 359);
  points[60]  = new PVector(644, 351);
  points[61]  = new PVector(634, 348);
  points[62]  = new PVector(627, 343);
  points[63]  = new PVector(620, 348);
  points[64]  = new PVector(611, 349);
  points[65]  = new PVector(602, 345);
  points[66]  = new PVector(594, 342);
  points[67]  = new PVector(584, 347);
  points[68]  = new PVector(577, 345);
  points[69]  = new PVector(566, 345);
  points[70]  = new PVector(561, 341);
  points[71]  = new PVector(557, 333);
  points[72]  = new PVector(554, 323);
  points[73]  = new PVector(553, 311);
  points[74]  = new PVector(553, 301);
  points[75]  = new PVector(551, 292);
  points[76]  = new PVector(549, 285);
  points[77]  = new PVector(546, 272);
  points[78]  = new PVector(540, 265);
  points[79]  = new PVector(532, 257);
  points[80]  = new PVector(523, 251);
  points[81]  = new PVector(513, 251);
  points[82]  = new PVector(512, 249);
  points[83]  = new PVector(496, 239);
  points[84]  = new PVector(488, 231);
  points[85]  = new PVector(486, 223);
  points[86]  = new PVector(481, 210);
  points[87]  = new PVector(481, 205);
  points[88]  = new PVector(480, 196);
  points[89]  = new PVector(473, 187);
  points[90]  = new PVector(464, 183);
  points[91]  = new PVector(457, 193);
  points[92]  = new PVector(450, 187);
  points[93]  = new PVector(447, 177);
  points[94]  = new PVector(446, 168);
  points[95]  = new PVector(442, 157);
  points[96]  = new PVector(440, 149);
  points[97]  = new PVector(431, 140);
  points[98]  = new PVector(423, 136);
  points[99]  = new PVector(416, 129);
  points[100]  = new PVector(414, 120);
  points[101]  = new PVector(413, 111);
  points[102]  = new PVector(404, 107);
  points[103]  = new PVector(396, 104);
  points[104]  = new PVector(393, 95);
  points[105]  = new PVector(389, 86);
  points[106]  = new PVector(383, 82);
  points[107]  = new PVector(381, 72);
  points[108]  = new PVector(374, 67);
  points[109]  = new PVector(374, 63);
  points[110]  = new PVector(372, 58);
  points[111]  = new PVector(367, 55);
  points[112]  = new PVector(364, 52);
  points[113]  = new PVector(362, 46);
  points[114]  = new PVector(357, 49);
  points[115]  = new PVector(353, 46);
  points[116]  = new PVector(344, 50);
  points[117]  = new PVector(342, 58);
  points[118]  = new PVector(340, 60);
  points[119]  = new PVector(337, 58);
  points[120]  = new PVector(335, 57);
  points[121]  = new PVector(332, 52);
  points[122]  = new PVector(325, 48);
  points[123]  = new PVector(318, 46);
  points[124]  = new PVector(317, 49);
  points[125]  = new PVector(307, 41);
  points[126]  = new PVector(303, 41);
  points[127]  = new PVector(302, 41);
  points[128]  = new PVector(298, 41);
  points[129]  = new PVector(295, 41);
  points[130]  = new PVector(293, 41);
  points[131]  = new PVector(291, 41);
  points[132]  = new PVector(285, 44);
  points[133]  = new PVector(282, 48);
  points[134]  = new PVector(275, 49);
  points[135]  = new PVector(266, 47);
  points[136]  = new PVector(259, 44);
  points[137]  = new PVector(253, 44);
  points[138]  = new PVector(251, 46);
  points[139]  = new PVector(246, 50);
  points[140]  = new PVector(241, 55);
  points[141]  = new PVector(236, 62);
  points[142]  = new PVector(228, 65);
  points[143]  = new PVector(224, 63);
  points[144]  = new PVector(222, 61);
  points[145]  = new PVector(214, 62);
  points[146]  = new PVector(210, 67);
  points[147]  = new PVector(207, 70);
  points[148]  = new PVector(206, 72);
  points[149]  = new PVector(201, 75);
  points[150]  = new PVector(199, 77);
  points[151]  = new PVector(192, 80);
  points[152]  = new PVector(185, 86);
  points[153]  = new PVector(176, 95);
  points[154]  = new PVector(168, 97);
  points[155]  = new PVector(155, 102);
  points[156]  = new PVector(147, 103);
  points[157]  = new PVector(137, 104);
  points[158]  = new PVector(126, 108);
  points[159]  = new PVector(116, 108);
  points[160]  = new PVector(109, 106);
  points[161]  = new PVector(101, 108);
  points[162]  = new PVector(90, 108);
  points[163]  = new PVector(85, 102);
  points[164]  = new PVector(77, 92);
  points[165]  = new PVector(70, 84);
  points[166]  = new PVector(70, 84);
}
