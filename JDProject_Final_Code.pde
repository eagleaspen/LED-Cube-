/*
Junior Design LED Cube Project
Aspen Eagle, Carson Edmonds, Benjamin Green
6/1/2021

This file contains the GUI control software and all pre-programmed displays. Options for user
control include a custom message display, direct to the cube drawing tool, and buttons for the
pre-programmed animations.
*/

import controlP5.*;
import processing.serial.*;
import java.util.Random;

int D_ANIM = 100;

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

//2D integer array of a bitmap for each alpha-numeric character
int[][] A =  {
              {0,0,0,0,0,0,0,0},
              {0,0,1,1,1,1,0,0},
              {0,1,1,0,0,1,1,0},
              {0,1,1,0,0,1,1,0},
              {0,1,1,1,1,1,1,0},
              {0,1,1,0,0,1,1,0},
              {0,1,1,0,0,1,1,0},
              {0,1,1,0,0,1,1,0},
};

int [][] B = {
              {0,0,0,0,0,0,0,0},
              {0,1,1,1,1,1,0,0},
              {0,1,1,0,0,1,1,0},
              {0,1,1,0,0,1,1,0},
              {0,1,1,1,1,1,0,0},
              {0,1,1,0,0,1,1,0},
              {0,1,1,0,0,1,1,0},
              {0,1,1,1,1,1,0,0},
};

int [][] C = {
              {0,0,0,0,0,0,0,0},
              {0,0,1,1,1,1,0,0},
              {0,1,1,0,0,1,1,0},
              {0,1,1,0,0,0,0,0},
              {0,1,1,0,0,0,0,0},
              {0,1,1,0,0,0,0,0},
              {0,1,1,0,0,1,1,0},
              {0,0,1,1,1,1,0,0},
};

int [][] D = {  
            {0,0,0,0,0,0,0,0},
            {0,1,1,1,1,1,0,0},
            {0,1,1,0,0,1,1,0},
            {0,1,1,0,0,1,1,0},
            {0,1,1,0,0,1,1,0},
            {0,1,1,0,0,1,1,0},
            {0,1,1,0,0,1,1,0},
            {0,1,1,1,1,1,0,0},
};

int [][] E = {  
            {0,0,0,0,0,0,0,0},
            {0,1,1,1,1,1,1,0},
            {0,1,1,0,0,0,0,0},
            {0,1,1,0,0,0,0,0},
            {0,1,1,1,1,1,0,0},
            {0,1,1,0,0,0,0,0},
            {0,1,1,0,0,0,0,0},
            {0,1,1,1,1,1,1,0},
};

int [][] F = {  
            {0,0,0,0,0,0,0,0},
            {0,1,1,1,1,1,1,0},
            {0,1,1,0,0,0,0,0},
            {0,1,1,0,0,0,0,0},
            {0,1,1,1,1,1,0,0},
            {0,1,1,0,0,0,0,0},
            {0,1,1,0,0,0,0,0},
            {0,1,1,0,0,0,0,0},
};

int [][] G = {
             {0,0,0,0,0,0,0,0},
             {0,0,1,1,1,1,0,0},
             {0,1,1,0,0,1,1,0},
             {0,1,1,0,0,0,0,0},
             {0,1,1,0,0,0,0,0},
             {0,1,1,0,1,1,1,0},
             {0,1,1,0,0,1,1,0},
             {0,0,1,1,1,1,0,0},
};

int [][] H = {
              {0,0,0,0,0,0,0,0},
              {0,1,1,0,0,1,1,0},
              {0,1,1,0,0,1,1,0},
              {0,1,1,0,0,1,1,0},
              {0,1,1,1,1,1,1,0},
              {0,1,1,0,0,1,1,0},
              {0,1,1,0,0,1,1,0},
              {0,1,1,0,0,1,1,0},
};

int [][] I = {
            {0,0,0,0,0,0,0,0},
            {0,0,1,1,1,1,0,0},
            {0,0,0,1,1,0,0,0},
            {0,0,0,1,1,0,0,0},
            {0,0,0,1,1,0,0,0},
            {0,0,0,1,1,0,0,0},
            {0,0,0,1,1,0,0,0},
            {0,0,1,1,1,1,0,0},
};

int [][] J = {  
            {0,0,0,0,0,0,0,0},
            {0,0,0,1,1,1,1,0},
            {0,0,0,0,1,1,0,0},
            {0,0,0,0,1,1,0,0},
            {0,0,0,0,1,1,0,0},
            {0,1,1,0,1,1,0,0},
            {0,1,1,0,1,1,0,0},
            {0,0,1,1,1,0,0,0},
};

int [][] K = {
            {0,0,0,0,0,0,0,0},
            {0,1,1,0,0,1,1,0},
            {0,1,1,0,1,1,0,0},
            {0,1,1,1,1,0,0,0},
            {0,1,1,1,0,0,0,0},
            {0,1,1,1,1,0,0,0},
            {0,1,1,0,1,1,0,0},
            {0,1,1,0,0,1,1,0},
};

int [][] L = {
            {0,0,0,0,0,0,0,0},
            {0,1,1,0,0,0,0,0},
            {0,1,1,0,0,0,0,0},
            {0,1,1,0,0,0,0,0},
            {0,1,1,0,0,0,0,0},
            {0,1,1,0,0,0,0,0},
            {0,1,1,0,0,0,0,0},
            {0,1,1,1,1,1,1,0},
};

int [][] M = {
            {0,0,0,0,0,0,0,0},
            {0,1,1,0,0,0,1,1},
            {0,1,1,1,0,1,1,1},
            {0,1,1,1,1,1,1,1},
            {0,1,1,0,1,0,1,1},
            {0,1,1,0,0,0,1,1},
            {0,1,1,0,0,0,1,1},
            {0,1,1,0,0,0,1,1},
};

int [][] N = {
            {0,0,0,0,0,0,0,0},
            {0,1,1,0,0,0,1,1},
            {0,1,1,1,0,0,1,1},
            {0,1,1,1,1,0,1,1},
            {0,1,1,0,1,1,1,1},
            {0,1,1,0,0,1,1,1},
            {0,1,1,0,0,0,1,1},
            {0,1,1,0,0,0,1,1},
};

int [][] O = {
            {0,0,0,0,0,0,0,0},
            {0,0,1,1,1,1,0,0},
            {0,1,1,0,0,1,1,0},
            {0,1,1,0,0,1,1,0},
            {0,1,1,0,0,1,1,0},
            {0,1,1,0,0,1,1,0},
            {0,1,1,0,0,1,1,0},
            {0,0,1,1,1,1,0,0},
};

int [][] P = {
            {0,0,0,0,0,0,0,0},
            {0,1,1,1,1,1,0,0},
            {0,1,1,0,0,1,1,0},
            {0,1,1,0,0,1,1,0},
            {0,1,1,0,0,1,1,0},
            {0,1,1,1,1,1,0,0},
            {0,1,1,0,0,0,0,0},
            {0,1,1,0,0,0,0,0},
};

int [][] Q = {
            {0,0,0,0,0,0,0,0},
            {0,0,1,1,1,1,0,0},
            {0,1,1,0,0,1,1,0},
            {0,1,1,0,0,1,1,0},
            {0,1,1,0,0,1,1,0},
            {0,1,1,0,1,1,1,0},
            {0,0,1,1,1,1,0,0},
            {0,0,0,0,0,1,1,0},
};
 
int [][] R = {
            {0,0,0,0,0,0,0,0},
            {0,1,1,1,1,1,0,0},
            {0,1,1,0,0,1,1,0},
            {0,1,1,0,0,1,1,0},
            {0,1,1,1,1,1,0,0},
            {0,1,1,1,1,0,0,0},
            {0,1,1,0,1,1,0,0},
            {0,1,1,0,0,1,1,0},
};
 
int [][] S = {
            {0,0,0,0,0,0,0,0},
            {0,0,1,1,1,1,0,0},
            {0,1,1,0,0,1,1,0},
            {0,1,1,0,0,0,0,0},
            {0,0,1,1,1,1,0,0},
            {0,0,0,0,0,1,1,0},
            {0,1,1,0,0,1,1,0},
            {0,0,1,1,1,1,0,0},
};

int [][] T = {
            {0,0,0,0,0,0,0,0},
            {0,1,1,1,1,1,1,0},
            {0,1,0,1,1,0,1,0},
            {0,0,0,1,1,0,0,0},
            {0,0,0,1,1,0,0,0},
            {0,0,0,1,1,0,0,0},
            {0,0,0,1,1,0,0,0},
            {0,0,0,1,1,0,0,0},
};

int [][] U = {
            {0,0,0,0,0,0,0,0},
            {0,1,1,0,0,1,1,0},
            {0,1,1,0,0,1,1,0},
            {0,1,1,0,0,1,1,0},
            {0,1,1,0,0,1,1,0},
            {0,1,1,0,0,1,1,0},
            {0,1,1,0,0,1,1,0},
            {0,0,1,1,1,1,1,0},
};

int [][] V = {
            {0,0,0,0,0,0,0,0},
            {0,1,1,0,0,1,1,0},
            {0,1,1,0,0,1,1,0},
            {0,1,1,0,0,1,1,0},
            {0,1,1,0,0,1,1,0},
            {0,1,1,0,0,1,1,0},
            {0,0,1,1,1,1,0,0},
            {0,0,0,1,1,0,0,0},
};

int [][] W = {
            {0,0,0,0,0,0,0,0},
            {0,1,1,0,0,0,1,1},
            {0,1,1,0,0,0,1,1},
            {0,1,1,0,0,0,1,1},
            {0,1,1,0,1,0,1,1},
            {0,1,1,1,1,1,1,1},
            {0,1,1,1,0,1,1,1},
            {0,1,1,0,0,0,1,1},
};

int [][] X = {
            {0,0,0,0,0,0,0,0},
            {0,1,1,0,0,0,1,1},
            {0,1,1,0,0,0,1,1},
            {0,0,1,1,0,1,1,0},
            {0,0,0,1,1,1,0,0},
            {0,0,1,1,0,1,1,0},
            {0,1,1,0,0,0,1,1},
            {0,1,1,0,0,0,1,1},
};

int [][] Y = {
            {0,0,0,0,0,0,0,0},
            {0,1,1,0,0,1,1,0},
            {0,1,1,0,0,1,1,0},
            {0,1,1,0,0,1,1,0},
            {0,0,1,1,1,1,0,0},
            {0,0,0,1,1,0,0,0},
            {0,0,0,1,1,0,0,0},
            {0,0,0,1,1,0,0,0},
};

int [][] Z = {
            {0,0,0,0,0,0,0,0},
            {0,1,1,1,1,1,1,0},
            {0,0,0,0,0,1,1,0},
            {0,0,0,0,1,1,0,0},
            {0,0,0,1,1,0,0,0},
            {0,0,1,1,0,0,0,0},
            {0,1,1,0,0,0,0,0},
            {0,1,1,1,1,1,1,0},
};

int [][] zero = {
            {0,0,0,0,0,0,0,0},
            {0,0,1,1,1,1,0,0},
            {0,1,1,0,0,1,1,0},
            {0,1,1,0,1,1,1,0},
            {0,1,1,1,0,1,1,0},
            {0,1,1,0,0,1,1,0},
            {0,1,1,0,0,1,1,0},
            {0,0,1,1,1,1,0,0},
};

int [][] one = {
              {0,0,0,0,0,0,0,0},
              {0,0,0,1,1,0,0,0},
              {0,0,0,1,1,0,0,0},
              {0,0,1,1,1,0,0,0},
              {0,0,0,1,1,0,0,0},
              {0,0,0,1,1,0,0,0},
              {0,0,0,1,1,0,0,0},
              {0,1,1,1,1,1,1,0},
};


int [][] two = {
            {0,0,0,0,0,0,0,0},
            {0,0,1,1,1,1,0,0},
            {0,1,1,0,0,1,1,0},
            {0,0,0,0,0,1,1,0},
            {0,0,0,0,1,1,0,0},
            {0,0,1,1,0,0,0,0},
            {0,1,1,0,0,0,0,0},
            {0,1,1,1,1,1,1,0},
};

int [][] three = {
            {0,0,0,0,0,0,0,0},
            {0,0,1,1,1,1,0,0},
            {0,1,1,0,0,1,1,0},
            {0,0,0,0,0,1,1,0},
            {0,0,0,1,1,1,0,0},
            {0,0,0,0,0,1,1,0},
            {0,1,1,0,0,1,1,0},
            {0,0,1,1,1,1,0,0},
};

int [][] four = {
            {0,0,0,0,0,0,0,0},
            {0,0,0,0,1,1,0,0},
            {0,0,0,1,1,1,0,0},
            {0,0,1,0,1,1,0,0},
            {0,1,0,0,1,1,0,0},
            {0,1,1,1,1,1,1,0},
            {0,0,0,0,1,1,0,0},
            {0,0,0,0,1,1,0,0},
};

int [][] five = {
            {0,0,0,0,0,0,0,0},
            {0,1,1,1,1,1,1,0},
            {0,1,1,0,0,0,0,0},
            {0,1,1,1,1,1,0,0},
            {0,0,0,0,0,1,1,0},
            {0,0,0,0,0,1,1,0},
            {0,1,1,0,0,1,1,0},
            {0,0,1,1,1,1,0,0},
};

int [][] six = {
            {0,0,0,0,0,0,0,0},
            {0,0,1,1,1,1,0,0},
            {0,1,1,0,0,1,1,0},
            {0,1,1,0,0,0,0,0},
            {0,1,1,1,1,1,0,0},
            {0,1,1,0,0,1,1,0},
            {0,1,1,0,0,1,1,0},
            {0,0,1,1,1,1,0,0},
};

int [][] seven = {
            {0,0,0,0,0,0,0,0},
            {0,1,1,1,1,1,1,0},
            {0,1,1,0,0,1,1,0},
            {0,0,0,0,1,1,0,0},
            {0,0,0,0,1,1,0,0},
            {0,0,0,1,1,0,0,0},
            {0,0,0,1,1,0,0,0},
            {0,0,0,1,1,0,0,0},
};

int [][] eight = {
            {0,0,0,0,0,0,0,0},
            {0,0,1,1,1,1,0,0},
            {0,1,1,0,0,1,1,0},
            {0,1,1,0,0,1,1,0},
            {0,0,1,1,1,1,0,0},
            {0,1,1,0,0,1,1,0},
            {0,1,1,0,0,1,1,0},
            {0,0,1,1,1,1,0,0},
};

int [][] nine = { 
                {0,0,0,0,0,0,0,0},
                {0,0,1,1,1,1,0,0},
                {0,1,1,0,0,1,1,0},
                {0,1,1,0,0,1,1,0},
                {0,0,1,1,1,1,1,0},
                {0,0,0,0,0,1,1,0},
                {0,1,1,0,0,1,1,0},
                {0,0,1,1,1,1,0,0},
};      

//adds and initializes the gui toolset consisting of the matrix, sliders, buttons, and message textfield  
void setup() {
  size(750, 900);    //screen size

  port = new Serial(this, "COM6", 9600); // connect to com3 serial port w/ a baud rate of 9600
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
  cp5.addButton("WAVE")
     .setPosition(75,650)
     .setSize(150,50)
     .setFont(createFont("arial",15))     
     ;
  
  // and add another 2 buttons
  cp5.addButton("CUBECEPTION")
     .setPosition(275,650)
     .setSize(150,50)
     .setFont(createFont("arial",15))     
     ;
     
  cp5.addButton("RAIN")
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

//when the WAVE buton is pressed this function calls animation1() to send the animation to the cube
public void WAVE(){
  animation1(); 
}

//when the CUBECEPTION buton is pressed this function calls animation2() to send the animation to the cube
public void CUBECEPTION(){
  animation2(); 
}

//when the CUBECEPTION buton is pressed this function calls animation2() to send the animation to the cube
public void RAIN(){
  animation3(); 
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
  //pause/play animation que with spacebar 
  if (key==' ') {                                              
    if (cp5.get(Matrix.class, "myMatrix").isPlaying()) {
      cp5.get(Matrix.class, "myMatrix").pause();
    }     
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
          letterDisp(A);
      } 
        
      if (text.charAt(i) == 'B' || text.charAt(i) == 'b' ){
        letterDisp(B);
      }  
      
      if (text.charAt(i) == 'C' || text.charAt(i) == 'c' ){
        letterDisp(C);
      }  
      
      if (text.charAt(i) == 'D' || text.charAt(i) == 'd' ){
        letterDisp(D);
      }  
      
      if (text.charAt(i) == 'E' || text.charAt(i) == 'e'){
        letterDisp(E);
      }  
      
      if (text.charAt(i) == 'F' || text.charAt(i) == 'f' ){
        letterDisp(F);
      }  
      
      if (text.charAt(i) == 'G' || text.charAt(i) == 'g' ){
        letterDisp(G);
      } 
      
      if (text.charAt(i) == 'H' || text.charAt(i) == 'h' ){
        letterDisp(H);
      }  
      
      if (text.charAt(i) == 'I' || text.charAt(i) == 'i' ){
        letterDisp(I);
      }  
      
      if (text.charAt(i) == 'J' || text.charAt(i) == 'j' ){
        letterDisp(J);
      } 
      
      if (text.charAt(i) == 'K' || text.charAt(i) == 'k' ){
        letterDisp(K);
      } 
      
      if (text.charAt(i) == 'L' || text.charAt(i) == 'l' ){
        letterDisp(L);
      } 
      
      if (text.charAt(i) == 'M' || text.charAt(i) == 'm' ){
        letterDisp(M);
      }  
      
      if (text.charAt(i) == 'N' || text.charAt(i) == 'n' ){
        letterDisp(N);
      } 
      
      if (text.charAt(i) == 'O' || text.charAt(i) == 'o' ){
        letterDisp(O);
      }  
      
      if (text.charAt(i) == 'P' || text.charAt(i) == 'p' ){
        letterDisp(P);
      }  
      
      if (text.charAt(i) == 'Q' || text.charAt(i) == 'q' ){
        letterDisp(Q);
      }  
      
      if (text.charAt(i) == 'R' || text.charAt(i) == 'r' ){
        letterDisp(R);
      } 
      
      if (text.charAt(i) == 'S' || text.charAt(i) == 's' ){
        letterDisp(S);
      }  
      
      if (text.charAt(i) == 'T' || text.charAt(i) == 't' ){
        letterDisp(T);
      } 
      
      if (text.charAt(i) == 'U' || text.charAt(i) == 'u' ){
        letterDisp(U);
      }  
      
      if (text.charAt(i) == 'V' || text.charAt(i) == 'v' ){
        letterDisp(V);
      }  
      
      if (text.charAt(i) == 'W' || text.charAt(i) == 'w' ){
        letterDisp(W);
      }
      
      if (text.charAt(i) == 'X' || text.charAt(i) == 'x' ){
        letterDisp(X);
      }  
      
      if (text.charAt(i) == 'Y' || text.charAt(i) == 'y' ){
        letterDisp(Y);
      } 
      
      if (text.charAt(i) == 'Z' || text.charAt(i) == 'z' ){
        letterDisp(Z);
      }  
      
      if (text.charAt(i) == '0'){
        letterDisp(zero);
      }  
      
      if (text.charAt(i) == '1'){
        letterDisp(one);
      }  
     
      if (text.charAt(i) == '2'){
        letterDisp(two);
      }  
      
      if (text.charAt(i) == '3'){
        letterDisp(three);
      } 
     
      if (text.charAt(i) == '4'){
        letterDisp(four);
      }  
     
      if (text.charAt(i) == '5'){
        letterDisp(five);
      } 
     
      if (text.charAt(i) == '6'){
        letterDisp(six);
      } 
      
      if (text.charAt(i) == '7'){
        letterDisp(seven);
      }  
     
      if (text.charAt(i) == '8'){
        letterDisp(eight);
      } 
     
      if (text.charAt(i) == '9'){
        letterDisp(nine);
      } 
      delay(10*D_ANIM);       //delay 500ms
       
    }
  }
}


//This function sends a display to the LED cube by parsing through the matrix array and converting it to a bit stream that is sent to the microcontroller
//  *the print functions are for debugging and demo only, uncomment port.write() commands when interfacing with the cube
void parse_array(){
  byte stream = 0;
  byte s;
  for(int l = 0; l < 2; l++){              //parse intensity
    for(int h = 0; h < 8; h++){            //parse layers
      //delay(2);
      //port.write(h);
      for(int i = 0; i < 8; i++){          //parse rows
        for(int j = 0; j < 3; j++){        //parse colors
          stream = 0;
          for(int k = 0; k < 8; k++){      //parse each column in a row
            if(l == 0){                    //check for LED intensity in frame one
              if(matrix[k][i][h][j] > 0) {
                stream += (1 << k);
              }
            }
            if(l == 1){                      //check for LED intensity in frame two
              if(matrix[k][i][h][j] > 127) {
                stream += (1 << k);
              }
            }
          }
          port.write(stream);
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
  //RED = 0;
  //GREEN = 0;
  //BLUE = 0;
}

void set(int val) {
  for(int i = 0; i < 8; i++){
    for(int j = 0; j < 8; j++){
      for(int k = 0; k < 8; k++){
        matrix[i][j][k][0] = val;
        matrix[i][j][k][1] = val;
        matrix[i][j][k][2] = val; 
      }
    }
  }  
}



/////////////////////////////////////////////////////// PRE-PROGRAMMED ANIMATIONS /////////////////////////////////////////////////////////////////////////////////////


//waveform animation
//Stores the matrix display then calls parse_array() to display for each frame of the animation. Also calls reset at being and end of the function
void animation1(){
  reset();
  int [] wave_array = {8, 7, 4, 1, 0, 1, 4, 7}; //array of sin wave values
  for(int r = 0; r < 5; r++){  //cycle through the wave 16 times
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
      delay(D_ANIM); //delay 50ms betweeen frames of the wave
    }
  }
  reset();
  parse_array();
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
      delay(D_ANIM);      //delay 50ms
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
      delay(D_ANIM);      //delay 50ms
    } 
  }
  reset();
  parse_array();
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
        delay(D_ANIM);     //delay 50ms
      }
    }
  }
  reset();
}

///////////// PRE-PROGRAMMED ALPHA-NUMERIC DISPLAYS //////////////////////////////////

//Passes in a bitmap array and stores RGB values in the matrix array wherever the bitmap value is 1 then calls parse_array to display on the cube
void letterDisp(int[][] bitmap) {
  reset();
  
  for(int i = 0; i < 8; i++) {
    for(int j = 0; j < 8; j++) {
      
      matrix[i][0][j][0] = (bitmap[j][i] == 1 ? RED : 0);
      matrix[i][0][j][1] = (bitmap[j][i] == 1 ? GREEN : 0);
      matrix[i][0][j][2] = (bitmap[j][i] == 1 ? BLUE : 0);
    }
  }
  
  parse_array();
  
}

