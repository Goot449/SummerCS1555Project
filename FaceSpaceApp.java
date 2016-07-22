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
                    String requestEmail = "";
                    String toEmail = "";

                    initiateFriendship(requestEmail, toEmail);
                }
                else if(command == 3){
                    String user1Email = "";
                    String user2Email = "";

                    establishFriendship(user1Email, user2Email);
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
            if (!dob.isEmpty()){
                SimpleDateFormat sdf = new SimpleDateFormat("mm/dd/yyyy");
                date = sdf.parse(dob);
                if (!dob.equals(sdf.format(date))) {
                    date = null;
                }
            }
            // checks for valid user data
            if( !fname.isEmpty() && !lname.isEmpty() && !email.isEmpty() &&  date != null){
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
            if( !requestEmail.isEmpty() && !toEmail.isEmpty() ){
                // query requester's ID
                String selectQuery = "SELECT userID FROM users WHERE email = ?"; 
                prepStatement = connection.prepareStatement(selectQuery);
                prepStatement.setString(1, requestEmail);
                resultSet = prepStatement.executeQuery();
                if(resultSet.next()){
                    requestID = resultSet.getLong("userID");

                    // query requested to ID
                    selectQuery = "SELECT userID FROM users WHERE email = ?"; 
                    prepStatement = connection.prepareStatement(selectQuery);
                    prepStatement.setString(1, toEmail);
                    resultSet = prepStatement.executeQuery();
                    if(resultSet.next()) {
                        toID = resultSet.getLong("userID");

                        // check if friendship exists
                        selectQuery = "SELECT COUNT(*) FROM friends WHERE (userID1 = ? and userID2 = ?) or (userID1 = ? and userID2 = ?)"; 
                        prepStatement = connection.prepareStatement(selectQuery);
                        prepStatement.getLong(1, requestID);
                        prepStatement.getLong(2, toID);
                        prepStatement.getLong(3, toID);
                        prepStatement.getLong(4, requestID);
                        resultSet = prepStatement.executeQuery();
                        if(!resultSet.next()){
                            
                            // create insert query and fill in user fields
                            query = "insert into pendingFriends values (?,?)";
                            prepStatement = connection.prepareStatement(query);
                            prepStatement.setLong(1, requestID); 
                            prepStatement.setLong(2, toID);
                            prepStatement.executeUpdate();
                            
                            // change last login timie of requester
                            query = "UPDATE users SET lastLogin=? WHERE email = ?";
                            prepStatement = connection.prepareStatement(query);
                            java.util.Date date= new java.util.Date();
                            Timestamp current = new Timestamp(date.getTime());
                            prepStatement.setTimestamp(1, current);
                            prepStatement.setString(2, requestEmail);
                            prepStatement.executeUpdate();     

                            System.out.println("Friend Request Sent!");
                        } else {
                            System.out.println("Friendship already exists");
                        }
                    } else {
                        System.out.println("Invalid requested to email");
                    }
                } else {
                    System.out.println("Invalid requester email");
                }
                resultSet.close();
            } else {
                System.out.println("Invalid user input: Make sure no values are empty");
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

    public void establishFriendship(String user1Email, String user2Email){
        try{
            long user1ID = 0;
            long user2ID = 0;
            java.util.Date date = new java.util.Date();
            java.sql.Date sqlDate = new java.sql.Date(date.getTime());
            
            // checks for valid user data
            if( !user1Email.isEmpty() && !user2Email.isEmpty() ){
                // query user1's ID
                String selectQuery = "SELECT userID FROM users WHERE email = ?"; 
                prepStatement = connection.prepareStatement(selectQuery);
                prepStatement.setString(1, user1Email);
                resultSet = prepStatement.executeQuery();
                if(resultSet.next()){
                    user1ID = resultSet.getLong("userID");

                    // query user2's ID
                    selectQuery = "SELECT userID FROM users WHERE email = ?"; 
                    prepStatement = connection.prepareStatement(selectQuery);
                    prepStatement.setString(1, user2Email);
                    resultSet = prepStatement.executeQuery();
                    if(resultSet.next()){
                        user2ID = resultSet.getLong("userID");

                        // find ID of confirmer to update last login
                        selectQuery = "select toID from pendingFriends where toID = ? or toID = ?)";
                        prepStatement = connection.prepareStatement(selectQuery);
                        prepStatement.setLong(1, user1ID); 
                        prepStatement.setLong(2, user2ID);
                        resultSet = prepStatement.executeQuery();
                        if(resultSet.next()){
                            long confirmer = resultSet.getLong("userID");
                            
                            // create insert query and fill in friendship
                            query = "insert into friends values (?,?,?)";
                            prepStatement = connection.prepareStatement(query);
                            prepStatement.setLong(1, user1ID); 
                            prepStatement.setLong(2, user2ID);
                            prepStatement.setDate(3, sqlDate);
                            prepStatement.executeUpdate();
                            
                            // delete pending friendship
                            query = "delete from pendingFriends where toID = ? and (requestID = ? or requestID = ?)";
                            prepStatement = connection.prepareStatement(query);
                            prepStatement.setLong(1, confirmer); 
                            prepStatement.setLong(2, user1ID);
                            prepStatement.setLong(3, user2ID);
                            prepStatement.executeUpdate();
                            
                            // change last login time of confirmer
                            query = "UPDATE users SET lastLogin=? WHERE userID = ?";
                            prepStatement = connection.prepareStatement(query);
                            Timestamp current = new Timestamp(date.getTime());
                            prepStatement.setTimestamp(1, current);
                            prepStatement.setLong(2, confirmer);
                            prepStatement.executeUpdate();     

                            System.out.println("Friendship Confirmed!");
                        } else {
                            System.out.println("No pending friendship");
                        }
                    } else {
                        System.out.println("Invalid user 2 email");
                    }
                } else {
                    System.out.println("Invalid user 1 email");
                }
                resultSet.close();
            } else {
                System.out.println("Invalid user input: Make sure no values are empty");
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
