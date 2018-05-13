// Assets class loads and caches images and associated data 

class Assets {

	boolean PRINT_IMAGE_DATA = false;
	int BLACK_BG_ID = 1;

	PImage [] backgrounds = new PImage[NUM_BACKGROUNDS];

	PImage [][][] frames;
	PImage [][][] frameBGs;

	ImageData [] imageData;
	PImage [] images;
	PImage [] imageOutlines;

	PImage horizonImage;
	PImage horizonOutline;

	Assets() {
		frames = new PImage[GRID_W][GRID_H][NUM_FRAME_VARIATIONS];
		frameBGs = new PImage[GRID_W][GRID_H][NUM_FRAME_VARIATIONS];
	}

	void loadFrames() {
		print("Loading frames... ");
		int i = 0;
		for(int w = 1; w <= MAX_CELL_W; w++){
			for(int h = 1; h <= MAX_CELL_H; h++){
				if(h > MAX_CELL_H) continue;

				for(int v = 1; v <= NUM_FRAME_VARIATIONS; v++){
					String imgName = w + "x" + h + "-" + v + ".png";
					PImage f = loadImage(IMG_SRC_FOLDER + "/frames/" + imgName);
					f.pixelDensity = PX_DENSITY;
					frames[w-1][h-1][v-1] = f;

					PImage bg = loadImage(IMG_SRC_FOLDER + "/frameBGs/" + imgName);
					bg.pixelDensity = PX_DENSITY;
					frameBGs[w-1][h-1][v-1] = bg;
					i++;
				}
			}
		}
		println("done: " + i);
	}

	PImage getRandomBackground() {
		int index = int(random(0, NUM_BACKGROUNDS));
		if(backgrounds[index] == null){
			backgrounds[index] = loadImage(IMG_SRC_FOLDER + "/backgrounds/bg" + (index+1) + ".png");
			setPixelDensity(backgrounds[index]);
		}

		return backgrounds[index];
	}

	PImage getBackgroundImage(int id) {
		if(backgrounds[id] == null){
			backgrounds[id] = loadImage(IMG_SRC_FOLDER + "/backgrounds/bg" + (id+1) + ".png");
			setPixelDensity(backgrounds[id]);
		}

		return backgrounds[id];
	}

	int getRandomBackgroundId() {
		return int(random(0, NUM_BACKGROUNDS));
	}

	boolean shouldUseHorizonForImageId(int id) {
		return imageData[id].useHorizon;
	}

	Range getHorizonRangeForImageId(int id) {
		return imageData[id].horizonRange;
	}

	int getRandomImageIdForPanelSize(int w, int h){
		int minW = 0;
		int minH = 0;
		int id;

		do {
			id = int(random(0, images.length));
			minW = imageData[id].minWidth;
			minH = imageData[id].minHeight;
		} while(w < minW || h < minH);

		return id;
	}

	String getNameForImageId(int id) {
		return imageData[id].filename;
	}

	String getAnchorForImageId(int id) {
		return imageData[id].anchor;
	}

	PImage getRandomImage() {
		int index = int(random(0, images.length));
		return getImageForId(index);
	}

	PImage getImageForId(int id) {
		if(images[id] == null) {
			cacheImage(id);
		}
		return images[id];
	}

	PImage getOutlineForImageId(int id) {
		return imageOutlines[id];
	}

	Frame getFocalAreaForImageId(int id) {
		return imageData[id].focalArea;
	}

	int getRandomImageId() {
		return int(random(0, images.length));
	}

	void cacheImage(int index) {
		String imageName = imageData[index].filename;
		images[index] = loadImage(IMG_SRC_FOLDER + "/images/" + imageName);
		setPixelDensity(images[index]);
		imageOutlines[index] = loadImage(IMG_SRC_FOLDER + "/imageOutlines/" + imageName);
		setPixelDensity(imageOutlines[index]);
		// println("cacheImage: " + imageName);
	}

	void loadImageData() {
		println("loadImageData");

		Table table = loadTable("assets.csv", "header");
		int numImages = table.getRowCount();
		images = new PImage[numImages];
		imageOutlines = new PImage[numImages];

		imageData = new ImageData[numImages];

		int id = 0;
		for(TableRow row : table.rows()) {

			String filename = row.getString("filename");
			if(filename.length() < 1) {
				println(" - ERROR: missing filename for row: " + id);
				exit();
			}
			if(PRINT_IMAGE_DATA) println("image id: " + id);
			String focalAreaStr = row.getString("focalArea");
			Frame focalArea = null;
			if(focalAreaStr.length() > 0){
				focalArea = new Frame(focalAreaStr, PX_DENSITY);
			}

			ImageData imgData = new ImageData(filename, focalArea,
				row.getInt("minWidth"), row.getInt("minHeight"), row.getString("anchor"),
				boolean(row.getInt("useHorizon")),
				row.getInt("horizonMin") / PX_DENSITY, row.getInt("horizonMax") / PX_DENSITY);

			imgData.scale(config.coordinateScale);

			if(PRINT_IMAGE_DATA) println(imgData.description());
			imageData[id] = imgData;
			id++;
		}

		horizonImage = loadImage(IMG_SRC_FOLDER + "/images/horizon.png");
		setPixelDensity(horizonImage);
		horizonOutline = loadImage(IMG_SRC_FOLDER + "/imageOutlines/horizon.png");
		setPixelDensity(horizonOutline);


	}

	void setPixelDensity(PImage img) {
		img.pixelDensity = PX_DENSITY;
		img.width /= PX_DENSITY;
		img.height /= PX_DENSITY;
	}

}