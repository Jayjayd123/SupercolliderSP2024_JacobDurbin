----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
"Sharing is Caring" "Uncomfortable" by Jacob Durbin
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
SynthDef(\cfstring1, { arg i_out, freq = 360, gate = 1, pan, amp=0.1;
    var out, eg, fc, osc, a, b, w;
    fc = LinExp.kr(LFNoise1.kr(Rand(0.25, 0.4)), -1, 1, 500, 2000);
    osc = Mix.fill(8, {LFSaw.ar(freq * [Rand(0.99, 1.01), Rand(0.99, 1.01)], 0, amp) }).distort * 1;
    eg = EnvGen.kr(Env.asr(1, 1, 3), gate, doneAction: Done.freeSelf);
    out = eg * RLPF.ar(osc, fc, 0.1);
    #a, b = out;
    Out.ar(i_out, Mix.ar(PanAz.ar(4, [a, b], [pan, pan])));
}).add;
)

(
SynthDef(\squareSynth, {
    arg freq = 440, // default frequency
        amp = 0.5,  // default amplitude
        width = 0.5, // default pulse width (duty cycle)
	    gate = 1;

    var sound, eg;

    sound = Pulse.ar(freq, width); // generate a square wave with the specified pulse width
	eg = EnvGen.kr(Env.asr(1, 1, 3), gate, doneAction: Done.freeSelf);

    Out.ar(0, sound * amp * eg); // output the sound with the specified amplitude
}).add;
)

(
	SynthDef(\farEnough, {
		arg pitch, freq=70, addFreq=17, attack=1, release = 12;
		var sig, sig1, saws, env, shapeEnv, local, local2;
		sig =
		Mix.new(
			Array.fill(8,
				{SinOsc.ar(freq + addFreq.rand, 0.95.rand, 0.03)}));

		env = EnvGen.kr(
			Env.perc(attack, release ),
			doneAction:2);
		sig1 = sig + (sig *
			Mix.new(
				Array.fill(8,
					{SinOsc.ar(0.02, 0.7.rand, LFNoise1.kr(0.02, 0.08))})));

		sig = sig * env;
		sig1 = sig1 * env;

		sig = PitchShift.ar(sig, 0.1, SinOsc.kr(pitch.rrand(0.1, 0.2), 3.2.rand, 0.9, 3));
		sig1 = PitchShift.ar(sig1, 0.1, SinOsc.kr(pitch.rrand(0.1, 9.2), 0, 0.9, 3));

		saws = Mix.new(
			Array.fill(8,
				{LFSaw.ar(\sawFreq.ir(4000) + addFreq.rand, 0.9.rand, 0.02)}));
		shapeEnv = EnvGen.kr(Env([0.1, 0.02, 0.8, 0.0], [1, 5, 3 , 2]));

		saws = saws * shapeEnv;
		saws = saws * env;

		local = LocalIn.ar(2) + [sig+sig1, sig1+sig];
		local = DelayN.ar(local, 0.8, [0.3, 0.33.rand]);
		local2 = LocalIn.ar(2) + [saws, saws];
		local2 = DelayN.ar(local2, 0.8, [0.02, 0.02.rand]);
		local = local + local2;

		local = Compander.ar(
			local, local,
			0.2, slopeBelow: 1.3,
			slopeAbove: 0.1,
			clampTime:0.1,
			relaxTime:0.01);
		local = local.tanh;
		local = HPF.ar(local, 70);
		//local = BRF.ar(local, 260);
		LocalOut.ar(local * 0.8);
		Out.ar(0, local);

	}).add;
)


(
SynthDef(\impul, {
		arg freq = 1000;
		var sig, sig1, env;
		sig = Pan2.ar(
			Mix.ar(
				Array.fill(8,
					{Impulse.ar(freq + 130.rand, 0.7.rand,
						LFNoise1.kr(20, 0.2.rand))})), 0);
		4.do({ sig = AllpassN.ar(sig, 0.050, [0.050.rand, 0.050.rand], 1) });
		sig1 = sig * LFNoise1.ar(23, Dust2.kr(20));
		4.do({ sig1 = AllpassN.ar(sig, 0.050, [0.050.rand, 0.050.rand], 1) });
		env = EnvGen.kr(Env.perc(5, 20), doneAction:2);
		sig = (sig  + sig1)*env;


		Out.ar(0, sig);
	}).add;
)



//set the tempo FIRST
t = TempoClock(4);


(
c.stop;
t.schedAbs(t.nextBar,
	{
		c = Pbind(
		\instrument, \cfstring1,
		\scale, Scale.minor,
		\root, 0,

		\amp, 0.01,
		\dur, 2,
		\sustain, 0.1,
		\octave, 5,
		\degree, Pseq([[0, 2, 4, 6, 8], [0, 2, 4, 6, 8], [0, 2, 4, 6], [0, 2, 4, 6], [0, 3, 5, 7, 9], [0, 3, 5, 7, 9], [0, 3, 5, 7, 9], [0, 3, 5, 7, 9]],inf)

	).play;
	}
)
);


// chord variation to the V minor. run at random moments for as long as you want

(
c.stop;
t.schedAbs(t.nextBar,
	{
		c = Pbind(
		\instrument, \cfstring1,
		\scale, Scale.minor,
		\root, 0,

		\amp, 0.01,
		\dur, 2,
		\sustain, 0.1,
		\octave, 5,
			\degree, Pseq([[1, 4, 6, 7, 8]],inf)

	).play;
	}
)
);

c.stop;


-----------------------------------------------------------------------------------------------------------------------------------------------

//second instrument is an odd meter arp. Can be played whenever honestly
(
j.stop;
t.schedAbs(t.nextBar,
	{
		j = Pbind(
		\instrument, \squareSynth,
		\scale, Scale.minor,
		\root, 0,

		\amp, 0.05,
		\dur, 0.5,
		\sustain, 0.1,
		\octave, 5,
		\degree, Pseq([0, 2, 4, 6, 8],inf)

	).play;
	}
)
);
j.stop;
j.free;


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


(
n = Pbind(
	\instrument, \impul,
	\amp, 100,
	\dur, 1,
	\freq, Pseq([60, 70, 90, 80, 100], inf)

).play;
)


// C = the synth chords
// n = the weird impul sound
n.play;
n.stop;
n.free;


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

// launch the "Synth(\impul)" for ambient effect
Synth(\impul);
//Same with the \farEnough
Synth(\farEnough);
(
f = Pbind(
	\instrument, \farEnough,
	\amp, 80,
	\dur, 10,
	\freq, Pseq([60, 70, 90, 80, 100], inf),

).play;
)


f.play;
f.stop;
f.free;





// This FM synth is for vibe. You can start and stop it whenever.

(
SynthDef(\fmSynth, { |carrierFreq=100, carrierLvl=0.5, modulatorRatio=5, modulatorIndex=1.5, outputAmp=0.2, sig, out=0|

	// the simple FM core
	sig = LFSaw.ar(carrierFreq, 1, 0.5, 0.5) * carrierLvl;
	sig = sig + SinOsc.ar(carrierFreq * modulatorRatio) * modulatorIndex;
	sig = cos( sig * 2pi) * outputAmp * 0.06;
	Out.ar(out, sig);
},1!5).add;
)


//Start with the "G = Synth(\fmSynth);" then use the "g.set" functions to change it up either slowely or rapidly. Just pick random ones.

// At first start the synth:
g = Synth(\fmSynth);

// Play with the parameters:
g.set(\carrierFreq, 800);
g.set(\carrierFreq, 50);
g.set(\carrierFreq, 100, \modulatorRatio, 5, \modulatorIndex, 0.5);
g.set(\carrierFreq, 40, \modulatorRatio, 7, \modulatorIndex, 1.5);
g.set(\carrierFreq, 955, \carrierLvl, 0.4, \modulatorRatio, 3, \modulatorIndex, 4);
// ... etc.

// To stop:
g.free;



