#require 'combine_pdf'
require 'fillable-pdf'
require 'rmagick'
class CertificateRequestsController < ApplicationController
  PATH_CERFA = './app/assets/cerfa/'
  CERFA = PATH_CERFA + 'cerfa.pdf'
  RESULTPDF = PATH_CERFA + 'resultpdf'
  CONTENTPDF = PATH_CERFA + 'content.pdf'
  WPARCLR = PATH_CERFA + 'WPARCLR.pdf'
  before_action :set_certificate, only: [:show]

  def show; end

  def new
    @certificate_request = CertificateRequest.new
    @user = current_user
  end

  def create
    @certificate_request = CertificateRequest.new(certificate_params)
    @user = current_user
    @certificate_request.user = @user
    if @certificate_request.save
      setfieldscerfa
      pdftoimage(RESULTPDF)
      redirect_to certificate_request_path(@certificate_request)
    else
      render :new
    end
  end

  def showcerfapdf
    showpdf(CONTENTPDF)
  end

  private

  def set_certificate
    @certificate_request = CertificateRequest.find(params[:id])
  end

  def certificate_params
    params.require(:certificate_request).permit(:parcel_street_number, :parcel_street,
                                                :parcel_zip_code, :parcel_city,
                                                :parcel_section, :parcel_number,
                                                :parcel_area)
  end

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
    @user = current_user
    if @user.prefix == 'M.'
      homme = 'Oui'
      femme = ''
    else
      femme = 'Oui'
      homme = ''
    end
    file.set_fields("topmostSubform[0].Page1[0].D1F_femme[0]": femme,
                    "topmostSubform[0].Page1[0].D1H_homme[0]": homme)
  end

  #                   -- USER --
  def setuser(file)
    @user = current_user
    file.set_fields("topmostSubform[0].Page1[0].D1N_nom[0]": @user.last_name,
                    "topmostSubform[0].Page1[0].D1P_prenom[0]": @user.first_name,
                    "topmostSubform[0].Page1[0].D3N_numero[0]": @user.street_number,
                    "topmostSubform[0].Page1[0].D3V_voie[0]": @user.street,
                    "topmostSubform[0].Page1[0].D3L_localite[0]": @user.city,
                    "topmostSubform[0].Page1[0].D3C_code[0]": @user.zip_code,
                    "topmostSubform[0].Page1[0].D3T_telephone[0]": @user.phone,
                    "topmostSubform[0].Page1[0].D5A_acceptation[0]": "Oui",
                    "topmostSubform[0].Page1[0].T2Q_numero[0]": @certificate_request.parcel_street_number,
                    "topmostSubform[0].Page1[0].T2V_voie[0]": @certificate_request.parcel_street,
                    "topmostSubform[0].Page1[0].T2L_localite[0]": @certificate_request.parcel_city,
                    "topmostSubform[0].Page1[0].T2C_code[0]": @certificate_request.parcel_zip_code,
                    "topmostSubform[0].Page1[0].T2S_section[0]": @certificate_request.parcel_section,
                    "topmostSubform[0].Page1[0].T2N_numero[0]": @certificate_request.parcel_number,
                    "topmostSubform[0].Page1[0].D5T_total[0]": @certificate_request.parcel_area)
  end

  def setemail(file)
    @user = current_user
    file.set_fields("topmostSubform[0].Page1[0].D5GE1_email[0]": @user.email,
                    "topmostSubform[0].Page1[0].D5GE2_email[0]": "")
  end

  def setfieldscerfa
    cerfa = opencerfa
    setobject(cerfa)
    setgender(cerfa)
    setuser(cerfa)
    setemail(cerfa)
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
