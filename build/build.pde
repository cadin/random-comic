import processing.net.*;
Client myClient;

// CONTROLS:
// 'r' : Randomize entire comic
//       (click to randomize an individual panel)
// 's' : Save Image


// ************************ //
// *****  CONFIG **********//

// configurations:                  density, ppi, margin, scale, imgFolder, autosave
Config CONFIG_FULL_RES = new Config(2,       600, 0.125,  0.24,  "600ppi",  false);

// low res config for running on robot
// thermal printer outputs 384px wide image
Config CONFIG_LOW_RES  = new Config(1,       128, 0,      1,     "128ppi",  true);

Config config = CONFIG_FULL_RES;

// ************************ //
// ************************ //


boolean AUTOPLAY = config.autoplay;
int PX_DENSITY = config.pxDensity;

int GRID_W = config.gridW;
int GRID_H = config.gridH;

int MAX_CELL_W = config.maxCellW;
int MAX_CELL_H = config.maxCellH;

int NUM_BACKGROUNDS = config.numBackgrounds;

boolean ALLOW_VERTICAL_PANELS = config.allowVerticalPanels;

// PRINT_PPI specifies both the output resolution AND the resolution of input images
int PRINT_PPI = config.printPPI;

float CELL_SIZE_INCHES = config.cellSizeInches;
float PRINT_MARGIN_INCHES = config.printMarginInches;

// How big should the comic appear on screen
// with 600 ppi, 0.24 looks right on MPB screen
float SCREEN_SCALE_PCENT = config.screenScalePcent;

String IMG_SRC_FOLDER = config.imgSrcFolder;


// CONSTANTS
int PRINT_RESOLUTION = PRINT_PPI / PX_DENSITY;
float PRINT_W_INCHES = (CELL_SIZE_INCHES * GRID_W) + (PRINT_MARGIN_INCHES * 2);
float PRINT_H_INCHES = (CELL_SIZE_INCHES * GRID_H) + (PRINT_MARGIN_INCHES * 2);

int CELL_SIZE_PX = int(CELL_SIZE_INCHES * PRINT_RESOLUTION);
int PRINT_MARGIN_PX = int(PRINT_MARGIN_INCHES * PRINT_RESOLUTION);
int PRINT_W_PX = int(PRINT_W_INCHES * PRINT_RESOLUTION);
int PRINT_H_PX = int(PRINT_H_INCHES * PRINT_RESOLUTION);

float SCREEN_SCALE = SCREEN_SCALE_PCENT * PX_DENSITY;
int SCREEN_W = int(PRINT_W_PX * SCREEN_SCALE);
int SCREEN_H = int(PRINT_H_PX * SCREEN_SCALE);
int SCREEN_RESOLUTION = int(PRINT_RESOLUTION * SCREEN_SCALE);


int[][] cells = new int[GRID_H][GRID_W];
PGraphics fullResBuffer;
PImage screenPreview;
PImage smResBuffer;

// There are 4 different frame drawings per frame size (for visual variation)
int NUM_FRAME_VARIATIONS = 4;

ArrayList <Panel> panels = new ArrayList<Panel>();

Assets assets = new Assets();

PImage testImg;

void settings() {

	size(SCREEN_W,SCREEN_H);
	pixelDensity(PX_DENSITY);
}


void setup() {
	println("p5: booting...");
	if(config.useServer){
		myClient = new Client(this, "127.0.0.1", 5204);
	}

	if(AUTOPLAY){
		frameRate(2);
	} else if(config.useServer == false) {
		noLoop();
	}

	fullResBuffer = createGraphics(PRINT_W_PX, PRINT_H_PX);
	assets.loadFrames();
	assets.loadImageData();

	// smResBuffer = createGraphics(384, 384);

	randomize();
}

void draw() {

	if(config.useServer){
		checkServerMessages();
		return;
	}

	clearBuffer();
	if(AUTOPLAY) randomize();

	for(int i =0; i < panels.size(); i++) {
		Panel p = panels.get(i);
		drawFrameToBuffer(p.getGraphics(), p.x, p.y);
	}

	image(fullResBuffer, 0, 0, SCREEN_W, SCREEN_H);
	if(config.autosave) saveImage();
}

void checkServerMessages() {
	if(myClient.available() > 0){
		String data = myClient.readString();
		if(data.indexOf("generate image") > -1){
			println("p5: press received");
			clearBuffer();
			randomize();
			saveImage();
		} else {
			println("p5 received data: " + data);
		}
	}
}

void randomize() {
	chooseFrames();
}

void clearBuffer() {
	fullResBuffer.beginDraw();
	fullResBuffer.background(255);
	fullResBuffer.endDraw();
}

void reset() {
	clearBuffer();
	cells = new int[GRID_H][GRID_W];
	panels = new ArrayList<Panel>();
}

boolean isMouseOverPanel(Panel p) {
	int cellSize = int(CELL_SIZE_INCHES * SCREEN_RESOLUTION);
	int panelX = int(p.x * cellSize + PRINT_MARGIN_INCHES * SCREEN_RESOLUTION);
	int panelY = int(p.y * cellSize + PRINT_MARGIN_INCHES * SCREEN_RESOLUTION);
	int panelW = p.width * cellSize;
	int panelH = p.height * cellSize;

	if( (mouseX > panelX && mouseX < panelX + panelW) &&
		(mouseY > panelY && mouseY < panelY + panelH)) {
		return true;
	}
	return false;
}

void mousePressed() {
	for(int i = 0; i < panels.size(); i++) {
		Panel p = panels.get(i);
		if(isMouseOverPanel(p)){
			p.recompose();
			redraw();
		}
	}
}

void keyPressed() {
	switch(key) {
	case 'r':
		randomize();
		redraw();

	break;
	case 's' :
		saveImage();
	break;

	}
}

FrameSize chooseFrameForPosition(int x, int y) {
	int nextCell = x;
	int availableW = 0;
	while(cells[y][nextCell] == 0){
		availableW++;
		nextCell++;
		if(nextCell >= GRID_W) break;
	}

	availableW = min(availableW, GRID_W);
	int availableH = min(GRID_H - y, GRID_H);
	int w = int(random(1, availableW + 1));
	int h = int(random(1, availableH + 1));

	w = min(w, MAX_CELL_W);
	if(!ALLOW_VERTICAL_PANELS) h = min(w, h);
	h = min(h, MAX_CELL_H);

	return new FrameSize(w, h);
}

void chooseFrames() {
	reset();
	int shapeID = 1;
	for(int y=0; y < GRID_H; y++) {
		for(int x=0; x < GRID_W; x++) {
			boolean thisCellIsEmpty = cells[y][x] == 0;
			if(!thisCellIsEmpty) continue;

			FrameSize s = chooseFrameForPosition(x, y);
			markCells(shapeID, x, y, s.width, s.height);

			Panel p = new Panel(x, y, s.width, s.height);
			panels.add(p);

			drawFrameToBuffer(p.getGraphics(), p.x, p.y);
			shapeID++;
		}
	}
}

void drawFrameToBuffer(PGraphics img, int x, int y) {
	fullResBuffer.beginDraw();
	fullResBuffer.translate(PRINT_MARGIN_PX, PRINT_MARGIN_PX);
	fullResBuffer.image(img, x * CELL_SIZE_PX, y * CELL_SIZE_PX);
	fullResBuffer.endDraw();
}

void markCells(int shapeID, int x, int y, int w, int h) {
	for(int row=y; row < y+h; row++){
		for(int col=x; col < x+w; col++){
			cells[row][col] = shapeID;
		}
	}
}

// SAVE FINAL IMAGE ---
void saveImage() {
	println("Saving ---");
	println(" - writing file...");

	String filename = getFileName();
	fullResBuffer.save("output/" + filename);

	println("DONE!");
	println("Nice job. Here's your file:");
	println(" - " + filename);
	println("");

	if(config.outputSmallSize){
		println(" - saving small size...");
		smResBuffer = fullResBuffer.copy();
		smResBuffer.resize(config.smallSize, config.smallSize);
		smResBuffer.save("output/sm_" + filename);
		println("DONE!");
		println("");
	}
}

String getFileName() {
	if(config.useSimpleFilename){
		return "image.png";
	}
	String d  = str( day()    );  // Values from 1 - 31
	String mo = str( month()  );  // Values from 1 - 12
	String y  = str( year()   );  // 2003, 2004, 2005, etc.
	String s  = str( second() );  // Values from 0 - 59
 	String min= str( minute() );  // Values from 0 - 59
 	String h  = str( hour()   );  // Values from 0 - 23

 	String date = y + "-" + mo + "-" + d + " " + h + "-" + min + "-" + s;
 	String n = PRINT_W_INCHES + "x" + PRINT_H_INCHES + " " + date + ".png";
 	return n;
}