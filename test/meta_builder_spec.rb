require 'rspec'
require_relative '../metabuilder/metabuilder'

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