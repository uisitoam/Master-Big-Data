package cursohadoop.simplereducesidejoin;

import java.io.IOException;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

public class CNBPTaggedMapper extends Mapper<IntWritable, IntWritable, IntWritable, TaggedText> {
    /**
     * map - para cada línea de la salida de 02-citationnumberbypatent_chained, 
     * obtiene la patente y el número de citas con la etiqueta "cite"
     * 
     * @param key  n de patente
     * @param value número de citas
     * 
     * @see org.apache.hadoop.mapreduce.Mapper#map(KEYIN, VALUEIN,
     * org.apache.hadoop.mapreduce.Mapper.Context)
     */    
    // Completar el mapper
    @Override
    public void map(IntWritable key, IntWritable value, Context context) throws IOException, InterruptedException {
        try {
            // La clave es el número de la patente
            // TODO: Completa
			IntWritable npatente = key;
            
            // El valor es el número de citas
            // TODO: Completa
			int ncites = value.get();
        
            // Etiquetamos el número de citas con el texto "cite" para hacer el join
            // pasando el número de citas a String
            // TODO: Completa
			nCitesTagged.set(new Text("cite"), new Text(String.valueOf(ncites)));
            
            // Escribimos en el contexto el número de patente y el número de citas etiquetado
            // TODO: Completa
			context.write(npatente, nCitesTagged);
        } catch (NumberFormatException e) {
            System.err.println("Error procesando patente en CNBPTaggedMapper " + key.toString());
            context.setStatus("Error procesando patente en CNBPTaggedMapper " + key.toString());
        }
    }
    private TaggedText nCitesTagged = new TaggedText();
}