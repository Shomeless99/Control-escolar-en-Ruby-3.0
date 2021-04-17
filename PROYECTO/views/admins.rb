require 'fox16'
include Fox
require_relative './../database/obtener'
require_relative './../database/guardar'
require_relative './login'

class VentanaAdmins < FXMainWindow

    @dataMaestros = nil
    @dataAlumnos = nil
    @dataMaterias = nil
    
    @tableMaestros = nil
    @tableAlumnos = nil
    @tableMaterias = nil

    @frameMaestros = nil
    @frameAlumnos = nil
    @frameMaterias = nil

    @user = nil

    def initialize(app, user)
        @user = user
        super(app, "Mis calificaciones", :width => 1230, :height => 700, :x => 40, :y => 10)
        self.connect(SEL_CLOSE, method(:on_close))
        
        hFrame1 = FXHorizontalFrame.new(self, :opts => LAYOUT_CENTER_X)
        labelWelcome = FXLabel.new(hFrame1, "Bienvenido administrador, #{user[:name]}", :opts => LAYOUT_CENTER_X)
        labelWelcome.textColor = FXRGB(255, 0, 0)
        labelWelcome.font = FXFont.new(getApp(), "Arial", 20)

        btnSignOut = FXButton.new(self, "Cerrar Sesión", :opts => LAYOUT_CENTER_X | BUTTON_NORMAL)
        btnSignOut.font = FXFont.new(getApp(), "Arial", 20)
        btnSignOut.connect(SEL_COMMAND) do
            on_close(nil, nil, nil)
        end

        formFrame = FXVerticalFrame.new(self, :opts => LAYOUT_FILL_X | LAYOUT_CENTER_X)
        
        
        formFrameH1 = FXHorizontalFrame.new(formFrame, :opts => LAYOUT_CENTER_X)
        label = FXLabel.new(formFrameH1, "Nombre")
        label.font = FXFont.new(getApp(), "Arial", 15)
        fieldName = FXTextField.new(formFrameH1, 30)
        fieldName.font = FXFont.new(getApp(), "Arial", 15)

        formFrameH2 = FXHorizontalFrame.new(formFrame, :opts => LAYOUT_CENTER_X)
        label = FXLabel.new(formFrameH2, "Usuario")
        label.font = FXFont.new(getApp(), "Arial", 15)
        fieldUser = FXTextField.new(formFrameH2, 30)
        fieldUser.font = FXFont.new(getApp(), "Arial", 15)

        formFrameH3 = FXHorizontalFrame.new(formFrame, :opts => LAYOUT_CENTER_X)
        label = FXLabel.new(formFrameH3, "Password")
        label.font = FXFont.new(getApp(), "Arial", 15)
        fieldPassword = FXTextField.new(formFrameH3, 30)
        fieldPassword.font = FXFont.new(getApp(), "Arial", 15)
        
        formFrameH4 = FXHorizontalFrame.new(formFrame, :opts => LAYOUT_CENTER_X)
        label = FXLabel.new(formFrameH4, "Tipo")
        label.font = FXFont.new(getApp(), "Arial", 15)
        cbo = FXComboBox.new(formFrameH4, 30, nil, 0, COMBOBOX_STATIC)
        cbo.font = FXFont.new(getApp(), "Arial", 15)


        
        cbo.editable = false
        cbo.appendItem("Maestro", 0)
        cbo.appendItem("Alumno", 1)
        cbo.appendItem("Administrador", 2)
        cbo.appendItem("Materia", 3)

        cbo.connect(SEL_COMMAND) do
            if ( cbo.currentItem == 3 )
                formFrameH2.visible = false
                formFrameH3.visible = false
            else
                formFrameH2.visible = true
                formFrameH3.visible = true
            end
            update_data()
        end
        
        btn = FXButton.new(formFrame, "Agregar", :opts => LAYOUT_CENTER_X | BUTTON_NORMAL)

        btn.font = FXFont.new(getApp(), "Arial", 20)
        btn.connect(SEL_COMMAND) do
            type = cbo.currentItem
            name = fieldName.text
            user = fieldUser.text
            password = fieldPassword.text
            
            res = true
            db_executed = false
            if ( type == 0 )
                if ( name == "" || user == "" || password == "" )
                    FXMessageBox.warning(app, MBOX_OK, "Error!", "Debes de llenar todos los campos.")
                else
                    res = insert_user(user, name, password, 2)
                    db_executed = true
                end
            elsif ( type == 1 )
                if ( name == "" || user == "" || password == "" )
                    FXMessageBox.warning(app, MBOX_OK, "Error!", "Debes de llenar todos los campos.")
                else
                    res = insert_user(user, name, password, 3)
                    db_executed = true
                end
            elsif ( type == 2 )
                if ( name == "" || user == "" || password == "" )
                    FXMessageBox.warning(app, MBOX_OK, "Error!", "Debes de llenar todos los campos.")
                else
                    res = insert_user(user, name, password, 1)
                    db_executed = true
                end
            else
                if ( name == "" )
                    FXMessageBox.warning(app, MBOX_OK, "Error!", "Debes de llenar todos los campos.")
                else
                    res = insert_materia(name, 10)
                    db_executed = true
                end
            end
            print "RESULTADO\n", res
            if ( ! res && db_executed ) 
                FXMessageBox.warning(app, MBOX_OK, "Error!", "Elemento ya registrado")
            else
                fieldName.text = ""
                fieldUser.text = ""
                fieldPassword.text = ""
            end
            update_data()
        end

        mainFrame = FXHorizontalFrame.new(self, :opts => LAYOUT_FILL)

        @frameMaestros = FXVerticalFrame.new(mainFrame, :opts => LAYOUT_FILL)
        @frameAlumnos = FXVerticalFrame.new(mainFrame, :opts => LAYOUT_FILL)
        @frameMaterias = FXVerticalFrame.new(mainFrame, :opts => LAYOUT_FILL)


        labelWelcome = FXLabel.new(@frameMaestros, "Maestros", :opts => LAYOUT_CENTER_X)
        labelWelcome.textColor = FXRGB(255, 0, 0)
        labelWelcome.font = FXFont.new(getApp(), "Arial", 20)
        labelWelcome = FXLabel.new(@frameAlumnos, "Alumnos", :opts => LAYOUT_CENTER_X)
        labelWelcome.textColor = FXRGB(255, 0, 0)
        labelWelcome.font = FXFont.new(getApp(), "Arial", 20)

        labelWelcome = FXLabel.new(@frameMaterias, "Materias", :opts => LAYOUT_CENTER_X)
        labelWelcome.textColor = FXRGB(255, 0, 0)
        labelWelcome.font = FXFont.new(getApp(), "Arial", 20)

        define_tables()
        update_data()
    end

    def define_tables
        @tableMaestros = FXTable.new(@frameMaestros, :opts => LAYOUT_FILL | TABLE_COL_SIZABLE | TABLE_NO_COLSELECT)
        @tableMaestros.setTableSize(1, 2)
        @tableMaestros.rowHeaderMode = LAYOUT_FIX_WIDTH
        @tableMaestros.rowHeaderWidth = 0
        @tableMaestros.editable = false
        @tableMaestros.setColumnText(0, "Nombre")
        @tableMaestros.setColumnText(1, "Usuario")


        @tableAlumnos = FXTable.new(@frameAlumnos, :opts => LAYOUT_FILL | TABLE_COL_SIZABLE | TABLE_NO_COLSELECT)
        @tableAlumnos.setTableSize(1, 2)
        @tableAlumnos.rowHeaderMode = LAYOUT_FIX_WIDTH
        @tableAlumnos.rowHeaderWidth = 0
        @tableAlumnos.editable = false
        @tableAlumnos.setColumnText(0, "Nombre")
        @tableAlumnos.setColumnText(1, "Usuario")

        @tableMaterias = FXTable.new(@frameMaterias, :opts => LAYOUT_FILL | TABLE_COL_SIZABLE | TABLE_NO_COLSELECT)
        @tableMaterias.setTableSize(1, 2)
        @tableMaterias.rowHeaderMode = LAYOUT_FIX_WIDTH
        @tableMaterias.rowHeaderWidth = 0
        @tableMaterias.editable = false
        @tableMaterias.setColumnText(0, "Nombre")
        @tableMaterias.setColumnText(1, "ID")
    end

    def update_data()
        maestros = get_maestros()
        alumnos = get_alumnos_all()
        materias = get_materias_all()


        print "\n", materias
        print "\n", maestros
        print "\n", alumnos

        @dataMaestros = maestros
        @dataAlumnos = alumnos
        @dataMaterias = materias

        update_maestros(maestros)
        update_alumnos(alumnos)
        update_materias(materias)

    end

    def update_maestros(data)
        @tableMaestros.setTableSize(data.length(), 3)
        
        @tableMaestros.setColumnText(0, "Nombre")
        @tableMaestros.setColumnText(1, "Usuario")
        @tableMaestros.setColumnText(2, "Acción")
        for i in 0...data.length()
            maestro = data[i]
            @tableMaestros.setItemText(i, 0, maestro[:name])
            @tableMaestros.setItemText(i, 1, maestro[:user])
            @tableMaestros.setItemText(i, 2, "Baja")
        end

        @tableMaestros.connect(SEL_SELECTED) do |sender, sel, pos|
            item = sender.getItem(pos.row, pos.col)
            row = pos.row
            col = pos.col
            if ( col == 2 )
                maestro = @dataMaestros[row]
                mainWindow2 = FXMainWindow.new(app, "Eliminar maestro", :width => 700, :height => 200, :x => 500, :y => 450)
                labelWelcome = FXLabel.new(mainWindow2, "¿Seguro que deseas eliminar al maestro #{maestro[:name]}?", :opts => LAYOUT_CENTER_X)
                labelWelcome.textColor = FXRGB(255, 0, 0)
                labelWelcome.font = FXFont.new(getApp(), "Arial", 20)

                hFrame = FXHorizontalFrame.new(mainWindow2, :opts => LAYOUT_CENTER_X)
                btnAceptar = FXButton.new(hFrame, "Aceptar")
                btnAceptar.font = FXFont.new(getApp(), "Arial", 20)
                btnCancel = FXButton.new(hFrame, "Cancelar")
                btnCancel.font = FXFont.new(getApp(), "Arial", 20)

                btnAceptar.connect(SEL_COMMAND) do
                    puts "should update"
                    puts "Eliminar #{maestro}"
                    #Obtiene materias del maestro
                    materias = get_materias(maestro)
                    for i in 0...materias.length()
                        materia = materias[i]
                        asignar_materia(materia[:id], nil)
                    end
                    delete_user(maestro[:user])
                    mainWindow2.close()
                    update_data()
                end
                btnCancel.connect(SEL_COMMAND) do
                    mainWindow2.close()
                end
                mainWindow2.create
                mainWindow2.show
            end
        end
    end

    def update_alumnos(data)
        @tableAlumnos.setTableSize(data.length(), 6)
        
        @tableAlumnos.setColumnText(0, "Nombre")
        @tableAlumnos.setColumnText(1, "Usuario")
        @tableAlumnos.setColumnText(2, "Acción")
        @tableAlumnos.setColumnText(3, "Acción")
        @tableAlumnos.setColumnText(4, "Acción")
        @tableAlumnos.setColumnText(5, "Materias")
        for i in 0...data.length()
            alumno = data[i]
            @tableAlumnos.setItemText(i, 0, alumno[:name])
            @tableAlumnos.setItemText(i, 1, alumno[:user])
            @tableAlumnos.setItemText(i, 2, "Inscribir")
            @tableAlumnos.setItemText(i, 3, "Baja Materia")
            @tableAlumnos.setItemText(i, 4, "Baja")
            @tableAlumnos.setItemText(i, 5, alumno[:materias].map { |item| item[:name] }.join(","))
        end

        @tableAlumnos.connect(SEL_SELECTED) do |sender, sel, pos|
            item = sender.getItem(pos.row, pos.col)
            row = pos.row
            col = pos.col
            if ( col == 2 )
                #INSCRICPIÓN DE ALUMNO A MATERIA
                materia = @dataAlumnos[row]
                mainWindow2 = FXMainWindow.new(app, "Selección", :width => 500, :height => 200, :x => 500, :y => 350)
                labelWelcome = FXLabel.new(mainWindow2, "Selecciona la materia a dar de alta", :opts => LAYOUT_CENTER_X)
                labelWelcome.textColor = FXRGB(255, 0, 0)
                labelWelcome.font = FXFont.new(getApp(), "Arial", 20)


                frameCBO = FXHorizontalFrame.new(mainWindow2, :opts => LAYOUT_CENTER_X)
                cbo = FXComboBox.new(frameCBO, 30, nil, 0, COMBOBOX_STATIC)
                cbo.font = FXFont.new(getApp(), "Arial", 15)
                cbo.editable = false

                materiasAlumno = @dataAlumnos[row][:materias].map { |item| item[:id] }
                alumno = @dataAlumnos[row]
                showedMaterias = []

                for i in 0...@dataMaterias.length()
                    materia = @dataMaterias[i]
                    if ( ! materiasAlumno.include?( materia[ :id ] ) )
                        cbo.appendItem("Materia: #{materia[:name]}, ID: #{materia[:id]}", i)
                        showedMaterias.append(materia)
                    end
                end

                hFrame = FXHorizontalFrame.new(mainWindow2, :opts => LAYOUT_CENTER_X)
                btnAceptar = FXButton.new(hFrame, "Aceptar")
                btnAceptar.font = FXFont.new(getApp(), "Arial", 20)
                btnCancel = FXButton.new(hFrame, "Cancelar")
                btnCancel.font = FXFont.new(getApp(), "Arial", 20)

                btnAceptar.connect(SEL_COMMAND) do
                    puts "should update"
                    materia = showedMaterias[cbo.currentItem]
                    inscribir_alumno(materia[:id], alumno[:user])
                    mainWindow2.close()
                    update_data()
                end
                btnCancel.connect(SEL_COMMAND) do
                    mainWindow2.close()
                end
                mainWindow2.create
                mainWindow2.show
            elsif ( col == 3)
                #BAJA DE ALUMNO EN UNA MATERIA
                materia = @dataAlumnos[row]
                mainWindow2 = FXMainWindow.new(app, "Selección", :width => 500, :height => 200, :x => 500, :y => 350)
                labelWelcome = FXLabel.new(mainWindow2, "Selecciona la materia a dar de baja", :opts => LAYOUT_CENTER_X)
                labelWelcome.textColor = FXRGB(255, 0, 0)
                labelWelcome.font = FXFont.new(getApp(), "Arial", 20)

                frameCBO = FXHorizontalFrame.new(mainWindow2, :opts => LAYOUT_CENTER_X)
                cbo = FXComboBox.new(frameCBO, 30, nil, 0, COMBOBOX_STATIC)
                cbo.font = FXFont.new(getApp(), "Arial", 15)

                cbo.editable = false

                materiasAlumno = @dataAlumnos[row][:materias]
                alumno = @dataAlumnos[row]

                for i in 0...materiasAlumno.length()
                    materia = materiasAlumno[i]
                    cbo.appendItem("Materia: #{materia[:name]}, ID: #{materia[:id]}", i)
                end

                hFrame = FXHorizontalFrame.new(mainWindow2, :opts => LAYOUT_CENTER_X)
                btnAceptar = FXButton.new(hFrame, "Aceptar")
                btnAceptar.font = FXFont.new(getApp(), "Arial", 20)
                btnCancel = FXButton.new(hFrame, "Cancelar")
                btnCancel.font = FXFont.new(getApp(), "Arial", 20)

                btnAceptar.connect(SEL_COMMAND) do
                    puts "should update"
                    materia = materiasAlumno[cbo.currentItem]
                    baja_alumno_materia(materia[:id], alumno[:user])
                    mainWindow2.close()
                    update_data()
                end
                btnCancel.connect(SEL_COMMAND) do
                    mainWindow2.close()
                end
                mainWindow2.create
                mainWindow2.show
            elsif ( col == 4 )
                #BAJA ALUMNO (BORRADO)
                alumno = @dataAlumnos[row]
                mainWindow2 = FXMainWindow.new(app, "Selección", :width => 700, :height => 200, :x => 400, :y => 350)
                labelWelcome = FXLabel.new(mainWindow2, "¿Seguro que deseas eliminar al alumno #{alumno[:name]}?", :opts => LAYOUT_CENTER_X)
                labelWelcome.textColor = FXRGB(255, 0, 0)
                labelWelcome.font = FXFont.new(getApp(), "Arial", 20)

                hFrame = FXHorizontalFrame.new(mainWindow2, :opts => LAYOUT_CENTER_X)
                btnAceptar = FXButton.new(hFrame, "Aceptar")
                btnAceptar.font = FXFont.new(getApp(), "Arial", 20)
                btnCancel = FXButton.new(hFrame, "Cancelar")
                btnCancel.font = FXFont.new(getApp(), "Arial", 20)

                btnAceptar.connect(SEL_COMMAND) do
                    puts "should update"
                    delete_user(alumno[:user])
                    mainWindow2.close()
                    update_data()
                end
                btnCancel.connect(SEL_COMMAND) do
                    mainWindow2.close()
                end
                mainWindow2.create
                mainWindow2.show
            end
        end
    end

    def update_materias(data)
        @tableMaterias.setTableSize(data.length(), 5)

        @tableMaterias.setColumnText(0, "Nombre")
        @tableMaterias.setColumnText(1, "ID")
        @tableMaterias.setColumnText(2, "Maestro")
        @tableMaterias.setColumnText(3, "Acción")
        @tableMaterias.setColumnText(4, "Acción")
        for i in 0...data.length()
            materia = data[i]
            @tableMaterias.setItemText(i, 0, materia[:name])
            @tableMaterias.setItemText(i, 1, materia[:id].to_s)
            @tableMaterias.setItemText(i, 2, materia[:maestro])
            @tableMaterias.setItemText(i, 3, "Asignar")
            @tableMaterias.setItemText(i, 4, "Baja")
            

        end

        @tableMaterias.connect(SEL_SELECTED) do |sender, sel, pos|
            item = sender.getItem(pos.row, pos.col)
            row = pos.row
            col = pos.col
            if ( col == 3 )
                materia = @dataMaterias[row]
                mainWindow2 = FXMainWindow.new(app, "Selección", :width => 300, :height => 200, :x => 300, :y => 150)
                labelWelcome = FXLabel.new(mainWindow2, "Selecciona el maestro", :opts => LAYOUT_CENTER_X)
                labelWelcome.textColor = FXRGB(255, 0, 0)
                labelWelcome.font = FXFont.new(getApp(), "Arial", 20)

                frameCBO = FXHorizontalFrame.new(mainWindow2, :opts => LAYOUT_CENTER_X)
                cbo = FXComboBox.new(frameCBO, 30, nil, 0, COMBOBOX_STATIC)

                cbo.font = FXFont.new(getApp(), "Arial", 10)
                cbo.editable = false

                for i in 0...@dataMaestros.length()
                    maestro = @dataMaestros[i]
                    cbo.appendItem("Nombre: #{maestro[:name]}, Usuario: #{maestro[:user]}", i)
                end

                hFrame = FXHorizontalFrame.new(mainWindow2, :opts => LAYOUT_CENTER_X)
                btnAceptar = FXButton.new(hFrame, "Aceptar")
                btnAceptar.font = FXFont.new(getApp(), "Arial", 20)
                btnCancel = FXButton.new(hFrame, "Cancelar")
                btnCancel.font = FXFont.new(getApp(), "Arial", 20)
                btnAceptar.connect(SEL_COMMAND) do
                    puts "should update"
                    maestro = @dataMaestros[cbo.currentItem]
                    asignar_materia(materia[:id], maestro[:user])
                    mainWindow2.close()
                    update_data()
                end
                btnCancel.connect(SEL_COMMAND) do
                    mainWindow2.close()
                end
                mainWindow2.create
                mainWindow2.show
            elsif ( col == 4 )
                #BAJA MATERIA (BORRADO)
                materia = @dataMaterias[row]
                mainWindow2 = FXMainWindow.new(app, "Selección", :width => 700, :height => 200, :x => 400, :y => 350)
                labelWelcome = FXLabel.new(mainWindow2, "¿Seguro que deseas eliminar la materia #{materia[:name]}, ID #{materia[:id]}?", :opts => LAYOUT_CENTER_X)
                labelWelcome.textColor = FXRGB(255, 0, 0)
                labelWelcome.font = FXFont.new(getApp(), "Arial", 20)

                hFrame = FXHorizontalFrame.new(mainWindow2, :opts => LAYOUT_CENTER_X)
                btnAceptar = FXButton.new(hFrame, "Aceptar")
                btnAceptar.font = FXFont.new(getApp(), "Arial", 20)
                btnCancel = FXButton.new(hFrame, "Cancelar")
                btnCancel.font = FXFont.new(getApp(), "Arial", 20)

                btnAceptar.connect(SEL_COMMAND) do
                    puts "should update"
                    baja_materia(materia[:id])
                    mainWindow2.close()
                    update_data()
                end
                btnCancel.connect(SEL_COMMAND) do
                    mainWindow2.close()
                end
                mainWindow2.create
                mainWindow2.show
            end
        end
    end

    def write_data_table(table)

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
        window = VentanaAdmins.new(app, {user: "adrian1", name: "Adrian Perez"})
        app.create
        app.run
    end
end
