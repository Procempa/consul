
require_dependency Rails.root.join('app', 'models', 'verification', 'residence').to_s

class Verification::Residence

  validate :postal_code_in_poa
  validate :residence_in_poa

  def postal_code_in_poa
    errors.add(:postal_code, I18n.t('verification.residence.new.error_not_allowed_postal_code')) unless valid_postal_code?
  end

  def residence_in_poa
    return if errors.any?

    unless residency_valid?
      errors.add(:residence_in_madrid, false)
      store_failed_attempt
      Lock.increase_tries(user)
    end
  end

  private

    def valid_postal_code?
      # faixa de Porto Alegre segundo o site https://thiagorodrigo.com.br/artigo/cep-brasil-lista-de-cep-por-estados-capitais-e-interior/ no dia 31/07/2018
      postal_code > '90000000' && postal_code < '91999999'
    end

end
