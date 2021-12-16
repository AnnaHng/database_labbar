
--INSERT INTO Departments VALUES ('Department2', 'Dep2');
CREATE TABLE Departments(
    name CHAR(255) NOT NULL UNIQUE,
    abbreviation CHAR(5) NOT NULL,
     CONSTRAINT check_digits_characters_underscore_allowed
            CHECK(name~*'^([0-9]|[a-z_ ])*$'),
    PRIMARY KEY(abbreviation)
);

--INSERT INTO Programs VALUES ('Program1', 'Prog1', 'Dep2');
CREATE TABLE Programs(
    name CHAR(255) NOT NULL,
    abbreviation CHAR(5) NOT NULL UNIQUE, 
    department CHAR(5) NOT NULL,
    PRIMARY KEY(name),
    CONSTRAINT check_valid_program_format CHECK(abbreviation~'^Prog[0-9]$'),
    FOREIGN KEY(department) REFERENCES Departments(abbreviation)
); 

-- INSERT INTO Branches VALUES ('B1','Prog1');
CREATE TABLE Branches(
    name CHAR(2) NOT NULL,
    program CHAR(5) NOT NULL,
    PRIMARY KEY(name, program), 
    CONSTRAINT check_valid_branch_format CHECK(name~'^B[0-9]$'),
    FOREIGN KEY(program) REFERENCES Programs(abbreviation)
);

-- INSERT INTO Students VALUES ('1111111111','N1','ls1','Prog1');
CREATE TABLE Students(
    idnr CHAR(10) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    login VARCHAR(255) NOT NULL,
    program CHAR(5) NOT NULL,
    UNIQUE(login),
    UNIQUE(idnr,program), 
    CONSTRAINT check_ten_digits_allowed CHECK(idnr~'^[0-9]{10}$'),
    CONSTRAINT check_digits_characters_underscore_allowed
               CHECK(name~*'^([0-9]|[a-z_ ])*$'),
    FOREIGN KEY(program) REFERENCES Programs(abbreviation)
);

-- INSERT INTO Courses VALUES ('CCC111','C1',22.5,'Dep1');
CREATE TABLE Courses(
    code CHAR(6) NOT NULL,
    name VARCHAR(255) NOT NULL,
    credits DECIMAL NOT NULL,
    department VARCHAR(255) NOT NULL,
    PRIMARY KEY(code),
    FOREIGN KEY(department) REFERENCES Departments(abbreviation),
    CONSTRAINT check_valid_course_format CHECK(code~'^[A-Z]{3}[0-9]{3}$'),
    CONSTRAINT check_digits_characters_underscore_allowed
               CHECK(name~*'^([0-9]|[a-z_ ])*$'),
    CONSTRAINT check_more_than_zero CHECK(credits > 0)
);

-- INSERT INTO LimitedCourses VALUES ('CCC222',1);
CREATE TABLE LimitedCourses(
    code CHAR(6) NOT NULL,
    capacity SMALLINT NOT NULL,
    CONSTRAINT check_more_than_zero CHECK(capacity > 0),
    PRIMARY KEY(code),
    FOREIGN KEY(code) REFERENCES Courses(code)
);

-- INSERT INTO Classifications VALUES ('math');
CREATE TABLE Classifications(
    name VARCHAR(255) PRIMARY KEY
    CONSTRAINT check_characters_underscore_allowed CHECK(name~*'^[a-z_ ]*$')
);

-- INSERT INTO Classifications VALUES ('math');
CREATE TABLE Classified(
    course CHAR(6) NOT NULL,
    classification VARCHAR(255) NOT NULL,
    PRIMARY KEY(course,classification),
    FOREIGN KEY(course) REFERENCES Courses(code),
    FOREIGN KEY(classification) REFERENCES Classifications(name)
);

-- INSERT INTO StudentBranches VALUES ('2222222222','B1','Prog1');
CREATE TABLE StudentBranches(
    student CHAR(10) NOT NULL,
    branch CHAR(2) NOT NULL,
    program CHAR(5) NOT NULL,
    PRIMARY KEY(student),
    FOREIGN KEY(branch, program) REFERENCES Branches(name, program),
    FOREIGN KEY(student, program) REFERENCES Students(idnr, program) 
);

-- INSERT INTO MandatoryProgram VALUES ('CCC111','Prog1');
CREATE TABLE MandatoryProgram(
    course CHAR(6) NOT NULL,
    program CHAR(5) NOT NULL,
    PRIMARY KEY(course,program),
    FOREIGN KEY(course) REFERENCES Courses(code),
    FOREIGN KEY(program) REFERENCES Programs(abbreviation)
);

-- INSERT INTO MandatoryBranch VALUES ('CCC333', 'B1', 'Prog1');
CREATE TABLE MandatoryBranch(
    course CHAR(6) NOT NULL,
    branch CHAR(2) NOT NULL,
    program CHAR(5) NOT NULL,
    PRIMARY KEY(course,branch,program),
    FOREIGN KEY(course) REFERENCES Courses(code),
    --FOREIGN KEY(branch) REFERENCES Branches(name),
    FOREIGN KEY(branch, program) REFERENCES Branches(name, program)
    --FOREIGN KEY(program) REFERENCES Programs(abbreviation)
);

-- INSERT INTO RecommendedBranch VALUES ('CCC222', 'B1', 'Prog1');
CREATE TABLE RecommendedBranch(
    course CHAR(6) NOT NULL,
    branch CHAR(2) NOT NULL,
    program CHAR(5) NOT NULL,
    PRIMARY KEY(course,branch,program),
    FOREIGN KEY(course) REFERENCES Courses(code),
    --FOREIGN KEY(branch) REFERENCES Branches(name),
    FOREIGN KEY(branch, program) REFERENCES Branches(name, program)
    --FOREIGN KEY(program) REFERENCES Programs(abbreviation)
);

-- INSERT INTO Registered VALUES ('1111111111','CCC111');
CREATE TABLE Registered(
    student CHAR(10) NOT NULL,
    course CHAR(6) NOT NULL,
    PRIMARY KEY(student,course),
    FOREIGN KEY(student) REFERENCES Students(idnr),
    FOREIGN KEY(course) REFERENCES Courses(code)
);

-- INSERT INTO Taken VALUES('4444444444','CCC111','5');
CREATE TABLE Taken(
    student CHAR(10) NOT NULL,
    course CHAR(6) NOT NULL,
    grade CHAR(1) NOT NULL,
    PRIMARY KEY(student,course),
    FOREIGN KEY(student) REFERENCES Students(idnr),
    FOREIGN KEY(course) REFERENCES Courses(code),
    CONSTRAINT check_valid_grade CHECK(grade IN ('U','3','4','5'))
);

-- INSERT INTO WaitingList VALUES('3333333333','CCC222',1);
CREATE TABLE WaitingList(
    student CHAR(10) NOT NULL,
    course CHAR(6) NOT NULL,
    position INTEGER NOT NULL,
    UNIQUE(course,position),
    PRIMARY KEY(student,course), 
    FOREIGN KEY(student) REFERENCES Students(idnr),
    FOREIGN KEY(course) REFERENCES LimitedCourses(code),
    CONSTRAINT check_status_more_than_0 CHECK(position > 0)
);


