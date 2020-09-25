# random-comic
A Processing app to generate random comics.
![Comic](sampleComics.gif)

## Getting Started

### Basics
Run `build.pde` in [Processing 3](https://processing.org/download/).

While the app is running, press `r` to randomize your comic. This will change the layout as well as the selected images.  
Click any panel to change the panel image without altering the comic layout.

To save your image press the `s` key.  
Images are saved to the `output` folder.

### Adding Images
Images should be saved as transparent PNG files in the `images` folder.  
Each image needs to have a identically sized and named outline image saved to the `imageOutlines` folder. These white outlines are placed behind images when a black panel background is used.

The default resolution for both input and output is 600 ppi. Panels are sized in increments of 0.75 inches. So a 1x1 image would be 450 x 450px.  
The image resolution can be adjusted via the Config file.

Each image needs to have an entry in the `assets.csv` file. The minimum required data is the filename, but you can also specify a focal area (in pixels, based on a 600 ppi image), minimum number of panels for width and height, which side of the panel (if any) the image should be anchored to, whether or not the image uses a horizon line, and minimum and maximum y positions for the horizon line (in pixels, based on a 600 ppi image).

### Customization
Customize the comic features by editing variables in the `Config.pde` file.  
You can create and customize instances of `Config` to make it easier to switch between versions (for quickly changing resolution and margins for example).

If you want panels larger than 4x4, you'll need to draw your own frames for them.

## Troubleshooting

#### Error: "mask() can only be used with an image that's the same size"
This error occurs when running the project configured for a 2x display on 1x display.

The easiest fix is to change line 14 in `build.pde` from  
`Config CONFIG_FULL_RES = new Config(2, 600, 0.125, 0.24, "600ppi", false);`  
to  
`Config CONFIG_FULL_RES = new Config(1, 600, 0.125, 0.24, "600ppi", false);`

The first argument for Config is the pixel density.
See the [Config.pde](https://github.com/cadin/random-comic/blob/master/build/Config.pde) file for more configuration options.

## License

This project is licensed under the Unlicense - see the [LICENSE](LICENSE) file for details.
