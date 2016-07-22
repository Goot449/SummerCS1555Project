import java.sql.*;
import java.text.ParseException;
import java.util.Scanner;
import java.text.SimpleDateFormat;

public class FaceSpaceApp {
    private static Connection connection; //used to hold the jdbc connection to the DB
    private Statement statement; //used to create an instance of the connection
    private PreparedStatement prepStatement; //used to create a prepared statement
    private ResultSet resultSet; //used to hold the result of your query
    private String query;  //this will hold the query we are using
    static Scanner scanner = new Scanner(System.in); //used to read user input

    public FaceSpaceApp(String mode){
        System.out.println("\n"+"Welcome to FaceSpace!");
        //user mode
        //This is where the main app will interface with the user to call the different methods
        if(mode.equalsIgnoreCase("user")){
            System.out.println("FaceSpaceApp is now in USER MODE");
            int command;
            while(true){
                System.out.print("\n"+"Please Enter a Command:"+"\n"+
                    "0 - Quit"+"\n"+"1 - createUser"+"\n"+"2 - initiateFriendship"+"\n"+"3 - establishFriendShip"+"\n"+
                    "4 - displayFriends"+"\n"+"5 - createGroup"+"\n"+"6 - addToGroup"+"\n"+"7 - sendMessageToUser"+"\n"+
                    "8 - sendMessageToGroup"+"\n"+"9 - displayMessages"+"\n"+"10 - displayNewMessages"+"\n"+
                    "11 - searchForUser"+"\n"+"12 - threeDegrees"+"\n"+"13 - topMessagers"+"\n"+"14 - dropUser"+"\n"+"Command: ");
                command = Integer.parseInt(scanner.next());

                if(command == 0){
                    System.out.println("Logging Out");
                    break;
                }
                else if(command == 1){
                    String fname = "";
                    String lname = "";
                    String email = "";
                    String dob = "";

                    createUser(fname, lname, email, dob);
                }
                else if(command == 2){
                    String requestEmail = "jimjohn@gmail.com";
                    String toEmail = "jed@gmail.com";
                
                    initiateFriendship(requestEmail, toEmail);
                }
                else if(command == 3){
                    establishFriendShip();
                }
                else if(command == 4){
                    displayFriends();
                }
                else if(command == 5){
                    createGroup();
                }
                else if(command == 6){
                    addToGroup();
                }
                else if(command == 7){
                    sendMessageToUser();
                }
                else if(command == 8){
                    sendMessageToGroup();
                }
                else if(command == 9){
                    displayMessages();
                }
                else if(command == 10){
                    displayNewMessages();
                }
                else if(command == 11){
                    searchForUser();
                }
                else if(command == 12){
                    threeDegrees();
                }
                else if(command == 13){
                    topMessagers();
                }
                else if(command == 14){
                    dropUser();
                }
                else{
                    System.out.println("Command Not Recognized!");
                }
            }
        }
        else if(mode.equalsIgnoreCase("driver")){
            //driver mode
            System.out.println("FaceSpaceApp is now in DRIVER MODE");
            //testDriver Class is now executing its tests
        }
        else{
            System.out.println("Mode Not Recognized <User/Driver>");
        }
    }

    public void createUser(String fname, String lname, String email, String dob){
        try{
            java.util.Date date = null;
            if (!dob.isEmpty())
            {
                SimpleDateFormat sdf = new SimpleDateFormat("mm/dd/yyyy");
                date = sdf.parse(dob);
                if (!dob.equals(sdf.format(date))) {
                    date = null;
                }
            }
            // checks for valid user data
            if( !fname.isEmpty() && !lname.isEmpty() && !email.isEmpty() &&  date != null)
            {
                // query number of users to increment to next user id
                statement = connection.createStatement();
                String selectQuery = "SELECT COUNT(*) AS total FROM users";
                resultSet = statement.executeQuery(selectQuery);
                resultSet.next();
                int ids = resultSet.getInt("total");
                ids++;

                // create insert query and fill in user fields
                query = "insert into users values (?,?,?,?, TO_DATE(?, 'mm/dd/yyyy'), ?)";
                prepStatement = connection.prepareStatement(query);
                prepStatement.setLong(1, ids);
                prepStatement.setString(2, fname);
                prepStatement.setString(3, lname);
                prepStatement.setString(4, email);
                prepStatement.setString(5, dob);
                java.util.Date time = new java.util.Date();
                Timestamp current = new Timestamp(time.getTime());
                prepStatement.setTimestamp(6, current);
                
                // run insert and notify user of success
                prepStatement.executeUpdate();
                resultSet.close();
                System.out.println("User Account Created!");
            } else {
                System.out.println("Invalid user input: Make sure no values are empty and the date format is mm/dd/yyyy");
            }
        }
        catch(SQLException Ex) {
            System.out.println("Error running the sample queries.  Machine Error: " +
                       Ex.toString());
        }
        catch (ParseException ex) {
            System.out.println("Invalid user input: Make sure no values are empty and the date format is mm/dd/yyyy");
        }
        finally{
            try {
                if (statement != null) statement.close();
                if (prepStatement != null) prepStatement.close();
            } catch (SQLException e) {
                System.out.println("Cannot close Statement. Machine error: "+e.toString());
            }
        }
    }

    public void initiateFriendship(String requestEmail, String toEmail){
        try{
            long requestID = 0;
            long toID = 0;
            
            // checks for valid user data
            if( !requestEmail.isEmpty() && !toEmail.isEmpty() )
            {
                // query requester's ID
                statement = connection.createStatement();
                String selectQuery = "SELECT userID FROM users WHERE email = " + requestEmail; 
                resultSet = statement.executeQuery(selectQuery);
                resultSet.next();
                requestID = resultSet.getLong("userID");

                if( requestID != 0 ) {
                    // query requester's ID
                    selectQuery = "SELECT userID FROM users WHERE email = " + toEmail; 
                    resultSet = statement.executeQuery(selectQuery);
                    resultSet.next();
                    toID = resultSet.getLong("userID");
                    
                    if( toID != 0 ) {
                        // create insert query and fill in user fields
                        query = "insert into pendingFriends values (?,?)";
                        prepStatement = connection.prepareStatement(query);
                        prepStatement.setLong(1, requestID); 
                        prepStatement.setLong(2, toID);
                        prepStatement.executeUpdate();
                        
                        query = "UPDATE users SET lastLogin=? WHERE email = " + requestEmail;
                        prepStatement = connection.prepareStatement(query);
                        java.util.Date date= new java.util.Date();
                        Timestamp current = new Timestamp(date.getTime());
                        prepStatement.setTimestamp(1, current);
                        prepStatement.executeUpdate();                 
                        
                        System.out.println("Friend Request Sent!");
                    } else {
                        System.out.println("Not a valid email to send friend request to");
                    }
                } else {
                    System.out.println("Not a valid email from requester");
                }
                resultSet.close();
            } else {
                System.out.println("Invalid user input: Make sure no values are empty and user emails exist");
            }
        }
        catch(SQLException Ex) {
            System.out.println("Error running the sample queries.  Machine Error: " +
                       Ex.toString());
        } 
        finally{
            try {
                if (statement != null) statement.close();
                if (prepStatement != null) prepStatement.close();
            } catch (SQLException e) {
                System.out.println("Cannot close Statement. Machine error: "+e.toString());
            }
        }
    }

    public void establishFriendShip(){

    }

    public void displayFriends(){

    }

    public void createGroup(){

    }

    public void addToGroup(){

    }

    public void sendMessageToUser(){

    }

    public void sendMessageToGroup(){

    }

    public void displayMessages(){

    }

    public void displayNewMessages(){

    }

    public void searchForUser(){

    }

    public void threeDegrees(){

    }

    public void topMessagers(){

    }

    public void dropUser(){

    }

    public static void main(String args[]) throws SQLException {
        //validate argument and set FaceSpaceApp "mode"
        String mode;
        if(args.length == 0){
            System.out.println("***Invalid Argument***");
            System.out.print("Please Choose Mode <User/Driver>: ");
            mode = scanner.next();
        }
        else{
            mode = args[0];
        }
        while(true){
            if(!mode.equalsIgnoreCase("user") && !mode.equalsIgnoreCase("driver")){
                System.out.println("***Invalid Mode***");
                System.out.print("Please Choose Mode <User/Driver>: ");
                mode = scanner.next();
            }
            else{
                break;
            }
        }

        //User is prompted for Oracle Username and Password
        String username, password;
        System.out.print("Enter Oracle Username: ");//This is your username in oracle
        username = scanner.next();
        System.out.print("Enter Oracle Password: "); //This is your password in oracle
        password = scanner.next();

        try{
            System.out.println("Logging In...");
            // Register the oracle driver.
            DriverManager.registerDriver (new oracle.jdbc.driver.OracleDriver());
            //This is the location of the database
            String url = "jdbc:oracle:thin:@class3.cs.pitt.edu:1521:dbclass";
            //create a connection to DB on class3.cs.pitt.edu
            connection = DriverManager.getConnection(url, username, password);

            if(mode.equalsIgnoreCase("user")){
                FaceSpaceApp fsa = new FaceSpaceApp(mode);
            }
            else{
                testDriver testApp = new testDriver();
            }
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
