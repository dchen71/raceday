class Racer
  include Mongoid::Document
  include ActiveModel::Model
  attr_accessor :id, :number, :first_name, :last_name, :gender, :group, :secs


  #Shortcut to default database
  def self.mongo_client
  	db = Mongo::Client.new('mongodb://localhost:27017')
  end

  #Returns db collection holding Racer
  def self.collection
  	self.mongo_client['racers']
  end

  #Finds all rows in collection which can match based on sort, skip, limit
  def self.all(prototype={}, sort={:number => 1}, skip=0, limit=nil)    
  	result=collection.find(prototype)        
  	.sort(sort)        
  	.skip(skip)      
  	if !limit.nil?
  		result = result.limit(limit)
  	end
  	result  
  end

  #Initializes properties of class using keys from racers
  def initialize(params={})
  	@id=params[:_id].nil? ? params[:id] : params[:_id].to_s
  	@number=params[:number].to_i
  	@first_name=params[:first_name]
  	@last_name=params[:last_name]
  	@gender=params[:gender]
  	@group=params[:group]
  	@secs=params[:secs].to_i
  end

  #Finds document with specific _id
  def self.find(id)
  	result=collection.find(:_id => BSON::ObjectId.from_string(id))
  					 .projection({_id:true, number:true, first_name:true, last_name:true, gender:true, group:true, secs:true})
  					 .first
  	return result.nil? ? nil : Racer.new(result)
  end

  #Saves and inserts data into database
  def save
  	result=self.class.collection.insert_one(number:@number, first_name: @first_name, 
  		last_name: @last_name, gender: @gender, group: @group, secs: @secs)
  	@id=result.inserted_id.to_s
  end

  #Updates database based on hash
  def update(params)
  	@number=params[:number].to_i
  	@first_name=params[:first_name]
  	@last_name=params[:last_name]
  	@secs=params[:secs].to_i
  	@gender=params[:gender]
  	@group=params[:group]
  	
  	params.slice!(:number, :first_name, :last_name, :gender, :group, :secs)
	self.class.collection
	            .find(:_id=>BSON::ObjectId.from_string(@id))
	            .replace_one(params)
  	
  end

  #Deletes an entry
  def destroy
  	self.class.collection.find(_id:BSON::ObjectId.from_string(@id)).delete_one()
  
  end

  #Checks if object is persisted or not
  def persisted?
  	!@id.nil?
  end

  #Added placeholder functions
  def created_at
  	nil
  end
  def updated_at
  	nil
  end

  #Pagination
  def self.paginate(params)
    page=(params[:page] || 1).to_i
    limit=(params[:per_pate] || 30).to_i
    skip=(page-1)*limit

    racers=[]

      racers << Racer.new(doc)



    WillPaginate::Collection.create(page, limit, total) do |pager|
      pager.replace(racers)
    end
  end

end
