
--SELECT idnr, name, login, program, branch FROM BasicInformation;
CREATE VIEW BasicInformation AS
    SELECT students.idnr,name,login,students.program,branch
        FROM students LEFT OUTER JOIN studentbranches
        ON students.idnr = studentbranches.idnr;

--SELECT student, course, grade, credits FROM FinishedCourses;
CREATE VIEW FinishedCourses AS
    SELECT idnr AS student,Taken.course,grade,credits
        FROM Taken JOIN Courses ON Taken.course=Courses.course;

--SELECT student, course, credits FROM PassedCourses;
CREATE VIEW PassedCourses AS
    SELECT idnr AS student,Taken.course,credits
        FROM Taken JOIN Courses on Taken.course=Courses.course
        WHERE Taken.grade<>'U';

--SELECT student, course, status FROM Registrations;
CREATE VIEW Registrations AS
    SELECT idnr AS student,course,(SELECT 'registered' AS status)
        FROM Registered
    UNION
    SELECT idnr AS student,course,(SELECT 'waiting' AS status)
        FROM WaitingList;

--SELECT student, course FROM UnreadMandatory;

CREATE VIEW UnreadMandatory AS
(WITH
DidMandatoryProgram AS
    (
        SELECT PassedCourses.student,
               PassedCourses.course,
               MandatoryProgram.program

        FROM Students 
        LEFT OUTER JOIN PassedCourses
            ON Students.idnr = PassedCourses.student
        LEFT OUTER JOIN MandatoryProgram
            ON MandatoryProgram.course = PassedCourses.course

        WHERE Students.program = MandatoryProgram.program
    ),

DidMandatoryBranch AS
    (
        SELECT PassedCourses.student,
               PassedCourses.course,
               MandatoryBranch.branch,
               MandatoryBranch.program

        FROM StudentBranches
        LEFT OUTER JOIN PassedCourses
            ON StudentBranches.idnr = PassedCourses.student
        LEFT OUTER JOIN MandatoryBranch
            ON MandatoryBranch.course = PassedCourses.course

        WHERE StudentBranches.program = MandatoryBranch.program
              AND StudentBranches.branch = MandatoryBranch.branch
    ),

TodoMandatoryProgram AS
    (
        SELECT Students.idnr AS student,
               MandatoryProgram.program,
               MandatoryProgram.course

        FROM Students 
        LEFT OUTER JOIN MandatoryProgram
            ON Students.program = MandatoryProgram.program

        WHERE Students.program = MandatoryProgram.program
    ),

TodoMandatoryBranch AS
    (
        SELECT StudentBranches.idnr AS student,
               MandatoryBranch.branch,
               MandatoryBranch.program,
               MandatoryBranch.course

        FROM StudentBranches
        LEFT OUTER JOIN MandatoryBranch
            ON StudentBranches.program = MandatoryBranch.program

        WHERE StudentBranches.program = MandatoryBranch.program
            AND StudentBranches.branch = MandatoryBranch.branch
    )

SELECT student,course FROM TodoMandatoryBranch
EXCEPT
SELECT student,course FROM DidMandatoryBranch

UNION

SELECT student,course FROM TodoMandatoryProgram
EXCEPT
SELECT student,course FROM DidMandatoryProgram
);


--SELECT student, totalCredits, mandatoryLeft, mathCredits, researchCredits, seminarCourses, qualified FROM PathToGraduation;

-------------------------------------------------------------------------------
-- These are not part of the lab 


CREATE VIEW MandatoryCourses AS
    SELECT * FROM MandatoryBranch
    UNION
    SELECT course,(select 'ALL' as branch),program FROM MandatoryProgram;


--    ORDER BY StudentsInfo.student;

--  studentsinfo:
--   student   | branch | program 
-- ------------+--------+---------
--  2222222222 | B1     | Prog1
--  3333333333 | B1     | Prog2
--  4444444444 | B1     | Prog1
--  5555555555 | B1     | Prog2
--  6666666666 |        | Prog2
--  1111111111 |        | Prog1

CREATE VIEW StudentsInfo AS
    (SELECT Students.idnr AS student,branch,Students.program
    FROM Students
        LEFT OUTER JOIN StudentBranches
        ON Students.idnr=StudentBranches.idnr);


