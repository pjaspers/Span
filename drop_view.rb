# drop_view.rb
# Span
#
# Created by Piet Jaspers on 05/04/10.
# Copyright 2010 10to1. All rights reserved.

require 'cgi'
require 'PJDockProgressIndicator'

class DropView < NSView
	attr_accessor :progress_bar, :text_label, :height, :progressBar

	def awakeFromNib
		puts "Wakker worden uit de xib"
		text_label.setStringValue("Drop something here")
		# Nodig voor te drag te kunnen doen
		self.registerForDraggedTypes([NSFilenamesPboardType])
		@progressBar = PJDockProgressIndicator.alloc.init
		@progressBar.maxValue = 1.0
		@progressBar.minValue = 0.0
		@progressBar.current = 1.0
		@height = 0.0
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
		files.each do |file_path|
			send_http_post file_path
		end
		return true
	end
	
	def handle_query_response(response)
		puts response
    end
	
	def get_file_name(file_path)
		# S3 houdt niet van + -en
		CGI.escape(file_path.lastPathComponent.to_s).gsub(/\+/,"_")
	end
	# via deze http://www.cocoadev.com/index.pl?HTTPFileUpload
	def send_http_post(file_path)
		# creating the url request:
		url_string = "http://www.postbin.org/1ka5qz6"
		url_string = "#{NSUserDefaults.standardUserDefaults.stringForKey('SpicUrl')}"
		@url = NSURL.URLWithString(url_string)
		@request      = NSMutableURLRequest.requestWithURL(@url, 
														   cachePolicy:NSURLRequestReloadIgnoringCacheData,
														   timeoutInterval:30.0)
		# adding header information:
		@request.setHTTPMethod "POST"
		
		# geen idee wat dit precies doet, maar tis nodig.
		string_boundary = "0xKhTmLbOuNdArY" 
		content_type = "multipart/form-data; boundary=#{string_boundary}"
		puts content_type
		
		@request.addValue(content_type, :forHTTPHeaderField => "Content-Type")
		
		# setting up the body:
		post_body = NSMutableData.data
		post_body.appendData("--#{string_boundary}\r\n".dataUsingEncoding(NSUTF8StringEncoding))
		post_body.appendData("Content-Disposition: form-data; name=\"secret\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding))
		post_body.appendData("#{NSUserDefaults.standardUserDefaults.stringForKey('SpicSecret')}".dataUsingEncoding(NSUTF8StringEncoding))
		post_body.appendData("\r\n--#{string_boundary}\r\n".dataUsingEncoding(NSUTF8StringEncoding))
		post_body.appendData("Content-Disposition: form-data; name=\"name\"; filename=\"#{get_file_name file_path}\"\r\n".dataUsingEncoding(NSUTF8StringEncoding))
		post_body.appendData("Content-Type: application/octet-stream\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding))
		post_body.appendData(NSData.dataWithContentsOfFile(file_path))
		post_body.appendData("\r\n--#{string_boundary}\r\n".dataUsingEncoding(NSUTF8StringEncoding))
		@request.setHTTPBody post_body
		progress_bar.setDoubleValue 0.0
		@progressBar.current = 0.0
		connection   = NSURLConnection.connectionWithRequest(@request, delegate:self)
	end
	
	def test_progress_bar
		(1..100).each do |i|
			progress_bar.setDoubleValue(i)
		end
	end
	def connection(connection, didSendBodyData:bytesWritten, totalBytesWritten:totalBytesWritten, totalBytesExpectedToWrite:totalBytesExpectedToWrite)
		puts "Written: #{bytesWritten} TotalBytesWritten: #{totalBytesWritten} TotalBytesExpectedToWrite: #{totalBytesExpectedToWrite}"
		puts "Double: #{(totalBytesWritten / (totalBytesExpectedToWrite/100))/10}"
		progress_bar.setDoubleValue(totalBytesWritten / (totalBytesExpectedToWrite/100))
		# hier mag iets langer over nagedacht worden
		@progressBar.current = ((totalBytesWritten / (totalBytesExpectedToWrite/100))/10)*0.1
	end
	
	def connectionDidFinishLoading(connection)
		puts "Klaar als een klontje."
		progress_bar.stopAnimation self
		progress_bar.setDoubleValue 100.0
	end
end


