require 'fox16'
include Fox
require_relative './../database/obtener'
require_relative './../database/guardar'
require_relative './login'

class VentanaMaestros < FXMainWindow
    @user = nil
    def initialize(app, user)
        @user = user
        super(app, "Maestros", :width => 1000, :height => 660, :x => 40, :y => 50)
        self.connect(SEL_CLOSE, method(:on_close))

        hFrame1 = FXHorizontalFrame.new(self, :opts => LAYOUT_CENTER_X)
        labelWelcome = FXLabel.new(hFrame1, "Bienvenido maestro, #{user[:name]}", :opts => LAYOUT_CENTER_X)
        labelWelcome.textColor = FXRGB(255, 0, 0)
        labelWelcome.font = FXFont.new(getApp(), "Arial", 20)

        btnSignOut = FXButton.new(self, "Cerrar Sesión", :opts => LAYOUT_CENTER_X | BUTTON_NORMAL)
        btnSignOut.font = FXFont.new(getApp(), "Arial", 20)
        btnSignOut.connect(SEL_COMMAND) do
            on_close(nil, nil, nil)
        end

        max_periodos = 10
        materias = get_materias(user)
        print materias
        materia_alumnos, total_rows = get_alumnos(materias)


        #CANTIDAD DE FILAS NECESARIAS A MOSTRAR


        calificaciones = get_user_calificaciones(user)

        info = create_structure(materia_alumnos, total_rows, max_periodos)


        hFrame2 = FXHorizontalFrame.new(self)

        table = FXTable.new(self, :opts => LAYOUT_FILL | TABLE_COL_SIZABLE | TABLE_NO_COLSELECT)
        table.setTableSize(total_rows + materias.length() + 2, max_periodos + 2)


        table.rowHeaderMode = LAYOUT_FIX_WIDTH
        table.rowHeaderWidth = 0


        table.setColumnText(0, "Materia")
        table.setColumnText(1, "Alumno")



        table.connect(SEL_REPLACED) do |sender, selector, data|
            #puts sender

            sender.each {|cc| puts cc}
            pos = data.to()
            row = pos.row
            col = pos.col
            newValueRaw = sender.getItem(row, col)

            lastValue = ""
            if ( row.to_i < total_rows )
                lastValue = info[row][col + 2].to_s
            end

            print "\n ASIGNANDO /////////////"
            newValue = newValueRaw.to_s.to_f
            if ( row.to_i >= total_rows || col < 2)
                table.setItemText(row, col, lastValue)
            elsif ( ! ( Float(newValueRaw.to_s) rescue false ) )
                #print newValueRaw.to_s, "\n", newValue.to_s
                #print "|\n DEBE ALERTAR ERROR VALOR"
                table.setItemText(row, col, lastValue.to_s)
                FXMessageBox.warning(app, MBOX_OK, "Error!", "Calificación no válida!")
            
            elsif ( newValue >= 0 && newValue <= 100)
                #puts "CAMBIAR"
                
                if ( ! ( Float(lastValue.to_s) rescue false ))
                    res = capturar_calificacion(info[row][0], col - 1, info[row][1], newValue)
                
                    if ( res )
                        info[row][col + 2] = newValue
                    else
                        table.setItemText(row, col, info[row][col + 2].to_s)
                    end
                else
                    res = actualizar_calificacion(info[row][0], col - 1, info[row][1], newValue)
                    if ( res == true )
                        #print "TRUE"
                        info[row][col + 2] = newValue
                    else
                        table.setItemText(row, col, info[row][col + 2].to_s)
                    end
                end
                
            else
                table.setItemText(row, col, info[row][col + 2].to_s)
                #puts "CALIFICACION INCORRECTA"
                FXMessageBox.warning(app, MBOX_OK, "Error!", "Calificación no válida!")
            end
        end


        
        for i in 0...max_periodos
            table.setColumnText(i + 2, "Periodo #{i + 1}")
        end

        
        for i in 0...info.length()

            for j in 0...info[i].length()
                table.setItemText(i, j, info[i][j + 2])
            end

        end


        #LISTAR MATERIAS
        table.setItemText(total_rows + 1, 0, "LISTA DE MATERIAS")
        for i in 0...materias.length()

            materia = materias[i]
            table.setItemText(i + total_rows + 2, 0, materia[:name])

        end

    end

    def create_structure(materias_alumnos, total, max_periodos)
        structure = Array.new(total) { Array.new(max_periodos + 1, nil) }
        c = 0
        for i in 0...materias_alumnos.length()
            materia = materias_alumnos[i][:materia]
            alumnos = materias_alumnos[i][:alumnos]
            print materia

            for k in 0...alumnos.length()
                print "\nALUMNOSSSS", alumnos
                alumno = alumnos[k]

                structure[c][0] = materia[:id]
                structure[c][1] = alumno[:user]
                structure[c][2] = materia[:name]
                structure[c][3] = alumno[:name]
                for j in 0...max_periodos
                    calif = get_calificacion_alumno_materia(alumno, materia, j)
                    if ( calif ) 
                        structure[c][j + 3] = calif
                    end
                end
                c += 1

            end    
        end
        structure
    end

    def get_alumnos(materias)
        materia_alumnos = Array.new()
        count = 0
        for i in 0...materias.length()
            materia = materias[i]
            alumnos = get_alumnos_materia(materia)

            materia_alumnos.append({
                materia: materia,
                alumnos: alumnos
            })
            count += alumnos.length()
        end
        #alumnos = get_alumnos_materia(materias)

        return materia_alumnos, count
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
        window = VentanaMaestros.new(app, {user: "estrellaa", name: "Diana"})
        app.create
        app.run
    end
end
