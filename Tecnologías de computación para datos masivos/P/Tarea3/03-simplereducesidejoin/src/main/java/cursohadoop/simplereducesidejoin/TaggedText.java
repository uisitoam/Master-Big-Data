package cursohadoop.simplereducesidejoin;

import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;

import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.Writable;

/**
 * 
 * TaggedText -> Writable a medida para almacenar dos Text
 * Permite etiquetar los valores de salida de los mappers para  
 * que el reducir pueda distinguir el origen de las claves.
 * 
 * @author tomas
 * 
 */

public class TaggedText implements Writable {

	public TaggedText() {
		set(new Text(), new Text());
	}
	
	public TaggedText(String first, String second) {
		set(new Text(first), new Text(second));
	}
	
	public TaggedText(Text first, Text second) {
		set(first, second);
	}
	
	public void set(Text tag, Text value) {
		this.tag = tag;
		this.value = value;
	}
	
	public Text getTag() {
		return tag;
	}
	
	public Text getValue() {
		return value;
	}

	@Override
	public void readFields(DataInput in) throws IOException {
		tag.readFields(in);
		value.readFields(in);
	}

	@Override
	public void write(DataOutput out) throws IOException {
		tag.write(out);
		value.write(out);
	}
	
	@Override
	public String toString() {
		return tag+" ,"+value;
	}
	
	private Text tag;
	private Text value;

}


