class Colaborador
    attr_accessor :nombres, :apellidos, :area, :edad, :dni, :sueldo, :estadoActual, :evaluacionMedica, :convenios

    def initialize(nombres, apellidos, area, edad, dni, sueldo, estadoActual)
        @nombres = nombres
        @apellidos = apellidos
        @area = area
        @edad = edad
        @dni = dni
        @sueldo = sueldo
        @estadoActual = estadoActual
        @evaluacionMedica = nil
        @convenios = []
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
        peso / (altura * altura)
    end
end

class Convenio
    attr_reader :nombre, :categoria, :costoBase, :meses
    
    def initialize(nombre, categoria, costoBase)
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

    def initialize(nombre, categoria, costoBase, nivelAcceso)
        super(nombre, categoria, costoBase)
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

    def initialize(nombre, categoria, costoBase, desayuno, almuerzo, cena)
        super(nombre, categoria, costoBase)
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
end

class Administrador
    attr_reader :listaColaboradores, :listaEvaluaciones
end

class Factory
    def self.generarObjeto(tipo, *arg)
        case tipo
        when "c"
            Colaborador.new(arg[0],arg[1],arg[2],arg[3],arg[4],arg[5],arg[6])
        when "em"
            EvaluacionMedica.new(arg[0],arg[1],arg[2],arg[3],arg[4],arg[5],arg[6])
        when "cg"
            Gimnasio.new(arg[0],arg[1],arg[2],arg[3])
        when "ca"
            Alimentacion.new(arg[0],arg[1],arg[2],arg[3],arg[4],arg[5])
        end
    end
end