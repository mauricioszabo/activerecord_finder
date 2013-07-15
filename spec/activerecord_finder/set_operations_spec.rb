require_relative "../helper"

describe ActiveRecordFinder::SetOperations do
  let!(:seventeen) { Person.create! :name => 'Foo', :age => 17 }
  let!(:eighteen) { Person.create! :name => 'Foo', :age => 18 }

  it 'UNIONs two relations' do
    relation1 = Person.where(age: 17)
    relation2 = Person.where(age: 18)
    relation1.unite_with(relation2).should include(seventeen, eighteen)
  end

  it 'UNIONs two relations with JOIN' do
    seventeen_with_join = Person.create!(age: 17)
    seventeen_with_join.addresses.create!
    relation1 = Person.where(age: 17).joins(:addresses)
    relation2 = Person.where(age: 18)

    result = relation1.unite_with(relation2)
    result.should include(seventeen_with_join, eighteen)
    result.should_not include(seventeen)
  end

  it 'INTERSECTs two relations' do
    bar = Person.create!(name: "Bar", age: 17)
    relation1 = Person.where(age: 17)
    relation2 = Person.where(name: "Foo")
    relation1.intersect_with(relation2).should == [seventeen]
  end

  it 'INTERSECTs two relations using another fields and another tables' do
    seventeen_bar = Person.create!(name: "Bar", age: 17)
    relation1 = Person.where(age: 17)
    relation2 = Person.where(name: "Foo")
    relation1.intersect_with(relation2, :age).should include(seventeen_bar, seventeen)
    relation1.intersect_with(relation2, :age).should_not include(eighteen)
  end

  it 'SUBTRACTs a relation from this one' do
    relation1 = Person.where(name: "Foo")
    relation2 = Person.where(age: 18)
    relation1.subtract(relation2).should == [seventeen]
  end
end