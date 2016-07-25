import java.sql.*;
import java.text.ParseException;
import java.util.Scanner;
import java.text.SimpleDateFormat;
import java.util.Stack;

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
                    System.out.println("**Create New User**");
                    System.out.print("Enter New User's First Name: ");
                    String fname = scanner.next();
                    System.out.print("Enter New User's Last Name: ");
                    String lname = scanner.next();
                    System.out.print("Enter New User's Email: ");
                    String email = scanner.next();
                    System.out.print("Enter New User's Date Of Birth (mm/dd/yyyy): ");
                    String dob = scanner.next();

                    createUser(fname, lname, email, dob);
                }
                else if(command == 2){
                    System.out.println("**Initiate Friendship**");
                    System.out.print("Enter User's Email Who's Requesting Friendship: ");
                    String requestEmail = scanner.next();
                    System.out.print("Enter User's Email Who's Recieving Request: ");
                    String toEmail = scanner.next();

                    initiateFriendship(requestEmail, toEmail);
                }
                else if(command == 3){
                    System.out.println("**Establish Friendship**");
                    System.out.print("Enter User1's Email: ");
                    String user1Email = scanner.next();
                    System.out.print("Enter User2's Email: ");
                    String user2Email = scanner.next();

                    establishFriendship(user1Email, user2Email);
                }
                else if(command == 4){
                    System.out.println("**Display Friends**");
                    System.out.print("Enter Users Email: ");
                    String email = scanner.next();

                    displayFriends(email);
                }
                else if(command == 5){
                    System.out.println("**Create Group**");
                    System.out.print("Enter Group Name: ");
                    String name = scanner.next();
                    System.out.print("Enter Group Description: ");
                    String description = scanner.next();
                    System.out.println("Set Member Limit: ");
                    int memberLimit = Integer.parseInt(scanner.next());

                    createGroup(name, description, memberLimit);
                }
                else if(command == 6){
                    System.out.println("**Add Member To Group**");
                    System.out.println("Enter New Member's Email: ");
                    String email = scanner.next();
                    System.out.println("Enter Group Name: ");
                    String groupName = scanner.next();

                    addToGroup(email, groupName);
                }
                else if(command == 7){
                    System.out.println("**Send Message To User**");
                    System.out.println("Enter Message's Subject: ");
                    String subject = scanner.next();
                    System.out.println("Enter Message's Body Text: ");
                    String body = scanner.next();
                    System.out.println("Enter Recipients Email: ");
                    String recipientEmail = scanner.next();
                    System.out.println("Enter Sender's Email: ");
                    String senderEmail = scanner.next();

                    sendMessageToUser(subject, body, recipientEmail, senderEmail);
                }
                else if(command == 8){
                    System.out.println("**Send Message To Group**");
                    System.out.println("Enter Message's Subject: ");
                    String subject = scanner.next();
                    System.out.println("Enter Message's Body Text: ");
                    String body = scanner.next();
                    System.out.println("Enter Group Name: ");
                    String groupName = scanner.next();
                    System.out.println("Enter Sender's Email: ");
                    String senderEmail = scanner.next();

                    sendMessageToGroup(subject, body, groupName, senderEmail);
                }
                else if(command == 9){
                    System.out.println("**Display Messages**");
                    System.out.println("Enter User's Email: ");
                    String userEmail = scanner.next();

                    displayMessages(userEmail);
                }
                else if(command == 10){
                    System.out.println("**Display New Messages**");
                    System.out.println("Enter User's Email: ");
                    String userEmail = scanner.next();

                    displayNewMessages(userEmail);
                }
                else if(command == 11){
                    System.out.println("**Search For User**");
                    System.out.println("Enter Search: ");
                    scanner.nextLine();
                    String search = scanner.nextLine();

                    searchForUser(search);
                }
                else if(command == 12){
                    System.out.println("**Three Degrees**");
                    System.out.print("Enter User1's Email: ");
                    String emailA = scanner.next();
                    System.out.print("Enter User2's Email: ");
                    String emailB = scanner.next();

                    threeDegrees(emailA, emailB);
                }
                else if(command == 13){
                    System.out.println("**Top Messagers**");
                    System.out.print("Enter Number of Top X Messagers: ");
                    int numMessagers = Integer.parseInt(scanner.next());
                    System.out.print("Enter Number of Months: ");
                    int numMonths = Integer.parseInt(scanner.next());

                    topMessagers(numMessagers, numMonths);
                }
                else if(command == 14){
                    System.out.println("**Drop User**");
                    System.out.print("Enter User's Email: ");
                    String userEmail = scanner.next();

                    dropUser(userEmail);
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
                        selectQuery = "SELECT userID1 FROM friends WHERE (userID1 = ? and userID2 = ?) or (userID1 = ? and userID2 = ?)";
                        prepStatement = connection.prepareStatement(selectQuery);
                        prepStatement.setLong(1, requestID);
                        prepStatement.setLong(2, toID);
                        prepStatement.setLong(3, toID);
                        prepStatement.setLong(4, requestID);
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
                        selectQuery = "select toID from pendingFriends where toID = ? or toID = ?";
                        prepStatement = connection.prepareStatement(selectQuery);
                        prepStatement.setLong(1, user1ID);
                        prepStatement.setLong(2, user2ID);
                        resultSet = prepStatement.executeQuery();
                        if(resultSet.next()){
                            long confirmer = resultSet.getLong("toID");

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

    public void displayFriends(String userEmail){
        try{
            long userID;
            long friendUserID;
            ResultSet resultSet2;
            ResultSet resultSetNames;
            // checks for valid user data
            if( !userEmail.isEmpty() ) {
                // query requester's userID
                String selectQuery = "SELECT userID FROM users WHERE email = ?";
                prepStatement = connection.prepareStatement(selectQuery);
                prepStatement.setString(1, userEmail);
                resultSet = prepStatement.executeQuery();
                //if user exists continue
                if(resultSet.next()){
                    userID = resultSet.getLong("userID");
                    //get userIDs that are friends with requester's ID
                    selectQuery = "SELECT userID2 FROM friends WHERE userID1 = ?";
                    prepStatement = connection.prepareStatement(selectQuery);
                    prepStatement.setLong(1, userID);
                    resultSet = prepStatement.executeQuery();
                    selectQuery = "SELECT userID1 FROM friends WHERE userID2 = ?";
                    prepStatement = connection.prepareStatement(selectQuery);
                    prepStatement.setLong(1, userID);
                    resultSet2 = prepStatement.executeQuery();
                    //Start showing names of user's Friends
                    System.out.println("Established Friends:");
                    //loop through all userIDs returned
                    while(resultSet.next()){
                        friendUserID = resultSet.getLong("userID2");
                        //get name from queried username (friend)
                        selectQuery = "SELECT fname,lname FROM users WHERE userID = ?";
                        prepStatement = connection.prepareStatement(selectQuery);
                        prepStatement.setLong(1, friendUserID);
                        resultSetNames = prepStatement.executeQuery();
                        //queue up the next name
                        resultSetNames.next();
                        //print name to screen
                        System.out.println(resultSetNames.getString("fname") + " " + resultSetNames.getString("lname"));
                    }
                    while(resultSet2.next()){
                        friendUserID = resultSet2.getLong("userID1");
                        //get name from queried username (friend)
                        selectQuery = "SELECT fname,lname FROM users WHERE userID = ?";
                        prepStatement = connection.prepareStatement(selectQuery);
                        prepStatement.setLong(1, friendUserID);
                        resultSetNames = prepStatement.executeQuery();
                        //queue up the next name
                        resultSetNames.next();
                        //print name to screen
                        System.out.println(resultSetNames.getString("fname") + " " + resultSetNames.getString("lname"));
                    }
                    //get userIDs that are Pending friends with requester's ID
                    selectQuery = "SELECT requestID FROM pendingFriends WHERE toID = ?";
                    prepStatement = connection.prepareStatement(selectQuery);
                    prepStatement.setLong(1, userID);
                    resultSet = prepStatement.executeQuery();
                    selectQuery = "SELECT toID FROM pendingFriends WHERE requestID = ?";
                    prepStatement = connection.prepareStatement(selectQuery);
                    prepStatement.setLong(1, userID);
                    resultSet2 = prepStatement.executeQuery();
                    //Start showing names of user's Pending Friends
                    System.out.println("Pending Friends:");
                    //loop through all userIDs returned
                    while(resultSet.next()){
                        friendUserID = resultSet.getLong("requestID");
                        //get name from queried username (friend)
                        selectQuery = "SELECT fname,lname FROM users WHERE userID = ?";
                        prepStatement = connection.prepareStatement(selectQuery);
                        prepStatement.setLong(1, friendUserID);
                        resultSetNames = prepStatement.executeQuery();
                        //queue up the next name
                        resultSetNames.next();
                        //print name to screen
                        System.out.println(resultSetNames.getString("fname") + " " + resultSetNames.getString("lname"));
                    }
                    while(resultSet2.next()){
                        friendUserID = resultSet2.getLong("toID");
                        //get name from queried username (friend)
                        selectQuery = "SELECT fname,lname FROM users WHERE userID = ?";
                        prepStatement = connection.prepareStatement(selectQuery);
                        prepStatement.setLong(1, friendUserID);
                        resultSetNames = prepStatement.executeQuery();
                        //queue up the next name
                        resultSetNames.next();
                        //print name to screen
                        System.out.println(resultSetNames.getString("fname") + " " + resultSetNames.getString("lname"));
                    }
                }
                else{
                    System.out.println("Invalid user input: No user exists with the given email");
                }
            }
            else{
                System.out.println("Invalid user input: Make sure to enter the user email");
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

    public void createGroup(String name, String description, int memberLimit){
        try{
            // checks for valid user data
            if( !name.isEmpty() && memberLimit > 0 ){
                // query number of groups to increment to next user id
                statement = connection.createStatement();
                String selectQuery = "SELECT COUNT(*) AS total FROM groupInfo";
                resultSet = statement.executeQuery(selectQuery);
                resultSet.next();
                int ids = resultSet.getInt("total");
                ids++;

                // create insert query and fill in user fields
                query = "insert into groupInfo values (?,?,?,?)";
                prepStatement = connection.prepareStatement(query);
                prepStatement.setLong(1, ids);
                prepStatement.setString(2, name);
                prepStatement.setString(3, description);
                prepStatement.setInt(4, memberLimit);

                // run insert and notify user of success
                prepStatement.executeUpdate();
                System.out.println("Group Created!");
                resultSet.close();
            } else {
                System.out.println("Invalid user input: Make sure no values are empty and Member limit is greater than 0");
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

    public void addToGroup(String email, String groupName){
        try{
            long userID;
            long groupID;
            int memberLimit;

            // checks for valid user data
            if( !email.isEmpty() && !groupName.isEmpty() ){

                // query user's ID
                String selectQuery = "SELECT userID FROM users WHERE email = ?";
                prepStatement = connection.prepareStatement(selectQuery);
                prepStatement.setString(1, email);
                resultSet = prepStatement.executeQuery();
                if(resultSet.next()){
                    userID = resultSet.getLong("userID");

                    // query group's ID
                    selectQuery = "SELECT groupID, memberLimit FROM groupInfo WHERE name = ?";
                    prepStatement = connection.prepareStatement(selectQuery);
                    prepStatement.setString(1, groupName);
                    resultSet = prepStatement.executeQuery();
                    if(resultSet.next()){
                        groupID = resultSet.getLong("groupID");
                        memberLimit = resultSet.getInt("memberLimit");

                        // query group's member size
                        selectQuery = "SELECT COUNT(*) AS total FROM groupMembership WHERE groupID = ?";
                        prepStatement = connection.prepareStatement(selectQuery);
                        prepStatement.setLong(1, groupID);
                        resultSet = prepStatement.executeQuery();
                        resultSet.next();
                        int size = resultSet.getInt("total");

                        if( size < memberLimit ){
                            // create insert query and fill in
                            query = "insert into groupMembership values (?,?)";
                            prepStatement = connection.prepareStatement(query);
                            prepStatement.setLong(1, groupID);
                            prepStatement.setLong(2, userID);

                            // run insert and notify user of success
                            prepStatement.executeUpdate();
                            System.out.println("Group Member Added!");
                        } else {
                            System.out.println("The group is full");
                        }
                    } else {
                        System.out.println("Invalid group name");
                    }
                } else {
                    System.out.println("Invalid user email");
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

    public void sendMessageToUser(String subject, String body, String recipientEmail, String senderEmail){
        try{
            long recipientID;
            long senderID;
            java.util.Date date = new java.util.Date();
            java.sql.Date sqlDate = new java.sql.Date(date.getTime());

            // checks for valid user data
            if( !subject.isEmpty() && !body.isEmpty() && !recipientEmail.isEmpty() && !senderEmail.isEmpty() ){
                // query recipient's ID
                String selectQuery = "SELECT userID FROM users WHERE email = ?";
                prepStatement = connection.prepareStatement(selectQuery);
                prepStatement.setString(1, recipientEmail);
                resultSet = prepStatement.executeQuery();
                if(resultSet.next()){
                    recipientID = resultSet.getLong("userID");

                    // query sender's ID
                    selectQuery = "SELECT userID FROM users WHERE email = ?";
                    prepStatement = connection.prepareStatement(selectQuery);
                    prepStatement.setString(1, senderEmail);
                    resultSet = prepStatement.executeQuery();
                    if(resultSet.next()) {
                        senderID = resultSet.getLong("userID");

                        // query number of messages to increment to next msg id
                        statement = connection.createStatement();
                        selectQuery = "SELECT COUNT(*) AS total FROM messages";
                        resultSet = statement.executeQuery(selectQuery);
                        resultSet.next();
                        int ids = resultSet.getInt("total");
                        ids++;

                        // create insert query and fill in messages fields
                        query = "insert into messages values (?,?,?,NULL,?,?,?)";
                        prepStatement = connection.prepareStatement(query);
                        prepStatement.setLong(1, ids);
                        prepStatement.setLong(2, senderID);
                        prepStatement.setLong(3, recipientID);
                        prepStatement.setString(4, subject);
                        prepStatement.setString(5, body);
                        prepStatement.setDate(6, sqlDate);
                        prepStatement.executeUpdate();

                        // change last login time of sender
                        query = "UPDATE users SET lastLogin=? WHERE userID = ?";
                        prepStatement = connection.prepareStatement(query);
                        Timestamp current = new Timestamp(date.getTime());
                        prepStatement.setTimestamp(1, current);
                        prepStatement.setLong(2, senderID);
                        prepStatement.executeUpdate();
                        System.out.println("Message Sent!");
                    } else {
                        System.out.println("Invalid sender email");
                    }
                } else {
                    System.out.println("Invalid recipient email");
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

    public void sendMessageToGroup(String subject, String body, String groupName, String senderEmail){
        try{
            long groupID;
            long senderID;
            java.util.Date date = new java.util.Date();
            java.sql.Date sqlDate = new java.sql.Date(date.getTime());

            // checks for valid user data
            if( !subject.isEmpty() && !body.isEmpty() && !groupName.isEmpty() && !senderEmail.isEmpty() ){
                // query group's ID
                String selectQuery = "SELECT groupID FROM groupInfo WHERE name = ?";
                prepStatement = connection.prepareStatement(selectQuery);
                prepStatement.setString(1, groupName);
                resultSet = prepStatement.executeQuery();
                if(resultSet.next()){
                    groupID = resultSet.getLong("groupID");

                    // query sender's ID
                    selectQuery = "SELECT userID FROM users WHERE email = ?";
                    prepStatement = connection.prepareStatement(selectQuery);
                    prepStatement.setString(1, senderEmail);
                    resultSet = prepStatement.executeQuery();
                    if(resultSet.next()) {
                        senderID = resultSet.getLong("userID");

                        // query number of messages to increment to next msg id
                        statement = connection.createStatement();
                        selectQuery = "SELECT COUNT(*) AS total FROM messages";
                        resultSet = statement.executeQuery(selectQuery);
                        resultSet.next();
                        int ids = resultSet.getInt("total");
                        ids++;

                        // create insert query and fill in messages fields
                        query = "insert into messages values (?,?,NULL,?,?,?,?)";
                        prepStatement = connection.prepareStatement(query);
                        prepStatement.setLong(1, ids);
                        prepStatement.setLong(2, senderID);
                        prepStatement.setLong(3, groupID);
                        prepStatement.setString(4, subject);
                        prepStatement.setString(5, body);
                        prepStatement.setDate(6, sqlDate);
                        prepStatement.executeUpdate();

                        // change last login time of sender
                        query = "UPDATE users SET lastLogin=? WHERE userID = ?";
                        prepStatement = connection.prepareStatement(query);
                        Timestamp current = new Timestamp(date.getTime());
                        prepStatement.setTimestamp(1, current);
                        prepStatement.setLong(2, senderID);
                        prepStatement.executeUpdate();
                        System.out.println("Message Sent!");
                    } else {
                        System.out.println("Invalid sender email");
                    }
                } else {
                    System.out.println("Invalid group name");
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

    public void displayMessages(String userEmail){
        try{
            long userID;

            // checks for valid user data
            if( !userEmail.isEmpty() ){

                // query user's ID
                String selectQuery = "SELECT userID FROM users WHERE email = ?";
                prepStatement = connection.prepareStatement(selectQuery);
                prepStatement.setString(1, userEmail);
                resultSet = prepStatement.executeQuery();
                if(resultSet.next()){
                    userID = resultSet.getLong("userID");

                    // display all messages to user
                    selectQuery = "SELECT * FROM messages WHERE recipientID = ?";
                    prepStatement = connection.prepareStatement(selectQuery);
                    prepStatement.setLong(1, userID);
                    resultSet = prepStatement.executeQuery();
                    while(resultSet.next()) {
                        System.out.println(resultSet.getString("subject") + "    " + resultSet.getString("message"));
                    }

                    // display all messages to user's groups
                    selectQuery = "SELECT * FROM groupMessageRecipients WHERE recipientID = ?";
                    prepStatement = connection.prepareStatement(selectQuery);
                    prepStatement.setLong(1, userID);
                    resultSet = prepStatement.executeQuery();
                    Stack<Long> resultStack = new Stack<Long>();
                    while(resultSet.next()){
                        long messageID = resultSet.getLong("msgID");
                        resultStack.push(new Long(messageID));
                    }

                    while(!resultStack.empty()){
                        selectQuery = "SELECT * FROM messages WHERE msgID = ?";
                        prepStatement = connection.prepareStatement(selectQuery);
                        Long messageID = (Long)resultStack.pop();
                        prepStatement.setLong(1, messageID);
                        resultSet = prepStatement.executeQuery();
                        while(resultSet.next()) {
                            System.out.println(resultSet.getString("subject") + "    " + resultSet.getString("message"));
                        }
                    }

                    // change last login time of sender
                    query = "UPDATE users SET lastLogin=? WHERE userID = ?";
                    prepStatement = connection.prepareStatement(query);
                    java.util.Date date = new java.util.Date();
                    Timestamp current = new Timestamp(date.getTime());
                    prepStatement.setTimestamp(1, current);
                    prepStatement.setLong(2, userID);
                    prepStatement.executeUpdate();

                } else {
                    System.out.println("Invalid user email");
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

    public void displayNewMessages(String userEmail){
        try{
            long userID;
            Timestamp lastLogin;

            // checks for valid user data
            if( !userEmail.isEmpty() ){

                // query user's ID
                String selectQuery = "SELECT userID, lastLogin FROM users WHERE email = ?";
                prepStatement = connection.prepareStatement(selectQuery);
                prepStatement.setString(1, userEmail);
                resultSet = prepStatement.executeQuery();
                if(resultSet.next()){
                    userID = resultSet.getLong("userID");
                    lastLogin = resultSet.getTimestamp("lastLogin");
                    if(lastLogin == null) {
                        displayMessages(userEmail);
                    } else {

                        // display all messages to user
                        selectQuery = "SELECT * FROM messages WHERE recipientID = ?";
                        prepStatement = connection.prepareStatement(selectQuery);
                        prepStatement.setLong(1, userID);
                        resultSet = prepStatement.executeQuery();
                        while(resultSet.next()) {
                            if(lastLogin.before(new Timestamp(resultSet.getDate("dateSent").getTime()))){
                                System.out.println(resultSet.getString("subject") + "    " + resultSet.getString("message"));
                            }
                        }

                        // display all messages to user's groups
                        selectQuery = "SELECT * FROM groupMessageRecipients WHERE recipientID = ?";
                        prepStatement = connection.prepareStatement(selectQuery);
                        prepStatement.setLong(1, userID);
                        resultSet = prepStatement.executeQuery();
                        Stack<Long> resultStack = new Stack<Long>();
                        while(resultSet.next()){
                            long messageID = resultSet.getLong("msgID");
                            resultStack.push(new Long(messageID));
                        }

                        while(!resultStack.empty()){
                            selectQuery = "SELECT * FROM messages WHERE msgID = ?";
                            prepStatement = connection.prepareStatement(selectQuery);
                            Long messageID = (Long)resultStack.pop();
                            prepStatement.setLong(1, messageID);
                            resultSet = prepStatement.executeQuery();
                            while(resultSet.next()) {
                                if(lastLogin.before(new Timestamp(resultSet.getDate("dateSent").getTime()))){
                                    System.out.println(resultSet.getString("subject") + "    " + resultSet.getString("message"));
                                }
                            }
                        }

                        // change last login time of sender
                        query = "UPDATE users SET lastLogin=? WHERE userID = ?";
                        prepStatement = connection.prepareStatement(query);
                        java.util.Date date = new java.util.Date();
                        Timestamp current = new Timestamp(date.getTime());
                        prepStatement.setTimestamp(1, current);
                        prepStatement.setLong(2, userID);
                        prepStatement.executeUpdate();
                    }
                } else {
                    System.out.println("Invalid user email");
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

    public void searchForUser(String search){


        try{
            //do not search if term is empty
            if (search.length()>1) {
                String[] terms = search.split(" ");
                long userID;
                long friendUserID;
                ResultSet resultSet2;
                ResultSet resultSetSearch;
                // checks for valid user data
                int i=0;
                int j=1;
                String selectQuery="";
                //Build Query
                for(String s : terms ) {
                    i++;
                    if (i > 1) {
                        selectQuery = selectQuery + " UNION ";
                    }
                    selectQuery = selectQuery + "SELECT DISTINCT fname,lname FROM users WHERE (fname LIKE ? OR lname LIKE ? OR email LIKE ?)";
                }
                //Prepare Statement
                prepStatement = connection.prepareStatement(selectQuery);
                //Bind terms to statement
                for(String s : terms ) {

                    String fname = s;
                    String lname = s;
                    String email = s;
                    prepStatement.setString(j, '%'+fname+'%');
                    prepStatement.setString(j+1, '%'+lname+'%');
                    prepStatement.setString(j+2, '%'+email+'%');
                    j=j+3;
                }
                resultSetSearch = prepStatement.executeQuery();
                //queue up the next name
                while(resultSetSearch.next()){
                    //print name to screen
                    System.out.println(resultSetSearch.getString("fname") + " " + resultSetSearch.getString("lname"));
                }
            }else{
                System.out.println("No search term entered.");
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

    public void threeDegrees(String emailA, String emailB){
        try{
            long AID = 0;
            long BID = 0;

            // checks for valid user data
            if( !emailA.isEmpty() && !emailB.isEmpty() ){
                // query requester's ID
                String selectQuery = "SELECT userID FROM users WHERE email = ?";
                prepStatement = connection.prepareStatement(selectQuery);
                prepStatement.setString(1, emailA);
                resultSet = prepStatement.executeQuery();
                if(resultSet.next()){
                    AID = resultSet.getLong("userID");

                    // query requested to ID
                    selectQuery = "SELECT userID FROM users WHERE email = ?";
                    prepStatement = connection.prepareStatement(selectQuery);
                    prepStatement.setString(1, emailB);
                    resultSet = prepStatement.executeQuery();
                    if(resultSet.next()) {
                        BID = resultSet.getLong("userID");

                        // find one hop friends
                        selectQuery = "SELECT userID2 FROM friends WHERE userID1 = ?";
                        prepStatement = connection.prepareStatement(selectQuery);
                        prepStatement.setLong(1, AID);
                        resultSet = prepStatement.executeQuery();
                        Stack<Long> hop1Stack = new Stack<Long>();
                        while(resultSet.next()){
                            long messageID = resultSet.getLong("userID2");
                            hop1Stack.push(new Long(messageID));
                        }
                        selectQuery = "SELECT userID1 FROM friends WHERE userID2 = ?";
                        prepStatement = connection.prepareStatement(selectQuery);
                        prepStatement.setLong(1, AID);
                        resultSet = prepStatement.executeQuery();
                        while(resultSet.next()){
                            long friend1ID = resultSet.getLong("userID1");
                            hop1Stack.push(new Long(friend1ID));
                        }

                        while(!hop1Stack.empty()){
                            Long hop1ID = (Long)hop1Stack.pop();
                            if(hop1ID == BID) {
                                System.out.println(AID + " -> " + BID);
                            } else {
                                // find two hop friends
                                selectQuery = "SELECT userID2 FROM friends WHERE userID1 = ?";
                                prepStatement = connection.prepareStatement(selectQuery);
                                prepStatement.setLong(1, hop1ID);
                                resultSet = prepStatement.executeQuery();
                                Stack<Long> hop2Stack = new Stack<Long>();
                                while(resultSet.next()){
                                    long friend2ID = resultSet.getLong("userID2");
                                    if(friend2ID != AID){
                                        hop2Stack.push(new Long(friend2ID));
                                    }
                                }
                                selectQuery = "SELECT userID1 FROM friends WHERE userID2 = ?";
                                prepStatement = connection.prepareStatement(selectQuery);
                                prepStatement.setLong(1, hop1ID);
                                resultSet = prepStatement.executeQuery();
                                while(resultSet.next()){
                                    long friend2ID = resultSet.getLong("userID1");
                                    hop2Stack.push(new Long(friend2ID));
                                }

                                while(!hop2Stack.empty()){
                                    Long hop2ID = (Long)hop2Stack.pop();
                                    if(hop2ID == BID) {
                                        System.out.println(AID + " -> " + hop1ID + " -> " + BID);
                                    } else {
                                        // find three hop friends
                                        selectQuery = "SELECT userID2 FROM friends WHERE userID1 = ?";
                                        prepStatement = connection.prepareStatement(selectQuery);
                                        prepStatement.setLong(1, hop2ID);
                                        resultSet = prepStatement.executeQuery();
                                        Stack<Long> hop3Stack = new Stack<Long>();
                                        while(resultSet.next()){
                                            long friend3ID = resultSet.getLong("userID2");
                                            hop3Stack.push(new Long(friend3ID));
                                        }
                                        selectQuery = "SELECT userID1 FROM friends WHERE userID2 = ?";
                                        prepStatement = connection.prepareStatement(selectQuery);
                                        prepStatement.setLong(1, hop2ID);
                                        resultSet = prepStatement.executeQuery();
                                        while(resultSet.next()){
                                            long friend3ID = resultSet.getLong("userID1");
                                            hop3Stack.push(new Long(friend3ID));
                                        }

                                        while(!hop3Stack.empty()){
                                            Long hop3ID = (Long)hop3Stack.pop();
                                            if(hop3ID == BID) {
                                                System.out.println(AID + " -> " + hop1ID + " -> " + hop2ID + " -> " + BID);
                                            }
                                        }
                                    }
                                }
                            }
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

    public void topMessagers(int numMessagers, int numMonths){

    }

    public void dropUser(String userEmail){

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
