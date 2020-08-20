import processing.serial.*;
import uibooster.*;
import uibooster.components.*;
import uibooster.model.*;
import uibooster.model.formelements.*;
import uibooster.utils.*;
import java.util.Arrays; 

Serial port; // Create object from Serial class
int maxnsamp = 1200;
int[] values = new int[maxnsamp];
int maxval = 4096;

int w_scrn = 900;
int h_scrn = 600;
// sets the dimensions of the window showing the traces
int x_scrn = 60;
int y_scrn = 60;

//trigger status
int x_ts = x_scrn + w_scrn + 50;
int y_ts = y_scrn;
int w_ts = 50;
int h_ts = 20;
int trig_mode = 0; //0 means in run mode, 1 means in shot mode
int trig_level = maxval / 2;
int trig_offset = 100;
boolean doread = false;

//channels
int x_ch = x_ts;
int y_ch = y_ts + 4 * h_ts;
int w_ch = w_ts;
int h_ch = h_ts;
int maxnchan = 6;
int nchan = 1;
int fchan = 0;
int tchan = maxnchan;
int tmode = 0;
//0=off 1=on 2=up 3=down
int chanstat[] = {1, 0, 0, 0, 0, 0};
int nextchan[] = {0, 0, 0, 0, 0, 0};

// Colour of channels
color[] chan_color = {
	color(230, 25, 75),	 // red
	color(245, 130, 48), // orange
	color(255, 225, 25), // yellow
	color(210, 245, 60), // lime
	color(70, 240, 240), // cyan
	color(240, 50, 230), // magenta
};

//time bar
int x_tb = x_ch;
int y_tb = y_ch + 8 * h_ch;
int w_tb = w_ch;
int h_tb = h_ch;
int[] tbms = {2, 5, 10, 20, 50, 100};
int[] ADCPS = {32, 64, 128, 128, 128, 128};
int[] skipsamp = {1, 1, 1, 2, 5, 10};
int ntbval = tbms.length;
int tbval = 0;

//nsamp bar
int x_ns = x_tb;
int y_ns = y_tb + (ntbval + 2) * h_tb;
int w_ns = w_tb;
int h_ns = h_tb;
int[] ns = {1200, 600, 300};
int nns = ns.length;
int ins = 0;
int nsamp = ns[ins];

//vertical bar
int x_vb = x_ns;
int y_vb = y_ns + (nns + 2) * h_ch;
int w_vb = w_ns;
int h_vb = h_ns;
int ivb = 0;
float Vmax[] = {5.0};
float Vdiv[] = {1.0};
int nVdiv = Vdiv.length;

//x cursor bar
int x_xcb = x_vb - w_vb / 3;
int y_xcb = y_vb + (nVdiv + 2) * h_ch;
int w_xcb = 50 + 35;
int h_xcb = h_vb;
int xcb[] = {1};
int nxcb = xcb.length;

//y cursor bar
int x_ycb = x_xcb;
int y_ycb = y_xcb + (nxcb + 2) * h_ch;
int w_ycb = w_xcb;
int h_ycb = h_xcb;
int ycb[] = {1};

//pulser - everything in units of 1/8th of microsecond
int x_pb = x_scrn + 50;
int y_pb = y_scrn + h_scrn + 40;
int w_pb = w_scrn - 80;
int h_pb = h_ch;
int pls_period[] = {16, 40, 80, 160, 400, 800, 1600, 4000, 8000, 16000, 40000, 10000, 20000, 50000, 12500, 25000, 62500};
int pls_prescale[] = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 8, 8, 8, 64, 64, 64};
int pls_len[][] = {
	{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15},
	{1, 2, 4, 6, 8, 12, 16, 20, 24, 28, 32, 34, 36, 38, 39},
	{1, 2, 4, 8, 16, 24, 32, 40, 48, 56, 64, 72, 76, 78, 79},
	{1, 2, 4, 8, 16, 32, 48, 80, 112, 128, 144, 152, 156, 158, 159},
	{1, 2, 4, 8, 20, 40, 80, 200, 320, 360, 380, 392, 396, 398, 399},
	{2, 4, 8, 16, 40, 80, 160, 400, 640, 720, 760, 784, 792, 796, 798},
	{4, 8, 16, 40, 80, 160, 320, 800, 1280, 1440, 1520, 1568, 1584, 1592, 1596},
	{10, 20, 40, 80, 200, 400, 800, 2000, 3200, 3600, 3800, 3920, 3960, 3980, 3990},
	{20, 40, 80, 160, 400, 800, 1600, 4000, 6400, 7200, 7600, 7840, 7920, 7960, 7980},
	{40, 80, 160, 400, 800, 1600, 3200, 8000, 12800, 14400, 15200, 15680, 15840, 15920, 15960},
	{100, 200, 400, 800, 2000, 4000, 8000, 20000, 32000, 36000, 38000, 39200, 39600, 39800, 39900},
	{25, 50, 100, 200, 500, 1000, 2000, 5000, 8000, 9000, 9500, 9800, 9900, 9950, 9975},
	{50, 100, 200, 500, 1000, 2000, 5000, 10000, 16000, 18000, 19000, 19600, 19800, 19900, 19950},
	{125, 250, 500, 1000, 2500, 5000, 10000, 25000, 40000, 45000, 48000, 49000, 49500, 49750, 49875},
	{25, 50, 125, 250, 500, 1250, 2500, 6250, 10000, 11250, 12000, 12250, 12375, 12450, 12475},
	{50, 100, 250, 500, 1000, 2500, 5000, 12500, 20000, 22500, 24000, 24500, 24750, 24900, 24950},
	{125, 250, 625, 1250, 2500, 6250, 12500, 31250, 50000, 56250, 60000, 61250, 61875, 62250, 62375}};
int pls_np = pls_period.length;
int pls_nl = pls_len[0].length;
int pls_ip = 8;
int pls_il = 7;

PFont f;
PFont f2;
CursorBars XY;
RectangularButton Ohmmeter;

RectangularButton a0Button;
RectangularButton a1Button;
RectangularButton a2Button;
RectangularButton a3Button;
RectangularButton a4Button;
RectangularButton a5Button;
RectangularButton Scope;

// state variable of the program.
int STATE = 1;
float ref_resistor; 
PImage pins;
ButtonCollection BC;
boolean configured = false;

void setup()
{	
	// PinButton a0Button = new PinButton(x_scrn, y_scrn, 10, 10);
	PinButton[] pinButtons = {new PinButton(x_scrn+19, y_scrn+70, 10, 10),
							  new PinButton(x_scrn+19+30, y_scrn+70, 10, 10),
							  new PinButton(x_scrn+19+60, y_scrn+70, 10, 10),
							  new PinButton(x_scrn+19+90, y_scrn+70, 10, 10),
							  new PinButton(x_scrn+19+120, y_scrn+70, 10, 10),
							  new PinButton(x_scrn+19+150, y_scrn+70, 10, 10),
	};

	BC = new ButtonCollection(pinButtons);
	Scope = new RectangularButton(x_scrn, y_ycb + (nxcb + 2) * h_ch, w_ycb, h_ycb, "Scope");

	pins = loadImage("./data/pins.png");
	f = loadFont("muktinarrow-16.vlw");
	f2 = createFont("DSEG7Modern-Regular.ttf", 80);
	size(1100, 800);
	background(0);

	drawtb(); // trigger settings bar
	drawvb(); // v/div bar
	drawts(); // ms/div bar
	drawns(); // fraw sampling rate bar
	drawch(); // draw channel selection
	drawpb(); // draw pulser bar

	HScrollbar xc1 = new HScrollbar(x_scrn - 6, y_scrn - 16, w_scrn + 12, 12, 150, 1, color(255, 250, 200), color(255, 200, 200));
	HScrollbar xc2 = new HScrollbar(x_scrn - 6, y_scrn - 16 - 12, w_scrn + 12, 12, 100, 1, color(255, 250, 200), color(255, 200, 200));
	XCursorBar XC = new XCursorBar(xc1, xc2);

	VScrollbar yc1 = new VScrollbar(x_scrn - 22, y_scrn - 6, 12, h_scrn + 12, 150, 1, color(170, 255, 195), color(170, 200, 195));
	VScrollbar yc2 = new VScrollbar(x_scrn - 22 - 12, y_scrn - 6, 12, h_scrn + 12, 100, 1, color(170, 255, 195), color(170, 200, 195));
	YCursorBar YC = new YCursorBar(yc1, yc2);

	XY = new CursorBars(XC, YC);

	Ohmmeter = new RectangularButton(x_ycb, y_ycb + (nxcb + 2) * h_ch, w_ycb, h_ycb, "Ohmmeter");

	String[] options = {"Try again", "Auto connect", "Exit"};
	boolean end = false;
	int state = 1;

	if (Serial.list().length == 0){
		new UiBooster().showErrorDialog("No serial device found. Remember to connect your Arduino.\nThe program will now exit.", "ERROR");
		exit();
		return;
	}
	
	while (end == false)
	{
		switch (state)
		{
		case 1:
			String selection = new UiBooster().showSelectionDialog(
				"Choose the serial port that connects the\nArduino to this computer:",
				"Connect",
				Serial.list());
			try
			{
				port = new Serial(this, selection, 115200);
				new UiBooster().showInfoDialog("Successfuly connected to" + selection + ".");
				end = true;
			}
			catch (Exception e)
			{
				new UiBooster().showErrorDialog("Failed to connect to " + selection + ".\n" + e, "ERROR");
				state = 2;
			}
			break;

		case 2:
			String next = new UiBooster().showSelectionDialog(
				"What would you like to do?",
				"Next Step",
				options);

			if (next == options[0])
			{
				state = 1;
			}
			else if (next == options[1])
			{
				state = 3;
			}
			else if (next == options[2])
			{
				state = 4;
			}
			else {
				state = 4;
			}
			break;

		case 3:
			for (int i = 0; i < Serial.list().length; i += 1)
			{
				try
				{
					port = new Serial(this, Serial.list()[i], 115200);
				}
				catch (Exception e)
				{
					e.printStackTrace();
					continue;
				}
				new UiBooster().showInfoDialog("Successfuly connected to" + Serial.list()[i] + ".\nManually select the correct port traces do not vary.");
				break;
			}
			try
			{
				assert port != null;
				end = true;
			}
			catch (AssertionError e)
			{
				new UiBooster().showErrorDialog("Auto connect failed.", "ERROR");
				state = 2;
			}
			break;

		case 4:
			end = true;
			exit();
			break;
		}
	}
}

void keyPressed()
{

	switch (STATE) {
		case 1:
			int k = keyCode;

			if (k == ' ')
			{
				PImage snapshot = get();
				String name = "PHYS159_" + hour() + ";" + minute() + ";" + second();
				snapshot.save(name + ".png");

				printtraces(name);
				
				new UiBooster().showInfoDialog("Screenshot and channel data has been saved.");

				background(0);
				redraw_all();
			}

			int last_selected_cursor = XY.x_or_y;
			int c1_or_c2 = XY.one_or_two;

			if (last_selected_cursor == 2)
			{
				if (k == UP | k == 'W')
				{
					XY.Y.move(c1_or_c2, true);
				}
				else if (k == DOWN | k == 'S')
				{
					XY.Y.move(c1_or_c2, false);
				}
			}
			else
			{
				if (k == LEFT | k == 'A')
				{
					XY.X.move(c1_or_c2, true);
				}
				else if (k == RIGHT | k == 'D')
				{
					XY.X.move(c1_or_c2, false);
				}
			}
		break;

		case 2:
		break;

		case 3:
		break;
	}
	
}

//draw the pulser bar
void drawpb()
{
	fill(0);
	stroke(0);
	rect(x_pb + w_pb, y_pb, 50.0, 4 * h_pb);
	fill(255);
	stroke(0);
	textFont(f, 16);
	textAlign(LEFT);
	text("Pin 9: square wave signal settings", x_scrn, y_pb - 2);
	textAlign(RIGHT);
	text("period", x_pb - 2, y_pb + h_tb - 2);
	text("freq", x_pb - 2, y_pb + 2 * h_tb - 2);
	text("length", x_pb - 2, y_pb + 3 * h_tb - 2);
	text("dut cyc", x_pb - 2, y_pb + 4 * h_tb - 2);
	textAlign(LEFT);
	text("ms", x_pb + w_pb + 2, y_pb + h_tb - 2);
	text("kHz", x_pb + w_pb + 2, y_pb + 2 * h_tb - 2);
	float t = (pls_period[pls_ip] * pls_prescale[pls_ip]) / 8000.0;
	if (t > 1.0)
		text("ms", x_pb + w_pb + 2, y_pb + 3 * h_tb - 2);
	else
		text("us", x_pb + w_pb + 2, y_pb + 3 * h_tb - 2);
	textAlign(CENTER);
	for (int i = 0; i < pls_np; i++)
	{
		fill(0);
		stroke(255);
		if (i == pls_ip)
			fill(128);
		rect(x_pb + i * w_pb / pls_np, y_pb, w_pb / pls_np, h_pb);
		rect(x_pb + i * w_pb / pls_np, y_pb + h_pb, w_pb / pls_np, h_pb);
		fill(255);
		float period = (pls_period[i] * pls_prescale[i]) / 8000.0;
		text(nf(period, 0, 0), x_pb + (i + 0.5) * w_pb / pls_np, y_pb + h_pb - 2);
		float freq = 1.0 / period;
		text(nf(freq, 0, 0), x_pb + (i + 0.5) * w_pb / pls_np, y_pb + 2 * h_pb - 2);
	}
	for (int i = 0; i < pls_nl; i++)
	{
		fill(0);
		stroke(255);
		if (i == pls_il)
			fill(128);
		rect(x_pb + i * w_pb / pls_nl, y_pb + 2 * h_pb, w_pb / pls_nl, h_pb);
		rect(x_pb + i * w_pb / pls_nl, y_pb + 3 * h_pb, w_pb / pls_nl, h_pb);
		fill(255);
		stroke(255);
		float len = (pls_len[pls_ip][i] * pls_prescale[pls_ip]) / 8000.0;
		if (t <= 1.0)
			len *= 1e3;
		text(nf(len, 0, 0), x_pb + (i + 0.5) * w_pb / pls_nl, y_pb + 3 * h_pb - 2);
		float dut = 1.0 * pls_len[pls_ip][i] / pls_period[pls_ip];
		text(nf(dut, 0, 0), x_pb + (i + 0.5) * w_pb / pls_nl, y_pb + 4 * h_pb - 2);
	}
}

//draw the timebar
void drawtb()
{
	fill(255);
	stroke(255);
	textFont(f, 16);
	textAlign(CENTER);
	text("ms/div", x_tb + w_tb / 2, y_tb - 2);
	for (int i = 0; i < ntbval; i++)
	{
		fill(0);
		stroke(255);
		if (i == tbval)
			fill(128);
		rect(x_tb, y_tb + i * h_tb, w_tb, h_tb);
		fill(255);
		stroke(255);
		text(tbms[i], x_tb + 0.5 * w_tb, y_tb + (i + 1) * h_tb - 2);
	}
}

//draw the nsamp bar
void drawns()
{
	fill(255);
	stroke(255);

	textFont(f, 16);
	textAlign(CENTER);
	text("nsamp", x_ns + w_ns / 2, y_ns - 2);
	for (int i = 0; i < nns; i++)
	{
		fill(0);
		stroke(255);
		if (i == ins)
			fill(128);
		rect(x_ns, y_ns + i * h_ns, w_ns, h_ns);
		fill(255);
		stroke(255);
		text(ns[i], x_ns + 0.5 * w_ns, y_ns + (i + 1) * h_ns - 2);
	}
}

//draw the bar for the vertical scale
void drawvb()
{
	fill(255);
	stroke(255);

	textFont(f, 16);
	textAlign(CENTER);
	text("V/div", x_vb + w_vb / 2, y_vb - 2);
	fill(0);
	stroke(255);
	if (ivb == 0)
		fill(128);
	rect(x_vb, y_vb + 0 * h_vb, w_vb, h_vb);
	fill(255);
	stroke(255);
	text("1.0", x_vb + 0.5 * w_vb, y_vb + 1 * h_tb - 2);
	// fill(0); stroke(255);
	// if (ivb==1)fill(128);
	// rect(x_vb, y_vb+1*h_vb, w_vb, h_vb);
	// fill(255); stroke(255);
	// text("0.2", x_vb+0.5*w_vb, y_vb+2*h_tb-2);
}

// draw the trigger status
void drawts()
{
	fill(255);
	stroke(255);

	textFont(f, 16);
	textAlign(CENTER);
	text("trigger", x_ts + w_ts / 2, y_ts - 2);
	fill(0);
	stroke(255);
	if (trig_mode == 0)
		fill(128);
	rect(x_ts, y_ts, w_ts, h_ts);
	fill(255);
	stroke(255);
	text("run", x_ts + 0.5 * w_ts, y_ts + h_ts - 3);
	fill(0);
	stroke(255);
	if (trig_mode == 1)
		fill(128);
	rect(x_ts, y_ts + h_ts, w_ts, h_ts);
	fill(255);
	stroke(255);
	text("shot", x_ts + 0.5 * w_ts, y_ts + 2 * h_ts - 3);
}

//draw the channel selection
void drawch()
{
	fill(255);
	stroke(255);

	textFont(f, 16);
	textAlign(CENTER);
	text("channels", x_ch + w_ch / 2, y_ch - 2);
	for (int ichan = 0; ichan < maxnchan; ichan++)
	{
		fill(0);
		stroke(255);
		if (chanstat[ichan] > 0)
			fill(128);
		rect(x_ch, y_ch + ichan * h_ch, w_ch / 3, h_ch);
		fill(chan_color[ichan]);
		stroke(255);
		text(ichan, x_ch + w_ch / 6.0, y_ch + (ichan + 1) * h_ch - 3);
		fill(0);
		stroke(255);
		if (chanstat[ichan] == 2)
			fill(128);
		rect(x_ch + w_ch / 3.0, y_ch + ichan * h_ch, w_ch / 3, h_ch);
		fill(255);
		stroke(chan_color[ichan]);
		line(x_ch + w_ch * (1.0 / 2.0), y_ch + (ichan)*h_ch + 3, x_ch + w_ch * (1.0 / 2.0), y_ch + (ichan + 1) * h_ch - 3);
		line(x_ch + w_ch * (1.0 / 2.0), y_ch + (ichan)*h_ch + 3, x_ch + w_ch * (1.0 / 2.0) + 4, y_ch + (ichan)*h_ch + 3);
		line(x_ch + w_ch * (1.0 / 2.0), y_ch + (ichan + 1) * h_ch - 3, x_ch + w_ch * (1.0 / 2.0) - 4, y_ch + (ichan + 1) * h_ch - 3);
		fill(0);
		stroke(255);
		if (chanstat[ichan] == 3)
			fill(128);
		rect(x_ch + w_ch / 1.5, y_ch + ichan * h_ch, w_ch / 3, h_ch);
		fill(255);
		stroke(chan_color[ichan]);
		line(x_ch + w_ch * (5.0 / 6.0), y_ch + (ichan)*h_ch + 3, x_ch + w_ch * (5.0 / 6.0), y_ch + (ichan + 1) * h_ch - 3);
		line(x_ch + w_ch * (5.0 / 6.0), y_ch + (ichan)*h_ch + 3, x_ch + w_ch * (5.0 / 6.0) - 4, y_ch + (ichan)*h_ch + 3);
		line(x_ch + w_ch * (5.0 / 6.0), y_ch + (ichan + 1) * h_ch - 3, x_ch + w_ch * (5.0 / 6.0) + 4, y_ch + (ichan + 1) * h_ch - 3);
	}
}

MyResult drawscrn()
{
	//trigger level
	// draws a black box to cover up the previous cursor
	fill(0);
	stroke(0);
	rect(x_scrn - 10, y_scrn, 10, h_scrn);

	fill(255);
	stroke(60, 180, 75);
	// this is the y-coordinate of the horizontal trigger
	float y_tl = y_scrn + h_scrn - trig_level / (1.0 * maxval) * h_scrn;
	// drawing the trigger level
	line(x_scrn - 10, y_tl, x_scrn, y_tl);
	line(x_scrn - 5, y_tl - 4, x_scrn, y_tl);
	line(x_scrn - 5, y_tl + 4, x_scrn, y_tl);

	//trigger offset
	fill(0);
	stroke(0);
	rect(x_scrn, y_scrn - 10, w_scrn, 10);
	fill(255);
	stroke(255, 255, 25);
	float x_to = x_scrn + w_scrn * (1.0 * trig_offset) / (1.0 * nsamp);
	line(x_to, y_scrn - 10, x_to, y_scrn);
	line(x_to - 4, y_scrn - 4, x_to, y_scrn);
	line(x_to + 4, y_scrn - 4, x_to, y_scrn);

	//outline
	fill(0);
	stroke(255);
	rect(x_scrn, y_scrn, w_scrn, h_scrn);

	//grid
	int ndivy = int(Vmax[ivb] / Vdiv[ivb]);
	int nsdivy = 5;
	for (int i = 0; i <= ndivy; i++)
	{
		float y = y_scrn + h_scrn - i * h_scrn * Vdiv[ivb] / Vmax[ivb];
		fill(0);
		stroke(150);
		line(x_scrn, y, x_scrn + w_scrn, y); // these are horizontal lines on the grid

		for (int is = 1; is < nsdivy; is++)
		{
			y -= h_scrn * (Vdiv[ivb] / nsdivy) / Vmax[ivb];
			fill(0);
			stroke(30);
			if (y > y_scrn)
				line(x_scrn, y, x_scrn + w_scrn, y); // these are minor horizontal lines
		}
	}
	float fsamp = 16e6 / (13 * ADCPS[tbval] * skipsamp[tbval]);
	float xdivdist = 1e-3 * tbms[tbval] * fsamp * ((1.0 * w_scrn) / (1.0 * nsamp));
	int ndivx = int(w_scrn / xdivdist);
	int nsdivx = 2;
	if (nsamp == 600 && tbms[tbval] == 1.0)
		nsdivx = 5;
	if (nsamp == 600 && tbms[tbval] == 2.0)
		nsdivx = 4;
	if (nsamp == 600 && tbms[tbval] == 5.0)
		nsdivx = 5;
	if (nsamp == 600 && tbms[tbval] == 10.0)
		nsdivx = 5;
	if (nsamp == 600 && tbms[tbval] == 20.0)
		nsdivx = 4;
	if (nsamp == 600 && tbms[tbval] == 50.0)
		nsdivx = 5;
	if (nsamp == 600 && tbms[tbval] == 100.0)
		nsdivx = 5;
	if (nsamp == 300)
		nsdivx = 10;

	for (int i = 0; i <= ndivx; i++)
	{
		fill(0);
		stroke(150);
		float x = x_scrn + i * xdivdist; // the first line occurs at x = xscrn, these are major verticle lines
		line(x, y_scrn, x, y_scrn + h_scrn);
		for (int is = 1; is < nsdivx; is++)
		{
			x += xdivdist / nsdivx;
			fill(0);
			stroke(30);
			// draw minor horizontal lines
			if (x < x_scrn + w_scrn)
				line(x, y_scrn, x, y_scrn + h_scrn);
		}
	}
	return new MyResult(xdivdist, h_scrn * Vdiv[ivb] / Vmax[ivb]);
}

void getdata()
{
	//send command to arduino to readout data
	port.write(255);
	port.write(nsamp / 0x100);
	port.write(nsamp % 0x100);
	for (int i = 0; i < maxnchan; i++)
		port.write(chanstat[i]);
	for (int i = 0; i < maxnchan; i++)
		port.write(nextchan[i]);
	port.write(fchan);
	port.write(nchan);
	port.write(tchan);
	port.write(tmode);
	port.write(ADCPS[tbval]);
	port.write(skipsamp[tbval]);
	port.write(ivb);
	port.write(trig_level / 16);
	port.write(trig_offset / 0x100);
	port.write(trig_offset % 0x100);
	if (pls_prescale[pls_ip] == 1)
		port.write(1);
	if (pls_prescale[pls_ip] == 8)
		port.write(2);
	if (pls_prescale[pls_ip] == 64)
		port.write(3);
	port.write(pls_period[pls_ip] / 0x100);
	port.write(pls_period[pls_ip] % 0x100);
	port.write(pls_len[pls_ip][pls_il] / 0x100);
	port.write(pls_len[pls_ip][pls_il] % 0x100);

	//estimate the response time as the sum of the sampling time plus the time to send the data
	float sampletime = nsamp * (13 * ADCPS[tbval] * skipsamp[tbval]) / 16e3;
	float sendtime = 16.0 * nsamp / 115.2;

	delay(int((2.0 * sampletime + 1.1 * sendtime)));

	while (port.available() >= 2 * nsamp + 1)
	{
		if (port.read() == 255)
		{
			for (int isamp = 0; isamp < nsamp; isamp++)
			{
				int hsb = port.read();
				int lsb = port.read();
				values[isamp] = hsb * 64 + (lsb & 0xFF);
			}
			doread = false;
		}
	}
}

void printtraces(String name)
{

	float fsamp = 16e6 / (13 * ADCPS[tbval] * skipsamp[tbval]);
	float xdivdist = 1e-3 * tbms[tbval] * fsamp * ((1.0 * w_scrn) / (1.0 * nsamp));

	for (int ichan = 0; ichan < maxnchan; ichan++)
	{
		doread = true;
		getdata();

		if (chanstat[ichan] == 0)
			continue;
		PrintWriter output = createWriter(name + "_C" + ichan + ".csv");
		output.println("t, V");
		int i = fchan;
		for (int isamp = 0; isamp < nsamp; isamp++)
		{
			if (i == ichan)
			{
				float x = tbms[tbval] * (isamp * (w_scrn / (1.0 * nsamp))) / xdivdist;
				float y = (values[isamp] + 2.0) * (5.00 / (1.0 * maxval));
				output.println(x + ", " + y);
			}
			i = nextchan[i];
		}
		output.flush();
		output.close();
	}
}

void drawtraces()
{
	//draw the traces
	strokeWeight(1.2);
	for (int ichan = 0; ichan < maxnchan; ichan++)
	{
		if (chanstat[ichan] == 0)
			continue;

		fill(255);

		stroke(chan_color[ichan]);

		float xprev = 0.0;
		float yprev = 0.0;
		int i = fchan;
		for (int isamp = 0; isamp < nsamp; isamp++)
		{
			if (i == ichan)
			{
				float x = x_scrn + isamp * (w_scrn / (1.0 * nsamp));
				float y = y_scrn + h_scrn - values[isamp] * (h_scrn / (1.0 * maxval));

				if (isamp >= nchan)
				{
					// stroke(255);
					line(xprev, yprev, x, y);
				}
				xprev = x;
				yprev = y;
			}
			i = nextchan[i];
		}
	}
	strokeWeight(1);
}

void redraw_all(){
	drawtb(); // trigger settings bar
	drawvb(); // v/div bar
	drawts(); // ms/div bar
	drawns(); // fraw sampling rate bar
	drawch(); // draw channel selection
	drawpb(); // draw pulser bar
}

void draw()
{
	switch (STATE){
		case 1:
			fill(0);
			stroke(0);
			rect(0, 0, w_scrn, y_scrn - 30);
			rect(x_scrn, y_scrn + h_scrn, w_scrn, 10);

			MyResult spacings = drawscrn();
			if (trig_mode == 0 || doread)
				getdata();
			drawtraces();

			XY.update();
			XY.display(spacings);
			boolean ohm_selected = Ohmmeter.update();
			if (ohm_selected){
				if (!configured){
					STATE = 2;
				} else {
					if (configured){
						String selection = new UiBooster().showSelectionDialog(
						"Reset reference resistance?",
						"Reset?",
						Arrays.asList("No", "Yes"));
						if (selection ==  "Yes"){
							STATE = 2;
							return;
						}
					}
					STATE = 3;
				}
			}
			Ohmmeter.display();
		break;
		case 2:
			STATE = 3;
			setUpOhmmeter();
		break;
		case 3:
			configured = true;
			background(0);
			drawOhmmeter();
		break;
	}
}

double get_reading(int active_chan) {
	
	int[] chanstat = {0, 0, 0, 0, 0, 0};
	chanstat[active_chan] = 1;
	int[] nextchan = {active_chan, 
					  active_chan, 
					  active_chan, 
					  active_chan, 
					  active_chan, 
					  active_chan};

	port.write(255);
	port.write(nsamp / 0x100);
	port.write(nsamp % 0x100);
	for (int i = 0; i < maxnchan; i++)
		port.write(chanstat[i]);
	for (int i = 0; i < maxnchan; i++)
		port.write(nextchan[i]);
	port.write(fchan);
	port.write(nchan);
	port.write(tchan);
	port.write(tmode);
	port.write(ADCPS[tbval]);
	port.write(skipsamp[tbval]);
	port.write(ivb);
	port.write(trig_level / 16);
	port.write(trig_offset / 0x100);
	port.write(trig_offset % 0x100);
	if (pls_prescale[pls_ip] == 1)
		port.write(1);
	if (pls_prescale[pls_ip] == 8)
		port.write(2);
	if (pls_prescale[pls_ip] == 64)
		port.write(3);
	port.write(pls_period[pls_ip] / 0x100);
	port.write(pls_period[pls_ip] % 0x100);
	port.write(pls_len[pls_ip][pls_il] / 0x100);
	port.write(pls_len[pls_ip][pls_il] % 0x100);

	//estimate the response time as the sum of the sampling time plus the time to send the data
	float sampletime = nsamp * (13 * ADCPS[tbval] * skipsamp[tbval]) / 16e3;
	float sendtime = 16.0 * nsamp / 115.2;

	delay(int((2.0 * sampletime + 1.1 * sendtime)));
	float v_avg = 0;
	while (port.available() >= 2 * nsamp + 1)
	{
		if (port.read() == 255)
		{
			for (int isamp = 0; isamp < nsamp; isamp++)
			{
				int hsb = port.read();
				int lsb = port.read();
				v_avg += hsb * 64 + (lsb & 0xFF);
			}
		}
	}

	v_avg = (v_avg/nsamp);
	// v_avg = (v_avg + 2) * (5.00 / (1.0 * maxval));
	// return (float) (v_avg*ref_resistor)/(5.00 - v_avg);
	return v_avg;
	

}

double get_resistance (double v_avg){

	return (ref_resistor*v_avg)/(maxval - v_avg);

}
void drawOhmmeter() {
	
	image(pins, x_scrn, y_scrn, 200, 100);
	if (Scope.update()){
		fill(0);
		stroke(0);
		rect(0,0,1100, 800);
		redraw_all();
		STATE = 1;
		return;
	};
	Scope.display();
	int active_channel = BC.update();
	BC.display_all();
	fill(0);
	stroke(0);
	rect(0, y_scrn + 0.5 * h_scrn, 1100, 80);

	rect(0, y_scrn + 0.75 * h_scrn, 1100, 80);

	fill(255);
	textFont(f2);
	textAlign(CENTER);

	double v_avg = (get_reading(active_channel) + get_reading(active_channel))/2;
	float resistance_reading = (float) get_resistance(v_avg);
	println(v_avg);
	String result;
	String unit = "Ohm";

	if (resistance_reading < 10 || resistance_reading > 33000){
		result = "0L";
	}
	else if (resistance_reading < 100){
		result = nf(resistance_reading, 2, 2);
	}
	else if (resistance_reading < 1000){
		result = nf(resistance_reading, 3, 1);
	}
	else if (resistance_reading < 10000){
		result = nf(resistance_reading/1000.0, 1, 2);
		unit = "kOhm";
	}
	else {
		result = nf(resistance_reading/1000.0, 2, 1);
		unit = "kOhm";
	}
	text(result, x_scrn + 0.5 * w_scrn, y_scrn + 0.5 * h_scrn + 80);
	textFont(f, 16);
	text(unit, x_scrn + 0.5 * w_scrn + 4*textWidth(result), y_scrn + 0.5 * h_scrn );
}

void setUpOhmmeter(){
	fill(0);
	stroke(0);
	rect(0,0,1100, 800);
	new UiBooster().showInfoDialog("Let's set up your ohmmeter.");
	new UiBooster().showInfoDialog("Set up your breadboard according the following schematics.\nThe schematics show a connection to pin A0.\nBut feel free to choose any analog pin.");

	while (true){
		new UiBooster().showPictures(
			"Schematic",
			Arrays.asList(
				new File("./data/ohmmeter1.png"),
				new File("./data/ohmmeter2.png")
			)
		);
		String selection = new UiBooster().showSelectionDialog(
				"Have you built your circuit?",
				"Complete?",
				Arrays.asList("Yes", "Not Yet", "Return to Scope"));
		if (selection ==  "Yes"){
			break;
		}
		else if (selection == "Return to Scope"){
			STATE = 1; 
			return;
		}
		else {
			continue;
		}
	}

	while (true){
		String r_val = new UiBooster().showTextInputDialog("Enter the resistance of the reference resistor: [Ohms]");
		
		try{
			ref_resistor = float(r_val);
			assert !Float.isNaN(ref_resistor);
			break;
		} 
		catch (AssertionError e){
			new UiBooster().showErrorDialog("Please enter a valid resistance value.", "ERROR");
		}
	}
	new UiBooster().showInfoDialog("Set up complete.");
}

void mousePressed()
{ //check for mouse clicks

	switch (STATE) {
		case 1:
			//nsamp bar
			if (mouseX > x_ns && mouseX < x_ns + w_ns && mouseY > y_ns && mouseY < y_ns + nns * h_ns)
			{
				ins = int((mouseY - y_ns) / h_ns);
				nsamp = ns[ins];
				if (trig_offset >= nsamp)
					trig_offset = nsamp - 1;
				drawns();
				doread = true;
			}

			if (trig_mode == 0)
			{
				//vertical scale bar
				if (mouseX > x_vb && mouseX < x_vb + w_vb && mouseY > y_vb && mouseY < y_vb + nVdiv * h_vb)
				{
					ivb = int((mouseY - y_vb) / h_vb);
					drawvb();
				}

				//timebar
				if (mouseX > x_tb && mouseX < x_tb + w_tb && mouseY > y_tb && mouseY < y_tb + ntbval * h_tb)
				{
					tbval = int((mouseY - y_tb) / h_tb);
					drawtb();
				}

				//pulser bar - period/frequency selection
				if (mouseX > x_pb && mouseX < x_scrn+w_scrn && mouseY > y_pb && mouseY < y_pb + 4 * h_pb)
				{
					if (mouseY < y_pb + 2 * h_pb)
						pls_ip = constrain(int((mouseX - x_pb) / (w_pb / pls_np)), 0, pls_period.length - 1);
					if (mouseY > y_pb + 2 * h_pb)
						pls_il = constrain(int((mouseX - x_pb) / (w_pb / pls_nl)), 0, pls_len[0].length - 1);

					drawpb();
				}

				//trigger level
				if (mouseX > x_scrn - 10 && mouseX < x_scrn && mouseY > y_scrn && mouseY < y_scrn + h_scrn)
				{
					//trig_level=(mouseY-y_scrn)*255/h_scrn;
					trig_level = (y_scrn + h_scrn - mouseY) * maxval / h_scrn;
				}

				//trigger offset
				if (mouseX > x_scrn && mouseX < x_scrn + w_scrn && mouseY < y_scrn && mouseY > y_scrn - 10)
				{
					trig_offset = (int)((1.0 * mouseX - 1.0 * x_scrn) * (1.0 * nsamp) / (1.0 * w_scrn));
				}

				//channel and trigger selection
				if (mouseX > x_ch && mouseX < x_ch + w_ch && mouseY > y_ch && mouseY < y_ch + maxnchan * h_ch)
				{
					int ichan = int((mouseY - y_ch) / h_ch);
					int ipos = int(3 * (mouseX - x_ch) / w_ch);
					if (ipos == 0)
					{
						if (chanstat[ichan] == 0)
							chanstat[ichan] = 1;
						else if (chanstat[ichan] >= 1 && nchan > 1)
							chanstat[ichan] = 0;
					}
					if (ipos == 1 || ipos == 2)
					{
						if (chanstat[ichan] == ipos + 1)
							chanstat[ichan] = 1;
						else
						{
							for (int i = 0; i < maxnchan; i++)
								chanstat[i] = min(chanstat[i], 1);
							chanstat[ichan] = ipos + 1;
						}
					}

					//calculate some handy numbers
					fchan = 0;
					for (int i = maxnchan - 1; i >= 0; i--)
						if (chanstat[i] > 0)
							fchan = i;
					nchan = 0;
					for (int i = 0; i < maxnchan; i++)
						if (chanstat[i] > 0)
							nchan++;
					tchan = maxnchan;
					for (int i = 0; i < maxnchan; i++)
						if (chanstat[i] > 1)
							tchan = i;
					tmode = 0;
					for (int i = 0; i < maxnchan; i++)
						if (chanstat[i] > 1)
							tmode = chanstat[i];

					//build the nextchan array
					for (int i = 0; i < maxnchan; i++)
					{
						for (int j = 1; j <= maxnchan; j++)
						{
							int i2 = (i + j) % maxnchan;
							if (chanstat[i2] > 0)
							{
								nextchan[i] = i2;
								break;
							}
						}
					}
					drawch();
				}
			}
			//trigger mode
			if (mouseX > x_ts && mouseX < x_ts + w_ts && mouseY > y_ts && mouseY < y_ts + h_ts)
			{
				trig_mode = 0;
				drawts();
			}
			if (mouseX > x_ts && mouseX < x_ts + w_ts && mouseY > y_ts + h_ts && mouseY < y_ts + 2 * h_ts)
			{
				trig_mode = 1;
				drawts();
				doread = true;
			}

		break;
		case 2:

		break;
		case 3:
		
		break;
	}
}

class CursorBars
{
	private XCursorBar X;
	private YCursorBar Y;

	int x_or_y;
	int one_or_two;

	CursorBars(XCursorBar X, YCursorBar Y)
	{
		this.X = X;
		this.Y = Y;
	}

	void update()
	{
		int sx = X.update();
		int sy = Y.update();
		if (sx == 0)
		{

			if (sy != 0)
			{
				one_or_two = sy;
				x_or_y = 2;
			}
		}
		else if (sy == 0)
		{

			if (sx != 0)
			{
				one_or_two = sx;
				x_or_y = 1;
			}
		}
	}

	void display(MyResult spacings)
	{
		X.display(spacings.getFirst());
		Y.display(spacings.getSecond());
	}
}

class XCursorBar
{
	private HScrollbar xc1;
	private HScrollbar xc2;

	XCursorBar(HScrollbar xc_1, HScrollbar xc_2)
	{
		xc1 = xc_1;
		xc2 = xc_2;
	}

	void move(int which_bar, boolean direction)
	{
		if (which_bar == 1)
		{
			xc1.move(direction);
		}
		else
		{
			xc2.move(direction);
		}
	}

	int update()
	{
		boolean s1 = xc1.update();
		boolean s2 = xc2.update();

		if (s1)
		{
			return 1;
		}
		else if (s2)
		{
			return 2;
		}
		else
		{
			return 0;
		}
	}
	void display(float spacing)
	{
		xc1.display();
		xc2.display();
		drawxcb(spacing);
	}
	float displacement()
	{
		return xc1.x_pos() - xc2.x_pos();
	}
	//draw the bar for the vertical scale
	void drawxcb(float x_spacing)
	{
		fill(0);
		stroke(0);
		rect(x_xcb, y_xcb - 1 * h_xcb, w_xcb, h_xcb);
		fill(255);
		textFont(f, 16);
		textAlign(CENTER);
		text("x cursors", x_xcb + w_xcb / 2, y_xcb - 2);
		fill(0);
		stroke(255);
		rect(x_xcb, y_xcb + 0 * h_xcb, w_xcb, h_xcb);
		fill(255);
		String result = nf(tbms[tbval] * displacement() / x_spacing, 0, 2) + " ms";
		text(result, x_xcb + 0.5 * w_xcb, y_xcb + 1 * h_tb - 2);
	}
}

class HScrollbar
{

	private int swidth, sheight; // width and height of bar
	private float xpos, ypos; // x and y position of bar
	private float spos, newspos; // x position of slider
	private float sposMin, sposMax; // max and min values of slider
	private int loose; // how loose/heavy
	private boolean over; // is the mouse over the slider?
	private boolean locked;
	private float ratio;
	private color cursor_color;
	private color cursor_selected_color;

	HScrollbar(float xp, float yp, int sw, int sh, float sp, int l, color cc, color csc)
	{
		swidth = sw;
		sheight = sh;
		int widthtoheight = sw - sh;
		ratio = (float)sw / (float)widthtoheight;
		xpos = xp;
		ypos = yp - sheight / 2;
		sposMin = xpos;
		sposMax = xpos + swidth - sheight;
		spos = sp;
		newspos = spos;
		loose = l;
		cursor_color = cc;
		cursor_selected_color = csc;
	}

	void move(boolean left_or_right)
	{
		if (left_or_right)
		{
			newspos -= 0.5;
			newspos = constrain(newspos, sposMin, sposMax);
		}
		else
		{
			newspos += 0.5;
			newspos = constrain(newspos, sposMin, sposMax);
		}
	}

	float x_pos()
	{
		return spos;
	}
	void lock()
	{
		locked = false;
	}
	boolean get_mousePressed_over()
	{
		if (overEvent() && mousePressed)
		{
			return true;
		}

		return false;
	}
	boolean update()
	{
		if (overEvent())
		{
			over = true;
		}
		else
		{
			over = false;
		}
		if (mousePressed && over)
		{
			locked = true;
		}
		if (!mousePressed)
		{
			locked = false;
		}
		if (locked)
		{
			newspos = constrain(mouseX - sheight / 2, sposMin, sposMax);
		}
		if (abs(newspos - spos) > 1)
		{
			spos = spos + (newspos - spos) / loose;
		}

		if (locked)
		{
			return true;
		}
		else
		{
			return false;
		}
	}

	float constrain(float val, float minv, float maxv)
	{
		return min(max(val, minv), maxv);
	}

	boolean overEvent()
	{
		if (mouseX > xpos && mouseX < xpos + swidth &&
			mouseY > ypos && mouseY < ypos + sheight)
		{
			return true;
		}
		else
		{
			return false;
		}
	}

	void display()
	{

		noStroke();
		fill(0); // sets the scroll bar to be black
		// draws the scroll bar

		rect(xpos, ypos, swidth, sheight);
		if (over || locked)
		{
			fill(cursor_selected_color);
		}
		else
		{
			fill(cursor_color);
		}
		ellipseMode(CORNER);
		circle(spos, ypos, sheight);

		rect(spos + sheight / 2, ypos, 1, h_scrn - ypos + y_scrn);
	}
}

class YCursorBar
{
	private VScrollbar yc1;
	private VScrollbar yc2;

	YCursorBar(VScrollbar yc_1, VScrollbar yc_2)
	{
		yc1 = yc_1;
		yc2 = yc_2;
	}

	void move(int which_bar, boolean direction)
	{
		if (which_bar == 1)
		{
			yc1.move(direction);
		}
		else
		{
			yc2.move(direction);
		}
	}

	int update()
	{
		boolean s1 = yc1.update();
		boolean s2 = yc2.update();

		if (s1)
		{
			return 1;
		}
		else if (s2)
		{
			return 2;
		}
		return 0;
	}
	void display(float spacing)
	{
		yc1.display();
		yc2.display();
		drawycb(spacing);
	}
	float displacement()
	{
		return yc1.y_pos() - yc2.y_pos();
	}

	//draw the bar for the vertical scale
	void drawycb(float y_spacing)
	{
		fill(0);
		stroke(0);
		rect(x_ycb, y_ycb - 1 * h_ycb, w_ycb, h_ycb);
		fill(255);
		textFont(f, 16);
		textAlign(CENTER);
		text("y cursors", x_ycb + w_ycb / 2, y_ycb - 2);
		fill(0);
		stroke(255);
		rect(x_ycb, y_ycb + 0 * h_ycb, w_ycb, h_ycb);
		fill(255);
		String result = nf(Vdiv[ivb] * displacement() / y_spacing, 0, 2) + " V";
		text(result, x_ycb + 0.5 * w_ycb, y_ycb + 1 * h_tb - 2);
	}
}

class VScrollbar
{
	private int swidth, sheight; // width and height of bar
	private float xpos, ypos; // x and y position of bar
	private float spos, newspos; // y position of slider
	private float sposMin, sposMax; // max and min values of slider
	private int loose; // how loose/heavy
	private boolean over; // is the mouse over the slider?
	private boolean locked;
	private float ratio;
	private color cursor_color;
	private color cursor_selected_color;

	//xp, yp, 12, h_scrn, 1, color(255, 102, 102), 1
	VScrollbar(float xp, float yp, int sw, int sh, float sp, int l, color cc, color csc)
	{
		swidth = sw;
		sheight = sh;
		int widthtoheight = sw - sh;
		ratio = (float)sw / (float)widthtoheight;
		xpos = xp;
		ypos = yp;
		sposMin = ypos;
		sposMax = ypos + sheight - swidth;
		spos = sp;
		newspos = spos;
		loose = l;
		cursor_color = cc;
		cursor_selected_color = csc;
	}

	float y_pos()
	{
		return spos;
	}

	boolean get_mousePressed_over()
	{
		if (overEvent() && mousePressed)
		{
			return true;
		}

		return false;
	}

	void move(boolean up_or_down)
	{
		if (up_or_down)
		{
			newspos -= 0.5;
			newspos = constrain(newspos, sposMin, sposMax);
		}
		else
		{
			newspos += 0.5;
			newspos = constrain(newspos, sposMin, sposMax);
		}
	}

	boolean update()
	{
		if (overEvent())
		{
			over = true;
		}
		else
		{
			over = false;
		}
		if (mousePressed && over)
		{
			locked = true;
		}
		if (!mousePressed)
		{
			locked = false;
		}
		if (locked)
		{
			newspos = constrain(mouseY - swidth / 2, sposMin, sposMax);
		}
		if (abs(newspos - spos) > 1)
		{
			spos = spos + (newspos - spos) / loose;
		}

		if (locked)
		{
			return true;
		}
		else
		{
			return false;
		}
	}

	float constrain(float val, float minv, float maxv)
	{
		return min(max(val, minv), maxv);
	}

	boolean overEvent()
	{
		if (mouseX > xpos && mouseX < xpos + swidth &&
			mouseY > ypos && mouseY < ypos + sheight)
		{
			return true;
		}
		else
		{
			return false;
		}
	}

	void display()
	{
		noStroke();
		fill(0);
		rect(xpos, ypos, swidth, sheight);
		if (over || locked)
		{
			fill(cursor_selected_color);
		}
		else
		{
			fill(cursor_color);
		}
		ellipseMode(CORNER);
		circle(xpos, spos, swidth);
		rect(xpos, spos + swidth / 2, w_scrn - xpos + x_scrn, 1);
	}
}

class MyResult
{
private final float first;
private final float second;

public MyResult(float first, float second)
	{
		this.first = first;
		this.second = second;
	}

	public float getFirst()
	{
		return first;
	}

	public float getSecond()
	{
		return second;
	}
}

class ButtonCollection
{
	private PinButton[] button_list;
	private int active = 0;
	ButtonCollection(PinButton[] button_list){
		this.button_list = button_list;
	}

	int active_button() {
		return active;
	}
	
	int update(){
		for (int i = 0; i < button_list.length; i+= 1){
			if (button_list[i].get_mousePressed_over()){
				active = i;
				break;
			}
		}
		return active;	
	}

	void display_all(){
		for (int i = 0; i < button_list.length; i+= 1){
			if (i == active){
				button_list[i].display(true);
			}
			else {
				button_list[i].display(false);	
			}
		}
	}
}

class PinButton extends RectangularButton
{
	// class constructor
	PinButton(float xp, float yp, int sw, int sh)
	{
		super(xp, yp, sw, sh, "");
	}

	void display(boolean selected){
		stroke(255);
		strokeWeight(2);
		if (selected){
			fill(color(230, 25, 75));
		}
		else {
			fill(0);
		}
		rect(super.xpos, super.ypos, super.swidth, super.sheight);
		strokeWeight(1);
	}
}

class RectangularButton
{
	private int swidth, sheight; // width and height of button
	private float xpos, ypos; // x and y position of bar
	private boolean over; 
	private boolean locked;
	private String label;

	// class constructor
	RectangularButton(float xp, float yp, int sw, int sh, String lb)
	{
		swidth = sw;
		sheight = sh;
		xpos = xp;
		ypos = yp;
		label = lb;
	}

	/*
		Draws a square button at the specified location on the canvas

		Requires: None
		Modifies: None

		Returns: None
	*/
	void display()
	{
		if (over || locked)
		{
			fill(128);
		}
		else
		{
			fill(0);
		}
		stroke(255);
		strokeWeight(2);
		rect(xpos, ypos, swidth, sheight);
		strokeWeight(1);
		fill(color(255, 225, 25));
		textFont(f, 16);
		textAlign(CENTER);
		text(label, xpos + swidth / 2, ypos + sheight - 2);
	}

	/*
		Determines whether the mouse pointer is over the button

		Requires: None
		Modifies: None	

		Returns: true if the mouse is over the button, false otherwise
	*/
	boolean overEvent()
	{
		if (mouseX > xpos && mouseX < xpos + swidth &&
			mouseY > ypos && mouseY < ypos + sheight)
		{
			return true;
		}
		else
		{
			return false;
		}
	}

	boolean get_mousePressed_over()
	{
		if (overEvent() && mousePressed)
		{
			return true;
		}

		return false;
	}

	boolean update()
	{
		if (overEvent())
		{
			over = true;
		}
		else
		{
			over = false;
		}
		if (mousePressed && over)
		{
			locked = true;
		}
		if (!mousePressed || !over )
		{
			locked = false;
		}
		if (locked)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
}