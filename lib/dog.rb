require 'pry'

class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(hash)
    hash.each do |k, v|
        instance_variable_set("@#{k}", v)
    end
  end

  def self.create_table
    DB[:conn].execute('CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT);')
  end

  def self.drop_table
    DB[:conn].execute('DROP TABLE IF EXISTS dogs')
  end

  def self.create(hash)
    new_dog = Dog.new(hash)
    new_dog.save
  end

  def self.new_from_db(array)
    Dog.create({:id => array[0], :name => array[1], :breed => array[2]})
  end

  def self.find_or_create_by(hash)
    finding = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", hash[:name], hash[:breed])[0]
    finding ? Dog.new({:id => finding[0], :name => finding[1], :breed => finding[2]}) : Dog.new(hash).save
  end

  def self.find_by_name(name)
    finding = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? LIMIT 1", name)[0]
    finding ? Dog.new({:id => finding[0], :name => finding[1], :breed => finding[2]}) : false
  end

  def update
    result = DB[:conn].execute('SELECT * FROM dogs WHERE id = ?', self.id)[0]
    result ? DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id) : self.save
    self
  end

  def save
    Dog.create_table
    sql = <<-SQL
    INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].last_insert_row_id
    self
  end

  def self.find_by_id(id)
    result = DB[:conn].execute('SELECT * FROM dogs WHERE id = ?', id)[0]
    Dog.new({:id => result[0], :name => result[1], :breed => result[2]})
  end

end