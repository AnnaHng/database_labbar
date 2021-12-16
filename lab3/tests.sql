
  /*
  All possible tests:
    Test 1: registered to unlimited course
    Test 2: registered to limited course
    Test 3: waiting for limited course
    Test 4: removed from a waiting list (with additional students in it)
    Test 5: unregistered from unlimited course
    Test 6: unregistered from limited course without waiting list
    Test 7: unregistered from limited course with waiting list
    Test 8: unregiestered from overfull course with waiting list
  */

  -- Test 1: registered to unlimited course. 
  -- Outcome: success. 
INSERT INTO Registrations VALUES ('1111111111','CCC111');


-- Test 2: registered to limited course.
-- Outcome: success.
INSERT INTO Registrations VALUES ('6666666666','CCC222');
INSERT INTO Registrations VALUES ('6666666666','CCC333');


-- Test 3: waiting for limited course.
-- Outcome: success.
INSERT INTO Registrations VALUES ('1111111111','CCC222');
INSERT INTO Registrations VALUES ('3333333333','CCC222');


-- Test 4: removed from a waiting list (with additional students in it).
-- Outcome: success.
DELETE FROM Registrations WHERE student='1111111111' AND course='CCC222';


-- Test 5: unregistered from unlimited course
-- Outcome: success.
DELETE FROM Registrations WHERE student='1111111111' AND course='CCC111';


-- Test 6: unregistered from limited course without waiting list
-- Outcome: success.
DELETE FROM Registrations WHERE student='6666666666' AND course='CCC333';


-- Test 7: unregistered from limited course with waiting list
-- Outcome: success.
DELETE FROM Registrations WHERE student='6666666666' AND course='CCC222';


-- Prep. for test 8, inserting values 
INSERT INTO Registrations VALUES ('6666666666','CCC222');
-- Admin overriding course limits
INSERT INTO Registered VALUES ('5555555555','CCC222');
INSERT INTO Registrations VALUES ('1111111111','CCC222');
INSERT INTO Registrations VALUES ('2222222222','CCC222');


-- Test 8: unregiestered from overfull course with waiting list
-- Outcome: success.
DELETE FROM Registrations WHERE student='3333333333' AND course='CCC222';

