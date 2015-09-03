
import java.nio.ByteBuffer;
// Java convert string to hex 

public class MyStringEncoder {

    private static final String hexLetters = "0123456789abcdef";
    static char[] hexChar =
    {
         '0', '1', '2', '3', '4', '5', '6', '7',
         '8', '9', 'a', 'b', 'c', 'd', 'e', 'f',
    };
    
    public static String toHex(byte b) {
        char chars[] = new char[2];
        chars[1] = hexLetters.charAt((int)(b & 0x000F));
        chars[0] = hexLetters.charAt((int)((b & 0x00F0) >>> 4));
        return new String(chars);
    }
    
    public static String toHexString(byte[] val) {
        StringBuffer sb = new StringBuffer();
        for (int i = 0; i < val.length; i++) {
            sb.append(toHex(val[i]));
        }
        return sb.toString();
    }
	
    public static byte[] hexStringToBytes(String aString) {
        String s;
        if (aString.length() % 2 != 0) {
            s = "0" + aString;
        } else {
            s = aString;
        }
        int len = s.length() / 2;
        byte[] ba = new byte[ len ];
        for ( int i = 0; i < len; i++) {
            String ss = "0x" + s.substring(i*2, (i*2 + 2) );
            Integer b = Integer.decode(ss);
            ba[i] = b.byteValue();
       }
       return ba;
    }
    
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// TODO Auto-generated method stub

		String foo = "-XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:+UseCMSInitiatingOccupancyOnly -XX:NewSize=900m -XX:MaxNewSize=900m -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -XX:CMSIncrementalSafetyFactor=25 -XX:CMSInitiatingOccupancyFraction=50";
		
		System.out.println(foo);
		//Encode
		byte[] foobytes = foo.getBytes();
		String byteString = toHexString(foobytes);
		
		
		System.out.println(byteString);

		//Decode
		byte[] foo2bytes = hexStringToBytes(byteString);
		String foo2 = new String(foo2bytes);
		
		System.out.println(foo2);
		
		
	}

}
