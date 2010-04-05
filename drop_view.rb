# drop_view.rb
# Span
#
# Created by Piet Jaspers on 05/04/10.
# Copyright 2010 10to1. All rights reserved.

class DropView < NSView
	attr_accessor :text_label

	def awakeFromNib
		puts "Wakker worden uit de xib"
		text_label.setStringValue("Drop something here")
		# Nodig voor te drag te kunnen doen
		self.registerForDraggedTypes([NSFilenamesPboardType])
	end

	def draggingEntered(sender)
		puts "En we zijn aant draggen"
		text_label.setStringValue("Great, now drop it!")
		# Deze hieronder zorgt ervoor dat het draggen werkt,
		# zijn nog veel ander opties voor. Heb deze even gekozen
		# als placeholder
		NSDragOperationLink
	end

	def draggingEnded(sender)
		puts "En we zijn gestopt met draggen"
		text_label.setStringValue("Great, you dropped it!")
	end
	# Hier moeten we ,volgens de docs, de bulk van het werk in doen
	# Doet tot nu toe niet meer als zeggen waar de file vandaan komt.
	def performDragOperation(sender) 
		text_label.setStringValue("Drop something here")
		sourceDragMask = sender.draggingSourceOperationMask
		pboard = sender.draggingPasteboard
		files = pboard.propertyListForType(NSFilenamesPboardType)
		puts files
		return true
	end
end


