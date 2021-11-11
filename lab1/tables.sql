-- INSERT INTO Branches VALUES ('B1','Prog1');
CREATE TABLE Branches(
    branch CHAR(2) NOT NULL,
    program CHAR(5) NOT NULL,
    PRIMARY KEY(branch,program),
    CONSTRAINT check_valid_branch_format CHECK(branch~'^B[0-9]$'),
    CONSTRAINT check_valid_program_format CHECK(program~'^Prog[0-9]$')
);

-- INSERT INTO Students VALUES ('1111111111','N1','ls1','Prog1');
CREATE TABLE Students(
    idnr CHAR(10) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    login VARCHAR(255) NOT NULL,
    program CHAR(5) NOT NULL,
    UNIQUE(login),
    CONSTRAINT check_ten_digits_allowed CHECK(idnr~'^[0-9]{10}$'),
    CONSTRAINT check_digits_characters_underscore_allowed
               CHECK(name~*'^([0-9]|[a-z_ ])*$'),
    CONSTRAINT check_valid_program_format CHECK(program~'^Prog[0-9]$')
);

-- INSERT INTO Courses VALUES ('CCC111','C1',22.5,'Dep1');
CREATE TABLE Courses(
    course CHAR(6) NOT NULL,
    name VARCHAR(255) NOT NULL,
    credits DECIMAL NOT NULL,
    department VARCHAR(255) NOT NULL,
    PRIMARY KEY(course),
    CONSTRAINT check_valid_course_format CHECK(course~'^[A-Z]{3}[0-9]{3}$'),
    CONSTRAINT check_digits_characters_underscore_allowed
               CHECK(name~*'^([0-9]|[a-z_ ])*$'),
    CONSTRAINT check_more_than_zero CHECK(credits > 0),
    CONSTRAINT check_valid_department_format CHECK(department~'^Dep[0-9]$')
);

-- INSERT INTO LimitedCourses VALUES ('CCC222',1);
CREATE TABLE LimitedCourses(
    course CHAR(6) NOT NULL,
    limited SMALLINT NOT NULL,
    CONSTRAINT check_more_than_zero CHECK(limited > 0),
    FOREIGN KEY(course) REFERENCES Courses(course)
);

-- INSERT INTO Classifications VALUES ('math');
CREATE TABLE Classifications(
    class VARCHAR(255) PRIMARY KEY,
    CONSTRAINT check_characters_underscore_allowed CHECK(class~*'^[a-z_ ]*$')
);

-- INSERT INTO Classifications VALUES ('math');
CREATE TABLE Classified(
    course CHAR(6) NOT NULL,
    class VARCHAR(255) NOT NULL REFERENCES Classifications(class),
    FOREIGN KEY(course) REFERENCES Courses(course),
    FOREIGN KEY(class) REFERENCES Classifications(class)
);

-- INSERT INTO StudentBranches VALUES ('2222222222','B1','Prog1');
CREATE TABLE StudentBranches(
    idnr CHAR(10) NOT NULL,
    branch CHAR(2) NOT NULL,
    program CHAR(5) NOT NULL,
    FOREIGN KEY(idnr) REFERENCES Students(idnr),
    FOREIGN KEY(branch,program) REFERENCES Branches(branch,program)
);

-- INSERT INTO MandatoryProgram VALUES ('CCC111','Prog1');
CREATE TABLE MandatoryProgram(
    course CHAR(6) NOT NULL,
    program CHAR(5) NOT NULL,
    PRIMARY KEY(course,program),
    FOREIGN KEY(course) REFERENCES Courses(course),
    CONSTRAINT check_valid_program_format CHECK(program~'^Prog[0-9]$')
);

-- INSERT INTO MandatoryBranch VALUES ('CCC333', 'B1', 'Prog1');
CREATE TABLE MandatoryBranch(
    course CHAR(6) NOT NULL,
    branch CHAR(2) NOT NULL,
    program CHAR(5) NOT NULL,
    PRIMARY KEY(course,branch,program),
    FOREIGN KEY(course) REFERENCES Courses(course),
    FOREIGN KEY(branch,program) REFERENCES Branches(branch,program)
);

-- INSERT INTO RecommendedBranch VALUES ('CCC222', 'B1', 'Prog1');
CREATE TABLE RecommendedBranch(
    course CHAR(6) NOT NULL,
    branch CHAR(2) NOT NULL,
    program CHAR(5) NOT NULL,
    PRIMARY KEY(course,branch,program),
    FOREIGN KEY(course) REFERENCES Courses(course),
    FOREIGN KEY(branch,program) REFERENCES Branches(branch,program)
);

-- INSERT INTO Registered VALUES ('1111111111','CCC111');
CREATE TABLE Registered(
    idnr CHAR(10) NOT NULL,
    course CHAR(6) NOT NULL,
    PRIMARY KEY(idnr,course),
    FOREIGN KEY(idnr) REFERENCES Students(idnr),
    FOREIGN KEY(course) REFERENCES Courses(course)
);

-- INSERT INTO Taken VALUES('4444444444','CCC111','5');
CREATE TABLE Taken(
    idnr CHAR(10) NOT NULL,
    course CHAR(6) NOT NULL,
    grade CHAR(1) NOT NULL,
    PRIMARY KEY(idnr,course,grade),
    FOREIGN KEY(idnr) REFERENCES Students(idnr),
    FOREIGN KEY(course) REFERENCES Courses(course),
    CONSTRAINT check_valid_grade CHECK(grade IN ('U','3','4','5'))
);

-- INSERT INTO WaitingList VALUES('3333333333','CCC222',1);
CREATE TABLE WaitingList(
    idnr CHAR(10) NOT NULL,
    course CHAR(6) NOT NULL,
    status INTEGER NOT NULL,
    PRIMARY KEY(idnr,course,status),
    FOREIGN KEY(idnr) REFERENCES Students(idnr),
    FOREIGN KEY(course) REFERENCES Courses(course),
    CONSTRAINT check_status_more_than_0 CHECK(status > 0)
);

