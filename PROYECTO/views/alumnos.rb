require 'fox16'
include Fox
require_relative './../database/obtener'
require './login'
class VentanaAlumnos < FXMainWindow
    @user = nil
    def initialize(app, user)
        @user = user
        super(app, "Mis calificaciones", :width => 1000, :height => 660, :x => 40, :y => 50)
        self.connect(SEL_CLOSE, method(:on_close))

        hFrame1 = FXHorizontalFrame.new(self, :opts => LAYOUT_CENTER_X)
        labelWelcome = FXLabel.new(hFrame1, "Bienvenido alumno, #{user[:name]}")
        labelWelcome.textColor = FXRGB(255, 0, 0)
        labelWelcome.font = FXFont.new(getApp(), "Arial", 20)


        btnSignOut = FXButton.new(self, "Cerrar Sesión", :opts => LAYOUT_CENTER_X | BUTTON_NORMAL)
        btnSignOut.font = FXFont.new(getApp(), "Arial", 20)
        btnSignOut.connect(SEL_COMMAND) do
            on_close(nil, nil, nil)
        end


        max_periodos = 10
        materias = get_materias_alumno(user)
        calificaciones = get_user_calificaciones(user)

        hFrame2 = FXHorizontalFrame.new(self)

        table = FXTable.new(self, :opts => LAYOUT_FILL | TABLE_COL_SIZABLE | TABLE_NO_COLSELECT)
        table.setTableSize(materias.length(), max_periodos + 1)


        table.rowHeaderMode = LAYOUT_FIX_WIDTH
        table.rowHeaderWidth = 0

        table.editable = false

        #table.font = FXFont.new(getApp(), "Arial", 20)

        table.setColumnText(0, "Materia")


        for i in 0...max_periodos
            table.setColumnText(i + 1, "Periodo #{i + 1}")
        end

        

        for i in 0...materias.length()
            materia = materias[i]
            table.setItemText(i, 0, materia[:name])

            for j in 0...max_periodos
                calif = calificaciones.select {|calif| calif[:periodo] == j + 1 && calif[:materia] == materia[:id] }
                if ( calif.length() > 0 )
                    table.setItemText(i, j + 1, calif[0][:calificacion])
                end
            end

        end

    end

    def on_close(sender, sel, event)
        q = FXMessageBox.question(app, MBOX_YES_NO, "Cerrar?", "¿Estás seguro de cerrar sesión?")
        if q == MBOX_CLICKED_YES
            window = Ventana.new(app, @user)
            window.create
            window.show
            self.close()
        end
    end

    def create
        super
        show(PLACEMENT_SCREEN)
    end
end


if __FILE__ == $0
    FXApp.new do |app|
        window = VentanaAlumnos.new(app, {user: "adrian1", name: "Adrian Perez"})
        app.create
        app.run
    end
end
