# drop_view.rb
# Span
#
# Created by Piet Jaspers on 05/04/10.
# Copyright 2010 10to1. All rights reserved.

class DropView < NSView
	attr_accessor :text_label

	SINATRA_URL = "http://fierce-snow-64.heroku.com/p"
	SECRET = "uwe_secret_code"
  
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
		files.each do |file|
			# data = NSData.dataWithContentsOfFile(file)
			# puts data.to_s.dataUsingEncoding(NSUTF8StringEncoding)
			send_http_post file
			# puts "Schrijven van data"
			# data.writeToFile("/Users/junkiesxl/test.png", :atomically => true)
			# puts data
			#MacRubyHTTP.post("http://www.postbin.org/1ka5qz6", {:payload => data, :delegation => self }) 
		end
		return true
	end
	
		def handle_query_response(response)
		puts response
    end
	
	# via deze http://www.cocoadev.com/index.pl?HTTPFileUpload
	def send_http_post(file_path)
	# creating the url request:
	url_string = "http://www.postbin.org/1ka5qz6"
	url_string = "#{SINATRA_URL}"
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
	post_body.appendData("#{SECRET}".dataUsingEncoding(NSUTF8StringEncoding))
	post_body.appendData("\r\n--#{string_boundary}\r\n".dataUsingEncoding(NSUTF8StringEncoding))
	post_body.appendData("Content-Disposition: form-data; name=\"name\"; filename=\"test.txt\"\r\n".dataUsingEncoding(NSUTF8StringEncoding))
	post_body.appendData("Content-Type: application/octet-stream\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding))
	post_body.appendData(NSData.dataWithContentsOfFile(file_path))
	post_body.appendData("\r\n--#{string_boundary}\r\n".dataUsingEncoding(NSUTF8StringEncoding))
	@request.setHTTPBody post_body
	
	connection   = NSURLConnection.connectionWithRequest(@request, delegate:self)
	end
	
	def connectionDidFinishLoading(connection)
		puts "Klaar als een klontje."
	end
end


