
import java.sql.*; // JDBC stuff.
import java.util.Properties;

public class PortalConnection {

    // Set this to e.g. "portal" if you have created a database named portal
    // Leave it blank to use the default database of your database user
    static final String DBNAME = "";
    // For connecting to the portal database on your local machine
    static final String DATABASE = "jdbc:postgresql://localhost/"+DBNAME;
    static final String USERNAME = "postgres";
    static final String PASSWORD = "mimmi";

    // This is the JDBC connection object you will be using in your methods.
    private Connection conn;

    public PortalConnection() throws SQLException, ClassNotFoundException {
        this(DATABASE, USERNAME, PASSWORD);  
    }

    // Initializes the connection, no need to change anything here
    public PortalConnection(String db, String user, String pwd)
    throws SQLException, ClassNotFoundException {
        Class.forName("org.postgresql.Driver");
        Properties props = new Properties();
        props.setProperty("user", user);
        props.setProperty("password", pwd);
        conn = DriverManager.getConnection(db, props);
    }
            
    // Register a student on a course, returns a tiny JSON document (as a
    // String)
    public String register(String student, String courseCode){
        String query = "INSERT INTO Registrations VALUES(?,?);";
        try(PreparedStatement st = conn.prepareStatement(query)){
            st.setString(1, student);
            st.setString(2, courseCode);
            int rowsInserted = st.executeUpdate();
            return "{\"success\":true, \"rowsInserted\":" + rowsInserted + "}";
        } catch (SQLException e) {
            return "{\"success\":false, \"error\":\"" + getError(e) + "\"}";
        }
    }

    // Register a student on a course, returns a tiny JSON document (as a
    // String)
    public String registerDirectly(String student, String courseCode){
        String query = "INSERT INTO Registered VALUES(?,?);";
        try(PreparedStatement st = conn.prepareStatement(query)){
            st.setString(1, student);
            st.setString(2, courseCode);
            int rowsInserted = st.executeUpdate();
            return "{\"success\":true, \"rowsInserted\":" + rowsInserted + "}";
        } catch (SQLException e) {
            return "{\"success\":false, \"error\":\"" + getError(e) + "\"}";
        }
    }

    // Unregister a student from a course
    public String unregister(String student, String courseCode){
        String query =
            "DELETE FROM Registrations WHERE student=? AND course=?";
        String errorMessage =
            "The student "+student+" is not registered to "+courseCode+".";
        try(PreparedStatement st = conn.prepareStatement(query)){
            st.setString(1, student);
            st.setString(2, courseCode);
            int rowsDeleted = st.executeUpdate();
            if(rowsDeleted == 0)
                return "{\"success\":false,"
                     + " \"error\":\"" + errorMessage + "\"}";
            else
            return "{\"success\":true, \"rowsDeleted\":" + rowsDeleted + "}";
        } catch (SQLException e) {
            return "{\"success\":false, \"error\":\"" + getError(e) + "\"}";
        }
    }

    // Deletes all rows in a database with sql injection.
    public String SQLInjection(String student, String courseCode){
        String query = "DELETE FROM Registrations WHERE student='"
                + student +"' AND course='"+courseCode+"'";
        String errorMessage = "The student "+student+
                              " is not registered to "+courseCode+".";
        try(Statement st = conn.createStatement()) {
            int rowsDeleted = st.executeUpdate(query);
            if (rowsDeleted == 0)
                return "{\"success\":false,"
                     + " \"error\":\"" + errorMessage + "\"}";
            else
            return "{\"success\":true, \"rowsDeleted\":" + rowsDeleted + "}";

        } catch (SQLException e) {
            return "{\"success\":false, \"error\":\"" + getError(e) + "\"}";
        }
    }

    public String getInfo(String student) throws SQLException{
        
        try(PreparedStatement st = conn.prepareStatement(
                
 "                with"
+"                b AS (SELECT * FROM basicinformation),"
+"                c AS (SELECT * FROM courses),"
+"                p AS (SELECT * FROM pathtograduation),"
+"                r AS (SELECT * FROM registrations),"
+"                t AS (SELECT * FROM taken),"
+"                w AS (SELECT * FROM waitinglist),"
+"                JsonFinished AS ("
+"                    SELECT"
+"                         json_agg"
+"                            ("
+"                                json_build_object("
+"                                 'course',  c.name,"
+"                                 'code',    t.course,"
+"                                 'credits', c.credits,"
+"                                 'grade',   t.grade)"
+"                            ) AS fininfo"
+"                    FROM t,c"
+"                    WHERE"
+"                        t.student=?"
+"                        AND c.code=t.course"
+"                ),"
+"                JsonRegistered AS ("
+"                    SELECT"
+"                         json_agg"
+"                            ("
+"                                json_build_object("
+"                                 'course', c.name,"
+"                                 'code',   c.code,"
+"                                 'status', r.status,"
+"                                 'position',CASE WHEN status='registered'"
+"                                                THEN NULL ELSE position END"
+"                                )"
+"                            ) AS reginfo"
+"                    FROM c,r left outer join w"
+"                        ON r.student=w.student"
+"                    WHERE"
+"                        r.student=?"
+"                        AND r.course=c.code"
+"                ),"
+"                JsonInfo AS ("
+"                    SELECT"
+"                        json_build_object("
+"                            'student',         idnr,"
+"                            'name',            name,"
+"                            'login',           login,"
+"                            'program',         program,"
+"                            'branch',          branch,"
+"                            'finished',        fininfo,"
+"                            'registered',      reginfo,"
+"                            'seminarCourses',  seminarcourses,"
+"                            'mathCredits',     mathcredits,"
+"                            'researchCredits', researchcredits,"
+"                            'totalCredits',    totalcredits,"
+"                            'canGraduate',     qualified"
+"                        ) AS basinfo"
+"                          FROM b,JsonFinished,JsonRegistered,p"
+"                          WHERE b.idnr=? AND p.student=b.idnr"
+"                )"
+"                SELECT basinfo FROM JsonInfo;"
            );){
            
            st.setString(1, student);
            st.setString(2, student);
            st.setString(3, student);
            
            ResultSet rs = st.executeQuery();
            
            if(rs.next())
              return rs.getString("basinfo");
            else
              return "{\"student\":\"does not exist :(\"}"; 
            
        } 
    }
    // This is a hack to turn an SQLException into a JSON string error message.
    // No need to change.
    public static String getError(SQLException e){
       String message = e.getMessage();
       int ix = message.indexOf('\n');
       if (ix > 0) message = message.substring(0, ix);
       message = message.replace("\"","\\\"");
       return message;
    }
}