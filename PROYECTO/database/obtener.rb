#!/usr/bin/ruby

require 'sqlite3'

DBNAME = "test.db"

def get_bd_path()
    if __FILE__ != $0
        "./../database/#{DBNAME}"
    else
        DBNAME
    end
end

def user_match(user, password)
    begin
        
        # Open a database
        db = SQLite3::Database.new get_bd_path()

        db.execute( "select user, password, type, name from users" ) do |row|
            p row
            if (row[0] == user && row[1] == password) 
                return true, {
                    'user': row[0],
                    'type': row[2],
                    'name': row[3]
                }
            end
        end

        return false, nil
    
        
    rescue SQLite3::Exception => e 
        
        puts "Exception occurred"
        puts e

    ensure
        db.close if db
    end
end

def get_maestros
    begin
        
        # Open a database
        db = SQLite3::Database.new get_bd_path()

        maestros = Array.new
        db.execute( "select name, user from users where type = 2") do |row|
            maestros.append({
                name: row[0],
                user: row[1]
            })
        end

        return maestros
        
    rescue SQLite3::Exception => e 
        
        puts "Exception occurred"
        puts e

    ensure
        db.close if db
    end
end

def get_alumnos_all
    begin
        
        # Open a database
        db = SQLite3::Database.new get_bd_path()

        alumnos = Array.new
        db.execute( "select name, user from users where type = 3") do |row|
            materias = Array.new
            db.execute( "select materias.name, materias.id from materias INNER JOIN inscritos WHERE inscritos.materia = materias.id AND inscritos.alumno = ?", [row[1]]) do |fila|
                materias.push({
                    name: fila[0],
                    id: fila[1]
                })
            end

            alumnos.append({
                name: row[0],
                user: row[1],
                materias: materias
            })
        end

        print "\nALUMNOS", alumnos

        return alumnos
        
    rescue SQLite3::Exception => e 
        
        puts "Exception occurred"
        puts e

    ensure
        db.close if db
    end
end

def get_materias_all
    begin
        
        # Open a database
        db = SQLite3::Database.new get_bd_path()

        materias = Array.new
        db.execute( "select id, name, periodos, maestro from materias") do |row|
            materias.append({
                id: row[0],
                name: row[1],
                periodos: row[2],
                maestro: row[3]
            })
        end

        return materias
        
    rescue SQLite3::Exception => e 
        
        puts "Exception occurred"
        puts e

    ensure
        db.close if db
    end
end

def get_materias(user)
    begin
        
        # Open a database
        db = SQLite3::Database.new get_bd_path()

        materias = Array.new
        db.execute( "select id, name, periodos from materias where maestro = ?", [user[:user]]) do |row|
            materias.append({
                id: row[0],
                name: row[1],
                periodos: row[2]
            })
        end

        return materias
        
    rescue SQLite3::Exception => e 
        
        puts "Exception occurred"
        puts e

    ensure
        db.close if db
    end
end

def get_alumnos_materia(materia)
    begin
        
        # Open a database
        db = SQLite3::Database.new get_bd_path()

        alumnos = Array.new
        materia_id = materia[:id]
        db.execute( "SELECT users.user, users.name FROM inscritos INNER JOIN users WHERE inscritos.materia = ? AND users.type = 3 AND inscritos.alumno = users.user", [materia_id]) do |row|
            alumnos.append({
                user: row[0],
                name: row[1],
                materia: materia_id
            })
        end

        return alumnos
        
    rescue SQLite3::Exception => e 
        
        puts "Exception occurred"
        puts e

    ensure
        db.close if db
    end
end


def get_materias_alumno(user)
    begin
        
        # Open a database
        db = SQLite3::Database.new get_bd_path()

        materias = Array.new
        user_id = user[:user]
        db.execute( "SELECT materias.name, materias.id, materias.periodos FROM materias INNER JOIN inscritos WHERE inscritos.materia = materias.id AND inscritos.alumno = ?", [user_id]) do |row|
            materias.append({
                name: row[0],
                id: row[1],
                periodos: row[2]
            })
        end

        return materias
        
    rescue SQLite3::Exception => e 
        
        puts "Exception occurred"
        puts e

    ensure
        db.close if db
    end
end

def get_calificacion_alumno_materia(user, materia, periodo)
    begin
        
        # Open a database
        db = SQLite3::Database.new get_bd_path()

        calificacion = nil
        materia_id = materia[:id]
        user_id = user[:user]
        db.execute( "SELECT calificaciones.calificacion FROM calificaciones WHERE calificaciones.materia = ? AND calificaciones.alumno = ? AND calificaciones.periodo = ?", [materia_id, user_id, periodo]) do |row|
            calificacion = row[0]
        end

        return calificacion
        
    rescue SQLite3::Exception => e 
        
        puts "Exception occurred"
        puts e

    ensure
        db.close if db
    end
end

def get_user_calificaciones(user)
    begin
        
        # Open a database
        db = SQLite3::Database.new get_bd_path()

        user_id = user[:user]

        print user
        calificaciones = Array.new
        db.execute( "SELECT materias.id, calificaciones.calificacion, calificaciones.periodo FROM inscritos INNER JOIN calificaciones INNER JOIN materias WHERE inscritos.materia = calificaciones.materia AND materias.id = inscritos.materia AND inscritos.alumno = calificaciones.alumno AND inscritos.alumno = ?", [user_id]) do |row|
            calificaciones.append({
                materia: row[0],
                calificacion: row[1],
                periodo: row[2]
            })
        end
        print "\nMISCALIFICACIONES", calificaciones
        return calificaciones
        
    rescue SQLite3::Exception => e 
        
        puts "Exception occurred"
        puts e

    ensure
        db.close if db
    end
end

#user_match("aone","1")
#print get_materias_alumno({user: "adrian1"})
#print get_maestros()
#print "maestros"
#print get_materias(get_maestros[0])
#print "\nOK"
#print get_alumnos_materia(get_materias(get_maestros()[0])[0])
#print "\nNOT"
#print get_user_calificaciones({user: "adrian1"})
#print get_calificacion_alumno_materia(get_alumnos_materia(get_materias(get_maestros()[1])[0])[0])