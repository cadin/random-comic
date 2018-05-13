// simple structure for specifying an integer range

class Range {
	int min;
	int max;

	Range(int min, int max) {
		this.min = min;
		this.max = max;
	}

	void scale(float scale) {
		this.min = ceil(this.min * scale);
		this.max = ceil(this.max * scale);
	}

	String description() {
		return "min: " + min + ", max: " + max;
	}
}