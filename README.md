# MIDI input mod for the Korg Monotron
Adapted from my [ATtiny85 Synth Cable](https://mitxela.com/projects/midi_on_the_attiny) this code turns an ATtiny85 into a tiny MIDI-to-CV converter that can fit inside the case of a Korg Monotron to give it MIDI input. Like the synth cable, it supports pitch bend, modulation and an arpeggiator, and also can optionally retrigger the Monotron's LFO. 

It uses dual PWM outputs to simulate a higher resolution, you could potentially expose the trimpot so as to make the pitch-bend range adjustable. I also recommend a trimpot for tuning, as this can drift with temperature. If done correctly this modification should not affect any of the Monotron's original functionality. 

* Responds to Note On / Note Off on Channel 1 only
* CC1 / Aftertouch controls sine wave pitch modulation depth
* CC5 controls pitch modulation speed
* CC7 controls arpeggiator speed
* CC65 selects whether the arpeggiator should retrigger the LFO

More info and build instructions here: https://mitxela.com/projects/midi_monotron

Video demo here: https://www.youtube.com/watch?v=sK6SHGm2AZg

Last modified 15 Aug 2015