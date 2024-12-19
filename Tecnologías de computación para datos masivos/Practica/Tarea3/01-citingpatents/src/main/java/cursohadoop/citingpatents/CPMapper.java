package cursohadoop.citingpatents;

/**
 * Mapper para CitingPatents - cites by number: Obtiene el número de citas de una patente.
 * Para cada línea, invierte las columnas (patente citante, patente a la que cita)
 * conviertiéndolas primero en enteros para tener una ordenación numérica por clave
 *
 * Entrada: 
 *   Clave: Patente citante (String)
 *   Valor: Patente citada (String)
 * Salida:
 *   Clave: Patente citada (entero)
 *   Valor: Patente citante (entero)
 *
 */
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import java.io.IOException;

// TODO: Completa la clase mapper
public class CPMapper extends Mapper<Text, Text, IntWritable, IntWritable> {
    /*
     * Método map
     * @param key patente que cita
     * @param value patente citada
     * @param context Contexto MapReduce
     * @throws IOException
     * 
     * @see org.apache.hadoop.mapreduce.Mapper#map(KEYIN, VALUEIN,
     * org.apache.hadoop.mapreduce.Mapper.Context)
     */
	// TODO: Completar el mapper
    @Override
    public void map(Text key, Text value, Context context) throws IOException, 
			InterruptedException {
        // Convierte la clave y valor de entrada a enteros
        try {
            citing = Integer.valueOf(key.toString());
            cited = Integer.valueOf(value.toString());
            context.write(new IntWritable(cited), new IntWritable(citing));
        } catch (NumberFormatException e) {
            // Captura valores no numéricos, como la cabecera
            // Permite saltar la cabecera, que produce una excepción al pasarla a Integer.
            System.err.println("Error procesando patentes CPMapper " + cited + " " + citing);
            context.setStatus("Error procesando patentes en CPMapper " + cited + " " + citing);
        }

    }
    // Patente citada
    private Integer cited;
    // Patente citante
    private Integer citing;
}