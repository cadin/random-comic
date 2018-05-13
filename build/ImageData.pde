class ImageData {

	String filename;
	Frame focalArea = null;
	int minWidth = 0;
	int minHeight = 0;
	String anchor = "none";
	boolean useHorizon = true;
	Range horizonRange = new Range(0,0);

	ImageData(
		String filename, Frame focalArea,
		int minWidth, int minHeight, String anchor,
		boolean useHorizon,
		int horizonMin, int horizonMax) {

		this.filename = filename;
		this.focalArea = focalArea;
		this.minWidth = minWidth;
		this.minHeight = minHeight;
		this.anchor = anchor;

		this.useHorizon = useHorizon;
		this.horizonRange = new Range(horizonMin, horizonMax);
	}

	void scale(float scale) {
		if(this.focalArea != null) this.focalArea.scale(scale);
		this.horizonRange.scale(scale);
	}

	String description() {
		String str = filename;
		if(focalArea != null){
			str += "\n - " + focalArea.description();
		} else {
			str += "\n - no focal area";
		}
		str += "\n - " + minWidth;
		str += "\n - " + minHeight;
		str += "\n - " + anchor;
		return str;
	}

}