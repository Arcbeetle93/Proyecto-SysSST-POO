require 'singleton'

class Colaborador
    attr_accessor :dni, :nombre, :area, :edad, :sueldo, :estadoActual, :evaluacionMedica, :convenios

    def initialize(dni, nombre, area, edad, sueldo, estadoActual)
        @dni = dni
        @nombre = nombre
        @area = area
        @edad = edad
        @sueldo = sueldo
        @estadoActual = estadoActual
        @evaluacionMedica = nil
        @convenios = []
    end

    def validarDNI
        if !dni.numeric?
            raise "DNI debe ser numérico"
        end

        return true
    end

    def descripcionArea
        case area
        when 1
            "TI"
        when 2
            "Comercial"
        when 3
            "GH"
        when 4
            "Contraloría"
        when 5
            "AyF"
        end
    end

    def descripcionAfiliado
        case estadoActual
        when 0
            "No afiliado"
        when 1
            "Afiliado"
        end
    end
end

class EvaluacionMedica
    attr_reader :dni, :peso, :talla, :diabetes, :cardiovasculares, :respiratorias, :inmunodeficiencia

    def initialize(dni, peso, talla, diabetes, cardiovasculares, respiratorias, inmunodeficiencia)
        @dni = dni
        @peso = peso
        @talla = talla
        @diabetes = diabetes
        @cardiovasculares = cardiovasculares
        @respiratorias = respiratorias
        @inmunodeficiencia = inmunodeficiencia
    end

    def calcularIMC
        peso / (talla * talla)
    end
end

class Convenio
    attr_reader :codigo, :nombre, :categoria, :costoBase, :meses
    
    def initialize(codigo, nombre, categoria, costoBase, meses)
        @codigo = codigo
        @nombre = nombre
        @categoria = categoria
        @costoBase = costoBase
        @meses = meses
    end

    def calcularPrecio
        costoBase + calcularAdicionalCategoria
    end

    def calcularAdicionalCategoria
        adicionalCategoria = 0

        case categoria
        when 1
            adicionalCategoria += 100
        when 2
            adicionalCategoria += 200
        when 3
            adicionalCategoria += 300
        end

        return adicionalCategoria
    end
end

class Gimnasio < Convenio
    attr_reader :nivelAcceso

    def initialize(codigo, nombre, categoria, costoBase, meses, nivelAcceso)
        super(codigo, nombre, categoria, costoBase, meses)
        @nivelAcceso = nivelAcceso
    end

    def calcularPrecio
        super + calcularPrecioAcceso
    end

    def calcularPrecioAcceso
        adicionalAcceso = 0

        case nivelAcceso
        when 1
            adicionalAcceso += 100 #Distrito
        when 2
            adicionalAcceso += 200 #Distrito + Oficina
        when 3
            adicionalAcceso += 300 #Todo Lima + Oficina
        end

        return adicionalAcceso
    end
end

class Alimentacion < Convenio
    attr_reader :desayuno, :almuerzo, :cena  

    def initialize(codigo, nombre, categoria, costoBase, meses, desayuno, almuerzo, cena)
        super(codigo, nombre, categoria, costoBase, meses)
        @desayuno = desayuno
        @almuerzo = almuerzo
        @cena = cena
    end

    def calcularPrecio
        super + calcularPrecioComidas
    end

    def calcularPrecioComidas
        adicionalComidas = 0
        if desayuno
            adicionalComidas += 50
        end

        if almuerzo
            adicionalComidas += 50
        end

        if cena
            adicionalComidas += 50
        end

        return adicionalComidas
    end

    def tieneDesayuno
        if desayuno == 1
            "Sí"
        else
            "No"
        end
    end

    def tieneAlmuerzo
        if almuerzo == 1
            "Sí"
        else
            "No"
        end
    end

    def tieneCena
        if cena == 1
            "Sí"
        else
            "No"
        end
    end
end

class Factory
    def self.generarObjeto(tipo, *arg)
        case tipo
        when "c"
            Colaborador.new(arg[0],arg[1],arg[2],arg[3],arg[4],arg[5])
        when "em"
            EvaluacionMedica.new(arg[0],arg[1],arg[2],arg[3],arg[4],arg[5],arg[6])
        when "cg"
            Gimnasio.new(arg[0],arg[1],arg[2],arg[3],arg[4],arg[5])
        when "ca"
            Alimentacion.new(arg[0],arg[1],arg[2],arg[3],arg[4],arg[5],arg[6],arg[7])
        end
    end
end

class Model
    include Singleton
    attr_reader :listaColaboradores, :listaEvaluaciones, :listaConvenios

    def initialize
        @listaColaboradores = []
        @listaEvaluaciones = []
        @listaConvenios = []
    end

    def registrar(tipo, objeto)
        case tipo
        when "c"
            if objeto.validarDNI
                listaColaboradores.push(objeto)
            end
        when "em"
            listaEvaluaciones.push(objeto)
        when "cg"
            listaConvenios.push(objeto)
        when "ca"
            listaConvenios.push(objeto)
        end
    end

    def obtenerColaborador(dni)

        for objeto in listaColaboradores
            if objeto.dni == dni
                return objeto
            end
        end

        return nil
    end

    def obtenerEvaluacion(dni)

        for objeto in listaEvaluaciones
            if objeto.dni == dni
                return objeto
            end
        end

        return nil
    end

    def obtenerConvenio(codigo)

        for convenio in listaConvenios
            if convenio.codigo == codigo
                return convenio
            end
        end

        return nil
    end

    def realizarEvaluacion(dni)
        gimnasio = 0
        alimentacion = 0
        flag = 0

        evaluacion = obtenerEvaluacion(dni)

        if (evaluacion.diabetes == 1 || evaluacion.inmunodeficiencia == 1 || evaluacion.calcularIMC >= 32)
            alimentacion = 1
        end
        if (evaluacion.cardiovasculares == 1 || evaluacion.respiratorias == 1)
            gimnasio = 1
        end

        if(gimnasio == 1 && alimentacion == 0)
            flag = 1
        elsif(gimnasio == 0 && alimentacion == 1)
            flag = 2
        elsif(gimnasio == 1 && alimentacion == 1)
            flag = 3
        end

        return flag
    end

    def obtenerConvenios(tipo)
        convenios = []

        for convenio in listaConvenios
            if(tipo == 1 && convenio.class == Gimnasio)
                convenios.push(convenio)
            end

            if(tipo == 2 && convenio.class == Alimentacion)
                convenios.push(convenio)
            end
        end

        return convenios
    end

    def obtenerColaboradorMasDescuento
        colaboradorMasDescuento = nil;
        mayorPrecio = 0

        for colaborador in listaColaboradores
            precioColaborador = 0

            for convenio in colaborador.convenios
                precioColaborador += convenio.calcularPrecio
            end

            if precioColaborador > mayorPrecio
                precioColaborador = precioColaborador
                colaboradorMasDescuento = colaborador
            end
            
        end

        return colaboradorMasDescuento
    end

    def obtenerConvenioPreferido
        convenioPreferido = nil
        mayorVeces = 0

        for convenio in listaConvenios
            vecesConvenio = 0

            for colaborador in listaColaboradores
                
                for convenioCol in colaborador.convenios

                    if convenio.codigo == convenioCol.codigo
                        vecesConvenio += 1
                    end

                end

            end

            if vecesConvenio > mayorVeces
                mayorVeces = vecesConvenio
                convenioPreferido = convenio
            end
            
        end

        return convenioPreferido
    end
end

class View
    def mostrar(tipo)
        case tipo
        when "c"
            puts "Colaborador registrado"
        when "em"
            puts "Evaluación medica registrada"
        end
    end

    def mostrarError(error)
        puts error
    end

    def mostrarColaboradores(colaboradores)
        puts "-----Listado de Colaboradores-----"
        for colaborador in colaboradores
            mostrarColaborador(colaborador)
        end
    end

    def mostrarConvenios(convenios)
        puts "-----Listado de Convenios-----"
        for convenio in convenios
            mostrarConvenio(convenio)
        end
    end

    def mostrarColaborador(colaborador)
        puts "DNI: #{colaborador.dni}\t\tNombre: #{colaborador.nombre}\tÁrea: #{colaborador.descripcionArea}\t\tEdad: #{colaborador.edad}\tSueldo: #{colaborador.sueldo}\tEstado: #{colaborador.descripcionAfiliado}"
    end

     def mostrarConvenio(convenio)
        if convenio.class == Gimnasio
            puts "Código: #{convenio.codigo}\tNombre: #{convenio.nombre}\t\tCategoría: #{convenio.categoria}\tCosto Base: #{convenio.costoBase}\t\tMeses: #{convenio.meses}\tNivel de Acceso: #{convenio.nivelAcceso}\tPrecio Total: #{convenio.calcularPrecio}"
        else
            puts "Código: #{convenio.codigo}\tNombre: #{convenio.nombre}\t\tCategoría: #{convenio.categoria}\tCosto Base: #{convenio.costoBase}\t\tMeses: #{convenio.meses}\tDesayuno: #{convenio.tieneDesayuno}\tAlmuerzo: #{convenio.tieneAlmuerzo}\tCena: #{convenio.tieneCena}\tPrecio Total: #{convenio.calcularPrecio}"
        end
     end
end

class Controller
    attr_reader :view, :model

    def initialize(view, model)
        @view = view
        @model = model
    end

    def registrar(tipo, *arg)
      begin
            objeto = Factory.generarObjeto(tipo,*arg)
            model.registrar(tipo, objeto)      
            view.mostrar(tipo)
      rescue Exception => e
         view.mostrarError(e.message)
      end
    end

    def obtenerColaborador(dni)
        model.obtenerColaborador(dni)
    end

    def obtenerEvaluacion(dni)
        model.obtenerEvaluacion(dni)
    end

    def obtenerConvenio(codigo)
        model.obtenerConvenio(codigo)
    end

    def realizarEvaluacion(dni)
        model.realizarEvaluacion(dni)
    end

    def listarConvenios(tipo)
        convenios = model.obtenerConvenios(tipo)
        view.mostrarConvenios(convenios)
    end
    
    def mostrarListadoColaboradores
        colaboradores = model.listaColaboradores
        view.mostrarColaboradores(colaboradores)
    end

    def mostrarListadoConvenios
        convenios = model.listaConvenios
        view.mostrarConvenios(convenios)
    end

    def mostrarColaboradorMasDescuento
        colaborador = model.obtenerColaboradorMasDescuento
        puts "-----Colaborador con más descuento-----"
        if colaborador != nil
            view.mostrarColaborador(colaborador)
        end
    end

    def mostrarConvenioPreferido
        convenio = model.obtenerConvenioPreferido
        puts "-----Convenio Preferido-----"
        if convenio != nil
            view.mostrarConvenio(convenio)
        end
    end
end

class String
    def numeric?
        Float(self) != nil rescue false
    end
end

view = View.new
model = Model.instance
controller = Controller.new(view, model)

puts "PRUEBAS"

controller.registrar("c", "71927800", "José", 1, 20, 3000,1)
controller.registrar("c", "15849901", "Juan", 2, 30, 6000,1)

controller.registrar("em", "71927800", 70, 1.70, 1, 0, 1, 0)
controller.registrar("em", "15849901", 80, 2, 1.60, 0, 1, 0, 0)

colaborador = controller.obtenerColaborador("71927800")
evaluacion = controller.obtenerEvaluacion("71927800")
colaborador.evaluacionMedica = evaluacion

colaborador2 = controller.obtenerColaborador("15849901")
evaluacion2 = controller.obtenerEvaluacion("15849901")
colaborador2.evaluacionMedica = evaluacion2

controller.registrar("cg", "00001", "Plan Distrito", 1, 200, 3,1)
controller.registrar("cg", "00002", "Plan Oficina", 2, 200, 6,2)
controller.registrar("ca", "00003", "Plan Desayuno", 1, 100, 6, 1, 0, 0)
controller.registrar("ca", "00004", "Plan 2 comidas", 2, 100, 6, 1, 1, 0)
controller.registrar("ca", "00005", "Plan 3 comidas", 3, 100, 6, 1, 1, 1)

gimnasio = controller.obtenerConvenio("00002")
alimentacion = controller.obtenerConvenio("00005")
colaborador.convenios.push(alimentacion)
colaborador.convenios.push(gimnasio)
colaborador2.convenios.push(gimnasio)

valorSeleccionado = 0

while(valorSeleccionado != 9)
    system('cls')
    puts "Opciones:"
    puts "1. Registrar colaborador"
    puts "2. Registrar evaluación médica"
    puts "3. Listar colaboradores"
    puts "4. Listar convenios"
    puts "5. Listar colaborador con más descuento"
    puts "6. Listar el plan preferido por los colaboradores en ambos convenios"
    puts ""
    puts "9. Salir"
    print "Ingrese la opción deseada: "

    valorSeleccionado = gets.chomp.to_i

    case valorSeleccionado
    when 1
        #nombres, apellidos, area, edad, dni, sueldo, estadoActual
        print "Ingrese DNI: "
        dni = gets.chomp
        print "Ingrese nombre: "
        nombre = gets.chomp
        print "Ingrese área(1.TI, 2.Comercial, 3.GH, 4.Contraloría, 5.AyF): "
        area = gets.chomp.to_i
        print "Ingrese edad: "
        edad = gets.chomp.to_i
        print "Ingrese sueldo(en soles): "
        sueldo = gets.chomp.to_f
        estadoActual = 0 #0:No afiliado, 1:Afiliado

        controller.registrar("c", dni, nombre, area, edad, sueldo, estadoActual)

        system('pause')
    when 2
        print "Ingrese DNI: "
        dni = gets.chomp

        colaborador = controller.obtenerColaborador(dni)

        if colaborador == nil
            puts "DNI no existe"
            system('pause')
        else
            print "Ingrese su peso(kg): "
            peso = gets.chomp.to_f
            print "Ingrese su talla(m): "
            talla = gets.chomp.to_f
            puts "----------------------------------------------"
            print "¿Presenta diabetes? y/n: "
            diabetes = gets.chomp
            print "¿Presenta enfermedades cardiovasculares? y/n: "
            cardiovasculares = gets.chomp
            print "¿Presenta enfermedades respiratorias? y/n: "
            respiratorias = gets.chomp
            print "¿Sufre de inmunodeficiencia? y/n: "
            inmunodeficiencia = gets.chomp

            if diabetes == "y"
                diabetes = 1
            else
                diabetes = 0
            end

            if cardiovasculares == "y"
                cardiovasculares = 1
            else
                cardiovasculares = 0
            end

            if respiratorias == "y"
                respiratorias = 1
            else
                respiratorias = 0
            end

            if inmunodeficiencia == "y"
                inmunodeficiencia = 1
            else
                inmunodeficiencia = 0
            end
            
            controller.registrar("em", dni, peso, talla, diabetes, cardiovasculares, respiratorias, inmunodeficiencia)
            evaluacion = controller.obtenerEvaluacion(dni)
            colaborador.evaluacionMedica = evaluacion

            system('pause')

            flag = controller.realizarEvaluacion(dni)

            if(flag == 0)
                puts "No requiere convenio"
                system('pause')
            else
                print "¿Desea afiliarse a un plan de convenio? y/n: "
                sino = gets.chomp

                if sino == "y"
                    colaborador.estadoActual = 1
                    case flag
                    when 1
                        controller.listarConvenios(1)
                        print "Ingrese un convenio Gimnasio: "
                        sel1 = gets.chomp
                        gimnasio = controller.obtenerConvenio(sel1)
                        colaborador.convenios.push(gimnasio)
                        puts "Convenio afiliado"
                        system('pause')
                    when 2
                        controller.listarConvenios(2)
                        print "Ingrese un convenio Alimentación: "
                        sel2 = gets.chomp
                        alimentacion = controller.obtenerConvenio(sel2)
                        colaborador.convenios.push(alimentacion)
                        puts "Convenio afiliado"
                        system('pause')
                    when 3
                        controller.listarConvenios(1)
                        controller.listarConvenios(2)
        
                        print "Ingrese un convenio Gimnasio: "
                        sel1 = gets.chomp
                        print "Ingrese un convenio Alimentación: "
                        sel2 = gets.chomp
                        gimnasio = controller.obtenerConvenio(sel1)
                        alimentacion = controller.obtenerConvenio(sel2)
                        colaborador.convenios.push(gimnasio)
                        colaborador.convenios.push(alimentacion)
                        puts "Convenios afiliados"
                        system('pause')
                    end
                end
            end
        end
    when 3
        controller.mostrarListadoColaboradores
        system('pause')
    when 4
        controller.mostrarListadoConvenios
        system('pause')
    when 5
        controller.mostrarColaboradorMasDescuento
        system('pause')
    when 6
        controller.mostrarConvenioPreferido
        system('pause')
    end
end
