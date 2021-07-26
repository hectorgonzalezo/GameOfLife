
(
//feedback
~gridSize = 50;
// set them from outside later:
SynthDef('help-dynKlank', { |out|
    var freqs, ringtimes, signal, amplitudes, density;
	freqs = Control.names([\freqs]).kr(Array.rand(~gridSize, 100, 400));
	ringtimes = Control.names([\ringtimes]).kr(1!~gridSize);
	amplitudes = Control.names([\amplitudes]).kr(Array.rand(~gridSize, 0.1, 1)/~gridSize);
	density = Control.names([\density]).kr(1);
	signal = DynKlank.ar(`[freqs, amplitudes, ringtimes ], SoundIn.ar*density);
	Out.ar(out, Splay.ar(signal));
}).add;


a = Synth('help-dynKlank');



//receives osc from python and turns it into coordinates
OSCdef(\test, {|msg, time, addr, recvPort|
	~coordinates = msg.copyRange(1,msg.size).clump(2);
	~xCoord = msg.copySeries(1,3, msg.size);
	~yCoord = msg.copySeries(2,4, msg.size);
	msg.postln;

	a.set(\density, ~coordinates.size.lincurve(2, ~gridSize**2, 1.5, 0.8));

	a.setn(\freqs, ~xCoord.linexp(0, ~gridSize, 40, 5000));
	a.setn(\amplitudes, ~yCoord.linlin(0, ~gridSize, 0.2, 1)/~coordinates.size);
	a.setn(\ringtimes, ~yCoord.linlin(0, ~gridSize, 3, 1));

}, '/game'); // def style
)






