
(

~lowestFreq = 70;

~count = 0;


//function that groups al x coordiantes of a single y
~clumpsXbyYindex = {
	|coordinates|
	var initialNum, xOrdered, checkerArray;

	initialNum = 0;
	xOrdered = List.new;
	checkerArray = List.new;
	coordinates.do({
		|coord|

		if(coord[0] == initialNum,
			{checkerArray.add(coord[1])},
			{
			xOrdered.add(checkerArray);
			checkerArray = List.new;
			initialNum = initialNum +1;
			}
		);

	});
	xOrdered;

};




Tdef(\migrate,{
	//migrates from one harmonic area to another
	Array.interpolation(rrand(100, 200), ~lowestFreq, ~newLowestFreq).do{
		|number|
		a.set(\lowFreq, number*2);
		~lowestFreq = number;
		number.postln;
		0.1.wait;
	};

	~lowestFreq = ~newLowestFreq ;
});




//receives grid size from python
OSCdef(\gridReceiver, {

	|msg, time, addr, recvPort|

	~gridSize = msg[1];

	~initialrray = 0!~gridSize;

	//add synthdef
	SynthDef(\bells, {
		|out, lowFreq = 200, pan=0|
    var freqs, ringtimes, signal, amplitudes, density;

	freqs = Control.names([\freqs]).kr(Array.fill(~gridSize, {|i| i.linexp(0, ~gridSize, ~lowestFreq, 5000)}));
	ringtimes = Control.names([\ringtimes]).kr(1!~gridSize);
	amplitudes = Control.names([\amplitudes]).kr(0!~gridSize);
	density = Control.names([\density]).kr(1);
	signal = DynKlank.ar(`[freqs, amplitudes, ringtimes ], SoundIn.ar*density);
	Out.ar(0, Splay.ar(HPF.ar(signal, ~lowestFreq*4),0, center:pan));
}).add;


	//play a Synth for each side on the grid
	~bells = { |i| Synth(\bells, [\pan, i.linlin(0, ~gridSize, -1, 1)])}!~gridSize;



}, '/gridSize');




//receives osc from python and turns it into coordinates
OSCdef(\drum, {|msg, time, addr, recvPort|

	var coordinates, xCoord, yCoord, xOrdered;

	coordinates = msg.copyRange(1,msg.size).clump(2);
	xCoord = msg.copySeries(1,3, msg.size);
	yCoord = msg.copySeries(2,4, msg.size);



	xOrdered = ~clumpsXbyYindex.value(coordinates);

	//xOrdered.postln;

	//msg.postln;
	~count.postln;

	xOrdered.do({
		|yCoords, i|

		var ampsArray;

		ampsArray = 0!~gridSize;

		yCoords.do({ |yCoord| ampsArray.put(yCoord, 1)});


		//~bells[i].setn(\freqs, yCoords.linexp(0, ~gridSize, ~lowestFreq, 5000));
		~bells[i].setn(\amplitudes, ampsArray);
		~bells[i].setn(\ringtimes, i.lincurve(0, ~gridSize, 5.0, 0.5, -4));


		if(~count ==0, {
		~bells[i].setn(\density, coordinates.size.linlin(2, ~gridSize**2, 0.1, 0.05));
		});
		ampsArray.postln;
		});




	~count = ~count + 1;

	//migrate from one harmonic area to another every rrand(200, 500) instances
	if(~count%(rrand(200, 500)) == 0 ,{
		~newLowestFreq = exprand(100, 400);

		Tdef(\migrate).play;


	});


}, '/game'); // def style
)








