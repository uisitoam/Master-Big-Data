package cursohadoop.citationnumberbypatent_chained;

/**
 * Mapper Count Cites 
 * Para cada línea, obtiene la clave (patente) y cuenta el número de patentes que la citan
 */
import java.io.IOException;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

// TODO: Completa la clase Mapper
public class CCMapper extends Mapper<IntWritable, Text, IntWritable, IntWritable> {
    // TODO: Completar el mapper
    @Override
    public void map(IntWritable key, Text value, Context context)
            throws IOException, InterruptedException {
        // Divide el valor en una lista de patentes que citan
        cites = value.toString().split(",");
        // Cuenta el número de patentes que citan
        int count = cites.length;
        // Escribe la clave (patente) y el número de citas
        context.write(key, new IntWritable(count));
    }
    
    private String[] cites;
}