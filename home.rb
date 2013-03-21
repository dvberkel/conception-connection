# myapp.rb
require 'sinatra'
require 'date'
require 'open-uri'
require 'nokogiri'
require 'data_mapper'

class Event
  include DataMapper::Resource

  property :id,           Serial
  property :date,         Date,     :index => true
  property :description,  String ,  :length => 250
end

DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://conception:Test1234@localhost/conception")

get '/' do
  erb :index
end

post '/' do
  begin
    date = Date.parse(params[:date]) << 9

    eventlist = Event.all(:date.lte => date, :date.gt => date - 14, :order => [ :date.desc ])[0,4]
    unless eventlist.empty?
      event = eventlist.sample
      erb :result, :locals => {:date => event[:date], :description => event[:description] }
    else
      erb :bored, :locals => {:date => date}
    end
  rescue ArgumentError
    halt 500, 'Illegal date'
  end
end

get '/scrape' do
  DataMapper.auto_migrate!
  
  doc = Nokogiri::parse(open('/home/maarten/Documents/data/data.xml'))
  doc.xpath('//event').each do |event|
    begin
      date = Date.parse(event.xpath('date').text)
      description = event.xpath('description').text.strip()
      #dates[date] = [] unless dates[date]
      #dates[date] << description
      Event.create(:date => date, :description => description)
    rescue ArgumentError

    end
  end
  "Done!"
end
