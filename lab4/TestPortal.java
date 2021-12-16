public class TestPortal {

   // enable this to make pretty printing a bit more compact
   private static final boolean COMPACT_OBJECTS = false;

   // This class creates a portal connection and runs a few operation

   public static void main(String[] args) {
      try{
         PortalConnection c = new PortalConnection();

         c.unregister("1111111111", "CCC111"); 
         c.unregister("1111111111", "CCC222"); 
         c.unregister("2222222222", "CCC222"); 
         c.unregister("3333333333", "CCC222"); 
         c.unregister("5555555555", "CCC222"); 
         c.unregister("6666666666", "CCC222"); 
   
         System.out.println(
          "\n------------------------------------------------"
         +"\n                T E S T I N G"
         +"\n------------------------------------------------"
         +"\n1. List info for a student.");
         prettyPrint(c.getInfo("1111111111")); 
         pause();


   
         System.out.println("2. Register the student for an unrestricted "
         +"course,\nand check that they end up registered (print info again).");
         prettyPrint(c.register("1111111111", "CCC111")); 
         prettyPrint(c.getInfo("1111111111")); 
         pause();
          
          

         System.out.println("3. Register the same student for the same course"
         +"again, and check that you get an error response. ");
         prettyPrint(c.register("1111111111", "CCC111")); 
         prettyPrint(c.getInfo("1111111111")); 
         pause();

         
         System.out.println("4. Unregister the student from the course,"
         +"\nand then unregister again from the same course. Check that"
         +"\nthe student is no longer registered and the second unregistration"
         +"\ngives an error response. ");
         prettyPrint(c.unregister("1111111111", "CCC111")); 
         prettyPrint(c.unregister("1111111111", "CCC111")); 
         prettyPrint(c.getInfo("1111111111")); 
         pause();
         

         
         System.out.println("5. Register the student for a course that they"
         +"\ndon't have the prerequisites for,"
         +"\nand check that an error is generated.");
         prettyPrint(c.register("1111111111", "CCC444")); 
         prettyPrint(c.getInfo("1111111111")); 
         
         

         System.out.println("6. Unregister a student from a restricted course "
         +"that they are registered to, and which has at least two students "
         +"in the queue. Register again to the same course and check that the "
         +"student gets the correct (last) position in the waiting list. ");
         prettyPrint(c.register("6666666666", "CCC222"));
         System.out.println("(5555555555 should not be able to register)");
         prettyPrint(c.register("5555555555", "CCC222"));
         prettyPrint(c.register("3333333333", "CCC222")); 
         prettyPrint(c.register("2222222222", "CCC222")); 
         prettyPrint(c.register("1111111111", "CCC222")); 
         prettyPrint(c.getInfo("1111111111")); 
         prettyPrint(c.unregister("6666666666", "CCC222")); 
         prettyPrint(c.getInfo("1111111111")); 



         System.out.println("7. Unregister and re-register the same student"
         +" for the same restricted course, and check that the student is first"
         +" removed and then ends up in the same position as before (last).");
         prettyPrint(c.unregister("1111111111", "CCC222")); 
         prettyPrint(c.getInfo("1111111111")); 
         prettyPrint(c.register("1111111111", "CCC222")); 
         prettyPrint(c.getInfo("1111111111")); 
         pause();
         
         
         
         System.out.println("8. Unregister a student from an overfull course,"
         +" i.e. one with more students registered than there are places on the"
         +" course (you need to set this situation up in the database directly)."
         +" Check that no student was moved from the queue to being registered"
         +" as a result. ");
         prettyPrint(c.registerDirectly("6666666666", "CCC222"));
         System.out.println("Right now:\n"
                 + " course | place |  student   |   status   \n"
                 + "--------+-------+------------+------------\n"
                 + " CCC222 |     0 | 3333333333 | registered\n"
                 + " CCC222 |     0 | 6666666666 | registered\n"
                 + " CCC222 |     1 | 2222222222 | waiting\n"
                 + " CCC222 |     2 | 1111111111 | waiting\n");
         prettyPrint(c.unregister("3333333333", "CCC222"));
         System.out.println("after unregistering 3333333333:\n"
                 + " course | place |  student   |   status   \n"
                 + "--------+-------+------------+------------\n"
                 + " CCC222 |     0 | 6666666666 | registered\n"
                 + " CCC222 |     1 | 2222222222 | waiting\n"
                 + " CCC222 |     2 | 1111111111 | waiting\n");
         pause();

         

         System.out.println("9. Unregister with the SQL injection you"
         +" introduced, causing all (or almost all?) registrations to"
         +" disappear.");
         System.out.println(c.SQLInjection("1111111111",
         "CCC222'; DELETE FROM Registrations; DELETE FROM WaitingList; --"));
         pause();
         


      
      } catch (ClassNotFoundException e) {
         System.err.println("ERROR!\nYou do not have the Postgres JDBC driver (e.g. postgresql-42.2.18.jar) in your runtime classpath!");
      } catch (Exception e) {
         e.printStackTrace();
      }
   }
   
   
   
   public static void pause() throws Exception{
     System.out.println("PRESS ENTER");
     while(System.in.read() != '\n');
   }
   
   // This is a truly horrible and bug-riddled hack for printing JSON. 
   // It is used only to avoid relying on additional libraries.
   // If you are a student, please avert your eyes.
   public static void prettyPrint(String json){
      //System.out.print("Raw JSON:");
      //System.out.println(json);
      //System.out.println("Pretty-printed:"); // possibly broken
      
      int indent = 0;
      json = json.replaceAll("\\r?\\n", " ");
      json = json.replaceAll(" +", " "); // This might change JSON string values :(
      json = json.replaceAll(" *, *", ","); // So can this
      
      for(char c : json.toCharArray()){
        if (c == '}' || c == ']') {
          indent -= 2;
          breakline(indent); // This will break string values with } and ]
        }
        
        System.out.print(c);
        
        if (c == '[' || c == '{') {
          indent += 2;
          breakline(indent);
        } else if (c == ',' && !COMPACT_OBJECTS) 
           breakline(indent);
      }
      
      System.out.println();
   }
   
   public static void breakline(int indent){
     System.out.println();
     for(int i = 0; i < indent; i++)
       System.out.print(" ");
   }   
}