class Config {

	boolean useServer = false;

	boolean outputSmallSize = false;
	int smallSize = 384;

	boolean autoplay = false;
	int pxDensity = 1;

	int gridW = 4;
	int gridH = 4;

	int maxCellW = 4;
	int maxCellH = 3;

	int numBackgrounds = 3;

	boolean allowVerticalPanels = true;

	// PRINT_PPI specifies both the output resolution AND the resolution of input images
	int printPPI = 600;

	float cellSizeInches = 0.75;
	float printMarginInches = 0.125;

	// How big should the comic appear on screen
	// with 600 ppi, 0.24 looks right on MPB screen
	float screenScalePcent = 0.24;

	String imgSrcFolder = "600ppi";

	boolean useSimpleFilename = false;
	boolean autosave = false;
	
	
	float coordinateScale = 1.0;

	Config() {
		// default config
	}

	Config(int pxDensity, int ppi, float printMargin, float screenScale, String imgFolder, boolean autosave) {
		this.pxDensity = pxDensity;
		this.printPPI = ppi;
		this.printMarginInches = printMargin;
		this.screenScalePcent = screenScale;
		this.imgSrcFolder = imgFolder;
		this.autosave = autosave;

		// since coordinates are based on 600 ppi images
		this.coordinateScale = printPPI / 600.0;
	}

	Config(int pxDensity, int ppi, float printMargin, float screenScale, String imgFolder, boolean autosave, boolean useSmallSize, int smallSize, boolean useSimpleFilename) {
		this.pxDensity = pxDensity;
		this.printPPI = ppi;
		this.printMarginInches = printMargin;
		this.screenScalePcent = screenScale;
		this.imgSrcFolder = imgFolder;
		this.autosave = autosave;

		this.outputSmallSize = useSmallSize;
		this.smallSize = smallSize;
		this.useSimpleFilename = useSimpleFilename;

		// since coordinates are based on 600 ppi images
		this.coordinateScale = printPPI / 600.0;
	}

}