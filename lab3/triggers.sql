
-------------------------------------------------------------------------------
-- register student used for Registrations view

-- Register: Given a student id number and a course code, the system       
-- should try to register the student for that course. If the course is
-- full, the student should be placed in the waiting list for that course.
-- If the student has already passed the course, or is already registered,
-- or does not meet the prerequisites for the course, the registration
-- should fail.  The system should notify the student of the outcome of
-- the attempted registration.

CREATE OR REPLACE FUNCTION register_function() RETURNS trigger AS
$$
DECLARE
    crse CHAR(6)  := NEW.course;
    stud CHAR(10) := NEW.student;
    _position INTEGER;
BEGIN
    IF has_passed_the_course(stud,crse)
    THEN
        RAISE EXCEPTION '% has already passed the course %.', stud, crse;
    END IF;

    IF has_prerequisites_for_the_course(stud,crse) = FALSE
    THEN
        RAISE EXCEPTION '% does not have prerequisites for %.', stud, crse;
    END IF;

    IF is_limited_course(crse)
    THEN
        -- Fix limited list before continue
        PERFORM update_limited_course_queue(crse);

        IF is_on_waitinglist(stud,crse) AND is_registered(stud,crse)
        THEN
            RAISE EXCEPTION '% % is both registered and on waiting list.',
                             stud, crse;
        END IF;

        IF is_on_waitinglist(stud, crse)
        THEN
            RAISE EXCEPTION '%-% is already on waiting list.', stud, crse;
        END IF;

        IF is_registered(stud, crse)
        THEN
            RAISE EXCEPTION '%-% is already registered.', stud, crse;
        END IF;

        IF is_limited_course_full(crse) = TRUE
        THEN
            -- is full - move to waiting list 
            RAISE NOTICE '% is full - move % to waiting list.', crse, stud;
            _position := coalesce(max_waitinglist_position(crse),0);
            INSERT INTO waitinglist VALUES(stud,crse,_position+1);
        ELSE
            -- not full - register 
            RAISE NOTICE 'Registering % to limited course %.', stud, crse;
            INSERT INTO registered VALUES(stud,crse);
        END IF;
    END IF;

    IF is_unlimited_course(crse)
    THEN
        RAISE NOTICE 'Registering % to unlimited course %.', stud, crse;
        INSERT INTO registered VALUES(stud,crse);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-------------------------------------------------------------------------------
-- unregister student used for Registrations view

--     Unregister: Given a student id number and a course code, the system
--     should unregister the student from that course. If there are students
--     waiting to be registered, and there is now room on the course, the one
--     first in line should be registered for the course. The system should
--     acknowledge the removed registration for the student. If the student is
--     not registered to the course when trying to unregister, the system
--     should notify them.

CREATE OR REPLACE FUNCTION unregister_function() RETURNS trigger AS
$$
DECLARE
    crse CHAR(6)  := OLD.course;
    stud CHAR(10) := OLD.student;
BEGIN

    -- Cases when the unregistering is not needed -----------------------------
    -- Both on waiting list and registered
    IF is_on_waitinglist(stud,crse) AND is_registered(stud,crse)
    THEN
        RAISE EXCEPTION '% % is both registered and on waiting list.',
                         stud, crse;
    END IF;

    -- Not registered and on waiting list
    IF is_registered(stud,crse) = FALSE AND is_on_waitinglist(stud,crse) = FALSE
    THEN
        -- Not registered
        IF is_registered(stud,crse) = FALSE
        THEN
            RAISE EXCEPTION
                'The student % is not registered to %', stud, crse;

        -- Not on waiting list
        ELSIF is_on_waitinglist(stud,crse) = FALSE
        THEN
            RAISE EXCEPTION
                'The student % is not on waiting list for %', stud, crse;
        END IF;
    END IF;
    -- !Cases when the unregistering is not needed ----------------------------

    IF is_limited_course(crse)
    THEN

        IF is_registered(stud,crse)
        THEN
            IF is_limited_course_overfull(crse) = TRUE
                THEN
                RAISE NOTICE 'Unregistering % from overfull %.', stud, crse;
                DELETE FROM registered WHERE student=stud AND course=crse;
                RETURN OLD;
            END IF;
            RAISE NOTICE 'Unregistering % from %.', stud, crse;
            DELETE FROM registered WHERE student=stud AND course=crse;
            IF max_waitinglist_position(crse) >= 1
            THEN
                RAISE NOTICE 'Moving %-% waitinglist -> registered.',stud,crse;
                INSERT INTO registered VALUES(
                    (SELECT student FROM waitinglist
                        WHERE position=1 AND course=crse),crse);
                DELETE FROM waitinglist WHERE position=1 AND course=crse;
                PERFORM update_limited_course_queue(crse);
            END IF;
            RETURN OLD;
        END IF;

        IF is_on_waitinglist(stud,crse)
        THEN
            RAISE NOTICE 'Removing from waiting list % for %.', stud, crse;
            DELETE FROM waitinglist WHERE student=stud AND course=crse;
            PERFORM update_limited_course_queue(crse); 
        RETURN OLD;
        END IF;

    END IF;

    IF is_unlimited_course(crse)
    THEN
        RAISE NOTICE 'Unregistering % from %.', stud, crse;
        DELETE FROM registered WHERE student=stud AND course=crse;
        RETURN OLD;
    ELSE
        RAISE EXCEPTION 'Unregistration % from % failed.', stud, crse;
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-------------------------------------------------------------------------------
-- update (reorder) waiting queue on limited _course
CREATE OR REPLACE
    FUNCTION update_limited_course_queue(_course CHAR(6)) RETURNS BOOLEAN AS
$$ 
BEGIN
    IF is_limited_course(_course) = False
        -- or there is nobody on the waiting list
        OR exists(select * from waitinglist where course=_course) = FALSE
        THEN RETURN FALSE;
    ELSE
        UPDATE waitinglist i
            SET position = j.row_number
                FROM(
                    SELECT *,row_number() OVER (ORDER BY position)
                    FROM waitinglist
                        WHERE course=_course
                ) j
                WHERE i.student = j.student;
        RETURN TRUE;
    END IF;
END;
$$ LANGUAGE plpgsql;

-------------------------------------------------------------------------------
-- checks if _student is registered to limited course _course
CREATE OR REPLACE
    FUNCTION is_registered(_student CHAR(10),
                           _course CHAR(6))
                           RETURNS BOOLEAN AS
$$ 
BEGIN
    RETURN exists(SELECT student FROM registered
                    WHERE student = _student AND course=_course);
END;
$$ LANGUAGE plpgsql;

-------------------------------------------------------------------------------
-- checks if _student is on waiting list
CREATE OR REPLACE
    FUNCTION is_on_waitinglist(_student CHAR(10),
                               _course  CHAR(6))
                               RETURNS  BOOLEAN AS
$$
BEGIN
    RETURN exists(SELECT student FROM waitinglist 
                      WHERE student = _student AND course = _course);
END;
$$ LANGUAGE plpgsql;

-------------------------------------------------------------------------------
-- add _student to limited _course
CREATE OR REPLACE
    FUNCTION add_to_limited_course(_student CHAR(10),
                                   _course  CHAR(6))
                                   RETURNS  void AS
$$
BEGIN
    IF is_limited_course(_course)
        THEN INSERT INTO registered VALUES(_student,_course);
    ELSE
        RAISE EXCEPTION '% is not a limited course', _course;
    END IF;
END;
$$ LANGUAGE plpgsql;

-------------------------------------------------------------------------------
-- add _student to limited _course
CREATE OR REPLACE
    FUNCTION add_to_unlimited_course(_student CHAR(10),
                                     _course  CHAR(6))
                                     RETURNS  void AS
$$
BEGIN
    IF is_unlimited_course(_course)
        THEN INSERT INTO registered VALUES(_student,_course);
    ELSE
        RAISE EXCEPTION '% is not an unlimited course', _course;
    END IF;
END;
$$ LANGUAGE plpgsql;

-------------------------------------------------------------------------------
-- checks if _student is registered to unlimited course _course
CREATE OR REPLACE
    FUNCTION registered_to_unlimited_course(_student CHAR(10),
                                             _course CHAR(6))
                                             RETURNS BOOLEAN AS
$$
BEGIN
    RETURN exists(SELECT student FROM registered WHERE student = _student) 
           AND is_unlimited_course(_course);
END;
$$ LANGUAGE plpgsql;

-------------------------------------------------------------------------------
-- checks if _course is a limited course
CREATE OR REPLACE
    FUNCTION is_limited_course(_course CHAR(6)) RETURNS BOOLEAN AS
$$
BEGIN
    RETURN exists(SELECT * FROM LimitedCourses
                     WHERE LimitedCourses.code = _course);
END;
$$ LANGUAGE plpgsql;

-------------------------------------------------------------------------------
-- checks if _course is an unlimited course
CREATE OR REPLACE
    FUNCTION is_unlimited_course(_course CHAR(6)) RETURNS BOOLEAN AS
$$
BEGIN
    RETURN (is_limited_course(_course) = FALSE)
           AND exists(SELECT * FROM courses WHERE code = _course);
END;
$$ LANGUAGE plpgsql;

-------------------------------------------------------------------------------
-- checks if limited _course is full 
CREATE OR REPLACE
    FUNCTION is_limited_course_full(_course CHAR(6)) RETURNS BOOLEAN AS
$$
DECLARE
    count_registered_students INTEGER := (SELECT count(*) FROM Registered
                                         WHERE course=_course);
    capacity INTEGER := limitedcourse_capacity(_course);
BEGIN
    RETURN capacity <= count_registered_students;
END
$$ LANGUAGE plpgsql;

-------------------------------------------------------------------------------
-- checks if limited _course is overfull 
CREATE OR REPLACE
    FUNCTION is_limited_course_overfull(_course CHAR(6)) RETURNS BOOLEAN AS
$$
DECLARE
    count_registered_students INTEGER := (SELECT count(*) FROM Registered
                                         WHERE course=_course);
    capacity INTEGER := limitedcourse_capacity(_course);
BEGIN
    RETURN count_registered_students > capacity;
END
$$ LANGUAGE plpgsql;
-------------------------------------------------------------------------------
-- returns capacity of limited _course
CREATE OR REPLACE
    FUNCTION limitedcourse_capacity( _course CHAR(6)) RETURNS INTEGER AS
$$
BEGIN
    RETURN (SELECT capacity FROM limitedcourses WHERE code = _course);
END
$$ LANGUAGE plpgsql;

-------------------------------------------------------------------------------
-- gets maximum waiting list position
CREATE OR REPLACE
    FUNCTION max_waitinglist_position( _course CHAR(6)) RETURNS INTEGER AS
$$
BEGIN
    RETURN (SELECT position FROM waitinglist
            WHERE course=_course
            ORDER BY position DESC LIMIT 1);
END
$$ LANGUAGE plpgsql;

-------------------------------------------------------------------------------
-- checks if the _student has passed the _course
CREATE OR REPLACE
    FUNCTION has_passed_the_course(_student CHAR(10),
                                   _course  CHAR(6))
                                   RETURNS  BOOLEAN AS
$$
BEGIN
    RETURN exists(SELECT * FROM passedcourses
                  WHERE student=_student AND course=_course);
END
$$ LANGUAGE plpgsql;

-------------------------------------------------------------------------------
-- checks if the _student has needed prerequisites for the _course
CREATE OR REPLACE
    FUNCTION has_prerequisites_for_the_course(_student CHAR(10),
                                   _course  CHAR(6))
                                   RETURNS  BOOLEAN AS
$$
DECLARE
count_prerequisites INTEGER := (SELECT count(*) FROM prerequisites 
                               WHERE course=_course);
count_intersection INTEGER := (WITH
                               a AS (SELECT course FROM taken
                                     WHERE student=_student),
                               b AS (SELECT dependsOn FROM prerequisites
                                     WHERE course = _course),
                               c AS (SELECT * FROM a INTERSECT SELECT * FROM b)
                               SELECT count(*) FROM c);
BEGIN
-- prerequisites are satisfied if:
    -- count for intersection of (prerequisites for _course and _course taken)
    -- and
    -- count of prerequisites
    -- is the same
    IF exists(SELECT * FROM courses WHERE code =_course)
    THEN
        IF count_prerequisites = 1 -- no prerequisites
        THEN
            RETURN TRUE;
        ELSE
        RETURN count_prerequisites = count_intersection;
        END IF;
    ELSE 
        RAISE EXCEPTION 'Course % is not valid.', _course;
    END IF;
END
$$ LANGUAGE plpgsql;

-------------------------------------------------------------------------------


--                                 TRIGGER 0
--  When a student tries to register for a course that is full, that student
--  is added to the waiting list for the course. Be sure to check that the
--  student may actually register for the course before adding to either list,
--  if it may not you should raise an error (use RAISE EXCEPTION).
--      Hint: There are several requirements for registration stated in the
--      domain description, and some implicit ones like that a student cannot
--      be both waiting and registered for the same course at the same time.
CREATE TRIGGER register_trigger
  INSTEAD OF INSERT OR UPDATE ON Registrations 
  FOR EACH ROW EXECUTE FUNCTION register_function();

--                                 TRIGGER 1
--  A student can be unregistered (this includes being removing from the
--  waiting list) by deleting from the Registrations view. If removing the
--  student opens up a spot in the course, the first student (if any) in the
--  waiting list should be registered for the course instead.
--      Note: this should only be done if there is actually room on the course
--      (the course might have been over-full due to an administrator
--      overriding the restriction and adding students directly).
CREATE TRIGGER unregister_trigger
  INSTEAD OF DELETE ON Registrations 
  FOR EACH ROW EXECUTE FUNCTION unregister_function();

