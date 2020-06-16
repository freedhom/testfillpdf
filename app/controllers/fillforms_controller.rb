require 'combine_pdf'
require 'fillable-pdf'
require 'RMagick'

class FillformsController < ApplicationController
  PATH_CERFA = './app/assets/cerfa/'
  CERFA = PATH_CERFA + 'cerfa.pdf'
  RESULTPDF = PATH_CERFA + 'resultpdf'
  CONTENTPDF = PATH_CERFA + 'content.pdf'
  WPARCLR = PATH_CERFA + 'WPARCLR.pdf'

  def test
    setfields
    watermatkpdf(RESULTPDF, WPARCLR)
    pdftoimage(RESULTPDF)
    showpdf(WPARCLR.to_s + '.jpg')
  end

  private

  def showpdf(file)
    pdf_filename = File.join(Rails.root, file)
    send_file(pdf_filename, filename: 'resultpdf.pdf', disposition: 'inline', type: 'application/pdf')
  end

  def opencerfa
    FillablePDF.new CERFA
  end

  def save(file)
    file.save_as(RESULTPDF, flatten: true)
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

  # --- Watermark on PDF with : 'gem install combine_pdf'
  def watermatkpdf(source, logo)
    company_logo = CombinePDF.load(logo).pages[0]
    pdf = CombinePDF.load source
    pdf.pages.each { |page| page << company_logo }
    pdf.save CONTENTPDF
  end

  # --------- PDF to JPG
  def pdftoimage(pdf_file_name)
    im = Magick::Image.read(pdf_file_name)
    im[0].write(pdf_file_name + '.jpg') { self.quality = 100 }
  end
end
