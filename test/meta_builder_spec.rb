require 'rspec'

class MetaBuilder
  attr_accessor :target_class, :properties, :validations

  def initialize
    @properties=[]
    @validations=[]
  end

  def add_validation(&validation_block)
    @validations << validation_block
  end

  def add_property(property)
    @properties << property
  end

  def build
    builder = Builder.new self
    define_properties(builder.singleton_class)
    builder
  end

  def define_properties(a_class)
    @properties.each do |property|
      a_class.send :attr_accessor, property
    end
  end
end

class Builder
  attr_accessor :meta_builder

  def initialize(meta_builder)
    @meta_builder = meta_builder
  end

  def build
    instance = @meta_builder.target_class.new
    @meta_builder.define_properties(@meta_builder.target_class)
    populate_attributes(instance)
    check_validations(instance)
    instance
  end

  def all_validations_pass(instance)
    @meta_builder.validations.all? do |validation|
      validation.call instance
    end
  end

  def check_validations(instance)
    raise 'Fallo al menos una validacion' unless
        all_validations_pass(instance)
  end

  def populate_attributes(instance)
    @meta_builder.properties.each { |property|
      attribute_name = "@#{property.to_s}"
      value=self.instance_variable_get(attribute_name)
      instance.instance_variable_set(attribute_name, value)
    }
  end
end

describe 'Tests de Metabuilder' do

  before do
    class Perro
    end
  end

  after do
    Object.send :remove_const, :Perro
  end

  it 'should crear_metabuilder' do
    meta_builder = MetaBuilder.new
    meta_builder.target_class = Perro
    meta_builder.add_property(:nombre)
    meta_builder.add_property(:raza)

    builder_perro = meta_builder.build()
    builder_perro.nombre='Fido'
    builder_perro.raza='Chihuahua'

    fido=builder_perro.build()
    fido.nombre.should == 'Fido'
    fido.raza.should == 'Chihuahua'
  end

  it 'testar validaciones tira exception si no pasan' do
    meta_builder = MetaBuilder.new
    meta_builder.target_class = Perro
    meta_builder.add_property(:nombre)
    meta_builder.add_property(:edad)
    meta_builder.add_property(:raza)
    meta_builder.add_validation do |perro|
      perro.edad > 0
    end

    builder_perro = meta_builder.build()
    builder_perro.nombre='Fido'
    builder_perro.raza='Chihuahua'
    builder_perro.edad=3
    fido=builder_perro.build()

    fido.edad.should == 3
  end

  it 'testar validaciones no hace nada si las condiciones pasan' do
    meta_builder = MetaBuilder.new
    meta_builder.target_class = Perro
    meta_builder.add_property(:nombre)
    meta_builder.add_property(:edad)
    meta_builder.add_property(:raza)
    meta_builder.add_validation do |perro|
      perro.edad > 0
    end

    builder_perro = meta_builder.build()
    builder_perro.nombre='Fido'
    builder_perro.raza='Chihuahua'
    builder_perro.edad=-1
    expect { builder_perro.build() }.to raise_error(Exception)
  end


end