# Midi note ticks to seconds with tempo support
# @galacticfurball / Discatte
#     req: tested with ruby 2.3.3
# install: bundle install
#   usage: bundle exec ruby thisfile.rb midi_file

require 'rubygems'
require 'bundler/setup'

require 'pry'
require 'midilib/sequence'

seq = MIDI::Sequence.new
@seq = seq
File.open(ARGV[0], 'rb') { |file| seq.read(file) }

# testmidi3bar.mid
# M1 1 - 00:00 00:01
# M1 2 - 00:01 00:02
# M2 3 - 00:02 00:03
# M2 4 - 00:03 00:04
# M3 5 - 00:04 00:05
# M3 6 - 00:05 00:06


# testmidi3bar_tempo_120_60_30.mid
# M1 1 - 00:00 00:01
# M1 2 - 00:01 00:02
# M2 3 - 00:02 00:04
# M2 4 - 00:04 00:06
# M3 5 - 00:06 00:10
# M3 6 - 00:10 00:14


# testmidi3bar_tempo_120_60_30_middle_of_note.mid
# M1 1 - 00:00   00:01
# M1 2 - 00:01   00:02
# M2 3 - 00:02   00:03.5
# M2 4 - 00:03.5 00:05.5
# M3 5 - 00:05.5 00:08.5
# M3 6 - 00:08.5 00:12.5

all_tempo_events = []
all_note_events  = []


# Debug output and extract tempos and note from tracks
puts "-"*20
puts "File Summary"
puts "SEQ PPQN:#{seq.ppqn} TRACKS:#{seq.to_a.length}"

@gm_instrument_names = {
# 1-8 Piano
1=>"Acoustic Grand Piano", 2=>"Bright Acoustic Piano", 3=>"Electric Grand Piano", 4=>"Honky-tonk Piano", 5=>"Electric Piano 1", 6=>"Electric Piano 2", 7=>"Harpsichord", 8=>"Clavi",
# 9-16 Chromatic Percussion
9=>"Celesta", 10=>"Glockenspiel", 11=>"Music Box", 12=>"Vibraphone", 13=>"Marimba", 14=>"Xylophone", 15=>"Tubular Bells", 16=>"Dulcimer",
# 17-24 Organ
17=>"Drawbar Organ", 18=>"Percussive Organ", 19=>"Rock Organ", 20=>"Church Organ", 21=>"Reed Organ", 22=>"Accordion", 23=>"Harmonica", 24=>"Tango Accordion",
# 25-32 Guitar
25=>"Acoustic Guitar (nylon)", 26=>"Acoustic Guitar (steel)", 27=>"Electric Guitar (jazz)", 28=>"Electric Guitar (clean)", 29=>"Electric Guitar (muted)", 30=>"Overdriven Guitar", 31=>"Distortion Guitar", 32=>"Guitar harmonics",
# 33-40 Bass
33=>"Acoustic Bass", 34=>"Electric Bass (finger)", 35=>"Electric Bass (pick)", 36=>"Fretless Bass", 37=>"Slap Bass 1", 38=>"Slap Bass 2", 39=>"Synth Bass 1", 40=>"Synth Bass 2",
# 41-48 Strings
41=>"Violin", 42=>"Viola", 43=>"Cello", 44=>"Contrabass", 45=>"Tremolo Strings", 46=>"Pizzicato Strings", 47=>"Orchestral Harp", 48=>"Timpani",
# 49-56 Ensemble
49=>"String Ensemble 1", 50=>"String Ensemble 2", 51=>"SynthStrings 1", 52=>"SynthStrings 2", 53=>"Choir Aahs", 54=>"Voice Oohs", 55=>"Synth Voice", 56=>"Orchestra Hit",
# 57-64 Brass
57=>"Trumpet", 58=>"Trombone", 59=>"Tuba", 60=>"Muted Trumpet", 61=>"French Horn", 62=>"Brass Section", 63=>"SynthBrass 1", 64=>"SynthBrass 2",
# 65-72 Reed
65=>"Soprano Sax", 66=>"Alto Sax", 67=>"Tenor Sax", 68=>"Baritone Sax", 69=>"Oboe", 70=>"English Horn", 71=>"Bassoon", 72=>"Clarinet",
# 73-80 Pipe
73=>"Piccolo", 74=>"Flute", 75=>"Recorder", 76=>"Pan Flute", 77=>"Blown Bottle", 78=>"Shakuhachi", 79=>"Whistle", 80=>"Ocarina",
# 81-88 Synth Lead
81=>"Lead 1 (square)", 82=>"Lead 2 (sawtooth)", 83=>"Lead 3 (calliope)", 84=>"Lead 4 (chiff)", 85=>"Lead 5 (charang)", 86=>"Lead 6 (voice)", 87=>"Lead 7 (fifths)", 88=>"Lead 8 (bass + lead)",
# 89-96 Synth Pad
89=>"Pad 1 (new age)", 90=>"Pad 2 (warm)", 91=>"Pad 3 (polysynth)", 92=>"Pad 4 (choir)", 93=>"Pad 5 (bowed)", 94=>"Pad 6 (metallic)", 95=>"Pad 7 (halo)", 96=>"Pad 8 (sweep)",
# 97-104 Synth Effects
97=>"FX 1 (rain)", 98=>"FX 2 (soundtrack)", 99=>"FX 3 (crystal)", 100=>"FX 4 (atmosphere)", 101=>"FX 5 (brightness)", 102=>"FX 6 (goblins)", 103=>"FX 7 (echoes)", 104=>"FX 8 (sci-fi)",
# 105-112 Ethnic
105=>"Sitar", 106=>"Banjo", 107=>"Shamisen", 108=>"Koto", 109=>"Kalimba", 110=>"Bag pipe", 111=>"Fiddle", 112=>"Shanai",
# 113-120 Percussive
113=>"Tinkle Bell", 114=>"Agogo", 115=>"Steel Drums", 116=>"Woodblock", 117=>"Taiko Drum", 118=>"Melodic Tom", 119=>"Synth Drum", 120=>"Reverse Cymbal",
# 121-128 Sound Effects
121=>"Guitar Fret Noise", 122=>"Breath Noise", 123=>"Seashore", 124=>"Bird Tweet", 125=>"Telephone Ring", 126=>"Helicopter", 127=>"Applause", 128=>"Gunshot"
}

# utility for midi instrument names
def pc_to_general_midi program_change
	@gm_instrument_names[program_change+1] || program_change
end


@gm_drum_names = {
35=>"Acoustic Bass Drum", 36=>"Bass Drum 1", 37=>"Side Stick", 38=>"Acoustic Snare", 39=>"Hand Clap", 40=>"Electric Snare", 41=>"Low Floor Tom", 42=>"Closed Hi Hat", 43=>"High Floor Tom", 44=>"Pedal Hi-Hat", 45=>"Low Tom", 46=>"Open Hi-Hat", 47=>"Low-Mid Tom", 48=>"Hi-Mid Tom", 49=>"Crash Cymbal 1", 50=>"High Tom", 51=>"Ride Cymbal 1", 52=>"Chinese Cymbal", 53=>"Ride Bell", 54=>"Tambourine", 55=>"Splash Cymbal", 56=>"Cowbell", 57=>"Crash Cymbal 2", 58=>"Vibraslap", 59=>"Ride Cymbal 2", 60=>"Hi Bongo", 61=>"Low Bongo", 62=>"Mute Hi Conga", 63=>"Open Hi Conga", 64=>"Low Conga", 65=>"High Timbale", 66=>"Low Timbale", 67=>"High Agogo", 68=>"Low Agogo", 69=>"Cabasa", 70=>"Maracas", 71=>"Short Whistle", 72=>"Long Whistle", 73=>"Short Guiro", 74=>"Long Guiro", 75=>"Claves", 76=>"Hi Wood Block", 77=>"Low Wood Block", 78=>"Mute Cuica", 79=>"Open Cuica", 80=>"Mute Triangle", 81=>"Open Triangle"
}

# utility for midi drum names
def drum_note_to_general_midi drum_note
	@gm_drum_names[drum_note] || drum_note
end

# full summary
=begin
seq.each_with_index do |track, track_index|
	puts "TRACK [%02d] EVENTS:%d" % [track_index, track.to_a.length]
	track_events = track.events.group_by{|e| e.class.name}
	track_events_count = track_events.keys.sort.collect{|key| "#{key.gsub("MIDI::","")}:#{track_events[key].length}"}.join(", ")
	puts " \\SUMMARY %s" % track_events_count
end
=end

# tidy summary
seq.each_with_index do |track, track_index|
	puts "TRACK [%02d] EVENTS:%d" % [track_index, track.to_a.length]

	# Debug Program Change Summary
    programs_hash = track.events.select{|e| e.is_a? MIDI::ProgramChange}.group_by{|e| e.channel}
	programs_hash.keys.sort.each do |key|
		chan_programs = programs_hash[key].map{|e| e.program}
		if key == 9
			programs_used = chan_programs.uniq.map{|prog_number| "Drum Kit (#{prog_number})"}.join(",")
		else
			programs_used = chan_programs.uniq.map{|prog_number| pc_to_general_midi prog_number }.join(",")
		end
		puts " \\CHAN[%02d] PROGS:%3d <%s>" %
		[key, chan_programs.length, programs_used]
	end

	notes = track.events.select{|e| e.is_a? MIDI::NoteOn}
	notes.each do |note|
		all_note_events.push note
	end
	
	# Debug Channel Notes Summary
	event_count_length = track.to_a.length.to_s.length
	notes_hash = notes.select{|e| e.respond_to?(:channel)}.group_by{|e| e.channel}
	notes_hash.keys.sort.each do |key|
		chan_notes = notes_hash[key].map{|e| e.note}
		if key == 9
			notes_used = chan_notes.uniq.map{|note_number| drum_note_to_general_midi note_number }.join(",")
		else
			notes_used = chan_notes.uniq.map{|note_number| MIDI::Utils.note_to_s note_number }.join(",")
		end
		puts " \\CHAN[%02d] NOTES:%#{event_count_length}d (%3s-%3s) [%3d] <%s>" %
		[key, chan_notes.length, MIDI::Utils.note_to_s(chan_notes.min), MIDI::Utils.note_to_s(chan_notes.max), chan_notes.uniq.length,notes_used]
	end

	tempo_events = track.events.select{|e| e.is_a? MIDI::Tempo}
	tempo_events.each do |tempo|
		all_tempo_events.push tempo
	end
	
	# Debug Tempo on TRACK
	tempo_events.each do |tempo_event|
		puts " \\TEMPO %8d BPM: %3d" % [tempo_event.data, MIDI::Tempo.mpq_to_bpm(tempo_event.data)]
	end
end
puts "-"*20

# not sure if needed for tempo, but notes would be from different tracks interleaved
all_note_events.sort
all_tempo_events.sort


# Calculate seconds given a duration of ticks and a bpm ##############################################

def ticks_to_seconds(ticks, bpm)
	(ticks.to_f / @seq.ppqn.to_f / bpm.to_f) * 60
end

# Build tempo ranges out of tempo pairs, and the last event in the files tick time ###################

puts "Tempo to seconds map"
last_event = seq.tracks.collect{|track| track.events}.flatten.sort.last
all_tempo_events.push last_event

@tempo_ranges = []
tempo_elapsed_seconds = 0.0
# iterate in overlap pairs [0,1] [1,2] [2,3] etc
all_tempo_events.each_cons(2) do |tempos|
	curr_tempo = tempos[0]
	next_tempo = tempos[1]
	
	tempo_bpm = 60_000_000.0/curr_tempo.data
	
	tempo_duration_ticks = next_tempo.time_from_start - curr_tempo.time_from_start
	
	tempo_duration_seconds = ticks_to_seconds(tempo_duration_ticks, tempo_bpm)
	
	tempo_object  = {start_tick: curr_tempo.time_from_start,
					   end_tick: next_tempo.time_from_start,
							bpm: tempo_bpm,
				  start_seconds: tempo_elapsed_seconds,
			   duration_seconds: tempo_duration_seconds,
					end_seconds: tempo_elapsed_seconds + tempo_duration_seconds}
	@tempo_ranges.push tempo_object
	
	tempo_elapsed_seconds += tempo_duration_seconds
end

# dumb things
tick_str_size = @tempo_ranges.last[:end_tick].to_s.length
secs_str_size = ("%0.4f" % [@tempo_ranges.last[:end_seconds]]).length

# debug output
@tempo_ranges.each do |tempo_range|
	puts "TEMPO BPM:%3d  START: %#{tick_str_size}d/%#{secs_str_size}s  END: %#{tick_str_size}d/%#{secs_str_size}s  DURATION: %#{secs_str_size}s" %
	[tempo_range[:bpm],
	 tempo_range[:start_tick],
	 "%0.4f" % tempo_range[:start_seconds],
	 tempo_range[:end_tick],
	 "%0.4f" % tempo_range[:end_seconds],
	 "%0.4f" % tempo_range[:duration_seconds]
	]
end


# Show absolute time in seconds for each note event ##########################################

def get_event_absolute_time event
	last_tempo_range = @tempo_ranges.select do |tempo_range|
		tempo_range[:start_tick] <= event.time_from_start
	end.last
	
	ticks_since_tempo      = event.time_from_start - last_tempo_range[:start_tick]
	event_start_seconds    = ticks_to_seconds(ticks_since_tempo, last_tempo_range[:bpm])
	event_absolute_seconds = event_start_seconds + last_tempo_range[:start_seconds]
	
	puts "NOTE %3s (%3d) CH:%02d TIME:%6d/%7s" % [ MIDI::Utils.note_to_s(event.note), event.note, event.channel, event.time_from_start, "%0.4f" % event_absolute_seconds]
end


all_note_events.each do |note|
	get_event_absolute_time note
end