DROP TABLE users CASCADE CONSTRAINTS;
DROP TABLE friends CASCADE CONSTRAINTS;
DROP TABLE pendingFriends CASCADE CONSTRAINTS;
DROP TABLE groupInfo CASCADE CONSTRAINTS;
DROP TABLE groupMembership CASCADE CONSTRAINTS;
DROP TABLE messages CASCADE CONSTRAINTS;
DROP TABLE groupMessageRecipients CASCADE CONSTRAINTS;

DROP SEQUENCE seq_usersID;
DROP SEQUENCE seq_groupID;
DROP SEQUENCE seq_msgID;

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
--Allows new users to be added without needing to know the next available usersID
--to use: call seq_userID.nextval
CREATE SEQUENCE seq_usersID START WITH 1 INCREMENT BY 1;

CREATE TABLE friends
(
    userID1 NUMBER(10) NOT NULL,
    userID2 NUMBER(10) NOT NULL,
    dateEstablished DATE NOT NULL,
    CONSTRAINT friends_pk PRIMARY KEY (userID1, userID2),
    CONSTRAINT friends_fk1 FOREIGN KEY (userID1) REFERENCES users(userID),
    CONSTRAINT friends_fk2 FOREIGN KEY (userID2) REFERENCES users(userID)
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
    CONSTRAINT group_pk PRIMARY KEY (groupID)
);
CREATE SEQUENCE seq_groupID START WITH 1 INCREMENT BY 1;

CREATE TABLE groupMembership
(
    membershipID NUMBER(10) NOT NULL,
    groupID NUMBER(10) NOT NULL,
    userID NUMBER(10) NOT NULL,
    CONSTRAINT groupMembership_pk PRIMARY KEY (membershipID),
    CONSTRAINT groupMembership_fk1 FOREIGN KEY (groupID) REFERENCES groupInfo(groupID),
    CONSTRAINT groupMembership_fk2 FOREIGN KEY (userID) REFERENCES users(userID)
);
--user is prompted via the createGroup() function to set groupInfo.memberLimit
--addToGroup() function will enforce the groupInfo.memberLimit

--if recipientID is not null, message will be sent there. Otherwise, check toGroupID and send to all group members
--add respective rows to groupMessageRecipients
CREATE TABLE messages
(
    msgID NUMBER(10) NOT NULL,
    senderID NUMBER(10) NOT NULL,
    recipientID NUMBER(10) DEFAULT NULL,
    toGroupID NUMBER(10) DEFAULT NULL,
    subject VARCHAR2(50) NOT NULL,
    message VARCHAR2(100) NOT NULL,
    dateSent DATE NOT NULL,
    CONSTRAINT msg_pk PRIMARY KEY (msgID),
    CONSTRAINT msg_fk1 FOREIGN KEY (senderID) REFERENCES users(userID),
    CONSTRAINT msg_check CHECK (recipientID IS NOT NULL AND toGroupID IS NOT NULL)
    --check to make sure there is a recipient or group to receive message
);
CREATE SEQUENCE seq_msgID START WITH 1 INCREMENT BY 1;

CREATE TABLE groupMessageRecipients
(
    msgID NUMBER(10) NOT NULL,
    recipientID NUMBER(10) NOT NULL,
    CONSTRAINT groupMessageRecipients_pk PRIMARY KEY (msgID, recipientID),
    CONSTRAINT groupMessageRecipients_fk1 FOREIGN KEY (msgID) REFERENCES messages(msgID),
    CONSTRAINT groupMessageRecipients_fk2 FOREIGN KEY (recipientID) REFERENCES users(userID)
);

CREATE OR REPLACE TRIGGER GroupMessage
    AFTER INSERT
    ON messages
    FOR EACH ROW
    BEGIN
        IF(:new.toGroupID IS NOT NULL) THEN
            FOR cursor IN (SELECT GM.userID FROM groupMembership GM
                WHERE GM.groupID = :new.toGroupID)
            LOOP
                INSERT INTO groupMessageRecipients VALUES(:new.msgID, cursor.userID);
            END LOOP;
        END IF;
    END;
/

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
