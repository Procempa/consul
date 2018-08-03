class Address < ActiveRecord::Base
    belongs_to :user, touch: true , :dependent => :destroy
 
    validates :street, presence: true , length: { minimum: 2 }, on: :update
    validates :number, presence: true, format: /\A[0-9]{1,8}\z/, on: :update
    validates :postal_code, presence: true, format: /\A[0-9]{8}\z/, on: :update

    #validates :district, presence: true
    validates :complement, presence: false, on: :update
    #validates :neighbourhood, presence: true, length: { minimum: 2 }, on: :update
    validates :user, presence: true
  
    validate :postal_code_in_poa, on: :update

    def postal_code_in_poa
        errors.add(:postal_code, I18n.t('verification.residence.new.error_not_allowed_postal_code')) unless valid_postal_code?
    end    

    private

    def valid_postal_code?
        # faixa de Porto Alegre segundo o site https://thiagorodrigo.com.br/artigo/cep-brasil-lista-de-cep-por-estados-capitais-e-interior/ no dia 31/07/2018
        postal_code > '90000000' && postal_code < '91999999'
    end    
end


