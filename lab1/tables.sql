-- INSERT INTO Branches VALUES ('B1','Prog1');
CREATE TABLE Branches(
    branch CHAR(2) NOT NULL,
    program CHAR(5) NOT NULL,
    PRIMARY KEY(branch,program)
);

-- INSERT INTO Students VALUES ('1111111111','N1','ls1','Prog1');
CREATE TABLE Students(
    idnr CHAR(10) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    login VARCHAR(255) NOT NULL,
    program CHAR(5) NOT NULL
);

-- INSERT INTO Courses VALUES ('CCC111','C1',22.5,'Dep1');
CREATE TABLE Courses(
    course CHAR(6) NOT NULL,
    name VARCHAR(255) NOT NULL,
--    credits DECIMAL(4,1) NOT NULL,
    credits DECIMAL NOT NULL,
    department VARCHAR(255) NOT NULL
);

-- INSERT INTO LimitedCourses VALUES ('CCC222',1);
CREATE TABLE LimitedCourses(
    course CHAR(6) NOT NULL,
    limited SMALLINT NOT NULL
);

-- INSERT INTO Classifications VALUES ('math');
CREATE TABLE Classifications(
    class VARCHAR(255) PRIMARY KEY
);

-- INSERT INTO Classifications VALUES ('math');
CREATE TABLE Classified(
    course CHAR(6) NOT NULL,
    class VARCHAR(255) NOT NULL REFERENCES Classifications(class)
);

-- INSERT INTO StudentBranches VALUES ('2222222222','B1','Prog1');
CREATE TABLE StudentBranches(
    idnr CHAR(10) NOT NULL,  -- REFERENCES Students(idnr),
    branch CHAR(2) NOT NULL, -- REFERENCES Branches(branch),
    program CHAR(5) NOT NULL,
    FOREIGN KEY(idnr) REFERENCES Students(idnr),
    FOREIGN KEY(branch,program) REFERENCES Branches(branch,program)
);

-- INSERT INTO MandatoryProgram VALUES ('CCC111','Prog1');
CREATE TABLE MandatoryProgram(
    course CHAR(6) NOT NULL,
    program CHAR(5) NOT NULL
);

-- INSERT INTO MandatoryBranch VALUES ('CCC333', 'B1', 'Prog1');
CREATE TABLE MandatoryBranch(
    course CHAR(6) NOT NULL,
    branch CHAR(2) NOT NULL,
    program CHAR(5) NOT NULL
);

-- INSERT INTO RecommendedBranch VALUES ('CCC222', 'B1', 'Prog1');
CREATE TABLE RecommendedBranch(
    course CHAR(6) NOT NULL,
    branch CHAR(2) NOT NULL,
    program CHAR(5) NOT NULL
);

-- INSERT INTO Registered VALUES ('1111111111','CCC111');
CREATE TABLE Registered(
    idnr CHAR(10) NOT NULL,
    course CHAR(6) NOT NULL
);

-- INSERT INTO Taken VALUES('4444444444','CCC111','5');
CREATE TABLE Taken(
    idnr CHAR(10) NOT NULL,
    course CHAR(6) NOT NULL,
    grade CHAR(1) NOT NULL,
    CHECK(grade IN ('U','3','4','5'))
);

-- INSERT INTO WaitingList VALUES('3333333333','CCC222',1);
CREATE TABLE WaitingList(
    idnr CHAR(10) NOT NULL,
    course CHAR(6) NOT NULL,
    status CHAR(6) NOT NULL
);

