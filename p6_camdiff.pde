import processing.video.*;
import cvimage.*;
import org.opencv.core.*;
import org.opencv.imgproc.Imgproc;
import org.opencv.imgcodecs.Imgcodecs; // imread, imwrite

Capture cam;
CVImage img,pimg,auximg,cepe;
int bo_x=0;
int bo_y =0;
void setup() {
  
  size(1280, 480,P3D);
  //Cámara
  cam = new Capture(this, width/2 , height);
  cam.start(); 
  
  //OpenCV
  //Carga biblioteca core de OpenCV
  System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
  println(Core.VERSION);
  cepe = new CVImage(cam.width, cam.height);
  cpMat2CVImage(Imgcodecs.imread("j.jpg"),cepe);
  img = new CVImage(cam.width, cam.height);
  pimg = new CVImage(cam.width, cam.height);
  auximg=new CVImage(cam.width, cam.height);
}

void draw() {  
  if (cam.available()) {
    background(0);
    cam.read();
    
    //Obtiene la imagen de la cámara
    img.copy(cam, 0, 0, cam.width, cam.height, 
    0, 0, img.width, img.height);
    img.copyTo();
    
    //Imagen de grises
    Mat gris = img.getGrey();
    Mat pgris = pimg.getGrey();
    
    //Calcula diferencias en tre el fotograma actual y el previo
    Core.absdiff(gris, pgris, gris);
    int[]pos = re(gris);
    //Copia de Mat a CVImage
    cpMat2CVImage(gris,auximg);
    
    //Visualiza ambas imágenes
    image(img,0,0);
    
    
    image(auximg,width/2,0);
    
    
    //Copia actual en previa para próximo fotograma
    pimg.copy(img, 0, 0, img.width, img.height, 
    0, 0, img.width, img.height);
    pimg.copyTo();
    
    gris.release();
    lights();
    if(pos!=null){
      bo_x= pos[1];
      bo_y= pos[0];
      noStroke();
      fill(255,0,0);
      translate(bo_x,bo_y,0);
       sphere(20);
    }else{
      translate(bo_x,bo_y,0);
      noStroke();
      fill(255,0,0);
      sphere(20);
      
    }
  }
  
   
}

//Copia unsigned byte Mat a color CVImage
void  cpMat2CVImage(Mat in_mat,CVImage out_img)
{    
  byte[] data8 = new byte[cam.width*cam.height];
  
  out_img.loadPixels();
  in_mat.get(0, 0, data8);
  
  // Cada columna
  for (int x = 0; x < cam.width; x++) {
    // Cada fila
    for (int y = 0; y < cam.height; y++) {
      // Posición en el vector 1D
      int loc = x + y * cam.width;
      //Conversión del valor a unsigned basado en 
      //https://stackoverflow.com/questions/4266756/can-we-make-unsigned-byte-in-java
      int val = data8[loc] & 0xFF;
      //Copia a CVImage
      out_img.pixels[loc] = color(val);
    }
  }
  out_img.updatePixels();
}

int[] re(Mat img){
  
  
 int[] x_y = new int[2];
  int rows = img.rows(); //Calculates number of rows
  int cols = img.cols(); //Calculates number of columns
  int ch = img.channels(); //Calculates number of channels (Grayscale: 1, RGB: 3, etc.)
  int cont=0;
  for (int i=0; i<rows; i++)
  {
      for (int j=0; j<cols; j++)
      {
           
          double[] data = img.get(i, j); //Stores element in an array
         
          if(data[0]>50){
             x_y[0]+=i;
             x_y[1]+=j;
             cont++;
            
          }
          
      }
  }
  
  if(cont==0)return null;
  x_y[0] = x_y[0]/cont;
  x_y[1] = x_y[1]/cont;
  return x_y;
  
}
