

(
~gridSize = 50;
//receives osc from python and turns it into coordinates
OSCdef(\test, {|msg, time, addr, recvPort|
	~coordinates = msg.copyRange(1,msg.size).clump(2);
	~xCoord = msg.copySeries(1,3, msg.size);
	~yCoord = msg.copySeries(2,4, msg.size);

	a.set(\density, ~coordinates.size.lincurve(2, ~gridSize**2, 0.5, 20));

	a.setn(\freqs, ~xCoord.linexp(0, ~gridSize, 50, 2000));
	a.setn(\amplitudes, ~yCoord.linexp(0, ~gridSize, 0.1, 5));
	a.setn(\ringtimes, ~yCoord.linlin(0, ~gridSize, 1, 3));

}, '/game'); // def style
)


(
// set them from outside later:
SynthDef('help-dynKlank', { |out|
    var freqs, ringtimes, signal, amplitudes, density;
	freqs = Control.names([\freqs]).kr(Array.rand(~coordinates.size, 100, 400));
	ringtimes = Control.names([\ringtimes]).kr(1!~coordinates.size);
	amplitudes = Control.names([\amplitudes]).kr(Array.rand(~coordinates.size, 0.001, 0.2));
	density = Control.names([\density]).kr(5);
	signal = DynKlank.ar(`[freqs, amplitudes, ringtimes ], Dust.ar(density.lag2(0.5), 1));
	Out.ar(out, Splay.ar(signal));
}).add;


a = Synth('help-dynKlank');
)
