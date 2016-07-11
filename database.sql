CREATE TABLE user
{
    userID NUMBER(10) PRIMARY KEY,
    name VARCHAR2(50),
    email VARCHAR2(50),
    dob DATE,
    lastLogin DATE--time needed?
}

CREATE TABLE friends
{
    userID1 NUMBER(10) NOT NULL,
    userID2 NUMBER(10) NOT NULL,
    status CHAR(1),
    dateAccepted DATE,
    CONSTRAINT friends_pk REFERENCES (userID1, userID2),
    CONSTRAINT friends_fk1 FOREIGN KEY (userID1) REFERENCES profile(userID),
    CONSTRAINT friends_fk2 FOREIGN KEY (userID2) REFERENCES profile(userID)

}