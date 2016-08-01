--create database schema
--populate database with data

DROP TABLE users CASCADE CONSTRAINTS;
DROP TABLE friends CASCADE CONSTRAINTS;
DROP TABLE pendingFriends CASCADE CONSTRAINTS;
DROP TABLE groupInfo CASCADE CONSTRAINTS;
DROP TABLE groupMembership CASCADE CONSTRAINTS;
DROP TABLE messages CASCADE CONSTRAINTS;
DROP TABLE groupMessageRecipients CASCADE CONSTRAINTS;

purge recyclebin;

--Assuming that all users data is necessary (name, email, etc.)
CREATE TABLE users
(
    userID NUMBER(10) NOT NULL,
    fname VARCHAR2(20) NOT NULL,
    lname VARCHAR2(20) NOT NULL,
    email VARCHAR2(50) NOT NULL,
    dob DATE NOT NULL,
    lastLogin TIMESTAMP,
    CONSTRAINT users_pk PRIMARY KEY (userID),
    CONSTRAINT users_email UNIQUE (email)
    --an email can only be registered under one user
);

CREATE TABLE friends
(
    userID1 NUMBER(10) NOT NULL,
    userID2 NUMBER(10) NOT NULL,
    dateEstablished DATE NOT NULL,
    CONSTRAINT friends_pk PRIMARY KEY (userID1, userID2),
    CONSTRAINT friends_fk1 FOREIGN KEY (userID1) REFERENCES users(userID) ON DELETE CASCADE,
    CONSTRAINT friends_fk2 FOREIGN KEY (userID2) REFERENCES users(userID) ON DELETE CASCADE
);

CREATE TABLE pendingFriends
(
    requestID NUMBER(10) NOT NULL,
    toID NUMBER(10) NOT NULL,
    CONSTRAINT pendingFriends_pk PRIMARY KEY (requestID, toID),
    CONSTRAINT pendingFriends_fk1 FOREIGN KEY (requestID) REFERENCES users(userID),
    CONSTRAINT pendingFriends_fk2 FOREIGN KEY (toID) REFERENCES users(userID)
);

--assuming group description is not longer than 255 characters

CREATE TABLE groupInfo
(
    groupID NUMBER(10) NOT NULL,
    name VARCHAR2(50) NOT NULL,
    description VARCHAR2(255),
    memberLimit NUMBER(5) NOT NULL,
    CONSTRAINT group_pk PRIMARY KEY (groupID),
    CONSTRAINT group_name UNIQUE (name)
);

CREATE TABLE groupMembership
(
    groupID NUMBER(10) NOT NULL,
    userID NUMBER(10) NOT NULL,
    CONSTRAINT groupMembership_pk PRIMARY KEY (groupID, userID),
    CONSTRAINT groupMembership_fk1 FOREIGN KEY (groupID) REFERENCES groupInfo(groupID),
    CONSTRAINT groupMembership_fk2 FOREIGN KEY (userID) REFERENCES users(userID) ON DELETE CASCADE
);
--user is prompted via the createGroup() function to set groupInfo.memberLimit
--addToGroup() function will enforce the groupInfo.memberLimit

--if recipientID is not null, message will be sent there. Otherwise, check toGroupID and send to all group members
--add respective rows to groupMessageRecipients
--****possibly add a constraint that prevents a user from sending a message to a group they are not a member of****
CREATE TABLE messages
(
    msgID NUMBER(10) NOT NULL,
    senderID NUMBER(10) DEFAULT NULL,
    recipientID NUMBER(10) DEFAULT NULL,
    toGroupID NUMBER(10) DEFAULT NULL,
    subject VARCHAR2(50) NOT NULL,
    message VARCHAR2(100) NOT NULL,
    dateSent DATE NOT NULL,
    CONSTRAINT msg_pk PRIMARY KEY (msgID),
    CONSTRAINT msg_fk1 FOREIGN KEY (senderID) REFERENCES users(userID) ON DELETE SET NULL
    --CONSTRAINT msg_check CHECK ((recipientID IS NOT NULL AND toGroupID IS NULL) OR (toGroupID IS NOT NULL AND recipientID IS NULL))
    --check to make sure there is a recipient or group to receive message
);

--used to see who recieved a message sent to a group
--this way members that join later are not marked as seeing a message
CREATE TABLE groupMessageRecipients
(
    msgID NUMBER(10) NOT NULL,
    recipientID NUMBER(10) NOT NULL,
    CONSTRAINT groupMessageRecipients_pk PRIMARY KEY (msgID, recipientID),
    CONSTRAINT groupMessageRecipients_fk1 FOREIGN KEY (msgID) REFERENCES messages(msgID),
    CONSTRAINT groupMessageRecipients_fk2 FOREIGN KEY (recipientID) REFERENCES users(userID) ON DELETE CASCADE
);

--trigger on Insert into messages that ensures that a messages is only sent to a single recipient or single group and not both.
--needed to be trigger in order to drop user and delete a single ID from the messages table
CREATE OR REPLACE TRIGGER check_messages
    BEFORE INSERT ON messages
    FOR EACH ROW
    BEGIN
       IF NOT((:new.recipientID IS NOT NULL AND :new.toGroupID IS NULL) OR (:new.toGroupID IS NOT NULL AND :new.recipientID IS NULL))
            THEN RAISE_APPLICATION_ERROR(-20001, 'Cannot Insert into Messages because recipientID and toGroupID are not XOR (1 and only one must be NULL)');
       ELSIF (:new.senderID IS NULL)
            THEN RAISE_APPLICATION_ERROR(-20002, 'Cannot Insert into Messages because senderID is NULL');
       END IF;
    END;
/

--When a message to a group is inserted into Messages
--This trigger will populate the groupMessageRecipients table with the recipients of the message in the group
CREATE OR REPLACE TRIGGER GroupMessage
    AFTER INSERT
    ON messages
    FOR EACH ROW
    BEGIN
        IF(:new.toGroupID IS NOT NULL) THEN
            FOR cursor IN (SELECT GM.userID FROM groupMembership GM
                --do not want to insert the sender as a recipient
                WHERE (GM.groupID = :new.toGroupID AND GM.userID <> :new.senderID))
            LOOP
                INSERT INTO groupMessageRecipients VALUES(:new.msgID, cursor.userID);
            END LOOP;
        END IF;
    END;
/

-- A message is deleted only when both the sender and all receivers are deleted
CREATE OR REPLACE TRIGGER DropUserMessages
AFTER DELETE ON users
    BEGIN
        DELETE FROM messages
        WHERE 	(senderID IS NULL AND recipientID IS NULL AND toGroupID IS NULL);
    END;
/


--create 100 users
INSERT INTO users VALUES (1, 'jimmy', 'john', 'jimjohn@gmail.com', TO_DATE('01/02/1999', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (2, 'timmy', 'john', 'timjohn@gmail.com', TO_DATE('01/02/1999', 'mm/dd/yyyy'),  NULL);
INSERT INTO users VALUES (3, 'steve', 'turner', 'sturner@gmail.com', TO_DATE('04/09/1994', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (4, 'nate', 'spangler', 'spangy@gmail.com', TO_DATE('08/21/1993', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (5, 'jake', 'gob', 'turkeyboy@gmail.com', TO_DATE('05/02/1994', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (6, 'connor', 'kaz', 'kazzy@gmail.com', TO_DATE('07/23/1994', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (7, 'ricky', 'kot', 'kotr@gmail.com', TO_DATE('07/08/2000', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (8, 'rick', 'kot', 'kotrr@gmail.com', TO_DATE('07/08/2000', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (9, 'richard', 'kot', 'kotrrr@gmail.com', TO_DATE('07/08/2000', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (10, 'rick', 'kot', 'kotrr8@gmail.com', TO_DATE('07/08/2000', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (11, 'matt', 'vater', 'mater@gmail.com', TO_DATE('09/28/2000', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (12, 'matthew', 'vater', 'mvater@gmail.com', TO_DATE('09/28/2000', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (13, 'dan', 'vater', 'dater@gmail.com', TO_DATE('09/28/2001', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (14, 'daniel', 'vater', 'dvader@gmail.com', TO_DATE('09/28/2001', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (15, 'eric', 'friend', 'efri@gmail.com', TO_DATE('04/15/1994', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (16, 'greg', 'friend', 'gend@gmail.com', TO_DATE('09/28/1991', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (17, 'mike', 'logan', 'mogan@gmail.com', TO_DATE('09/28/1992', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (18, 'adam', 'carmichael', 'acam@gmail.com', TO_DATE('09/28/1996', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (19, 'trevor', 'fry', 'try@gmail.com', TO_DATE('04/12/1993', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (20, 'jon', 'rankin', 'runjohn@gmail.com', TO_DATE('02/28/1995', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (21, 'rip', 'cord', 'cordr@gmail.com', TO_DATE('09/13/2000', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (22, 'archer', 'sterling', 'archs@gmail.com', TO_DATE('03/28/1990', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (23, 'matt', 'reslink', 'mres@gmail.com', TO_DATE('09/28/1997', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (24, 'nick', 'reslink', 'res@gmail.com', TO_DATE('09/28/1994', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (25, 'pat', 'mehta', 'meh@gmail.com', TO_DATE('12/28/1993', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (26, 'cat', 'mehta', 'cater@gmail.com', TO_DATE('09/30/1989', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (27, 'zach', 'edge', 'zed@gmail.com', TO_DATE('06/28/1994', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (28, 'jessie', 'edge', 'jed@gmail.com', TO_DATE('09/28/1995', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (29, 'justin', 'paylo', 'payj@gmail.com', TO_DATE('09/28/1998', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (30, 'dylan', 'paylo', 'dpay@gmail.com', TO_DATE('09/28/2003', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (31, 'jimmy', 'john', 'jimjohn12@gmail.com', TO_DATE('01/02/1999', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (32, 'timmy', 'john', 'timjohn43@gmail.com', TO_DATE('01/02/1999', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (33, 'steve', 'turner', 'sturner54@gmail.com', TO_DATE('04/09/1994', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (34, 'nate', 'spangler', 'spangy1@gmail.com', TO_DATE('08/21/1993', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (35, 'jake', 'gob', 'turkeyboy21@gmail.com', TO_DATE('05/02/1994', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (36, 'connor', 'kaz', 'kazzy2@gmail.com', TO_DATE('07/23/1994', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (37, 'ricky', 'kot', 'kotr98@gmail.com', TO_DATE('07/08/2000', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (38, 'rick', 'kot', 'kotrr65@gmail.com', TO_DATE('07/08/2000', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (39, 'richard', 'kot', 'kotrrr43@gmail.com', TO_DATE('07/08/2000', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (40, 'rick', 'kot', 'kotrr23@gmail.com', TO_DATE('07/08/2000', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (41, 'matt', 'vater', 'mater7@gmail.com', TO_DATE('09/28/2000', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (42, 'matthew', 'vater', 'mvater09@gmail.com', TO_DATE('09/28/2000', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (43, 'dan', 'vater', 'dater67@gmail.com', TO_DATE('09/28/2001', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (44, 'daniel', 'vater', 'dvader65@gmail.com', TO_DATE('09/28/2001', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (45, 'eric', 'friend', 'efri44@gmail.com', TO_DATE('04/15/1994', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (46, 'greg', 'friend', 'gend43@gmail.com', TO_DATE('09/28/1991', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (47, 'mike', 'logan', 'mogan09@gmail.com', TO_DATE('09/28/1992', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (48, 'adam', 'carmichael', 'acam78@gmail.com', TO_DATE('09/28/1996', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (49, 'trevor', 'fry', 'try54@gmail.com', TO_DATE('04/12/1993', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (50, 'jon', 'rankin', 'runjohn22@gmail.com', TO_DATE('02/28/1995', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (51, 'rip', 'cord', 'cordr2@gmail.com', TO_DATE('09/13/2000', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (52, 'archer', 'sterling', 'archs87@gmail.com', TO_DATE('03/28/1990', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (53, 'matt', 'reslink', 'mres71@gmail.com', TO_DATE('09/28/1997', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (54, 'nick', 'reslink', 'res58@gmail.com', TO_DATE('09/28/1994', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (55, 'pat', 'mehta', 'meh29@gmail.com', TO_DATE('12/28/1993', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (56, 'cat', 'mehta', 'cater7@gmail.com', TO_DATE('09/30/1989', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (57, 'zach', 'edge', 'zed66@gmail.com', TO_DATE('06/28/1994', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (58, 'jessie', 'edge', 'jed54@gmail.com', TO_DATE('09/28/1995', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (59, 'justin', 'paylo', 'payj33@gmail.com', TO_DATE('09/28/1998', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (60, 'dylan', 'paylo', 'mater99@gmail.com', TO_DATE('09/28/2003', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (61, 'karen', 'derk', 'kart@gmail.com', TO_DATE('09/28/1987', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (62, 'geno', 'malkin', 'score71@gmail.com', TO_DATE('03/28/1971', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (63, 'sidney', 'crosby', 'bestever@gmail.com', TO_DATE('09/28/1987', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (64, 'marc', 'flower', 'fpower@gmail.com', TO_DATE('09/28/1978', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (65, 'kristen', 'lab', 'klab@gmail.com', TO_DATE('08/28/1994', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (66, 'sarah', 'lang', 'slang@gmail.com', TO_DATE('09/28/1998', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (67, 'corey', 'lang', 'clang@gmail.com', TO_DATE('09/28/1996', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (68, 'sara', 'long', 'slong@gmail.com', TO_DATE('05/28/1998', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (69, 'cory', 'long', 'clong@gmail.com', TO_DATE('05/17/1996', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (70, 'colby', 'donaldson', 'csur@gmail.com', TO_DATE('09/28/1983', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (71, 'cole', 'caleb', 'cc@gmail.com', TO_DATE('09/28/2002', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (72, 'nicky', 'lepore', 'lepn@gmail.com', TO_DATE('02/18/1994', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (73, 'mehgan', 'ball', 'mall@gmail.com', TO_DATE('09/28/1993', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (74, 'erin', 'hair', 'iren@gmail.com', TO_DATE('09/28/1999', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (75, 'audrey', 'plaza', 'plaa@gmail.com', TO_DATE('03/14/1992', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (76, 'aubrey', 'plaza', 'apla@gmail.com', TO_DATE('03/14/1992', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (77, 'nicole', 'pearson', 'np@gmail.com', TO_DATE('03/14/1993', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (78, 'jac', 'lucci', 'lucy@gmail.com', TO_DATE('03/14/1994', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (79, 'cheryl', 'lont', 'cl@gmail.com', TO_DATE('03/14/1967', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (80, 'tony', 'tort', 'tt@gmail.com', TO_DATE('03/14/1960', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (81, 'karen', 'derk', 'kart12@gmail.com', TO_DATE('09/28/1987', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (82, 'geno', 'malkin', 'score09@gmail.com', TO_DATE('03/28/1971', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (83, 'sidney', 'crosby', 'bestever87@gmail.com', TO_DATE('09/28/1987', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (84, 'marc', 'flower', 'fpower29@gmail.com', TO_DATE('09/28/1978', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (85, 'kristen', 'lab', 'klab54@gmail.com', TO_DATE('08/28/1994', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (86, 'sarah', 'lang', 'slang77@gmail.com', TO_DATE('09/28/1998', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (87, 'corey', 'lang', 'clang67@gmail.com', TO_DATE('09/28/1996', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (88, 'sara', 'long', 'slong88@gmail.com', TO_DATE('05/28/1998', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (89, 'cory', 'long', 'clong91@gmail.com', TO_DATE('05/17/1996', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (90, 'colby', 'donaldson', 'csur16@gmail.com', TO_DATE('09/28/1983', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (91, 'cole', 'caleb', 'cc22@gmail.com', TO_DATE('09/28/2002', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (92, 'nicky', 'lepore', 'lepn43@gmail.com', TO_DATE('02/18/1994', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (93, 'mehgan', 'ball', 'mall9@gmail.com', TO_DATE('09/28/1993', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (94, 'erin', 'hair', 'iren5@gmail.com', TO_DATE('09/28/1999', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (95, 'audrey', 'plaza', 'plaa4@gmail.com', TO_DATE('03/14/1992', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (96, 'aubrey', 'plaza', 'apla2@gmail.com', TO_DATE('03/14/1992', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (97, 'nicole', 'pearson', 'np3@gmail.com', TO_DATE('03/14/1993', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (98, 'jac', 'lucci', 'lucy11@gmail.com', TO_DATE('03/14/1994', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (99, 'cheryl', 'lont', 'cl1@gmail.com', TO_DATE('03/14/1967', 'mm/dd/yyyy'), NULL);
INSERT INTO users VALUES (100, 'tony', 'tort', 'tt00@gmail.com', TO_DATE('03/14/1960', 'mm/dd/yyyy'), NULL);

--generate 200 friendships
INSERT INTO friends VALUES (1, 2, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (1, 3, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (2, 3, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (2, 4, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (3, 4, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (3, 5, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (4, 5, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (4, 6, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (5, 6, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (5, 7, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (6, 7, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (6, 8, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (7, 8, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (7, 9, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (8, 9, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (8, 10, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (9, 10, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (9, 11, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (10, 11, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (10, 12, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (11, 12, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (11, 13, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (12, 13, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (12, 14, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (13, 14, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (13, 15, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (14, 15, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (14, 16, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (15, 16, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (15, 17, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (16, 17, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (16, 18, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (17, 18, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (17, 19, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (18, 20, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (18, 21, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (19, 21, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (19, 22, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (20, 22, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (20, 23, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (21, 23, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (21, 24, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (22, 24, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (22, 25, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (23, 25, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (23, 26, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (24, 26, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (24, 27, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (25, 27, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (25, 28, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (26, 28, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (26, 29, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (27, 29, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (27, 30, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (28, 30, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (28, 31, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (29, 31, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (29, 32, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (30, 32, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (30, 33, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (31, 33, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (31, 34, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (32, 34, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (32, 35, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (33, 35, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (33, 36, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (34, 36, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (34, 37, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (35, 37, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (35, 38, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (36, 38, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (36, 39, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (37, 39, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (37, 40, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (38, 40, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (38, 41, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (39, 41, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (39, 42, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (40, 42, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (40, 43, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (41, 44, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (41, 45, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (42, 45, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (42, 46, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (43, 46, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (43, 47, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (44, 47, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (44, 48, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (45, 48, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (45, 49, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (46, 49, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (46, 50, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (47, 50, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (47, 51, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (48, 51, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (48, 52, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (49, 52, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (49, 53, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (50, 53, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (50, 54, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (1, 55, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (1, 56, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (2, 56, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (2, 57, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (3, 57, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (3, 58, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (4, 58, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (4, 59, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (5, 59, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (5, 60, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (6, 60, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (6, 61, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (7, 61, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (7, 62, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (8, 62, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (8, 63, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (9, 63, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (9, 64, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (10, 64, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (10, 65, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (11, 65, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (11, 66, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (12, 66, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (12, 67, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (13, 67, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (13, 68, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (14, 68, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (14, 69, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (15, 69, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (15, 70, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (16, 70, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (16, 71, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (17, 71, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (17, 72, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (18, 72, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (18, 73, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (19, 73, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (19, 74, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (20, 74, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (20, 75, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (21, 75, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (21, 76, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (22, 76, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (22, 77, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (23, 77, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (23, 78, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (24, 78, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (24, 79, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (25, 79, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (25, 80, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (26, 80, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (26, 81, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (27, 81, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (27, 82, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (28, 82, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (28, 83, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (29, 83, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (29, 84, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (30, 85, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (30, 86, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (31, 86, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (31, 87, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (32, 87, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (32, 88, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (33, 88, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (33, 89, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (34, 89, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (34, 90, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (35, 90, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (35, 91, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (36, 91, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (36, 92, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (37, 92, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (37, 93, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (38, 93, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (38, 94, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (39, 94, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (39, 95, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (40, 95, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (40, 96, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (41, 96, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (41, 97, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (42, 97, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (42, 98, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (43, 98, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (43, 99, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (44, 99, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (44, 100, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (45, 100, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (45, 99, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (46, 98, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (46, 97, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (47, 96, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (47, 95, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (48, 94, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (48, 93, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (49, 92, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (49, 91, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (50, 90, TO_DATE('7/11/2016', 'mm/dd/yyyy'));
INSERT INTO friends VALUES (50, 89, TO_DATE('7/11/2016', 'mm/dd/yyyy'));

--create 10 groups
INSERT INTO groupInfo VALUES (1, 'Soccer', 'For soccer players', 50);
INSERT INTO groupInfo VALUES (2, 'Football', 'For football players', 50);
INSERT INTO groupInfo VALUES (3, 'Hockey', 'For hockey players', 50);
INSERT INTO groupInfo VALUES (4, 'Baseball', 'For baseball players', 50);
INSERT INTO groupInfo VALUES (5, 'Softball', 'For softball players', 50);
INSERT INTO groupInfo VALUES (6, 'Rugby', 'For rugby players', 50);
INSERT INTO groupInfo VALUES (7, 'Tennis', 'For tennis players', 50);
INSERT INTO groupInfo VALUES (8, 'Frisbee', 'For frisbee players', 50);
INSERT INTO groupInfo VALUES (9, 'Baseketball', 'For baseketball players', 50);
INSERT INTO groupInfo VALUES (10, 'Golf', 'For golf players', 50);

--add members to the groups
--membershipID,groupID,userID
--only users 1-13 are currently in groups for simplicity
INSERT INTO groupMembership VALUES (1,1 );
INSERT INTO groupMembership VALUES (1,2 );
INSERT INTO groupMembership VALUES (1,3 );
INSERT INTO groupMembership VALUES (2,4 );
INSERT INTO groupMembership VALUES (2,5 );
INSERT INTO groupMembership VALUES (2,6 );
INSERT INTO groupMembership VALUES (2,7 );
INSERT INTO groupMembership VALUES (2,8 );
INSERT INTO groupMembership VALUES (3,9 );
INSERT INTO groupMembership VALUES (3,10);
INSERT INTO groupMembership VALUES (3,11);
INSERT INTO groupMembership VALUES (4,1 );
INSERT INTO groupMembership VALUES (4,2 );
INSERT INTO groupMembership VALUES (4,3 );
INSERT INTO groupMembership VALUES (4,4 );
INSERT INTO groupMembership VALUES (5,5 );
INSERT INTO groupMembership VALUES (5,6 );
INSERT INTO groupMembership VALUES (5,7 );
INSERT INTO groupMembership VALUES (6,8 );
INSERT INTO groupMembership VALUES (6,9 );
INSERT INTO groupMembership VALUES (6,10);
INSERT INTO groupMembership VALUES (6,11);
INSERT INTO groupMembership VALUES (6,12);
INSERT INTO groupMembership VALUES (6,13);
INSERT INTO groupMembership VALUES (7,1 );
INSERT INTO groupMembership VALUES (7,2 );
INSERT INTO groupMembership VALUES (7,3 );
INSERT INTO groupMembership VALUES (8,4 );
INSERT INTO groupMembership VALUES (8,5 );
INSERT INTO groupMembership VALUES (8,6 );
INSERT INTO groupMembership VALUES (8,7 );
INSERT INTO groupMembership VALUES (8,8 );
INSERT INTO groupMembership VALUES (8,9 );
INSERT INTO groupMembership VALUES (9,10);
INSERT INTO groupMembership VALUES (9,11);
INSERT INTO groupMembership VALUES (9,12);
INSERT INTO groupMembership VALUES (9,13);
INSERT INTO groupMembership VALUES (10,1);
INSERT INTO groupMembership VALUES (10,2);
INSERT INTO groupMembership VALUES (10,3);
INSERT INTO groupMembership VALUES (10,4);

--generate 300 messages
--messages sent to a group only come from a member in the group
INSERT INTO messages VALUES(1  ,1  ,2 ,NULL,'Soccer Game','cant wait for the game!',TO_DATE('01/01/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(2  ,2  ,10,NULL,'Soccer Game','cant wait for the game!',TO_DATE('01/01/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(3  ,3  ,10,NULL,'Soccer Game','cant wait for the game!',TO_DATE('01/01/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(4  ,4  ,10,NULL,'Football Game','cant wait for the game!',TO_DATE('01/01/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(5  ,5  ,14,NULL,'Football Game','go steelers!',TO_DATE('01/01/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(6  ,6  ,13,NULL,'Football Game','go Eagles!',TO_DATE('01/01/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(7  ,7  ,18,NULL,'Football Game','go Eagles!',TO_DATE('01/01/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(8  ,8  ,10,NULL,'Football Game','go redskins!',TO_DATE('01/01/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(9  ,9  ,10,NULL,'Football Game','go Eagles!',TO_DATE('01/01/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(10 ,10 ,14,NULL,'Football Game','go Eagles!',TO_DATE('01/01/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(11 ,11 ,13,NULL,'Football Game','go team!',TO_DATE('01/01/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(12 ,12 ,18,NULL,'Baseball Game','go Eagles!',TO_DATE('01/01/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(13 ,13 ,10,NULL,'Baseball Game','cant wait for the game!',TO_DATE('1/1/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(14 ,14 ,10,NULL,'Baseball Game','wow the phillies suck',TO_DATE('2/2/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(15 ,15 ,14,NULL,'Baseball Game','wow the phillies suck',TO_DATE('3/3/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(16 ,16 ,13,NULL,'Baseball Game','wow the phillies suck',TO_DATE('4/4/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(17 ,17 ,18,NULL,'Baseball Game','homerun!',TO_DATE('5/5/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(18 ,18 ,10,NULL,'Baseball Game','cant wait for the game!',TO_DATE('6/6/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(19 ,19 ,10,NULL,'Baseball Game','Pirates are struggling',TO_DATE('7/7/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(20 ,20 ,14,NULL,'Baseball Game','Pirates are struggling',TO_DATE('8/8/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(21 ,21 ,13,NULL,'Baseball Game','Pirates are struggling',TO_DATE('9/9/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(22 ,22 ,18,NULL,'Hockey Game','cant wait for the game!',TO_DATE('1/1/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(23 ,23 ,10,NULL,'Hockey Game','cant wait for the game!',TO_DATE('2/3/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(24 ,24 ,10,NULL,'Hockey Game','we won the cup',TO_DATE('3/5/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(25 ,25 ,14,NULL,'Hockey Game','we won the cup',TO_DATE('4/7/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(26 ,26 ,13,NULL,'Hockey Game','we won the cup',TO_DATE('5/9/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(27 ,27 ,18,NULL,'Hockey Game','what a dirty shot',TO_DATE('6/11/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(28 ,28 ,10,NULL,'Hockey Game','what a dirty shot',TO_DATE('7/13/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(29 ,29 ,10,NULL,'Hockey Game','what a dirty shot',TO_DATE('8/15/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(30 ,30 ,14,NULL,'Hockey Game','what a dirty shot',TO_DATE('9/17/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(31 ,31 ,13,NULL,'Hockey Game','USA for gold!!',TO_DATE('10/19/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(32 ,32 ,18,NULL,'Hockey Game','USA for gold!!',TO_DATE('11/21/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(33 ,33 ,2 ,NULL,'Soccer Game','USA for gold!!',TO_DATE('01/01/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(34 ,34 ,10,NULL,'Soccer Game','USA USA',TO_DATE('01/01/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(35 ,35 ,10,NULL,'Soccer Game','goalllllllll',TO_DATE('01/01/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(36 ,36 ,2 ,NULL,'Soccer Game','goalllllllll',TO_DATE('01/01/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(37 ,37 ,10,NULL,'Soccer Game','goalllllllll',TO_DATE('01/01/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(38 ,38 ,10,NULL,'Cricket Game','What are the rules for cricket?',TO_DATE('01/01/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(39 ,39 ,2 ,NULL,'Cricket Game','What are the rules for cricket?',TO_DATE('01/02/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(40 ,40 ,10,NULL,'Cricket Game','What are the rules for cricket?',TO_DATE('01/03/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(41 ,41 ,10,NULL,'Cricket Game','What are the rules for cricket?',TO_DATE('01/04/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(42 ,42 ,2 ,NULL,'Cricket Game','What are the rules for cricket?',TO_DATE('01/05/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(43 ,43 ,10,NULL,'Cricket Game','What are the rules for cricket?',TO_DATE('01/06/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(44 ,44 ,10,NULL,'Cricket Game','What are the rules for cricket?',TO_DATE('01/07/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(45 ,45 ,2 ,NULL,'Cricket Game','What are the rules for cricket?',TO_DATE('01/08/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(46 ,46 ,10,NULL,'Cricket Game','What are the rules for cricket?',TO_DATE('01/09/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(47 ,47 ,10,NULL,'Cricket Game','What are the rules for cricket?',TO_DATE('01/10/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(48 ,48 ,2 ,NULL,'Cricket Game','What are the rules for cricket?',TO_DATE('01/11/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(49 ,49 ,10,NULL,'Cricket Game','What are the rules for cricket?',TO_DATE('02/12/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(50 ,50 ,10,NULL,'Cricket Game','What are the rules for cricket?',TO_DATE('02/13/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(51 ,51 ,10,NULL,'Normal Message','Hi, how are you?',TO_DATE('02/14/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(52 ,52 ,2 ,NULL,'Normal Message','Hi, how are you?',TO_DATE('02/15/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(53 ,53 ,10,NULL,'Normal Message','Hi, how are you?',TO_DATE('02/16/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(54 ,54 ,10,NULL,'Normal Message','Hi, how are you?',TO_DATE('02/17/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(55 ,55 ,2 ,NULL,'Normal Message','Hi, how are you?',TO_DATE('02/18/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(56 ,56 ,10,NULL,'Normal Message','Hi, how are you?',TO_DATE('02/19/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(57 ,57 ,10,NULL,'Normal Message','Hi, how are you?',TO_DATE('02/20/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(58 ,58 ,2 ,NULL,'Normal Message','Hi, how are you?',TO_DATE('02/21/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(59 ,59 ,10,NULL,'Normal Message','Hi, how are you?',TO_DATE('02/22/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(60 ,60 ,10,NULL,'Normal Message','I like to message my friends',TO_DATE('03/23/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(61 ,61 ,2 ,NULL,'Normal Message','I like to message my friends',TO_DATE('03/24/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(62 ,62 ,10,NULL,'Normal Message','I like to message my friends',TO_DATE('03/25/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(63 ,63 ,10,NULL,'Normal Message','I like to message my friends',TO_DATE('03/26/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(64 ,64 ,10,NULL,'Normal Message','I like to message my friends',TO_DATE('03/27/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(65 ,65 ,2 ,NULL,'Weird Message','I just love messaging you so much',TO_DATE('03/01/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(66 ,66 ,10,NULL,'Weird Message','I just love messaging you so much',TO_DATE('03/02/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(67 ,67 ,10,NULL,'Weird Message','I just love messaging you so much',TO_DATE('03/03/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(68 ,68 ,2 ,NULL,'Weird Message','I just love messaging you so much',TO_DATE('03/04/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(69 ,69 ,10,NULL,'Weird Message','I just love messaging you so much',TO_DATE('03/05/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(70 ,70 ,10,NULL,'Weird Message','I just love messaging you so much',TO_DATE('03/06/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(71 ,71 ,2 ,NULL,'Weird Message','I just love messaging you so much',TO_DATE('04/07/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(72 ,72 ,10,NULL,'Weird Message','I just love messaging you so much',TO_DATE('04/08/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(73 ,73 ,10,NULL,'Normal Message','On my way',TO_DATE('04/09/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(74 ,74 ,2 ,NULL,'Normal Message','On my way',TO_DATE('04/10/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(75 ,75 ,10,NULL,'Normal Message','On my way',TO_DATE('04/11/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(76 ,76 ,10,NULL,'Normal Message','On my way',TO_DATE('04/12/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(77 ,77 ,10,NULL,'Normal Message','On my way',TO_DATE('04/13/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(78 ,78 ,2 ,NULL,'Normal Message','On my way',TO_DATE('04/14/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(79 ,79 ,10,NULL,'Normal Message','Running Late!',TO_DATE('04/15/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(80 ,80 ,10,NULL,'Normal Message','Running Late!',TO_DATE('04/16/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(81 ,81 ,2 ,NULL,'Normal Message','Running Late!',TO_DATE('04/17/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(82 ,82 ,10,NULL,'Normal Message','Running Late!',TO_DATE('05/18/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(83 ,83 ,10,NULL,'Normal Message','Running Late!',TO_DATE('05/19/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(84 ,84 ,2 ,NULL,'Normal Message','Running Late!',TO_DATE('05/20/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(85 ,85 ,10,NULL,'message','Wanna get food',TO_DATE('05/21/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(86 ,86 ,10,NULL,'message','Wanna get food',TO_DATE('05/22/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(87 ,87 ,2 ,NULL,'message','Wanna get food',TO_DATE('05/23/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(88 ,88 ,10,NULL,'message','Wanna get food',TO_DATE('05/24/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(89 ,89 ,10,NULL,'message','Wanna get food',TO_DATE('05/25/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(90 ,90 ,10,NULL,'message','Wanna get food',TO_DATE('05/26/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(91 ,91 ,2 ,NULL,'message','Im wasted',TO_DATE('05/27/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(92 ,92 ,10,NULL,'message','Im wasted',TO_DATE('05/28/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(93 ,93 ,10,NULL,'message','Im wasted',TO_DATE('06/29/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(94 ,94 ,2 ,NULL,'message','Im wasted',TO_DATE('06/01/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(95 ,95 ,10,NULL,'message','Im wasted',TO_DATE('06/01/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(96 ,96 ,10,NULL,'message','Im wasted',TO_DATE('06/02/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(97 ,97 ,2 ,NULL,'message','You driving tonight?',TO_DATE('06/03/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(98 ,98 ,10,NULL,'message','You driving tonight?',TO_DATE('06/04/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(99 ,99 ,10,NULL,'message','You driving tonight?',TO_DATE('06/05/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(100,100,2 ,NULL,'message','You driving tonight?',TO_DATE('06/06/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(101,1  ,10,NULL,'message','You driving tonight?',TO_DATE('06/07/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(102,2  ,10,NULL,'message','You driving tonight?',TO_DATE('06/08/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(103,3  ,10,NULL,'message','You driving tonight?',TO_DATE('06/09/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(104,4  ,2 ,NULL,'message','I love rollercoasters',TO_DATE('07/10/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(105,5  ,10,NULL,'message','I love rollercoasters',TO_DATE('07/11/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(106,6  ,10,NULL,'message','I love rollercoasters',TO_DATE('07/12/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(107,7  ,2 ,NULL,'message','I love rollercoasters',TO_DATE('07/13/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(108,8  ,10,NULL,'message','I love rollercoasters',TO_DATE('07/14/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(109,9  ,10,NULL,'message','I love rollercoasters',TO_DATE('07/15/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(110,10 ,2 ,NULL,'message','I love rollercoasters',TO_DATE('07/16/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(111,11 ,10,NULL,'message','I love rollercoasters',TO_DATE('07/17/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(112,12 ,10,NULL,'message','I wanna go to the beach',TO_DATE('07/18/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(113,13 ,2 ,NULL,'message','I wanna go to the beach',TO_DATE('07/19/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(114,14 ,10,NULL,'message','I wanna go to the beach',TO_DATE('07/20/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(115,15 ,10,NULL,'message','I wanna go to the beach',TO_DATE('08/01/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(116,16 ,10,NULL,'message','I wanna go to the beach',TO_DATE('08/02/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(117,17 ,2 ,NULL,'message','I wanna go to the beach',TO_DATE('08/03/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(118,18 ,10,NULL,'message','Tell me a funny joke',TO_DATE('08/04/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(119,19 ,10,NULL,'message','Tell me a funny joke',TO_DATE('08/05/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(120,20 ,2 ,NULL,'message','Tell me a funny joke',TO_DATE('08/06/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(121,21 ,10,NULL,'message','Tell me a funny joke',TO_DATE('08/07/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(122,22 ,10,NULL,'message','Tell me a funny joke',TO_DATE('08/08/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(123,23 ,2 ,NULL,'message','Tell me a funny joke',TO_DATE('08/09/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(124,24 ,10,NULL,'message','your face, I like that',TO_DATE('08/10/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(125,25 ,10,NULL,'message','your face, I like that',TO_DATE('08/11/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(126,26 ,2 ,NULL,'message','your face, I like that',TO_DATE('09/12/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(127,27 ,10,NULL,'message','your face, I like that',TO_DATE('09/13/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(128,28 ,10,NULL,'message','your face, I like that',TO_DATE('09/14/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(129,29 ,10,NULL,'message','your face, I like that',TO_DATE('09/15/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(130,30 ,2 ,NULL,'message','your face, I like that',TO_DATE('09/16/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(131,31 ,10,NULL,'message','Reddit is my favorite website',TO_DATE('09/17/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(132,32 ,10,NULL,'message','Reddit is my favorite website',TO_DATE('09/18/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(133,33 ,2 ,NULL,'message','Reddit is my favorite website',TO_DATE('09/19/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(134,34 ,10,NULL,'message','Reddit is my favorite website',TO_DATE('09/20/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(135,35 ,10,NULL,'message','Reddit is my favorite website',TO_DATE('09/21/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(136,36 ,2 ,NULL,'message','Reddit is my favorite website',TO_DATE('09/22/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(137,37 ,10,NULL,'message','I am a database master',TO_DATE('10/23/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(138,38 ,10,NULL,'message','I am a database master',TO_DATE('10/24/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(139,39 ,2 ,NULL,'message','I am a database master',TO_DATE('10/25/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(140,40 ,10,NULL,'message','I am a database master',TO_DATE('10/26/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(141,41 ,10,NULL,'message','I am a database master',TO_DATE('10/27/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(142,42 ,10,NULL,'message','I am a database master',TO_DATE('10/28/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(143,43 ,2 ,NULL,'message','databases get get a little annoying',TO_DATE('10/01/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(144,44 ,10,NULL,'message','databases get get a little annoying',TO_DATE('10/02/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(145,45 ,10,NULL,'message','databases get get a little annoying',TO_DATE('10/03/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(146,46 ,2 ,NULL,'message','databases get get a little annoying',TO_DATE('10/04/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(147,47 ,10,NULL,'message','databases get get a little annoying',TO_DATE('10/05/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(148,48 ,10,NULL,'message','databases get get a little annoying',TO_DATE('11/06/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(149,49 ,2 ,NULL,'message','databases get get a little annoying',TO_DATE('11/07/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(150,50 ,10,NULL,'message','databases get get a little annoying',TO_DATE('11/08/2016','mm/dd/yyyy'));
--group messages
INSERT INTO messages VALUES(151,2  ,NULL,1 ,'Group Announcement','Everyong must be nice to one another'           ,TO_DATE('01/09/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(152,1  ,NULL,1 ,'Group Announcement','We are meeting up tomorrow'                     ,TO_DATE('01/02/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(153,1  ,NULL,1 ,'Group Announcement','This group is doing well'                       ,TO_DATE('01/03/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(154,2  ,NULL,1 ,'Group Announcement','Id like to introduce myself as admin'           ,TO_DATE('01/04/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(155,2  ,NULL,1 ,'Group Announcement','Please let me know if there is an issue'        ,TO_DATE('01/05/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(156,1  ,NULL,1 ,'Group Announcement','Our group is the best grouop in the whole world',TO_DATE('01/06/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(157,1  ,NULL,1 ,'Group Announcement','whats everyone up to'                           ,TO_DATE('01/07/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(158,3  ,NULL,1 ,'Group Announcement','Whos going to our meet and greet?'              ,TO_DATE('01/08/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(159,1  ,NULL,1 ,'Group Announcement','no advertising allowed in this group'           ,TO_DATE('01/09/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(160,3  ,NULL,1 ,'Group Announcement','Hope everyone is enjoying this weather'         ,TO_DATE('01/10/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(161,2  ,NULL,1 ,'Group Announcement','Everyone welcome Bob to the group'              ,TO_DATE('01/11/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(162,1  ,NULL,1 ,'Group Announcement','I will be in hawaii for the next week'          ,TO_DATE('01/12/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(163,1  ,NULL,1 ,'Group Announcement','Everyone welcome Tim as the newest admin'       ,TO_DATE('01/13/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(164,2  ,NULL,1 ,'Group Announcement','share our group and make us well known!'        ,TO_DATE('02/01/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(165,1  ,NULL,1 ,'Group Announcement','Hope youre all enjoying the group'              ,TO_DATE('02/02/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(166,4  ,NULL,2 ,'Group Announcement','Everyong must be nice to one another'           ,TO_DATE('02/03/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(167,4  ,NULL,2 ,'Group Announcement','We are meeting up tomorrow'                     ,TO_DATE('02/04/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(168,5  ,NULL,2 ,'Group Announcement','This group is doing well'                       ,TO_DATE('02/05/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(169,5  ,NULL,2 ,'Group Announcement','Id like to introduce myself as admin'           ,TO_DATE('02/06/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(170,5  ,NULL,2 ,'Group Announcement','Please let me know if there is an issue'        ,TO_DATE('02/07/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(171,6  ,NULL,2 ,'Group Announcement','Our group is the best grouop in the whole world',TO_DATE('02/08/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(172,6  ,NULL,2 ,'Group Announcement','whats everyone up to'                           ,TO_DATE('02/09/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(173,7  ,NULL,2 ,'Group Announcement','Whos going to our meet and greet?'              ,TO_DATE('02/10/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(174,7  ,NULL,2 ,'Group Announcement','no advertising allowed in this group'           ,TO_DATE('02/11/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(175,7  ,NULL,2 ,'Group Announcement','Hope everyone is enjoying this weather'         ,TO_DATE('02/12/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(176,4  ,NULL,2 ,'Group Announcement','Everyone welcome Bob to the group'              ,TO_DATE('02/13/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(177,4  ,NULL,2 ,'Group Announcement','I will be in hawaii for the next week'          ,TO_DATE('03/14/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(178,4  ,NULL,2 ,'Group Announcement','Everyone welcome Tim as the newest admin'       ,TO_DATE('03/15/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(179,4  ,NULL,2 ,'Group Announcement','share our group and make us well known!'        ,TO_DATE('03/16/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(180,4  ,NULL,2 ,'Group Announcement','Hope youre all enjoying the group'              ,TO_DATE('03/17/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(181,9  ,NULL,3 ,'Group Announcement','Everyong must be nice to one another'           ,TO_DATE('03/18/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(182,9  ,NULL,3 ,'Group Announcement','We are meeting up tomorrow'                     ,TO_DATE('03/19/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(183,9  ,NULL,3 ,'Group Announcement','This group is doing well'                       ,TO_DATE('03/20/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(184,9  ,NULL,3 ,'Group Announcement','Id like to introduce myself as admin'           ,TO_DATE('03/21/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(185,11 ,NULL,3 ,'Group Announcement','Please let me know if there is an issue'        ,TO_DATE('03/22/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(186,11 ,NULL,3 ,'Group Announcement','Our group is the best grouop in the whole world',TO_DATE('03/23/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(187,10 ,NULL,3 ,'Group Announcement','whats everyone up to'                           ,TO_DATE('03/24/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(188,9  ,NULL,3 ,'Group Announcement','Whos going to our meet and greet?'              ,TO_DATE('03/25/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(189,9  ,NULL,3 ,'Group Announcement','no advertising allowed in this group'           ,TO_DATE('03/26/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(190,9  ,NULL,3 ,'Group Announcement','Hope everyone is enjoying this weather'         ,TO_DATE('04/01/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(191,10 ,NULL,3 ,'Group Announcement','Everyone welcome Bob to the group'              ,TO_DATE('04/02/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(192,11 ,NULL,3 ,'Group Announcement','I will be in hawaii for the next week'          ,TO_DATE('04/03/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(193,9  ,NULL,3 ,'Group Announcement','Everyone welcome Tim as the newest admin'       ,TO_DATE('04/04/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(194,9  ,NULL,3 ,'Group Announcement','share our group and make us well known!'        ,TO_DATE('04/05/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(195,10 ,NULL,3 ,'Group Announcement','Hope youre all enjoying the group'              ,TO_DATE('04/06/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(196,1  ,NULL,4 ,'Group Announcement','Everyong must be nice to one another'           ,TO_DATE('04/07/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(197,2  ,NULL,4 ,'Group Announcement','We are meeting up tomorrow'                     ,TO_DATE('04/08/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(198,1  ,NULL,4 ,'Group Announcement','This group is doing well'                       ,TO_DATE('04/09/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(199,1  ,NULL,4 ,'Group Announcement','Id like to introduce myself as admin'           ,TO_DATE('04/10/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(200,2  ,NULL,4 ,'Group Announcement','Please let me know if there is an issue'        ,TO_DATE('04/11/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(201,1  ,NULL,4 ,'Group Announcement','Our group is the best grouop in the whole world',TO_DATE('04/12/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(202,1  ,NULL,4 ,'Group Announcement','whats everyone up to'                           ,TO_DATE('04/13/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(203,4  ,NULL,4 ,'Group Announcement','Whos going to our meet and greet?'              ,TO_DATE('05/14/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(204,1  ,NULL,4 ,'Group Announcement','no advertising allowed in this group'           ,TO_DATE('05/15/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(205,3  ,NULL,4 ,'Group Announcement','Hope everyone is enjoying this weather'         ,TO_DATE('05/16/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(206,3  ,NULL,4 ,'Group Announcement','Everyone welcome Bob to the group'              ,TO_DATE('05/17/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(207,2  ,NULL,4 ,'Group Announcement','I will be in hawaii for the next week'          ,TO_DATE('05/18/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(208,1  ,NULL,4 ,'Group Announcement','Everyone welcome Tim as the newest admin'       ,TO_DATE('05/19/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(209,4  ,NULL,4 ,'Group Announcement','share our group and make us well known!'        ,TO_DATE('05/20/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(210,2  ,NULL,4 ,'Group Announcement','Hope youre all enjoying the group'              ,TO_DATE('05/21/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(211,5  ,NULL,5 ,'Group Announcement','Everyong must be nice to one another'           ,TO_DATE('05/22/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(212,5  ,NULL,5 ,'Group Announcement','We are meeting up tomorrow'                     ,TO_DATE('05/23/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(213,6  ,NULL,5 ,'Group Announcement','This group is doing well'                       ,TO_DATE('05/24/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(214,6  ,NULL,5 ,'Group Announcement','Id like to introduce myself as admin'           ,TO_DATE('05/25/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(215,6  ,NULL,5 ,'Group Announcement','Please let me know if there is an issue'        ,TO_DATE('05/26/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(216,7  ,NULL,5 ,'Group Announcement','Our group is the best grouop in the whole world',TO_DATE('06/27/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(217,8  ,NULL,5 ,'Group Announcement','whats everyone up to'                           ,TO_DATE('06/28/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(218,7  ,NULL,5 ,'Group Announcement','Whos going to our meet and greet?'              ,TO_DATE('06/29/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(219,7  ,NULL,5 ,'Group Announcement','no advertising allowed in this group'           ,TO_DATE('06/30/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(220,5  ,NULL,5 ,'Group Announcement','Hope everyone is enjoying this weather'         ,TO_DATE('06/01/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(221,5  ,NULL,5 ,'Group Announcement','Everyone welcome Bob to the group'              ,TO_DATE('06/02/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(222,6  ,NULL,5 ,'Group Announcement','I will be in hawaii for the next week'          ,TO_DATE('06/01/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(223,7  ,NULL,5 ,'Group Announcement','Everyone welcome Tim as the newest admin'       ,TO_DATE('06/02/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(224,8  ,NULL,5 ,'Group Announcement','share our group and make us well known!'        ,TO_DATE('06/03/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(225,8  ,NULL,5 ,'Group Announcement','Hope youre all enjoying the group'              ,TO_DATE('06/04/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(226,10 ,NULL,6 ,'Group Announcement','Everyong must be nice to one another'           ,TO_DATE('06/05/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(227,11 ,NULL,6 ,'Group Announcement','We are meeting up tomorrow'                     ,TO_DATE('06/06/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(228,11 ,NULL,6 ,'Group Announcement','This group is doing well'                       ,TO_DATE('06/07/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(229,9  ,NULL,6 ,'Group Announcement','Id like to introduce myself as admin'           ,TO_DATE('07/08/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(230,13 ,NULL,6 ,'Group Announcement','Please let me know if there is an issue'        ,TO_DATE('07/09/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(231,8  ,NULL,6 ,'Group Announcement','Our group is the best grouop in the whole world',TO_DATE('07/10/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(232,12 ,NULL,6 ,'Group Announcement','whats everyone up to'                           ,TO_DATE('07/11/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(233,12 ,NULL,6 ,'Group Announcement','Whos going to our meet and greet?'              ,TO_DATE('07/12/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(234,11 ,NULL,6 ,'Group Announcement','no advertising allowed in this group'           ,TO_DATE('07/13/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(235,11 ,NULL,6 ,'Group Announcement','Hope everyone is enjoying this weather'         ,TO_DATE('07/14/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(236,12 ,NULL,6 ,'Group Announcement','Everyone welcome Bob to the group'              ,TO_DATE('07/15/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(237,10 ,NULL,6 ,'Group Announcement','I will be in hawaii for the next week'          ,TO_DATE('07/16/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(238,11 ,NULL,6 ,'Group Announcement','Everyone welcome Tim as the newest admin'       ,TO_DATE('07/17/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(239,12 ,NULL,6 ,'Group Announcement','share our group and make us well known!'        ,TO_DATE('07/18/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(240,13 ,NULL,6 ,'Group Announcement','Hope youre all enjoying the group'              ,TO_DATE('07/19/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(241,1  ,NULL,7 ,'Group Announcement','Everyong must be nice to one another'           ,TO_DATE('07/20/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(242,2  ,NULL,7 ,'Group Announcement','We are meeting up tomorrow'                     ,TO_DATE('08/21/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(243,1  ,NULL,7 ,'Group Announcement','This group is doing well'                       ,TO_DATE('08/01/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(244,1  ,NULL,7 ,'Group Announcement','Id like to introduce myself as admin'           ,TO_DATE('08/02/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(245,2  ,NULL,7 ,'Group Announcement','Please let me know if there is an issue'        ,TO_DATE('08/03/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(246,2  ,NULL,7 ,'Group Announcement','Our group is the best grouop in the whole world',TO_DATE('08/04/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(247,1  ,NULL,7 ,'Group Announcement','whats everyone up to'                           ,TO_DATE('08/05/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(248,3  ,NULL,7 ,'Group Announcement','Whos going to our meet and greet?'              ,TO_DATE('08/06/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(249,3  ,NULL,7 ,'Group Announcement','no advertising allowed in this group'           ,TO_DATE('08/07/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(250,1  ,NULL,7 ,'Group Announcement','Hope everyone is enjoying this weather'         ,TO_DATE('08/08/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(251,1  ,NULL,7 ,'Group Announcement','Everyone welcome Bob to the group'              ,TO_DATE('08/09/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(252,2  ,NULL,7 ,'Group Announcement','I will be in hawaii for the next week'          ,TO_DATE('08/10/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(253,3  ,NULL,7 ,'Group Announcement','Everyone welcome Tim as the newest admin'       ,TO_DATE('08/11/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(254,1  ,NULL,7 ,'Group Announcement','share our group and make us well known!'        ,TO_DATE('08/12/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(255,2  ,NULL,7 ,'Group Announcement','Hope youre all enjoying the group'              ,TO_DATE('09/13/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(256,4  ,NULL,8 ,'Group Announcement','Everyong must be nice to one another'           ,TO_DATE('09/14/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(257,4  ,NULL,8 ,'Group Announcement','We are meeting up tomorrow'                     ,TO_DATE('09/15/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(258,4  ,NULL,8 ,'Group Announcement','This group is doing well'                       ,TO_DATE('09/16/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(259,6  ,NULL,8 ,'Group Announcement','Id like to introduce myself as admin'           ,TO_DATE('09/17/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(260,6  ,NULL,8 ,'Group Announcement','Please let me know if there is an issue'        ,TO_DATE('09/18/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(261,5  ,NULL,8 ,'Group Announcement','Our group is the best grouop in the whole world',TO_DATE('09/19/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(262,7  ,NULL,8 ,'Group Announcement','whats everyone up to'                           ,TO_DATE('09/20/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(263,7  ,NULL,8 ,'Group Announcement','Whos going to our meet and greet?'              ,TO_DATE('09/21/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(264,8  ,NULL,8 ,'Group Announcement','no advertising allowed in this group'           ,TO_DATE('09/22/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(265,9  ,NULL,8 ,'Group Announcement','Hope everyone is enjoying this weather'         ,TO_DATE('09/23/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(266,8  ,NULL,8 ,'Group Announcement','Everyone welcome Bob to the group'              ,TO_DATE('09/24/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(267,7  ,NULL,8 ,'Group Announcement','I will be in hawaii for the next week'          ,TO_DATE('09/01/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(268,5  ,NULL,8 ,'Group Announcement','Everyone welcome Tim as the newest admin'       ,TO_DATE('10/02/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(269,5  ,NULL,8 ,'Group Announcement','share our group and make us well known!'        ,TO_DATE('10/03/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(270,4  ,NULL,8 ,'Group Announcement','Hope youre all enjoying the group'              ,TO_DATE('10/04/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(271,10 ,NULL,9 ,'Group Announcement','Everyong must be nice to one another'           ,TO_DATE('10/05/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(272,12 ,NULL,9 ,'Group Announcement','We are meeting up tomorrow'                     ,TO_DATE('10/06/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(273,11 ,NULL,9 ,'Group Announcement','This group is doing well'                       ,TO_DATE('10/07/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(274,11 ,NULL,9 ,'Group Announcement','Id like to introduce myself as admin'           ,TO_DATE('10/08/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(275,12 ,NULL,9 ,'Group Announcement','Please let me know if there is an issue'        ,TO_DATE('10/09/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(276,11 ,NULL,9 ,'Group Announcement','Our group is the best grouop in the whole world',TO_DATE('10/10/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(277,13 ,NULL,9 ,'Group Announcement','whats everyone up to'                           ,TO_DATE('10/11/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(278,13 ,NULL,9 ,'Group Announcement','Whos going to our meet and greet?'              ,TO_DATE('10/12/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(279,10 ,NULL,9 ,'Group Announcement','no advertising allowed in this group'           ,TO_DATE('10/13/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(280,11 ,NULL,9 ,'Group Announcement','Hope everyone is enjoying this weather'         ,TO_DATE('10/14/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(281,12 ,NULL,9 ,'Group Announcement','Everyone welcome Bob to the group'              ,TO_DATE('11/15/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(282,10 ,NULL,9 ,'Group Announcement','I will be in hawaii for the next week'          ,TO_DATE('11/16/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(283,11 ,NULL,9 ,'Group Announcement','Everyone welcome Tim as the newest admin'       ,TO_DATE('11/17/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(284,12 ,NULL,9 ,'Group Announcement','share our group and make us well known!'        ,TO_DATE('11/18/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(285,12 ,NULL,9 ,'Group Announcement','Hope youre all enjoying the group'              ,TO_DATE('11/19/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(286,1  ,NULL,10,'Group Announcement','Everyong must be nice to one another'           ,TO_DATE('11/20/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(287,3  ,NULL,10,'Group Announcement','We are meeting up tomorrow'                     ,TO_DATE('11/21/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(288,2  ,NULL,10,'Group Announcement','This group is doing well'                       ,TO_DATE('11/22/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(289,1  ,NULL,10,'Group Announcement','Id like to introduce myself as admin'           ,TO_DATE('11/23/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(290,1  ,NULL,10,'Group Announcement','Please let me know if there is an issue'        ,TO_DATE('11/24/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(291,2  ,NULL,10,'Group Announcement','Our group is the best grouop in the whole world',TO_DATE('11/25/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(292,1  ,NULL,10,'Group Announcement','whats everyone up to'                           ,TO_DATE('11/26/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(293,3  ,NULL,10,'Group Announcement','Whos going to our meet and greet?'              ,TO_DATE('11/27/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(294,2  ,NULL,10,'Group Announcement','no advertising allowed in this group'           ,TO_DATE('12/28/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(295,3  ,NULL,10,'Group Announcement','Hope everyone is enjoying this weather'         ,TO_DATE('12/29/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(296,1  ,NULL,10,'Group Announcement','Everyone welcome Bob to the group'              ,TO_DATE('12/01/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(297,2  ,NULL,10,'Group Announcement','I will be in hawaii for the next week'          ,TO_DATE('12/01/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(298,4  ,NULL,10,'Group Announcement','Everyone welcome Tim as the newest admin'       ,TO_DATE('12/01/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(299,4  ,NULL,10,'Group Announcement','share our group and make us well known!'        ,TO_DATE('12/01/2016','mm/dd/yyyy'));
INSERT INTO messages VALUES(300,1  ,NULL,10,'Group Announcement','Hope youre all enjoying the group'              ,TO_DATE('12/01/2016','mm/dd/yyyy'));

commit;
