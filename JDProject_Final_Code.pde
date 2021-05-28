/**

ignore special characters

 * ControlP5 Matrix
 *
 * A matrix can be used for example as a sequencer, a drum machine.
 *
 * find a list of public methods available for the Matrix Controller
 * at the bottom of this sketch.
 *
 * by Andreas Schlegel, 2012
 * www.sojamo.de/libraries/controlp5
 *
 */

import controlP5.*;
import processing.serial.*;
import java.util.Random;


ControlP5 cp5;
Serial port;

String textValue = ""; 

int RED = 0;          //stores red color value
int GREEN = 0;        //stores green
int BLUE = 0;         //stores blue
int LAYER = 0;        //stores current layer value

Slider abc;           //variable for sliders
Textlabel title;      //variable for textlabeling

layer[][] d;    //initializes aray for the size of mymatrix
int nx = 8;
int ny = 8;

//initialize the led matrix array
int [][][][] matrix = new int[8][8][8][3];  //[column][row][layer][color & intensity]       



//adds and initializes the gui toolset consisting of the matrix, sliders, buttons, and message textfield  
void setup() {
  size(750, 900);    //screen size

  //port = new Serial(this, "COM3", 9600); // connect to com3 serial port w/ a baud rate of 9600
  cp5 = new ControlP5(this);

//create matrix
  cp5.addMatrix("myMatrix") 
     .setPosition(50, 250)
     .setSize(300, 300)
     .setGrid(nx, ny)
     .setGap(5, 5)
     .pause()
     .setMode(ControlP5.MULTIPLES)
     .setColorBackground(color(120))
     .setBackground(color(50))
     .setFont(createFont("arial", 15))
     ;
    
  // use setMode to change the cell-activation which by 
  // default is ControlP5.SINGLE_ROW, 1 active cell per row, 
  // but can be changed to ControlP5.SINGLE_COLUMN or 
  // ControlP5.MULTIPLES
    d = new layer[nx][ny];
  for (int x = 0;x<nx;x++) {
    for (int y = 0;y<ny;y++) {
      d[x][y] = new layer();
    }
  }  
  noStroke();
  smooth();
  
  //create text field
    cp5.addTextfield("Message")
     .setPosition(100,100)
     .setSize(400,40)
     .setFont(createFont("arial",30))
     .setAutoClear(false)
     ;
       
 //create clear button
    cp5.addBang("clear")
     .setPosition(550,100)
     .setSize(80,40)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
     .setFont(createFont("arial",15))
     ; 

 //sliders
 
    cp5.addSlider("RED")
     .setPosition(500,200)
     .setSize(20,100)
     .setRange(0,255)
     .setNumberOfTickMarks(3)
     .setFont(createFont("arial",15))     
     ;

    cp5.addSlider("GREEN")
     .setPosition(575,200)
     .setSize(20,100)
     .setRange(0,255)
     .setNumberOfTickMarks(3)
     .setFont(createFont("arial",15))     
     ;
     
    cp5.addSlider("BLUE")
     .setPosition(650,200)
     .setSize(20,100)
     .setRange(0,255)
     .setNumberOfTickMarks(3)
     .setFont(createFont("arial",15))     
     ;
     
    cp5.addSlider("LAYER")
     .setPosition(400,250)
     .setSize(30,265)
     .setRange(0,7)
     .setNumberOfTickMarks(8)
     .setFont(createFont("arial",15))     
     ;
   
  //Title 
    title = cp5.addTextlabel("title")
     .setText("LED CUBE CONTROLLER")
     .setPosition(200, 10)
     .setColorValue(0xfffffff0)
     .setFont(createFont("arial",30))
     ;
     
  //instructions and hot keys
    title = cp5.addTextlabel("instructions")
     .setText("Hot keys" + "\n" + "\n" + "<SPACEBAR>: Start/Stop the MYMATRIX drawing tool " + "\n" + "<ENTER>: Send message to the cube (special characters will not be recognized)" + "\n" + "<0>: Clear MYMATRIX" )
     .setPosition(50, 800)
     .setColorValue(0xfffffff0)
     .setFont(createFont("arial",15))
     ;
     
  //add buttons for the three animations
  cp5.addButton("Animation1")
     .setPosition(75,650)
     .setSize(150,50)
     .setFont(createFont("arial",15))     
     ;
  
  // and add another 2 buttons
  cp5.addButton("Animation2")
     .setPosition(275,650)
     .setSize(150,50)
     .setFont(createFont("arial",15))     
     ;
     
  cp5.addButton("Animation3")
     .setPosition(475,650)
     .setSize(150,50)
     .setFont(createFont("arial",15))     
     ;
}

//draws the background, textboxes, and color indicator of the gui interface display
void draw() {
  background(25);                  //background color
  fill(255, 100);                  //textbox fill
  text(textValue, 360,180);        //textbox

  
  fill(RED, GREEN, BLUE);          //color indicator
  ellipse(550,425,75,75);          
    
  fill(30, 80, 150);               //textbox for hot keys
  rect(40, 790, 600, 100);
}

//clear text field if the clear button is pressed
public void clear() {
  cp5.get(Textfield.class,"Message").clear();
}

//when Animation1 buton is pressed this function calls animation1() to send the animation to the cube
public void Animation1(){
  animation1(); 
}

//when Animation2 buton is pressed this function calls animation2() to send the animation to the cube
public void Animation2(){
  animation2(); 
}



//updates the matrix array from the (x,y) position, layer, and color indicated by the user whenever the MYMATRIX tool sweeps over any LED cells 
//that are being actively written to then calls to parse_array() to send the new display to the cube. 
//i.e Any time the MYMATRIX changes the display the matrix array is updated then sent to the aruino.
void myMatrix(int theX, int theY) {
  matrix[theX][theY][LAYER][0] = RED;             //update red cells
  matrix[theX][theY][LAYER][1] = GREEN;           //update green cells
  matrix[theX][theY][LAYER][2] = BLUE;            //update blue cells
  parse_array();                                  //send array to arduino
}

//Defines the hot keys to start/stop the animation with spacebar or clear the matrix with 0
void keyPressed() {
  //pause animation que with spacebar 
  if (key==' ') {                                              
    if (cp5.get(Matrix.class, "myMatrix").isPlaying()) {
      cp5.get(Matrix.class, "myMatrix").pause();
    } 
    
   //play animation que otherwise 
    else {
      cp5.get(Matrix.class, "myMatrix").play();
    }
  }  
  
  //clear matrix if 0 is pressed
  else if (key=='0') {
    cp5.get(Matrix.class, "myMatrix").clear();
  }
}

//Declares class layer with x and y values for the matrix display
class layer {
  float x, y;
}

//control text field event and call to the corresponding character displays when enter is pressed then delay between each character
//ignores all non alpha-numeric characters
void controlEvent(ControlEvent theEvent) {
  if(theEvent.isAssignableFrom(Textfield.class)) {
    String text = theEvent.getStringValue();

    for(int i = 0; i < text.length(); i++){    //for loop searching for each letter
    
      clear();                                //clear the current matrix display
    
      if (text.charAt(i) == 'A' || text.charAt(i) == 'a' ){
          letterA();
      } 
        
      if (text.charAt(i) == 'B' || text.charAt(i) == 'b' ){
        letterB();
      }  
      
      if (text.charAt(i) == 'C' || text.charAt(i) == 'c' ){
        letterC();
      }  
      
      if (text.charAt(i) == 'D' || text.charAt(i) == 'd' ){
        letterD();
      }  
      
      if (text.charAt(i) == 'E' || text.charAt(i) == 'e'){
        letterE();
      }  
      
      if (text.charAt(i) == 'F' || text.charAt(i) == 'f' ){
        letterF();
      }  
      
      if (text.charAt(i) == 'G' || text.charAt(i) == 'g' ){
        letterG();
      }  
      
      if (text.charAt(i) == 'H' || text.charAt(i) == 'h' ){
        letterH();
      }  
      
      if (text.charAt(i) == 'I' || text.charAt(i) == 'i' ){
        letterI();
      }  
      
      if (text.charAt(i) == 'J' || text.charAt(i) == 'j' ){
        letterJ();
      } 
      
      if (text.charAt(i) == 'K' || text.charAt(i) == 'k' ){
        letterK();
      } 
      
      if (text.charAt(i) == 'L' || text.charAt(i) == 'l' ){
        letterL();
      } 
      
      if (text.charAt(i) == 'M' || text.charAt(i) == 'm' ){
        letterM();
      }  
      
      if (text.charAt(i) == 'N' || text.charAt(i) == 'n' ){
        letterN();
      } 
      
      if (text.charAt(i) == 'O' || text.charAt(i) == 'o' ){
        letterO();
        //call funct
      }  
      
      if (text.charAt(i) == 'P' || text.charAt(i) == 'p' ){
        letterP();
        //call funct
      }  
      
      if (text.charAt(i) == 'Q' || text.charAt(i) == 'q' ){
        //call funct
        letterQ();
      }  
      
      if (text.charAt(i) == 'R' || text.charAt(i) == 'r' ){
        //call funct
        letterR();
      } 
      
      if (text.charAt(i) == 'S' || text.charAt(i) == 's' ){
        //call funct
        letterS();
      }  
      
      if (text.charAt(i) == 'T' || text.charAt(i) == 't' ){
        //call funct
        letterT();
      } 
      
      if (text.charAt(i) == 'U' || text.charAt(i) == 'u' ){
        //call funct
        letterU();
      }  if (text.charAt(i) == 'V' || text.charAt(i) == 'v' ){
        //call funct
        letterV();
      }  
      
      if (text.charAt(i) == 'W' || text.charAt(i) == 'w' ){
        //call funct
        letterW();
      }
      
      if (text.charAt(i) == 'X' || text.charAt(i) == 'x' ){
        //call funct
        letterX();
      }  
      
      if (text.charAt(i) == 'Y' || text.charAt(i) == 'y' ){
        //call funct
        letterY();
      } 
      
      if (text.charAt(i) == 'Z' || text.charAt(i) == 'z' ){
        //call funct
        letterZ();
      }  
      
      if (text.charAt(i) == '0'){
        //call funct
        letterO();
      }  
      
      if (text.charAt(i) == '1'){
        num1();//call funct
      }  
     
      if (text.charAt(i) == '2'){
        num2();//call funct
      }  
      
      if (text.charAt(i) == '3'){
        num3();//call funct
      } 
     
      if (text.charAt(i) == '4'){
        num4();//call funct
      }  
     
      if (text.charAt(i) == '5'){
        num5();//call funct
      } 
     
      if (text.charAt(i) == '6'){
        num6();//call funct
      } 
      
      if (text.charAt(i) == '7'){
        num7();//call funct
      }  
     
      if (text.charAt(i) == '8'){
            num8();//call funct
      } 
     
      if (text.charAt(i) == '9'){
           num9(); //call funct
      } 
      delay(50);       //delay 50ms
       
    }
  }
}


//This function sends a display to the LED cube by parsing through the matrix array and converting it to a bit stream that is sent to the microcontroller
//  *the print functions are for debugging and demo only, uncomment port.write() commands when interfacing with the cube
void parse_array(){
  for(int l = 0; l < 2; l++){              //parse intensity
    for(int h = 0; h < 8; h++){            //parse layers
      for(int i = 0; i < 8; i++){          //parse rows
        for(int j = 0; j < 3; j++){        //parse colors
          for(int k = 0; k < 8; k++){      //parse each column in a row
          
            if(l == 0){                    //check for LED intensity in frame one
              if(matrix[k][i][h][j] > 0){
                port.write(1);
              }
              else{
                port.write(0);
              }
            }
            
            if(l == 1){                      //check for LED intensity in frame two
              if(matrix[k][i][h][j] == 255){
                port.write(1);
              }
              else{
                port.write(0); 
              }
            }
          }
        }
      }
    }
  }
}

//Resets all the matrix RGB values to 0
void reset(){
  for(int i = 0; i < 8; i++){
    for(int j = 0; j < 8; j++){
      for(int k = 0; k < 8; k++){
        matrix[i][j][k][0] = 0;
        matrix[i][j][k][1] = 0;
        matrix[i][j][k][2] = 0; 
      }
    }
  }  
  RED = 0;
  GREEN = 0;
  BLUE = 0;
}



/////////////////////////////////////////////////////// PRE-PROGRAMMED ANIMATIONS /////////////////////////////////////////////////////////////////////////////////////


//waveform animation
//Stores the matrix display then calls parse_array() to display for each frame of the animation. Also calls reset at being and end of the function
void animation1(){
  reset();
  int [] wave_array = {8, 7, 4, 1, 0, 1, 4, 7}; //array of sin wave values
  for(int r = 0; r < 16; r++){  //cycle through the wave 16 times
    for(int i = 0; i < 8; i++){  //wave starting position 0-7
      for(int j = 0; j < 8; j ++){ //row to store from 0-7
        int h = wave_array[(j+i) % 8];    //indicates the height of the wave 
        for(int a = 0; a < h; a++){      //for every layer under the wave's height
          if(a == 0){   //layer 0 - violet
            RED = 127;
            GREEN = 0;
            BLUE = 255;
          }
          if(a == 1){  //layer 1 - indigo
            RED = 127;
            GREEN = 0;
            BLUE = 127;
          }
          if(a == 2){  //layer 2 - blue
            RED = 0;
            GREEN = 0;
            BLUE = 255;
          }
          if(a == 3){  //layer 3 - green
            RED = 0;
            GREEN = 255;
            BLUE = 0;
          }
          if(a == 4){  //layer 4 - yellow
            RED = 255;
            GREEN = 255;
            BLUE = 0;
          }
          if(a == 5){  //layer 5 - orange
            RED = 255;
            GREEN = 127;
            BLUE = 0;
          }
          if(a == 6){  //layer 6 - red
            RED = 255;
            GREEN = 0;
            BLUE = 0;
          }
          if(a == 7){  //layer 7 - white
            RED = 255;
            GREEN = 255;
            BLUE = 255;
          }  
          for(int k = 0; k < 8; k++){ //load every LED in row i layer a
            matrix[k][i][a][0] = RED;
            matrix[k][i][a][1] = GREEN;
            matrix[k][i][a][2] = BLUE;
          }
        }
      }
      parse_array();
      delay(50); //delay 50ms betweeen frames of the wave
    }
  }
  reset();
}

//growing cube animation stores a frame of the animation in the matrix, calls to parse/display the matrix, waits 50ms, then resets the matrix and repeats for the rest of the animation 
void animation2(){
  for(int r = 0; r < 4; r++){        //repeats for r # of different cubes
      Random rand = new Random();
      RED = rand.nextInt(2) * 255/2;
      GREEN = rand.nextInt(2) * 255/2;
      BLUE = rand.nextInt(2) * 255/2;
      
    //growing cube
    for(int i = 0; i < 8; i++){      //i indicates the size of the cube
      reset();                       //reset the matrix
      for(int j = 0; j < i; j++){    //draw each of the cube's 12 edges with a length of i
        matrix[0][0][j][0] = RED;
        matrix[0][0][j][1] = GREEN;
        matrix[0][0][j][2] = BLUE;
        
        matrix[0][j][0][0] = RED;
        matrix[0][j][0][1] = GREEN;
        matrix[0][j][0][2] = BLUE;
        
        matrix[j][0][0][0] = RED;
        matrix[j][0][0][1] = GREEN;
        matrix[j][0][0][2] = BLUE;
        
        matrix[0][j][i][0] = RED;
        matrix[0][j][i][1] = GREEN;
        matrix[0][j][i][2] = BLUE;
        
        matrix[j][0][i][0] = RED;
        matrix[j][0][i][1] = GREEN;
        matrix[j][0][i][2] = BLUE;
       
        matrix[0][i][j][0] = RED;
        matrix[0][i][j][1] = GREEN;
        matrix[0][i][j][2] = BLUE;
        
        matrix[j][i][0][0] = RED;
        matrix[j][i][0][1] = GREEN;
        matrix[j][i][0][2] = BLUE;
        
        matrix[i][0][j][0] = RED;
        matrix[i][0][j][1] = GREEN;
        matrix[i][0][j][2] = BLUE;
        
        matrix[i][j][0][0] = RED;
        matrix[i][j][0][1] = GREEN;
        matrix[i][j][0][2] = BLUE;
        
        matrix[i][i][j][0] = RED;
        matrix[i][i][j][1] = GREEN;
        matrix[i][i][j][2] = BLUE;
        
        matrix[i][j][i][0] = RED;
        matrix[i][j][i][1] = GREEN;
        matrix[i][j][i][2] = BLUE;
        
        matrix[j][i][i][0] = RED;
        matrix[j][i][i][1] = GREEN;
        matrix[j][i][i][2] = BLUE;
      }
      parse_array();  //display cube
      delay(50);      //delay 50ms
    } 
    
    //shrinking cube
    for(int i = 7; i <= 0; i--){      //i indicates the size of the cube
      reset();                        //reset the matrix
      for(int j = 0; j < i; j++){     //draw each of the cube's 12 edges with a length of i
        matrix[0][0][j][0] = RED;
        matrix[0][0][j][1] = GREEN;
        matrix[0][0][j][2] = BLUE;
        
        matrix[0][j][0][0] = RED;
        matrix[0][j][0][1] = GREEN;
        matrix[0][j][0][2] = BLUE;
        
        matrix[j][0][0][0] = RED;
        matrix[j][0][0][1] = GREEN;
        matrix[j][0][0][2] = BLUE;
        
        matrix[0][j][i][0] = RED;
        matrix[0][j][i][1] = GREEN;
        matrix[0][j][i][2] = BLUE;
        
        matrix[j][0][i][0] = RED;
        matrix[j][0][i][1] = GREEN;
        matrix[j][0][i][2] = BLUE;
       
        matrix[0][i][j][0] = RED;
        matrix[0][i][j][1] = GREEN;
        matrix[0][i][j][2] = BLUE;
        
        matrix[j][i][0][0] = RED;
        matrix[j][i][0][1] = GREEN;
        matrix[j][i][0][2] = BLUE;
        
        matrix[i][0][j][0] = RED;
        matrix[i][0][j][1] = GREEN;
        matrix[i][0][j][2] = BLUE;
        
        matrix[i][j][0][0] = RED;
        matrix[i][j][0][1] = GREEN;
        matrix[i][j][0][2] = BLUE;
        
        matrix[i][i][j][0] = RED;
        matrix[i][i][j][1] = GREEN;
        matrix[i][i][j][2] = BLUE;
        
        matrix[i][j][i][0] = RED;
        matrix[i][j][i][1] = GREEN;
        matrix[i][j][i][2] = BLUE;
        
        matrix[j][i][i][0] = RED;
        matrix[j][i][i][1] = GREEN;
        matrix[j][i][i][2] = BLUE;
      }
      parse_array();  //display cube
      delay(50);      //delay 50ms
    } 
  }
  reset();
}

//this rain animation generates a random location for a raindrop that then falls and changes color till it hits the bottom of the cube. Calls to parse_array to display a frame of the animation
//and calls reset() to clear the matrix
void animation3(){
  for(int i = 0; i < 50; i++){        //repeats for 50 cycles
    reset();       //reset the matrix
    Random rand = new Random();
    int raining = rand.nextInt(3);
    if(raining == 0){
      int row = rand.nextInt(7);    
      int col = rand.nextInt(7);
      for(int a = 7; a >= 0; a--){
        if(a == 0){   //layer 0 - violet
          RED = 127;
          GREEN = 0;
          BLUE = 255;
        }
        if(a == 1){  //layer 1 - indigo
          RED = 127;
          GREEN = 0;
          BLUE = 127;
        }
        if(a == 2){  //layer 2 - blue
          RED = 0;
          GREEN = 0;
          BLUE = 255;
        }
        if(a == 3){  //layer 3 - green
          RED = 0;
          GREEN = 255;
          BLUE = 0;
        }
        if(a == 4){  //layer 4 - yellow
          RED = 255;
          GREEN = 255;
          BLUE = 0;
        }
        if(a == 5){  //layer 5 - orange
          RED = 255;
          GREEN = 127;
          BLUE = 0;
        }
        if(a == 6){  //layer 6 - red
          RED = 255;
          GREEN = 0;
          BLUE = 0;
        }
        if(a == 7){  //layer 7 - white
          RED = 255;
          GREEN = 255;
          BLUE = 255;
        }  
        matrix[col][row][a][0] = RED;
        matrix[col][row][a][1] = GREEN;
        matrix[col][row][a][2] = BLUE;
        
        parse_array();  //display this frame
        delay(50);     //delay 50ms
      }
    }
  }
  reset();
}

///////////// PRE-PROGRAMMED ALPHA-NUMERIC DISPLAYS //////////////////////////////////

//For each of these alpha-numeric display functions the corresponding matrix values for that character are written
//with the current RGB values determined by the GUI. After storing the character's matrix values parse_array() is called.



void letterA(){
  for (int i=0; i < 8; i++){ 
    if (i == 0){
      for (int j = 0; j < 8; j++){ //top row not lit up
        matrix[j][i][0][0] = 0;
        matrix[j][i][0][1] = 0;
        matrix[j][i][0][2] = 0;
      }
    }
  
    if (i == 1){ //next row makes the top of the A
      for (int j = 2; j < 6; j++){
        matrix[j][i][0][0] = RED;
        matrix[j][i][0][1] = GREEN;
        matrix[j][i][0][2] = BLUE;
      }
    }
    
    if (i == 2){ 
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
    
    if (i == 3){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
  
    if (i == 4){
      for (int j = 1; j < 6; j++){
        matrix[j][i][0][0] = RED;
        matrix[j][i][0][1] = GREEN;
        matrix[j][i][0][2] = BLUE;
      }
    }
    
    if (i == 5){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
    
    if (i == 6){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
 
    if (i == 7){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE; //bottom of A
    }
  }
    parse_array(); //send it to the board
}
  //0b00000000,
  //0b00111100,
  //0b01100110,
  //0b01100110,
  //0b01111110,
  //0b01100110,
  //0b01100110,
  //0b01100110,



void letterB(){
  for (int i=0; i < 8; i++){
   if (i == 0){
      for (int j = 0; j < 8; j++){
       matrix[j][i][0][0] = 0;
       matrix[j][i][0][1] = 0;
       matrix[j][i][0][2] = 0;
      }
   }
   
   if (i == 1){
    for (int j = 1; j < 5; j++){
        matrix[j][i][0][0] = RED;
        matrix[j][i][0][1] = GREEN;
        matrix[j][i][0][2] = BLUE;
      }
    }
    
    if (i == 2){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
  
    if (i == 3){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
    
    if (i == 4){
      for (int j = 1; j < 6; j++){
       matrix[j][i][0][0] = RED;
       matrix[j][i][0][1] = GREEN;
       matrix[j][i][0][2] = BLUE;
      }
    }
   
    if (i == 5){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
  
    if (i == 6){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
    
    if (i == 7){
     for (int j = 1; j < 5; j++){
       matrix[j][i][0][0] = RED;
       matrix[j][i][0][1] = GREEN;
       matrix[j][i][0][2] = BLUE;
     } 
    }
    
  }
  parse_array();
}

//capital B
 /* 
  0b00000000,
  0b01111100,
  0b01100110,
  0b01100110,
  0b01111100,
  0b01100110,
  0b01100110,
  0b01111100
  */

void letterC(){
  for (int i=0; i < 8; i++){
     if (i == 0){
      for (int j = 0; j < 8; j++){
        matrix[j][i][0][0] = 0;
        matrix[j][i][0][1] = 0;
        matrix[j][i][0][2] = 0;
      }
     }
     
     if (i == 1){
        for (int j = 2; j < 6; j++){
        matrix[j][i][0][0] = RED;
        matrix[j][i][0][1] = GREEN;
        matrix[j][i][0][2] = BLUE;
        }
     }
    
    if (i == 2){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
    
    if (i == 3){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    }
    
    if (i == 4){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    }
 
    if (i == 5){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    }
  
    if (i == 6){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
    
    if (i == 7){
       for (int j = 2; j < 6; j++){
           matrix[j][i][0][0] = RED;
           matrix[j][i][0][1] = GREEN;
           matrix[j][i][0][2] = BLUE;
       } 
    }
 }
  parse_array();
} 

/*
  B00000000,
  B00111100,
  B01100110,
  B01100000,
  B01100000,
  B01100000,
  B01100110,
  B00111100
*/

void letterD(){
  for (int i=0; i < 8; i++){
     if (i == 0){
        for (int j = 0; j < 8; j++){
           matrix[j][i][0][0] = 0;
           matrix[j][i][0][1] = 0;
           matrix[j][i][0][2] = 0;
        }
     }
     if (i == 1){
        for (int j = 2; j < 5; j++){
           matrix[j][i][0][0] = RED;
           matrix[j][i][0][1] = GREEN;
           matrix[j][i][0][2] = BLUE;
        }
     }
    
    if (i == 2){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
    
    if (i == 3){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
  
    if (i == 4){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
 
    if (i == 5){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
  
    if (i == 6){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
  
    if (i == 7){
       for (int j = 1; j < 5; j++){
           matrix[j][i][0][0] = RED;
           matrix[j][i][0][1] = GREEN;
           matrix[j][i][0][2] = BLUE;
      } 
    }
  }
  parse_array();
} 
/*LETTER D
  B00000000,
  B01111100,
  B01100110,
  B01100110,
  B01100110,
  B01100110,
  B01100110,
  B01111100
*/


void letterE(){
  for (int i=0; i < 8; i++){
     if (i == 0){
        for (int j = 0; j < 8; j++){
           matrix[j][i][0][0] = 0;
           matrix[j][i][0][1] = 0;
           matrix[j][i][0][2] = 0;
        }
     }
   
    if (i == 1){
      for (int j = 1; j < 7; j++){
           matrix[j][i][0][0] = RED;
           matrix[j][i][0][1] = GREEN;
           matrix[j][i][0][2] = BLUE;
      }
    }
    
    if (i == 2){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    }
  
    if (i == 3){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    }
   
    if (i == 4){
       for (int j = 1; j < 5; j++){
           matrix[j][i][0][0] = RED;
           matrix[j][i][0][1] = GREEN;
           matrix[j][i][0][2] = BLUE;
        }
    }
  
    if (i == 5){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    }
  
    if (i == 6){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    }
  
    if (i == 7){
       for (int j = 1; j < 7; j++){
           matrix[j][i][0][0] = RED;
           matrix[j][i][0][1] = GREEN;
           matrix[j][i][0][2] = BLUE;
       } 
    }
  }
  parse_array();
}
/* LETTER E
  B00000000,
  B01111110,
  B01100000,
  B01100000,
  B01111100,
  B01100000,
  B01100000,
  B01111110
*/


void letterF(){
  for (int i=0; i < 8; i++){
     if (i == 0){
        for (int j = 0; j < 8; j++){
        matrix[j][i][0][0] = 0;
        matrix[j][i][0][1] = 0;
        matrix[j][i][0][2] = 0;
        }
      }
      
      if (i == 1){
        for (int j = 1; j < 7; j++){
          matrix[j][i][0][0] = RED;
          matrix[j][i][0][1] = GREEN;
          matrix[j][i][0][2] = BLUE;
        }
      }
      
     if (i == 2){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
      }
      
      if (i == 3){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
      }
      
      if (i == 4){
         for (int j = 1; j < 5; j++){
              matrix[j][i][0][0] = RED;
              matrix[j][i][0][1] = GREEN;
              matrix[j][i][0][2] = BLUE;
         }
      }
      
      if (i == 5){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
      }
      
      if (i == 6){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
      }
      
      if (i == 7){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
      } 
  }
  parse_array();
} 
/* LETTER F
  B00000000,
  B01111110,
  B01100000,
  B01100000,
  B01111100,
  B01100000,
  B01100000,
  B01100000
*/


void letterG(){
  for (int i=0; i < 8; i++){
     if (i == 0){
        for (int j = 0; j < 8; j++){
          matrix[j][i][0][0] = 0;
          matrix[j][i][0][1] = 0;
          matrix[j][i][0][2] = 0;
        }
     }
   
    if (i == 1){
        for (int j = 2; j < 6; j++){
          matrix[j][i][0][0] = RED;
          matrix[j][i][0][1] = GREEN;
          matrix[j][i][0][2] = BLUE;
        }
    }
 
    if (i == 2){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
 
    if (i == 3){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    }
    
    if (i == 4){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
     }
  
    if (i == 5){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
    
    if (i == 6){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
  
    if (i == 7){
      for (int j = 2; j < 6; j++){
           matrix[j][i][0][0] = RED;
           matrix[j][i][0][1] = GREEN;
           matrix[j][i][0][2] = BLUE;
      } 
    }
  }
  parse_array();
} 
/* LETTER G
  B00000000,
  B00111100,
  B01100110,
  B01100000,
  B01100000,
  B01101110,
  B01100110,
  B00111100
*/


void letterH(){
  for (int i=0; i < 8; i++){ //top row not lit up
      if (i == 0){
        for (int j = 0; j < 8; j++){
           matrix[j][i][0][0] = 0;
           matrix[j][i][0][1] = 0;
           matrix[j][i][0][2] = 0;
        }
      }
  
    if (i == 1){ //next row makes the top of the H
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
 
    if (i == 2){ 
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
  
    if (i == 3){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
  
    if (i == 4){
      for (int j = 1; j < 7; j++){
           matrix[j][i][0][0] = RED;
           matrix[j][i][0][1] = GREEN;
           matrix[j][i][0][2] = BLUE;
    
      }
    }
    
    if (i == 5){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
  
    if (i == 6){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
    
    if (i == 7){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE; //bottom 
    }
 }
  parse_array(); //send it to the board
}
/* LETTER H
  B00000000,
  B01100110,
  B01100110,
  B01100110,
  B01111110,
  B01100110,
  B01100110,
  B01100110
*/


void letterI(){
  for (int i=0; i < 8; i++){ //top row not lit up
    if (i == 0){
      for (int j = 0; j < 8; j++){
           matrix[j][i][0][0] = 0;
           matrix[j][i][0][1] = 0;
           matrix[j][i][0][2] = 0;
      }
    }
  
    if (i == 1){ //next row makes the top of letter
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
      
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
        
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
    }
  
    if (i == 2){ 
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
        
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
    }
  
    if (i == 3){
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
        
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
    }
  
    if (i == 4){
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
        
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
    }
    
    if (i == 5){
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
        
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
    }
  
    if (i == 6){
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
        
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
    }
  
    if (i == 7){
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
      
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
        
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE; //bottom
    }
  }
  parse_array(); //send it to the board
}  
/* LETTER I
  B00000000,
  B00111100,
  B00011000,
  B00011000,
  B00011000,
  B00011000,
  B00011000,
  B00111100
*/


void letterJ(){
  for (int i=0; i < 8; i++){ //top row not lit up
      if (i == 0){
        for (int j = 0; j < 8; j++){
           matrix[j][i][0][0] = 0;
           matrix[j][i][0][1] = 0;
           matrix[j][i][0][2] = 0;
        }
      }
  
      if (i == 1){ //next row makes the top of letter
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
        
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
      }
 
      if (i == 2){ 
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
      }
     
      if (i == 3){
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
      }
  
      if (i == 4){
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
       }

      if (i == 5){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
        
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
      }
  
      if (i == 6){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
        
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
      }
  
      if (i == 7){
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
        
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;//bottom
      }
  }
  parse_array(); //send it to the board
} 
/* LETTER J
  B00000000,
  B00011110,
  B00001100,
  B00001100,
  B00001100,
  B01101100,
  B01101100,
  B00111000
*/


void letterK(){
    for (int i=0; i < 8; i++){ //top row not lit up
        if (i == 0){
          for (int j = 0; j < 8; j++){
               matrix[j][i][0][0] = 0;
               matrix[j][i][0][1] = 0;
               matrix[j][i][0][2] = 0;
          }
        }
    
      if (i == 1){ //next row makes the top of letter
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
      }
     
      if (i == 2){ //1245
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
      }
 
      if (i == 3){//1234
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
        
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
      }
  
      if (i == 4){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
      }

      if (i == 5){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
        
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
      }
  
      if (i == 6){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
      }
  
      if (i == 7){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;//bottom
      }
 }
  parse_array(); //send it to the board
} 
/* LETTER K
  B00000000,
  B01100110,
  B01101100,
  B01111000,
  B01110000,
  B01111000,
  B01101100,
  B01100110
*/

void letterL(){
    for (int i=0; i < 8; i++){ 
      if (i == 0){
        for (int j = 0; j < 8; j++){ //top row not lit up
               matrix[j][i][0][0] = 0;
               matrix[j][i][0][1] = 0;
               matrix[j][i][0][2] = 0;
        }
      }
      if (i == 1){ //next row makes the top of letter
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
      }
    
      if (i == 2){ 
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
       }
  
       if (i == 3){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
      }
 
      if (i == 4){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
      }

      if (i == 5){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
       }
     
      if (i == 6){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
      }
 
      if (i == 7){
            for (int j = 1; j < 7; j++){
               matrix[j][i][0][0] = RED;
               matrix[j][i][0][1] = GREEN;
               matrix[j][i][0][2] = BLUE; //bottom
            }
      }
   }
  parse_array(); //send it to the board
}  
/* LETTER L
  B00000000,
  B01100000,
  B01100000,
  B01100000,
  B01100000,
  B01100000,
  B01100000,
  B01111110
*/


void letterM(){
  for (int i=0; i < 8; i++){ //top row not lit up
  if (i == 0){
    for (int j = 0; j < 8; j++){
         matrix[j][i][0][0] = 0;
         matrix[j][i][0][1] = 0;
         matrix[j][i][0][2] = 0;
    }
  }
  if (i == 1){ //next row makes the top 1267
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
        
        matrix[7][i][0][0] = RED;
        matrix[7][i][0][1] = GREEN;
        matrix[7][i][0][2] = BLUE;
  }
  if (i == 2){ //123567
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
    
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
        
        matrix[7][i][0][0] = RED;
        matrix[7][i][0][1] = GREEN;
        matrix[7][i][0][2] = BLUE;
  }
  if (i == 3){
       for (int j = 0; j < 7; j++){
         matrix[j][i][0][0] = RED;
         matrix[j][i][0][1] = GREEN;
         matrix[j][i][0][2] = BLUE;
    }
  }
  if (i == 4){//12467
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
    
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
        
        matrix[7][i][0][0] = RED;
        matrix[7][i][0][1] = GREEN;
        matrix[7][i][0][2] = BLUE;
  }
  if (i == 5){//1267
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
        
        matrix[7][i][0][0] = RED;
        matrix[7][i][0][1] = GREEN;
        matrix[7][i][0][2] = BLUE;
  }
  if (i == 6){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
        
        matrix[7][i][0][0] = RED;
        matrix[7][i][0][1] = GREEN;
        matrix[7][i][0][2] = BLUE;
  }
  if (i == 7){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
        
        matrix[7][i][0][0] = RED;
        matrix[7][i][0][1] = GREEN;
        matrix[7][i][0][2] = BLUE; //bottom
    }
 }
  parse_array(); //send it to the board
}
/* LETTER M
  B00000000,
  B01100011,
  B01110111,
  B01111111,
  B01101011,
  B01100011,
  B01100011,
  B01100011
*/



void letterN(){
  for (int i=0; i < 8; i++){ //top row not lit up
  if (i == 0){
    for (int j = 0; j < 8; j++){
         matrix[j][i][0][0] = 0;
         matrix[j][i][0][1] = 0;
         matrix[j][i][0][2] = 0;
    }
  }
  if (i == 1){ //next row makes the top
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
        
        matrix[7][i][0][0] = RED;
        matrix[7][i][0][1] = GREEN;
        matrix[7][i][0][2] = BLUE;
  }
  if (i == 2){ //12367
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
    
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
        
        matrix[7][i][0][0] = RED;
        matrix[7][i][0][1] = GREEN;
        matrix[7][i][0][2] = BLUE;
  }
  if (i == 3){//123467
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
    
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
    
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
        
        matrix[7][i][0][0] = RED;
        matrix[7][i][0][1] = GREEN;
        matrix[7][i][0][2] = BLUE;
  
  }
  
  if (i == 4){//124567
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
    
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
        
        matrix[7][i][0][0] = RED;
        matrix[7][i][0][1] = GREEN;
        matrix[7][i][0][2] = BLUE;
  }
  if (i == 5){//12567
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
    
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
        
        matrix[7][i][0][0] = RED;
        matrix[7][i][0][1] = GREEN;
        matrix[7][i][0][2] = BLUE;
  }
  if (i == 6){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
        
        matrix[7][i][0][0] = RED;
        matrix[7][i][0][1] = GREEN;
        matrix[7][i][0][2] = BLUE;
  }
  if (i == 7){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
        
        matrix[7][i][0][0] = RED;
        matrix[7][i][0][1] = GREEN;
        matrix[7][i][0][2] = BLUE; //bottom
    }
 }
  parse_array(); //send it to the board
}
/* LETTER N
  B00000000,
  B01100011,
  B01110011,
  B01111011,
  B01101111,
  B01100111,
  B01100011,
  B01100011
*/


void letterO(){
 for (int i=0; i < 8; i++){ //top row not lit up
    if (i == 0){
      for (int j = 0; j < 8; j++){
          matrix[i][j][0][0] = 0;
          matrix[i][j][0][1] = 0;
          matrix[i][j][0][2] = 0;
      }
    }
    if (i == 1){ //next row makes the top //2345
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
      
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
    
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
    }
    if (i == 2){ 
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
    if (i == 3){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
    if (i == 4){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
    if (i == 5){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
    if (i == 6){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
    if (i == 7){
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
      
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
    
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE; //bottom
    }
  }
  parse_array(); //send it to the board
}
/* LETTER O
  B00000000,
  B00111100,
  B01100110,
  B01100110,
  B01100110,
  B01100110,
  B01100110,
  B00111100
*/


void letterP(){
  for (int i=0; i < 8; i++){ //top row not lit up
  if (i == 0){
    for (int j = 0; j < 8; j++){
          matrix[i][j][0][0] = 0;
          matrix[i][j][0][1] = 0;
          matrix[i][j][0][2] = 0;
    }
  }
  if (i == 1){ //next row makes the top 12345
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
        
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
  }
  if (i == 2){ //1256
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
  }
  if (i == 3){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
   }
 
  if (i == 4){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
  }
  if (i == 5){ //12345
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
      
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;

        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
  }
  if (i == 6){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
  }
  if (i == 7){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;//bottom
  }
 }
  parse_array(); //send it to the board
}
/* LETTER P
  B00000000,
  B01111100,
  B01100110,
  B01100110,
  B01100110,
  B01111100,
  B01100000,
  B01100000
*/


void letterQ(){
  for (int i=0; i < 8; i++){ //top row not lit up
      if (i == 0){
        for (int j = 0; j < 8; j++){
          matrix[j][i][0][0] = 0;
          matrix[j][i][0][1] = 0;
          matrix[j][i][0][2] = 0;
        }
      }
  
      if (i == 1){ //next row makes the top
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
      
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;

        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
      }
 
      if (i == 2){ 
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
      }
 
      if (i == 3){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
      }
 
      if (i == 4){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
      }
 
      if (i == 5){//12456
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
      }
 
      if (i == 6){ //2345
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
      
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
    
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
      }
 
      if (i == 7){        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE; //bottom
      }
    }
  parse_array(); //send it to the board
  }
/* LETTER Q
  B00000000,
  B00111100,
  B01100110,
  B01100110,
  B01100110,
  B01101110,
  B00111100,
  B00000110
*/


void letterR(){
  for (int i=0; i < 8; i++){ //top row not lit up
  if (i == 0){
    for (int j = 0; j < 8; j++){
          matrix[j][i][0][0] = 0;
          matrix[j][i][0][1] = 0;
          matrix[j][i][0][2] = 0;
    }
  }
  if (i == 1){ //next row makes the top of letter
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
        
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
  }
  
  if (i == 2){ 
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
  }
  if (i == 3){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
  }
  if (i == 4){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
        
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
  
  }
  
  if (i == 5){ //1234
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
        
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
  }
  if (i == 6){ //1245
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;

  }
  if (i == 7){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;//bottom
  }
  }
  parse_array(); //send it to the board
  } 
/* LETTER R
  B00000000,
 1 B01111100,
 2 B01100110,
 3 B01100110,
 4 B01111100,
 5 B01111000,
 6 B01101100,
 7 B01100110
*/


void letterS(){
  for (int i=0; i < 8; i++){ //top row not lit up
  if (i == 0){
    for (int j = 0; j < 8; j++){
          matrix[j][i][0][0] = 0;
          matrix[j][i][0][1] = 0;
          matrix[j][i][0][2] = 0;
    }
  }
  if (i == 1){ //next row makes the top of letter 2345
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
      
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
    
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
  }
  if (i == 2){ 
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
  }
  if (i == 3){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
  }
  if (i == 4){
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
      
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
    
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
    }
 
  if (i == 5){
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
  }
  if (i == 6){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
  }
  if (i == 7){
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
      
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
    
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;//bottom
    }
  }
  parse_array(); //send it to the board
} 
/* LETTER S
  B00000000,
  B00111100,
  B01100110,
  B01100000,
  B00111100,
  B00000110,
  B01100110,
  B00111100
*/


void letterT(){
  for (int i=0; i < 8; i++){ //top row not lit up
  if (i == 0){
    for (int j = 0; j < 8; j++){
          matrix[j][i][0][0] = 0;
          matrix[j][i][0][1] = 0;
          matrix[j][i][0][2] = 0;
    }
  }
  if (i == 1){ //next row makes the top of letter
for (int j = 1; j < 7; j++){
          matrix[j][i][0][0] = RED;
          matrix[j][i][0][1] = GREEN;
          matrix[j][i][0][2] = BLUE;
    }
  }
  if (i == 2){ 
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
    
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
    
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
  }
  
  if (i == 3){
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
    
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
  }
  if (i == 4){
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
    
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
    }
  
  if (i == 5){
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
    
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
  }
  if (i == 6){
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
    
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
  }
  if (i == 7){
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
    
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;//bottom
  }
  }
  parse_array(); //send it to the board
 }  
/* LETTER T
  B00000000,
  B01111110,
  B01011010,
  B00011000,
  B00011000,
  B00011000,
  B00011000,
  B00011000
*/


void letterU(){
  for (int i=0; i < 8; i++){ //top row not lit up
  if (i == 0){
    for (int j = 0; j < 8; j++){
          matrix[j][i][0][0] = 0;
          matrix[j][i][0][1] = 0;
          matrix[j][i][0][2] = 0;
    }
  }
  if (i == 1){ //next row makes the top
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
  }
  if (i == 2){ 
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
  }
  if (i == 3){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
  }
  if (i == 4){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
  }
  if (i == 5){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
  }
  if (i == 6){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
  }
  if (i == 7){
   for (int j = 2; j < 7; j++){
          matrix[j][i][0][0] = RED;
          matrix[j][i][0][1] = GREEN;
          matrix[j][i][0][2] = BLUE;
    } //bottom
  }
 }
  parse_array(); //send it to the board
}
/* LETTER U
  B00000000,
  B01100110,
  B01100110,
  B01100110,
  B01100110,
  B01100110,
  B01100110,
  B00111110
*/


void letterV(){
  for (int i=0; i < 8; i++){ //top row not lit up
  if (i == 0){
    for (int j = 0; j < 8; j++){
          matrix[j][i][0][0] = 0;
          matrix[j][i][0][1] = 0;
          matrix[j][i][0][2] = 0;
    }
  }
  if (i == 1){ //next row makes the top
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
  }
  if (i == 2){ 
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
  }
  if (i == 3){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
  }
  if (i == 4){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
  }
  if (i == 5){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
  }
  if (i == 6){
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
    
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
       
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
  }
  if (i == 7){
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
    
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
  }
 } 
  parse_array(); //send it to the board
  }
/* LETTER V
  B00000000,
  B01100110,
  B01100110,
  B01100110,
  B01100110,
  B01100110,
  B00111100,
  B00011000
*/


void letterW(){
  for (int i=0; i < 8; i++){ 
    if (i == 0){
      for (int j = 0; j < 8; j++){//top row not lit up
          matrix[j][i][0][0] = 0;
          matrix[j][i][0][1] = 0;
          matrix[j][i][0][2] = 0;
      }
    }
    if (i == 1){ //next row makes the top 1267
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
        
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
       
        matrix[7][i][0][0] = RED;
        matrix[7][i][0][1] = GREEN;
        matrix[7][i][0][2] = BLUE;
    }
    if (i == 2){ 
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
        
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
       
        matrix[7][i][0][0] = RED;
        matrix[7][i][0][1] = GREEN;
        matrix[7][i][0][2] = BLUE;
    }
    if (i == 3){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
        
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
       
        matrix[7][i][0][0] = RED;
        matrix[7][i][0][1] = GREEN;
        matrix[7][i][0][2] = BLUE;
    }
    if (i == 4){//12456
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
        
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
               
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
    
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
    if (i == 5){
      for (int j = 0; j < 8; j++){
          matrix[j][i][0][0] = RED;
          matrix[j][i][0][1] = GREEN;
          matrix[j][i][0][2] = BLUE;
      }
    }
    if (i == 6){ //123567
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
        
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
       
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
    
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
       
        matrix[7][i][0][0] = RED;
        matrix[7][i][0][1] = GREEN;
        matrix[7][i][0][2] = BLUE;
    }
    if (i == 7){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
        
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
       
        matrix[7][i][0][0] = RED;
        matrix[7][i][0][1] = GREEN;
        matrix[7][i][0][2] = BLUE;
    }
 }
  parse_array(); //send it to the board
}
/* LETTER W
  B00000000,
  B01100011,
  B01100011,
  B01100011,
  B01101011,
  B01111111,
  B01110111,
  B01100011
*/


void letterX(){
  for (int i=0; i < 8; i++){ 
    if (i == 0){
      for (int j = 0; j < 8; j++){//top row not lit up
          matrix[j][i][0][0] = 0;
          matrix[j][i][0][1] = 0;
          matrix[j][i][0][2] = 0;
      }
    }
    if (i == 1){ //next row makes the top
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
        
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
       
        matrix[7][i][0][0] = RED;
        matrix[7][i][0][1] = GREEN;
        matrix[7][i][0][2] = BLUE;
    }
    if (i == 2){ 
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
        
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
       
        matrix[7][i][0][0] = RED;
        matrix[7][i][0][1] = GREEN;
        matrix[7][i][0][2] = BLUE;
    }
    if (i == 3){ //2356
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
       
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
    if (i == 4){
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
    
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
       
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
    }
    if (i == 5){
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
       
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
    if (i == 6){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
        
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
       
        matrix[7][i][0][0] = RED;
        matrix[7][i][0][1] = GREEN;
        matrix[7][i][0][2] = BLUE;
    }
    if (i == 7){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
        
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
       
        matrix[7][i][0][0] = RED;
        matrix[7][i][0][1] = GREEN;
        matrix[7][i][0][2] = BLUE;
    }
 }
  parse_array(); //send it to the board
}
/* LETTER X
  B00000000,
  B01100011,
  B01100011,
  B00110110,
  B00011100,
  B00110110,
  B01100011,
  B01100011
*/


void letterY(){
  for (int i=0; i < 8; i++){ 
    if (i == 0){
      for (int j = 0; j < 8; j++){//top row not lit up
         matrix[j][i][0][0] = 0;
         matrix[j][i][0][1] = 0;
         matrix[j][i][0][2] = 0;
      }

    }
    if (i == 1){ //next row makes the top
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
    if (i == 2){ 
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
    if (i == 3){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
    if (i == 4){ //2345
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
      
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
    
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
    }
    if (i == 5){
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
    
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
    }
    if (i == 6){
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
    
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
    }
    if (i == 7){
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
    
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
    }
 }
  parse_array(); //send it to the board
}
/* LETTER Y
  B00000000,
  B01100110,
  B01100110,
  B01100110,
  B00111100,
  B00011000,
  B00011000,
  B00011000
*/


void letterZ(){
  for (int i=0; i < 8; i++){ 
    if (i == 0){
      for (int j = 0; j < 8; j++){//top row not lit up
         matrix[j][i][0][0] = 0;
         matrix[j][i][0][1] = 0;
         matrix[j][i][0][2] = 0;
      }
    }
    if (i == 1){ //next row makes the top
     for (int j = 1; j < 8; j++){
          matrix[j][i][0][0] = RED;
          matrix[j][i][0][1] = GREEN;
          matrix[j][i][0][2] = BLUE;
      }
    }
    if (i == 2){ 
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
          
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
    if (i == 3){
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
          
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
    }
    if (i == 4){  
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
          
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
    }
    if (i == 5){
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
          
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
    }
    if (i == 6){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
          
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    }
    if (i == 7){
      for (int j = 1; j < 7; j++){
          matrix[j][i][0][0] = RED;
          matrix[j][i][0][1] = GREEN;
          matrix[j][i][0][2] = BLUE;
      }
    }
 }
  parse_array(); //send it to the board
}
/* LETTER Z
  B00000000,
  B01111110,
  B00000110,
  B00001100,
  B00011000,
  B00110000,
  B01100000,
  B01111110
*/


void num0(){
 for (int i=0; i < 8; i++){ //top row not lit up
    if (i == 0){
      for (int j = 0; j < 8; j++){
          matrix[j][i][0][0] = 0;
          matrix[j][i][0][1] = 0;
          matrix[j][i][0][2] = 0;
      }
    }
    if (i == 1){ //next row makes the top
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
      
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
    
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
    }
    if (i == 2){ 
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
    if (i == 3){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
    if (i == 4){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
    if (i == 5){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
    if (i == 6){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
    if (i == 7){
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
      
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
    
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE; //bottom
    }
  }
  parse_array(); //send it to the board
}
/* NUM 0
  B00000000,
  B00111100,
  B01100110,
  B01101110,
  B01110110,
  B01100110,
  B01100110,
  B00111100
*/


void num1(){
 for (int i=0; i < 8; i++){ //top row not lit up
    if (i == 0){
      for (int j = 0; j < 8; j++){
          matrix[j][i][0][0] = 0;
          matrix[j][i][0][1] = 0;
          matrix[j][i][0][2] = 0;
      }
    }
    if (i == 1){ //next row makes the top
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
    
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
    }
    if (i == 2){ 
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
    
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
    }
    if (i == 3){
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
      
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
    
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
    }
    if (i == 4){
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
    
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
    }
    if (i == 5){
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
    
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
    }
    if (i == 6){
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
    
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
    }
    if (i == 7){
      for (int j = 1; j < 7; j++){
          matrix[j][i][0][0] = RED;
          matrix[j][i][0][1] = GREEN;
          matrix[j][i][0][2] = BLUE;
      }
    }
  }
  parse_array(); //send it to the board
}
/* NUM 1
  B00000000,
  B00011000,
  B00011000,
  B00111000,
  B00011000,
  B00011000,
  B00011000,
  B01111110
*/


void num2(){
 for (int i=0; i < 8; i++){ //top row not lit up
    if (i == 0){
      for (int j = 0; j < 8; j++){
          matrix[j][i][0][0] = 0;
          matrix[j][i][0][1] = 0;
          matrix[j][i][0][2] = 0;
      }
    }
    if (i == 1){ //next row makes the top
      for (int j = 2; j < 5; j++){
          matrix[j][i][0][0] = RED;
          matrix[j][i][0][1] = GREEN;
          matrix[j][i][0][2] = BLUE;
      }
        
    }
    if (i == 2){ //1256
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
    
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
    
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
    if (i == 3){//56
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
    
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
    }
    if (i == 4){
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
    
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
    }
    if (i == 5){
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
        
    }
    if (i == 6){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
    
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
    }
    if (i == 7){
      for (int j = 1; j < 7; j++){
          matrix[j][i][0][0] = RED;
          matrix[j][i][0][1] = GREEN;
          matrix[j][i][0][2] = BLUE;
      }
    }
  }
  parse_array(); //send it to the board
}
/* NUM 2
  B00000000,
  B00111100,
  B01100110,
  B00000110,
  B00001100,
  B00110000,
  B01100000,
  B01111110
*/


void num3(){
 for (int i=0; i < 8; i++){ //top row not lit up
    if (i == 0){
      for (int j = 0; j < 8; j++){
          matrix[j][i][0][0] = 0;
          matrix[j][i][0][1] = 0;
          matrix[j][i][0][2] = 0;
      }
    }
    if (i == 1){ //next row makes the top
       for (int j = 2; j < 5; j++){
        matrix[j][i][0][0] = RED;
        matrix[j][i][0][1] = GREEN;
        matrix[j][i][0][2] = BLUE;
      }
        
    }
    if (i == 2){ 
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
    
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
    
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
        
    }
    if (i == 3){
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
    
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
        
    }
    if (i == 4){
      for (int j = 3; j < 5; j++){
        matrix[j][i][0][0] = RED;
        matrix[j][i][0][1] = GREEN;
        matrix[j][i][0][2] = BLUE;
      }
        
    }
    if (i == 5){
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
    
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
        
    }
    if (i == 6){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE;
    
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
    
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
        
    }
    if (i == 7){
      for (int j = 2; j < 5; j++){
          matrix[j][i][0][0] = RED;
          matrix[j][i][0][1] = GREEN;
          matrix[j][i][0][2] = BLUE;
      }
    }
  }
  parse_array(); //send it to the board
}
/* NUM 3
  B00000000,
  B00111100,
  B01100110,
  B00000110,
  B00011100,
  B00000110,
  B01100110,
  B00111100
*/


void num4(){
 for (int i=0; i < 8; i++){ //top row not lit up
    if (i == 0){
      for (int j = 0; j < 8; j++){
          matrix[j][i][0][0] = 0;
          matrix[j][i][0][1] = 0;
          matrix[j][i][0][2] = 0;
      }
    }
    if (i == 1){ //next row makes the top
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
    }
    if (i == 2){ 
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE; 
      
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
    }
    if (i == 3){
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE; 
      
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
    }
    if (i == 4){     
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE; 
      
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
    }
    if (i == 5){
       for (int j = 1; j < 7; j++){
          matrix[j][i][0][0] = RED;
          matrix[j][i][0][1] = GREEN;
          matrix[j][i][0][2] = BLUE;
       }
    }
    if (i == 6){
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
    }
    if (i == 7){        //45
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
    }
  }
  parse_array(); //send it to the board
}
/* NUM 4
  B00000000,
  B00001100,
  B00011100,
  B00101100,
  B01001100,
  B01111110,
  B00001100,
  B00001100
*/


void num5(){
 for (int i=0; i < 8; i++){ //top row not lit up
    if (i == 0){
      for (int j = 0; j < 8; j++){
          matrix[j][i][0][0] = 0;
          matrix[j][i][0][1] = 0;
          matrix[j][i][0][2] = 0;
      }
    }
    if (i == 1){ //next row makes the top
      for (int j = 1; j < 7; j++){
          matrix[j][i][0][0] = RED;
          matrix[j][i][0][1] = GREEN;
          matrix[j][i][0][2] = BLUE;
      }
    }
    if (i == 2){ 
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE; 
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
    }
    if (i == 3){
       for (int j = 1; j < 6; j++){
          matrix[j][i][0][0] = RED;
          matrix[j][i][0][1] = GREEN;
          matrix[j][i][0][2] = BLUE;
      }
        
    }
    if (i == 4){      
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE; 
      
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;     
    }
    if (i == 5){
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE; 
      
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE; 
        
    }
    if (i == 6){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE; 
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE; 
      
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE; 
        
    }
    if (i == 7){ //2345
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE; 
      
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
        
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE; 
      
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
    }
  }
  parse_array(); //send it to the board
}
/* NUM 5
  B00000000,
  B01111110,
  B01100000,
  B01111100,
  B00000110,
  B00000110,
  B01100110,
  B00111100
*/


void num6(){
 for (int i=0; i < 8; i++){ //top row not lit up
    if (i == 0){
      for (int j = 0; j < 8; j++){
          matrix[j][i][0][0] = 0;
          matrix[j][i][0][1] = 0;
          matrix[j][i][0][2] = 0;
      }
    }
    if (i == 1){ //next row makes the top
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE; 
      
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
        
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE; 
      
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;

    }
    if (i == 2){ 
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE; 
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE; 
      
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
    if (i == 3){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE; 
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
    }
    if (i == 4){ //12345
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE; 
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE; 
      
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
    }
    if (i == 5){
      
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE; 
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE; 
      
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
        
    }
    if (i == 6){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE; 
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE; 
      
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
        
    }
    if (i == 7){
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE; 
      
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
    }
  }
  parse_array(); //send it to the board
}
/* NUM 6
  B00000000,
  B00111100,
  B01100110,
  B01100000,
  B01111100,
  B01100110,
  B01100110,
  B00111100
*/


void num7(){
 for (int i=0; i < 8; i++){ //top row not lit up
    if (i == 0){
      for (int j = 0; j < 8; j++){
          matrix[j][i][0][0] = 0;
          matrix[j][i][0][1] = 0;
          matrix[j][i][0][2] = 0;
      }
    }
    if (i == 1){ //next row makes the top
      for (int j = 1; j < 7; j++){
        matrix[i][j][0][0] = RED; //bottom
        matrix[i][j][0][1] = GREEN;
        matrix[i][j][0][2] = BLUE;
      }
        
    }
    if (i == 2){ 
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE; 
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE; 
      
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
        
    }
    if (i == 3){
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
    }
    if (i == 4){
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
    }
    if (i == 5){
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
        
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
    }
    if (i == 6){
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
        
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
        
    }
    if (i == 7){
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
        
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE;
    }
  }
  parse_array(); //send it to the board
}
/* NUM 7
  B00000000,
  B01111110,
  B01100110,
  B00001100,
  B00001100,
  B00011000,
  B00011000,
  B00011000
*/


void num8(){
 for (int i=0; i < 8; i++){ //top row not lit up
    if (i == 0){
      for (int j = 0; j < 8; j++){
          matrix[j][i][0][0] = 0;
          matrix[j][i][0][1] = 0;
          matrix[j][i][0][2] = 0;
      }
    }
    if (i == 1){ //next row makes the top
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
        
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE; 
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
    }
    if (i == 2){ 
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE; 
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE; 
      
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
    if (i == 3){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE; 
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE; 
      
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
    if (i == 4){
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE; 
      
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
        
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE; 
      
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
    }
    if (i == 5){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE; 
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
        
    }
    if (i == 6){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE; 
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE; 
      
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
        
    }
    if (i == 7){
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
        
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE; 
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
    }
  }
  parse_array();
}
/* NUM 8
  B00000000,
  B00111100,
  B01100110,
  B01100110,
  B00111100,
  B01100110,
  B01100110,
  B00111100
*/


void num9(){
 for (int i=0; i < 8; i++){ //top row not lit up
    if (i == 0){
      for (int j = 0; j < 8; j++){
          matrix[j][i][0][0] = 0;
          matrix[j][i][0][1] = 0;
          matrix[j][i][0][2] = 0;
      }
    }
    if (i == 1){ //next row makes the top
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
        
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE; 
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
    }
    if (i == 2){ 
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE; 
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE; 
      
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
    if (i == 3){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE; 
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE; 
      
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
    if (i == 4){ //23456
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
        
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE; 
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
    }
    if (i == 5){
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
        
    }
    if (i == 6){
        matrix[1][i][0][0] = RED;
        matrix[1][i][0][1] = GREEN;
        matrix[1][i][0][2] = BLUE; 
      
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE;
        
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE; 
      
        matrix[6][i][0][0] = RED;
        matrix[6][i][0][1] = GREEN;
        matrix[6][i][0][2] = BLUE;
        
    }
    if (i == 7){ //2345
        matrix[2][i][0][0] = RED;
        matrix[2][i][0][1] = GREEN;
        matrix[2][i][0][2] = BLUE; 
      
        matrix[3][i][0][0] = RED;
        matrix[3][i][0][1] = GREEN;
        matrix[3][i][0][2] = BLUE;
        
        matrix[4][i][0][0] = RED;
        matrix[4][i][0][1] = GREEN;
        matrix[4][i][0][2] = BLUE; 
      
        matrix[5][i][0][0] = RED;
        matrix[5][i][0][1] = GREEN;
        matrix[5][i][0][2] = BLUE;
        
    }
  }
  parse_array(); //send it to the board
}
/* NUM 9
  B00000000,
  B00111100,
  B01100110,
  B01100110,
  B00111110,
  B00000110,
  B01100110,
  B00111100
*/
