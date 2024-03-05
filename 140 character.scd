(
SynthDef(\bass, {
    arg freq = 432, amp = 0.5, dur = 1, pan = 0;

    // Envelope
    var env, sig;
	env = EnvGen.kr(Env.perc, doneAction: 2);

    // Oscillator
    sig = Saw.ar(freq);

    // Filter
    sig = LPF.ar(sig, freq * 1.3);  // Low-pass filter

    // Apply envelope and amplitude
    sig = sig * env * amp;

    // Output
    Out.ar(0, Pan2.ar(sig, pan));
}).add;
)



s.meter;
(
   ~bass =Pbind(
		\instrument, \bass,

		\scale, Scale.dorian,
		\root, 0,

		\amp, Pseq([Pseq([0.035], 2),Pseq([0], 2.4)], inf),
		\pan, [-0.5,0.5],

		\dur, 0.025,
		\sustain, 1,

		\octave, [1,3,2,4,4,6,1,-3,4,4,5,6,5,4,7,8,5,-3,-3.5,],
		\degree, Place( ([0,2,-1,3,4,5,6,2,3,4,-2,4].stutter(2)!1) , inf)
).play
);