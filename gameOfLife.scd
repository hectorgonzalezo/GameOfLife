
(

~lowestFreq = 200;
//receives grid size from python
OSCdef(\gridReceiver, {
	|msg, time, addr, recvPort|
	~gridSize = msg[1];

}, '/gridSize'); // def style




// set them from outside later:
SynthDef(\bells, { |out, lowFreq = 200|
    var freqs, ringtimes, signal, amplitudes, density;
	freqs = Control.names([\freqs]).kr(Array.rand(~gridSize, 100, 400));
	ringtimes = Control.names([\ringtimes]).kr(1!~gridSize);
	amplitudes = Control.names([\amplitudes]).kr(Array.rand(~gridSize, 0.1, 1)/~gridSize);
	density = Control.names([\density]).kr(1);
	signal = DynKlank.ar(`[freqs.lag2(0.05), amplitudes.lag2(0.05), ringtimes ], SoundIn.ar*density);
	Out.ar(out, Splay.ar(RHPF.ar(signal, lowFreq*2)));
}).add;


a = Synth(\bells);



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

~count = 280;

//receives osc from python and turns it into coordinates
OSCdef(\drum, {|msg, time, addr, recvPort|
	~coordinates = msg.copyRange(1,msg.size).clump(2);
	~xCoord = msg.copySeries(1,3, msg.size);
	~yCoord = msg.copySeries(2,4, msg.size);
	//msg.postln;
	~count.postln;

	a.setn(\density, ~coordinates.size.linlin(2, ~gridSize**2, 1.5, 0.8));

	a.setn(\freqs, ~xCoord.linexp(0, ~gridSize, ~lowestFreq, 10000));
	a.setn(\amplitudes, ~yCoord.linlin(0, ~gridSize, 0.2, 1)/~coordinates.size);
	a.setn(\ringtimes, ~yCoord.lincurve(0, ~gridSize, 5.0, 0.5, -4));

	~count = ~count + 1;

	if(~count%rran(200, 500) == 0 ,{
		~newLowestFreq = exprand(100, 400);

		Tdef(\migrate).play;


	});


}, '/game'); // def style
)








