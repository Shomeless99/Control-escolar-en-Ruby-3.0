require 'fox16'
include Fox
require_relative './registro'
require_relative './../database/obtener'
require_relative './alumnos'
require_relative './admins'
require_relative './maestros'

class Ventana < FXMainWindow
    def initialize(app, user)
        super(app, "Login", :width => 500, :height => 200)
        hFrame1 = FXHorizontalFrame.new(self, :opts => LAYOUT_CENTER_X)
        labelUser = FXLabel.new(hFrame1, "Usuario")
        labelUser.font = FXFont.new(getApp(), "Arial", 20)
        textFieldUser = FXTextField.new(hFrame1, 15, :opts => TEXTFIELD_ENTER_ONLY)
        textFieldUser.font = FXFont.new(getApp(), "Arial", 20)
        textFieldUser.text = user[:user]

        hFrame2 = FXHorizontalFrame.new(self, :opts => LAYOUT_CENTER_X)
        labelPassword = FXLabel.new(hFrame2, "Contraseña")
        labelPassword.font = FXFont.new(getApp(), "Arial", 20)
        textFieldPassword = FXTextField.new(hFrame2, 15, nil, 0, :opts => TEXTFIELD_PASSWD | TEXTFIELD_ENTER_ONLY)
        textFieldPassword.font = FXFont.new(getApp(), "Arial", 20)


        hFrame21 = FXHorizontalFrame.new(self, :opts => LAYOUT_CENTER_X)
        labelMessage = FXLabel.new(hFrame21, "")


        hFrame3 = FXHorizontalFrame.new(self, :opts => LAYOUT_CENTER_X)
        loginButton = FXButton.new(hFrame3, "Login")
        loginButton.font = FXFont.new(getApp(), "Arial", 20)
        cancelButton = FXButton.new(hFrame3, "Cancelar")
        cancelButton.font = FXFont.new(getApp(), "Arial", 20)

        
        registerButton = FXButton.new(hFrame3, "Registrar")
        registerButton.font = FXFont.new(getApp(), "Arial", 20)

        #Para quitar funcionalidad de registro
        registerButton.hide()

        labelMessage.textColor = FXRGB(255, 0, 0)
        labelMessage.font = FXFont.new(getApp(), "Arial", 20)

        

        inner = ->() {
            user = textFieldUser.text
            password = textFieldPassword.text
            if (textFieldUser.text == "")
                labelMessage.text = "Error: Ingresa el usuario"
                #return
            elsif (textFieldPassword.text == "")
                labelMessage.text = "Error: Ingresa el password"
                #return
            else
                matchs, user = user_match(user, password)
                if (matchs)
                    puts "Open window"
                    user_type = user[:type]
                    puts user_type
                    puts user
                    window = nil
                    if (user_type.to_i == 1)
                        window = VentanaAdmins.new(app, user)
                    elsif ( user_type.to_i == 2 )
                        window = VentanaMaestros.new(app, user)
                    
                    else
                        window = VentanaAlumnos.new(app, user)


                        #mainWindow2 = FXMainWindow.new(app, "Principal", :width => 1000, :height => 500, :x => 40, :y => 50)
                        #labelWelcome = FXLabel.new(mainWindow2, "Bienvenido #{user}")
                        #labelWelcome.textColor = FXRGB(255, 0, 0)
                        #mainWindow2.create
                        #mainWindow2.show
                    end
                    window.create
                    window.show
                    self.close()
                else
                    labelMessage.text = "Error: Datos incorrectos"
                end
            end
        }

        textFieldUser.connect(SEL_COMMAND) do inner.call() end
        textFieldPassword.connect(SEL_COMMAND) do inner.call() end
        loginButton.connect(SEL_COMMAND) do inner.call() end

        registerButton.connect(SEL_COMMAND) do
            window = VentanaRegistro.new(app)
            window.create
            window.show
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
        window = Ventana.new(app, { user: '' })
        app.create
        app.run
    end
end
