// data structure for defining a simple frame

class Frame {
	int width = 0;
	int height = 0;
	int x = 0;
	int y = 0;

	Frame(int x, int y, int w, int h, int pixelDensity){
		this.x = x / pixelDensity;
		this.y = y / pixelDensity;
		width = w / pixelDensity;
		height = h / pixelDensity;
	}

	Frame(JSONObject obj, int pixelDensity) {
		this.x = obj.getInt("x") / pixelDensity;
		this.y = obj.getInt("y") / pixelDensity;
		this.width = obj.getInt("width") / pixelDensity;
		this.height = obj.getInt("height") / pixelDensity;
	}

	Frame(String coordString, int pixelDensity){
		int[] coords = int(split(coordString, ','));
		if(coords.length == 4){
			this.x = int(coords[0] / pixelDensity);
			this.y = int(coords[1] / pixelDensity);
			this.width = int(coords[2] / pixelDensity);
			this.height = int(coords[3] / pixelDensity);
		} else {
			println("- ERROR: not enough coordinates in focal area data");
		}
	}

	void scale(float scale) {
		this.x *= scale;
		this.y *= scale;
		this.width *= scale;
		this.height *= scale;
	}

	String description() {
		return "x: " + x + ", y: " + y + ", w: " + width + ", h: " + height;
	}
}

class FrameSize {
	int width = 0;
	int height = 0;

	FrameSize(int w, int h){
		width = w;
		height = h;
	}
}