// each Panel can construct itself, given a width and height
// returns composite image from getGraphics() to add to comic layout

class Panel {

	int FRAME_MARGIN_PX = int(30 * config.coordinateScale);
	int FRAME_MARGIN_PT = FRAME_MARGIN_PX / PX_DENSITY;

	int x = 0;
	int y = 0;
	int width = 0;
	int height = 0;

	int ptWidth = 0;
	int ptHeight = 0;

	PImage _bgImg;
	PGraphics _contentGfx;
	PImage _frameImg;
	PGraphics _compositeGfx;

	Panel(int x, int y, int w, int h) {
		this.x = x;
		this.y = y;
		this.width = w;
		this.height = h;

		ptWidth = w * CELL_SIZE_PX;
		ptHeight = h * CELL_SIZE_PX;

		pixelWidth = ptWidth * PX_DENSITY;
		pixelHeight = ptHeight * PX_DENSITY;

		chooseGraphics();
		compositePanel(width, height);
	}

	PGraphics getGraphics() {
		return _compositeGfx;
	}

	PVector positionFocalAreaInPanel(Frame focalArea, int panelW, int panelH) {
		int px = int(random(FRAME_MARGIN_PT, panelW - focalArea.width - FRAME_MARGIN_PT));
		int py = int(random(FRAME_MARGIN_PT, panelH - focalArea.height - FRAME_MARGIN_PT));
		return new PVector(px - focalArea.x, py - focalArea.y);
	}

	// PVector positionFocalAreaInPanelBelowPosition(Frame focalArea, int panelW, int panelH, PVector, pos){

	// }

	PVector adjustPositionForAnchorInPanel(PVector pos, String anchor, FrameSize imgSize, FrameSize panelSize) {
		switch(anchor){
			case "top":
				pos.y = min(pos.y, 0);
				break;
			case "right":
				pos.x = max(panelSize.width - imgSize.width, pos.x);
				break;
			case "bottom":
				pos.y = max(panelSize.height - imgSize.height, pos.y);
				break;
			case "left":
				pos.x = min(pos.x, 0);
				break;
		}

		return pos;
	}

	int positionHorizonForImageId(int imgId, float imgY, int frameHeight) {
		Range range = assets.getHorizonRangeForImageId(imgId);
		int min = range.min;
		int max = range.max;

		// 0 in range means use frame bounds
		if(min != 0){
			min += imgY;
		}

		if(max == 0) {
			max = frameHeight;
		} else {
			max += imgY;
		}

		int pos = int(random(min, max));
		return pos;
	}

	PGraphics chooseContent() {

		PGraphics gfx = createGraphics(ptWidth, ptHeight);
		PGraphics imageGfx = createGraphics(ptWidth, ptHeight);
		PGraphics outlineGfx = createGraphics(ptWidth, ptHeight);

		outlineGfx.beginDraw();
		outlineGfx.background(255, 0);
		outlineGfx.endDraw();

		int numImages = 1;
		int horizonPos = 0;
		boolean useHorizon = false;
		boolean useOutlines = false;
		float prevBottomY = 0;
		float prevTopY = 0;

		for(int i=0; i < numImages; i++){
			int imageId = assets.getRandomImageIdForPanelSize(width, height);
			// print(" - " + assets.getNameForImageId(imageId));
			PImage img = assets.getImageForId(imageId);
			PImage imgOutline = assets.getOutlineForImageId(imageId);
			Frame focalArea = assets.getFocalAreaForImageId(imageId);

			PVector pos;
			if(focalArea == null){
				// no focalArea, use the full image
				// focalArea = new Frame(0,0, img.pixelWidth, img.pixelHeight, PX_DENSITY);

				// no focalArea, center the image
				int px = int((gfx.width / 2 - img.width / 2) );
				int py = int((gfx.height / 2 - img.height / 2));
				pos = new PVector(px, py);

			} else {
				pos = positionFocalAreaInPanel(focalArea, gfx.width, gfx.height);
			}
			String anchor = assets.getAnchorForImageId(imageId);
			if(anchor != null){
				FrameSize imgSize = new FrameSize(img.width, img.height);
				FrameSize panelSize = new FrameSize(gfx.width, gfx.height);

				pos = adjustPositionForAnchorInPanel(pos, anchor, imgSize, panelSize);
			}

			horizonPos = positionHorizonForImageId(imageId, pos.y, ptHeight);
			useHorizon = assets.shouldUseHorizonForImageId(imageId);

			if(useHorizon && (horizonPos < 20 * config.coordinateScale || horizonPos > gfx.height - (20 * config.coordinateScale))){
				// println(useHorizon, horizonPos, 20 * config.coordinateScale, config.coordinateScale);
				useHorizon = false;
				// println(useHorizon, horizonPos, 20 * config.coordinateScale, (gfx.height - (20 * config.coordinateScale, config.coordinateScale);
			}

			prevTopY = pos.y;
			prevBottomY = pos.y + img.height;

			boolean flipImage = false; //random(1) > 0.5;

			imageGfx.beginDraw();
			if(flipImage){
				imageGfx.scale(-1, 1);
				imageGfx.translate(-gfx.width, 0);
			}
			imageGfx.image(img, pos.x, pos.y);
			imageGfx.endDraw();

			outlineGfx.beginDraw();
			if(flipImage) {
				outlineGfx.scale(-1, 1);
				outlineGfx.translate(-gfx.width, 0);
			}
			outlineGfx.image(imgOutline, pos.x, pos.y);
			outlineGfx.endDraw();


		}

		int bgId = assets.getRandomBackgroundId();
		useOutlines = (bgId == assets.BLACK_BG_ID);
		PImage bg = assets.getBackgroundImage(bgId);

		int bgPosX = int(random(gfx.width - bg.width, 0));
		int bgPosY = int(random(gfx.height - bg.height, 0));

		gfx.beginDraw();
		gfx.image(bg, bgPosX, bgPosY);
		if(useOutlines) gfx.image(outlineGfx, 0, 0);
		if(useHorizon) {
			if(useOutlines) gfx.image(assets.horizonOutline, 0, horizonPos);
			gfx.image(assets.horizonImage, 0, horizonPos);
		}
		gfx.image(imageGfx, 0, 0);
		gfx.endDraw();
		return gfx;
	}

	void recompose() {
		chooseGraphics();
		compositePanel(width, height);
	}

	void chooseFrame(int w, int h) {
		int variation = int(random(1, NUM_FRAME_VARIATIONS));
		_frameImg = assets.frames[w-1][h-1][variation-1];
		_bgImg = assets.frameBGs[w-1][h-1][variation-1];
	}

	void chooseGraphics() {
		chooseFrame(width, height);
		_contentGfx = chooseContent();
	}

	void compositePanel(int w, int h) {
		PGraphics fullImg = chooseContent();
		PImage img = fullImg.get();

		img.mask(_bgImg);

		_compositeGfx = createGraphics(ptWidth, ptHeight);
		_compositeGfx.beginDraw();
		_compositeGfx.image(img, 0, 0, ptWidth, ptHeight);
		_compositeGfx.image(_frameImg, 0, 0);
		_compositeGfx.endDraw();
	}

}