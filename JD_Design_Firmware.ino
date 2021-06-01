
byte**** data;

const int ROW_CLK_PINS[8] = {23, 22, 21, 20, 19, 18, 17, 16};
const int DATA_PINS[3] = {15, 14, 13};
const int LAYER_CLK = 35;
const int LAYER_DATA = 36;
const int LAYER_EN = 37;
byte dr, dg, db;
int timeout;

void setup() {
  // put your setup code here, to run once:

  //set up a  LED data in the format: data[color intensity][layer][row][color]
  data = new byte***[2];
  for(int i = 0; i < 2; i++) {
    data[i] = new byte**[8];
    for(int j = 0; j < 8; j++) {
      data[i][j] = new byte*[8];
      for(int k = 0; k < 8; k++){
        data[i][j][k] = new byte[3];
        data[i][j][k][0] = 0;
        data[i][j][k][1] = 0;
        data[i][j][k][2] = 0;
      }
    }
  }
  
  
  //set up clock pins
  for(int i = 0; i < 8; i++){
    pinMode(ROW_CLK_PINS[i], OUTPUT);
  }
  //set up R, G, B data pins
  for(int i = 0; i < 3; i++){
    pinMode(DATA_PINS[i], OUTPUT);
  }
  //set up Layer control pins
  pinMode(LAYER_CLK, OUTPUT);
  pinMode(LAYER_DATA, OUTPUT);
  pinMode(LAYER_EN, OUTPUT);
  pinMode(3, OUTPUT);
  Serial.begin(9600);

  dr = 0, dg = 0, db = 0;

}

void fill_data(const int val) {
  for(int i = 0; i < 2; i++) {
    data[i] = new byte**[8];
    for(int j = 0; j < 8; j++) {
      data[i][j] = new byte*[8];
      for(int k = 0; k < 8; k++){
        data[i][j][k] = new byte[3];
        data[i][j][k][0] = val;
        data[i][j][k][1] = val;
        data[i][j][k][2] = val;
      }
    }
  }
}

//writes a byte of data into a register
void write_reg(const int CLK, const int SER, byte data) {
  for(byte i = 0; i < 8; i++) {
    digitalWrite(CLK, LOW);
    digitalWrite(SER, ((data & (1 << i)) != 0? HIGH: LOW));  //write 1 bit and shift to the next bit
    delayMicroseconds(1);
    digitalWrite(CLK, HIGH);
  }
  delayMicroseconds(1);
  digitalWrite(CLK, LOW);
  delayMicroseconds(1);
  digitalWrite(CLK, HIGH);
}

void shift_reg(const int CLK, const int SER, byte data) {
  digitalWrite(CLK, LOW);
  digitalWrite(SER, data);
  delayMicroseconds(1);
  digitalWrite(CLK, HIGH);
  delayMicroseconds(1);
}

void write_row_registers(const int CLK, const int R, const int G, const int B, byte d1,  byte d2, byte d3) {
  digitalWrite(3, HIGH);
  for(byte i = 0; i < 8; i++) {
    digitalWrite(CLK, LOW);
    digitalWrite(R, ((d1 & (1 << i)) != 0? HIGH: LOW));  //write 1 bit and shift to the next bit
    digitalWrite(G, ((d2 & (1 << i)) != 0? HIGH: LOW));  //write 1 bit and shift to the next bit
    digitalWrite(B, ((d3 & (1 << i)) != 0? HIGH: LOW));  //write 1 bit and shift to the next bit
    delayMicroseconds(1);
    digitalWrite(CLK, HIGH);
    //delayMicroseconds(1);
  }
  digitalWrite(CLK, LOW);
  //delayMicroseconds(1);
  digitalWrite(CLK, HIGH);
  digitalWrite(3, LOW);
}

void read_serial() {
  char _data;
  int int_data;
  timeout = 0;
  if(Serial.available()) {
    //reads in serial data and store it in the data array
    for(int i = 0; i < 2; i++) { // brightness
      for(int j = 0; j < 8; j++) { // vertical layer
        for(int k = 0; k <8; k++){ // row
          for(int l = 0; l < 3; l++){ // color
            C1:
            if(Serial.available()){
              _data = Serial.read();
              data[i][j][k][l] = (byte) _data; // byte for 1 register
              //Serial.println(data[i][j][k][l]);
            } else {
              delayMicroseconds(10);
              timeout++;
              if(timeout < 5000) {
                goto C1;
              } else {
                return;
              }
            }
          }
        }
      }
    }
    Serial.println("End of Data");
  }
}

void write_data() {
  int t_delay;
  char ri, rj, rk, rl;
  //Serial.println("Writing Data");
  for(int i = 0; i < 2; i++) {
    for(int j = 0; j < 8; j++) { // Layer Loop
      write_reg(LAYER_CLK, LAYER_DATA, 1 << (j)); // Reset Layer Register to show layer 1
      digitalWrite(LAYER_EN, HIGH);
      for(int k = 0; k < 8; k++) {
        write_row_registers(ROW_CLK_PINS[k],
                            DATA_PINS[0],
                            DATA_PINS[1],
                            DATA_PINS[2],
                            data[i][j][k][0],
                            data[i][j][k][1],
                            data[i][j][k][2]);
      }
      digitalWrite(LAYER_EN, LOW);
      t_delay = (i == 0? 300: 600);
      delayMicroseconds(t_delay);
    }
  }
}

void loop(){
  // put your main code here, to run repeatedly:
  /*dr+=1;
  dr = dr%256;
  dg+=2;
  dg = dg%256;
  db+=3;
  db = db%256;
  write_row_registers(ROW_CLK_PINS[0], DATA_PINS[0], DATA_PINS[1], DATA_PINS[2], 255, 0, 0);
  delay(1);
  write_row_registers(ROW_CLK_PINS[0], DATA_PINS[0], DATA_PINS[1], DATA_PINS[2], 0, 0, 0);
  delay(6);*/

  read_serial();
  /*fill_data(0b11111111);

  for(int i = 0; i < 8; i++) {
    write_row_registers(ROW_CLK_PINS[i],
              DATA_PINS[0],
              DATA_PINS[1],
              DATA_PINS[2],
              0b11111111,
              0b11111111,
              0b11111111);
  }

  for(int i = 0; i < 8; i++) {
    write_reg(LAYER_CLK, LAYER_DATA, 1 << i);
  delay(1000);
  }*/
  write_data();

  
  //digitalWrite(3, LOW);
  //delay(1);
}
