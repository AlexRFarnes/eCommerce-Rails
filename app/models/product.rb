# == Schema Information
#
# Table name: products
#
#  id         :bigint           not null, primary key
#  code       :string
#  price      :integer          default(0)
#  stock      :integer          default(0)
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Product < ApplicationRecord

    # save
    before_save :validate_product
    after_save :send_notification
    after_save :push_notification, if: :discount?

    validates :title, presence: { message: "Es necesario definir un valor para el titulo" }
    validates :code, presence: { message: "Es necesario definir un valor para el codigo" }

    validates :code, uniqueness: { message: "El codigo %{value} ya se encuentra en uso" } # El placeholder %{value} permite pasar el valor del atributo

    # validates :price, length: { minimum: 3, maximum: 10 }
    validates :price, length: { in: 3..10, message: "El precio se encuentra fuera de rango (Min: 3, Max: 10" }, if: :has_price?

    validate :code_validate

    validates_with ProductValidator

    
    def total
        # el precio esta guardado en centavos
        self.price / 100
    end

    def discount?
        self.total <= 5
    end

    def has_price?
        # primero chequear que tenga un precio y luego que sea mayor a 0
        !self.price.nil? && self.price > 0
    end

    private

    def code_validate
        if self.code.nil? || self.code.length < 3 
            self.errors.add(:code, "El codigo debe poseer al menos 3 caracteres.")
        end
    end

    def validate_product
        puts "\n\n\n>>>>>> Un nuevo producto sera añadido a almacen!"
    end

    def send_notification
        puts "\n\n\n>>>>>> Un nuevo producto fue añadido a almacen: #{self.title} - $#{self.total} USD"
    end

    # Si el precio es menor o igual que $5
    def push_notification
        puts "\n\n\n>>>>>> Un nuevo producto en descuento se encuentra disponible: #{self.title}"
    end


end
