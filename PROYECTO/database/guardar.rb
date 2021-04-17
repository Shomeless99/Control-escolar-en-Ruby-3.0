#!/usr/bin/ruby

require 'sqlite3'

BDNAME = "test.db"

def get_bd_path()
    if __FILE__ != $0
        "./../database/#{BDNAME}"
    else
        BDNAME
    end
end

def insert_user(user, name, password, type)
    begin
        
        # Open a database
        db = SQLite3::Database.new get_bd_path()


        rec = db.execute "insert into users (user, name, password, type) values ( ?, ?, ?, ? )", [user, name, password, type]
        return true
        
    rescue SQLite3::Exception => e 
        
        puts "Exception occurred"
        puts e
        return false
        
    ensure
        db.close if db
    end
end

def delete_user(user)
    begin
        # Open a database
        db = SQLite3::Database.new get_bd_path()

        db.execute("PRAGMA foreign_keys = ON")
        db.execute "DELETE FROM users WHERE user = ?", [user]

        return true
        
    rescue SQLite3::Exception => e 
        
        puts "Exception occurred"
        puts e
        return false
        
    ensure
        db.close if db
    end
end

def insert_materia(name, periodos)
    begin
        
        # Open a database
        db = SQLite3::Database.new get_bd_path()

        db.execute "insert into materias (name, periodos) values ( ? , ? )", [name, periodos]

        return true
        
    rescue SQLite3::Exception => e 
        
        puts "Exception occurred"
        puts e
        return false
        
    ensure
        db.close if db
    end
end

def baja_materia(id)
    begin
        
        # Open a database
        db = SQLite3::Database.new get_bd_path()
        db.execute("PRAGMA foreign_keys = ON")
        db.execute "DELETE FROM materias WHERE id = ?", [id]

        return true
        
    rescue SQLite3::Exception => e 
        
        puts "Exception occurred"
        puts e
        return false
        
    ensure
        db.close if db
    end
end

def asignar_materia(materia, maestro)
    begin
        
        # Open a database
        db = SQLite3::Database.new get_bd_path()

        db.execute "UPDATE materias SET maestro = ? WHERE id = ?", [maestro, materia]

        return true
        
    rescue SQLite3::Exception => e 
        
        puts "Exception occurred"
        puts e
        return false
        
    ensure
        db.close if db
    end
end

def inscribir_alumno(materia, alumno)
    begin
        
        # Open a database
        db = SQLite3::Database.new get_bd_path()

        db.execute "INSERT INTO inscritos (materia, alumno) VALUES( ?, ? )", [materia, alumno]

        return true
        
    rescue SQLite3::Exception => e 
        
        puts "Exception occurred"
        puts e
        return false
        
    ensure
        db.close if db
    end
end

def baja_alumno_materia(materia, alumno)
    begin
        
        # Open a database
        db = SQLite3::Database.new get_bd_path()
        #BORRAR CALIFICACIONES
        db.execute "DELETE FROM calificaciones WHERE materia = ? AND alumno = ?", [materia, alumno]

        #BORRAR INSCRIPCIÓN
        db.execute "DELETE FROM inscritos WHERE materia = ? AND alumno = ?", [materia, alumno]

        return true
        
    rescue SQLite3::Exception => e 
        
        puts "Exception occurred"
        puts e
        return false
        
    ensure
        db.close if db
    end
end

def capturar_calificacion(materia, periodo, alumno, calif)
    begin
        
        # Open a database
        db = SQLite3::Database.new get_bd_path()

        resdb = db.execute "INSERT INTO calificaciones (materia, periodo, alumno, calificacion) VALUES( ?, ?, ?, ? )", [materia, periodo, alumno, calif]
        print "@@@@RESULTADO ", resdb
        return true
        
    rescue SQLite3::Exception => e 
        
        puts "Exception occurred"
        puts e
        return false
        
    ensure
        db.close if db
    end
end

def actualizar_calificacion(materia, periodo, alumno, calif)
    begin
        # Open a database
        db = SQLite3::Database.new get_bd_path()

        db.execute "UPDATE calificaciones SET calificacion = ? WHERE materia = ? AND periodo = ? AND alumno = ?", [calif, materia, periodo, alumno]

        return true
        
    rescue SQLite3::Exception => e 
        
        puts "Exception occurred"
        puts e
        return false
        
    ensure
        db.close if db
    end
end




#insert_user("diego", "Diego Alejandro", "sopl", 3)
#print insert_materia("REDES", 4)
#print asignar_materia(5, "diana")
#print inscribir_alumno(5, "diego")
#print capturar_calificacion(5, "adrian1", 8.5)