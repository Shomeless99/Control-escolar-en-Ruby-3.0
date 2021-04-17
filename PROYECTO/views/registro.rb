require 'fox16'
include Fox
require './../database/insertar'
class VentanaRegistro < FXMainWindow
    def initialize(app)
        super(app, "Registrar", :width => 300, :height => 150)
        hFrame1 = FXHorizontalFrame.new(self)
        labelUser = FXLabel.new(hFrame1, "User")
        textFieldUser = FXTextField.new(hFrame1, 20)

        hFrame2 = FXHorizontalFrame.new(self)
        labelPassword = FXLabel.new(hFrame2, "Password")
        textFieldPassword = FXTextField.new(hFrame2, 20)


        hFrame3 = FXHorizontalFrame.new(self)
        loginButton = FXButton.new(hFrame3, "Registrar")
        cancelButton = FXButton.new(hFrame3, "Cancelar")

        hFrame4 = FXHorizontalFrame.new(self)
        labelMessage = FXLabel.new(hFrame4, "")
        labelMessage.textColor = FXRGB(255, 0, 0)

        loginButton.connect(SEL_COMMAND) do
            user = textFieldUser.text
            password = textFieldPassword.text
            if (textFieldUser.text == "")
                labelMessage.text = "Error: Ingresa el usuario"
            elsif (textFieldPassword.text == "")
                labelMessage.text = "Error: Ingresa el password"
            else
                regOk = insert_user(user, password)
                if (regOk)
                    labelMessage.text = "Usuario registrado correctamente"
                else
                    labelMessage.text = "Error: Usuario ya registrado"
                end
                #self.close()
            end
        end
        cancelButton.connect(SEL_COMMAND) do self.close() end
    end
    
    def create
        super
        show(PLACEMENT_SCREEN)
    end
end

if __FILE__ == $0
    FXApp.new do |app|
        window = VentanaRegistro.new(app)
        app.create
        app.run
    end
end
