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
seq.each_with_index do |track, track_index|
	puts "TRACK [%02d] EVENTS:%d" % [track_index, track.to_a.length]

	notes = track.events.select{|e| e.is_a? MIDI::NoteOn}
	notes.each do |note|
		all_note_events.push note
	end
	
	# Debug Channel Notes Summary
	notes_hash = notes.select{|e| e.respond_to?(:channel)}.group_by{|e| e.channel}
	notes_hash.keys.sort.each do |key|
		chan_notes = notes_hash[key].map{|e| e.note}
		puts " \\CHAN[%02d] NOTES:%6d (%3d-%3d) [%3d]" %
		[key, chan_notes.length, chan_notes.min, chan_notes.max, chan_notes.uniq.length]
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