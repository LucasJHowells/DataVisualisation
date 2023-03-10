import java.text.DecimalFormat;

PShape map;
Table table;
PFont f;

//Variables for Camera
float rotx = PI / 4;
float roty = PI / 4;
float eyeX = 1224;
float eyeY = 1401;
float zoom = 3;

//Global Variables
int yearSelected = 1991;
int popState = 1;
int minPop = 0;
int last;
int count=0;

DecimalFormat df=new DecimalFormat("#,###");

//Setting up the Environment
void setup(){
  //Creating screen size and loading the provided image/data
  size(1440,900,P3D);
  PImage img = loadImage("uk-admin.jpg");
  table = loadTable("Data.csv","header");
  
  //Creating varaible for font and setting the map texture to the rectangle created
  f = createFont("Arial",20,true);
  
  map = createShape(RECT,1,1,2448,2802);
  map.setStroke(false);
  map.setTexture(img);
}

//Drawing the environment
void draw(){
  rotateX(rotx);
  rotateY(roty);
  
  background(168,205,234);
  shape(map);
  
  //Iterating through the table. Accessing the x,y coordinates and population based on users year selected
  for (TableRow row : table.rows()){
    boolean increase = true;
    int x = row.getInt("xPos");
    int y = row.getInt("yPos");
    float pop = row.getFloat(str(yearSelected));
    if(yearSelected != 1991){
        float prevPop = row.getFloat(str(yearSelected-10));
        if(pop > prevPop) {
          increase = true;
        }
        else{
          increase = false;
        }
    }
    String city = row.getString("City");
    
    //Minimum Population options are 0, 200000 and 500000. The population is then divided by 5000 to make the 'graph' more readable
    switch(popState) {
      case 1:
           createBar(x,y,pop/5000,5,city,increase);    
        break;
      case 2:
        if(pop > 200000){
           createBar(x,y,pop/5000,5,city,increase);
        }
        break;
      case 3:
        if(pop > 500000){
           createBar(x,y,pop/5000,5,city,increase);
        }
        break;
      default:
        popState = 1;
    }
  }
  
  //Displaying in top left the year selected and filtered minimum population. The controls are also printed.
  textFont(f,50);  
  text("Year : " + yearSelected ,0,300,5);
  if(popState == 1){ minPop = 0; } else if (popState == 2) {minPop = 200000;} else if (popState == 3) {minPop = 500000;}
  String formattedNumber = df.format(minPop);
  text("Minimum Population : " + formattedNumber ,0,400,5);
  textFont(f,25); 
  text("(Use Keys 1-3 to Change Year and Keys 4-6 to Filter Minimum Population)",0,450,5);
  
  //To change the camera angle
  camera(eyeX,eyeY,(height/2.0) / tan(PI*30/180)*zoom,eyeX,eyeY,0,0,1,0);

}

//Create Bar for each city
void createBar(int x, int y, float height, int width,String City,boolean increase){
    float popMap = map(height,0,1,0,1);
    
    if(increase){
       fill(10,245,10,popMap);
    }
    else{
      fill(245,10,10,popMap);
    }
    
    pushMatrix();
    translate(x,y,height/2);
    box(width*5,width*5,height);
    popMatrix();
    fill(0);
    textFont(f,10); 
    textAlign(CENTER);
    int pop = int(height*5000);
    String formattedNumber = df.format(pop);
    text(City + " - " + formattedNumber,x,y+30,5);
    fill(255);
}

//Snap View
void doubleclick() {
  rotx = PI / 4;
  roty = PI / 4;
  eyeX = 1224;
  eyeY = 1401;
  zoom = 3;
}

//Use arrows for panning, numbers 1-3 for year (1991,2001,2011), numbers 4-6 for min population (0,200000,500000)
void keyPressed(){
  if (key==CODED){
    if(keyCode == UP){
      eyeY -= 50;
    }
    else if(keyCode == RIGHT){
      eyeX += 50;
    }
    else if(keyCode == DOWN){
      eyeY += 50;
    } 
    else if(keyCode == LEFT){
      eyeX -= 50;
    }
  }
  
  switch(key) {
      case '1':
           yearSelected = 1991;
        break;
      case '2':
            yearSelected = 2001;
        break;
      case '3':
            yearSelected = 2011;
        break;
      case '4':
            popState = 1;
        break;
      case '5':
            popState = 2;
        break;
      case '6':
            popState = 3;
        break;
      default:
    }
}

//Detect Snap View
void mousePressed(){
  if(mousePressed == true){
    count++;
    if (count==1)
      last=millis();
    if (count==2 && (millis()-last)<600) {
      doubleclick(); 
      count=0;
    }
    else if ((millis()-last)>600)
      count=0;
  }
}

//Rotate camera when mouse dragged
void mouseDragged(){
  float speed = 0.01;
  rotx += (pmouseY - mouseY) * speed;
  roty += (mouseX - pmouseX) * speed;
}

//Zoom in and out with mouse wheel
void mouseWheel(MouseEvent event){
  float e = event.getCount();
  zoom += e * 0.01;
}
