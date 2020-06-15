require 'fillable-pdf'
# install gem poppler
# require 'pdftoimage'
# require 'combine_pdf'

class FillformsController < ApplicationController
  PATH_CERFA = './app/assets/cerfa/'
  CERFA = 'cerfa.pdf'
  RESULTPDF = 'resultpdf'
  # PATH_CONTENTPDF = './app/assets/cerfa/contentpdf.pdf'
  # PATH_WPARCELR = './app/assets/cerfa/WPARCLR.pdf'

  def test
    setfields
    showpdf
  end

  private

  def showpdf
    pdf_filename = File.join(Rails.root, PATH_CERFA + RESULTPDF)
    send_file(pdf_filename, filename: RESULTPDF, disposition: 'inline', type: 'application/pdf')
  end

  def opencerfa
    FillablePDF.new PATH_CERFA + CERFA
  end

  def save(file)
    file.save_as(PATH_CERFA + RESULTPDF, flatten: true)
  end

  def setobject(file)
    file.set_field(:"topmostSubform[0].Page1[0].D6A_CUA[0]", 'Oui')
  end

  def setgender(file)
    file.set_field(:"topmostSubform[0].Page1[0].D1H_homme[0]", 'Oui')
  end

  def setuser(file)
    file.set_fields("topmostSubform[0].Page1[0].D1P_prenom[0]": 'Paul Muadib',
                    "topmostSubform[0].Page1[0].D1N_nom[0]": 'ATREIDE')
  end

  def setfields
    cerfa = opencerfa
    setobject(cerfa)
    setgender(cerfa)
    setuser(cerfa)
    save(cerfa)
  end

  # # --- Watermark on PDF with : 'gem install combine_pdf'
  # def watermatkpdf(file)
  #   company_logo = CombinePDF.load(PATH_WPARCELR).pages[0]
  #   pdf = CombinePDF.load PATH_RESULTPDF
  #   pdf.pages.each { |page| page << company_logo }
  #   pdf.save PATH_CONTENTPDF
  # end

  # # --------- PDF to JPG
  # def pdftoimage(file)
  #   images = PDFToImage.open(PATH_CONTENTPDF)
  #   images.each do |img|
  #   img.resize('100%').save("./app/assets/cerfa/pagea-#{img.page}.jpg")
  # end
end
