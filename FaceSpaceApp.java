import java.sql.*;
import java.text.ParseException;
import java.util.Scanner;

public class FaceSpaceApp {
    private static Connection connection; //used to hold the jdbc connection to the DB
    private Statement statement; //used to create an instance of the connection
    private PreparedStatement prepStatement; //used to create a prepared statement
    private ResultSet resultSet; //used to hold the result of your query
    private String query;  //this will hold the query we are using
    static Scanner scanner = new Scanner(System.in); //used to read user input

    public FaceSpaceApp(){
        System.out.println("in FaceSpaceApp method");
        //This is where the main app will interface with the user to call the different methods

    }

    public static void main(String args[]) throws SQLException {
        //User is prompted for Oracle Username and Password
        String username, password;
        System.out.print("Enter Oracle Username: ");//This is your username in oracle
        username = scanner.next();
        System.out.print("Enter Oracle Password: "); //This is your password in oracle
        password = scanner.next();

        try{
            // Register the oracle driver.
            DriverManager.registerDriver (new oracle.jdbc.driver.OracleDriver());
            //This is the location of the database
            String url = "jdbc:oracle:thin:@class3.cs.pitt.edu:1521:dbclass";
            //create a connection to DB on class3.cs.pitt.edu
            connection = DriverManager.getConnection(url, username, password);

            FaceSpaceApp fsa = new FaceSpaceApp();
        }
        catch(Exception Ex)  {
            System.out.println("Error connecting to database.  Machine Error: " + Ex.toString());
        }
        finally{
            /*
             * NOTE: the connection should be created once and used through out the whole project
             */
            connection.close();
        }
    }
}
