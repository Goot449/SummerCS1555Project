//driver
//used to run and show all methods in FaceSpaceApp working properly

public class testDriver {
    //this is used as a faster testing method
    public testDriver(){
        FaceSpaceApp testApp = new FaceSpaceApp("driver");

        //test createUser()
        System.out.println("***create user Billy Joe***");
        testApp.createUser("billy","joe","testuser@gmail.com","04/05/1995");
        System.out.println();

        //test initiateFriendship()
        System.out.println("***Nate Spangler friend Requests Billy Joe***");
        testApp.initiateFriendship("spangy@gmail.com","testuser@gmail.com");
        System.out.println();
        System.out.println("***Show Nate's Friends***");
        testApp.displayFriends("spangy@gmail.com");
        //test establishFriendship()
        System.out.println();
        System.out.println("***Billy Joe accepts friendship***");
        testApp.establishFriendship("spangy@gmail.com","testuser@gmail.com");

        //test displayFriends()
        System.out.println();
        System.out.println("***Show Billy's friends***");
        testApp.displayFriends("testuser@gmail.com");
        System.out.println();
        System.out.println("***Show Nate's friends (notice pending friends is now empty***");
        testApp.displayFriends("spangy@gmail.com");

        //test createGroup()


        //test addToGroup()


        //test sendMessageToUser()


        //test sendMessageToGroup()


        //test displayMessages()


        //test displayNewMessages()


        //test searchForUser()


        //test threeDegrees()


        //test topMessagers()


        //test dropUser()



    }
}
