# coding: utf-8

require 'spec_helper.rb'

describe Cacofonix::Product do

  before(:each) do
    load_doc_and_root("product.xml")
    @product_node = @root
  end

  it "should provide read access to first level attributes" do
    product = Cacofonix::Product.from_xml(@product_node.to_s)

    product.record_reference.should eql("365-9780194351898")
    product.notification_type.should eql(3)
    product.product_form.should eql("BC")
    product.edition_number.should eql(1)
    product.number_of_pages.should eql(100)
    product.bic_main_subject.should eql("EB")
    product.publishing_status.should eql(4)
    product.publication_date.should eql(Date.civil(1998,9,1))
    product.year_first_published.should eql(1998)

    # including ye olde, deprecated ones
    product.height.should eql(100)
    product.width.should eql(BigDecimal("200.5"))
    product.weight.should eql(300)
    product.thickness.should eql(300)
    product.dimensions.should eql("100x200")
  end

  it "should provide read access to product IDs" do
    product = Cacofonix::Product.from_xml(@product_node.to_s)
    product.product_identifiers.size.should eql(3)
  end

  it "should provide read access to titles" do
    product = Cacofonix::Product.from_xml(@product_node.to_s)
    product.titles.size.should eql(1)
  end

  it "should provide read access to subjects" do
    product = Cacofonix::Product.from_xml(@product_node.to_s)
    product.subjects.size.should eql(1)
  end

  it "should provide read access to measurements" do
    product = Cacofonix::Product.from_xml(@product_node.to_s)
    product.measurements.size.should eql(1)
  end

  it "should provide write access to first level attributes" do
    product = Cacofonix::Product.new

    product.notification_type = 3
    product.to_xml.to_s.include?("<NotificationType>03</NotificationType>").should be true

    product.record_reference = "365-9780194351898"
    product.to_xml.to_s.include?("<RecordReference>365-9780194351898</RecordReference>").should be true

    product.product_form = "BC"
    product.to_xml.to_s.include?("<ProductForm>BC</ProductForm>").should be true

    product.edition_number = 1
    product.to_xml.to_s.include?("<EditionNumber>1</EditionNumber>").should be true

    product.number_of_pages = 100
    product.to_xml.to_s.include?("<NumberOfPages>100</NumberOfPages>").should be true

    product.bic_main_subject = "EB"
    product.to_xml.to_s.include?("<BICMainSubject>EB</BICMainSubject>").should be true

    product.publishing_status = 4
    product.to_xml.to_s.include?("<PublishingStatus>04</PublishingStatus>").should be true

    product.publication_date = Date.civil(1998,9,1)
    product.to_xml.to_s.include?("<PublicationDate>19980901</PublicationDate>").should be true

    product.year_first_published = 1998
    product.to_xml.to_s.include?("<YearFirstPublished>1998</YearFirstPublished>").should be true
  end

  it "should correctly from_xml files that have an invalid publication date" do
    file = find_data_file("product_invalid_pubdate.xml")
    product = Cacofonix::Product.from_xml(File.read(file))

    product.bic_main_subject.should eql("VXFC1")
    product.publication_date.should be_nil
  end


  it "should load an interpretation" do
    product = Cacofonix::Product.new
    product.interpret(Cacofonix::SpecInterpretations::Setters)
    product.title = "Grimm's Fairy Tales"
    product.titles.first.title_text.should eql("Grimm's Fairy Tales")
  end

  it "should load several interpretations" do
    product = Cacofonix::Product.new
    product.interpret([
      Cacofonix::SpecInterpretations::Getters,
      Cacofonix::SpecInterpretations::Setters
    ])
    product.title = "Grimm's Fairy Tales"
    product.title.should eql("grimm's fairy tales")
  end

  it "should pass on interpretations to other products" do
    product1 = Cacofonix::Product.new
    product1.interpret([
      Cacofonix::SpecInterpretations::Getters,
      Cacofonix::SpecInterpretations::Setters
    ])

    product2 = Cacofonix::Product.new
    product1.interpret_like_me(product2)
    product2.title = "Grimm's Fairy Tales"
    product2.title.should eql("grimm's fairy tales")
  end

end
