SPOOL /tmp/oracle/projectPart6_spool.txt

SELECT
    to_char(sysdate, 'DD Month YYYY Year Day HH:MI:SS AM')
FROM
    dual;

/* Question 1:
Run script 7Northwoods in schemas des03
Create a procedure to display all the faculty member (f_id, f_last, f_first, 
f_rank), under each faculty member, display all the student advised by that 
faculty member
(s_id, s_last, s_first, birthdate, s_class). */
CONNECT des03/des03

SET SERVEROUTPUT ON FORMAT WRAPPED

CREATE OR REPLACE PROCEDURE p_show_faculty_members AS
CURSOR curr_faculty_member IS
    SELECT
        F_ID,
        F_LAST,
        F_FIRST,
        F_RANK
    FROM
        FACULTY;
    v_faculty_member_row curr_faculty_member%ROWTYPE;

CURSOR curr_student(p_f_id NUMBER) IS
    SELECT
        S_ID,
        S_LAST,
        S_FIRST,
        S_DOB,
        S_CLASS
    FROM
        STUDENT;
    v_student_row curr_student%ROWTYPE;

BEGIN
    OPEN curr_faculty_member;
    FETCH curr_faculty_member INTO v_faculty_member_row;
    WHILE curr_faculty_member%FOUND LOOP
        DBMS_OUTPUT.PUT_LINE('---------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Faculty member: ' || v_faculty_member_row.F_ID || '. ' || v_faculty_member_row.F_LAST ||
                            ' ' || v_faculty_member_row.F_FIRST || ', ' || v_faculty_member_row.F_RANK || ':');
        
        OPEN curr_student(v_faculty_member_row.F_ID);
        FETCH curr_student INTO v_student_row;
        WHILE curr_student%FOUND LOOP
            DBMS_OUTPUT.PUT_LINE(chr(32) || chr(32) || 'Student: ' || v_student_row.S_ID || '. ' || v_student_row.S_LAST ||
            ' ' || v_student_row.S_FIRST || ', ' || v_student_row.S_DOB || ', ' || v_student_row.S_CLASS);
            FETCH curr_student INTO v_student_row;
        END LOOP;
        CLOSE curr_student;

        FETCH curr_faculty_member INTO v_faculty_member_row;
    END LOOP;
    CLOSE curr_faculty_member;
END;
/

EXEC p_show_faculty_members


/* Question 2:
Run script 7Software in schemas des04
Create a procedure to display all the consultants. Under each 
consultant display all his/her skill (skill description) and the status of the 
skill (certified or not). */
CONNECT des04/des04

SET SERVEROUTPUT ON FORMAT WRAPPED

CREATE OR REPLACE PROCEDURE p_show_consultants AS
CURSOR curr_consultant IS
    SELECT
        C_ID,
        C_LAST,
        C_FIRST
    FROM
        CONSULTANT;
    v_consultant_row curr_consultant%ROWTYPE;

CURSOR curr_skill IS
    SELECT
        C_ID,
        s.SKILL_ID,
        SKILL_DESCRIPTION,
        CERTIFICATION
    FROM
        SKILL s JOIN CONSULTANT_SKILL cs ON s.SKILL_ID = cs.SKILL_ID;
    v_skill_row curr_skill%ROWTYPE;

BEGIN
    OPEN curr_consultant;
    FETCH curr_consultant INTO v_consultant_row;
    WHILE curr_consultant%FOUND LOOP       
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Consultant: ' || v_consultant_row.C_ID || '. ' || v_consultant_row.C_LAST ||
                            ' ' || v_consultant_row.C_FIRST || ':');
        
        OPEN curr_skill;
        FETCH curr_skill INTO v_skill_row;
        WHILE curr_skill%FOUND LOOP
            IF v_skill_row.C_ID = v_consultant_row.C_ID THEN
                DBMS_OUTPUT.PUT_LINE(chr(32) || chr(32) || 'Skill: ' || v_skill_row.SKILL_id || '. ' || v_skill_row.SKILL_DESCRIPTION);
                IF v_skill_row.CERTIFICATION = 'Y' THEN                        
                    DBMS_OUTPUT.PUT_LINE(chr(32) || chr(32) || chr(32) || chr(32) || chr(32) || chr(32) ||
                                        chr(32) || chr(32) || chr(32) || '--- CERTIFIED ---');
                ELSE
                    DBMS_OUTPUT.PUT_LINE(chr(32) || chr(32) || chr(32) || chr(32) || chr(32) || chr(32) ||
                                        chr(32) || chr(32) || chr(32) || '--- NOT CERTIFIED ---');
                END IF;
            END IF;
            FETCH curr_skill INTO v_skill_row;
        END LOOP;
        CLOSE curr_skill;

        FETCH curr_consultant INTO v_consultant_row;
    END LOOP;
    CLOSE curr_consultant;
END;
/

EXEC p_show_consultants


/* Question 3:
Run script 7Clearwater in schemas des02
Create a procedure to display all items (item_id, item_desc, cat_id) under 
each item, display all the inventories belong to it. */
CONNECT des02/des02

SET SERVEROUTPUT ON FORMAT WRAPPED

CREATE OR REPLACE PROCEDURE p_display_items AS
CURSOR curr_item IS
    SELECT
        ITEM_ID,
        ITEM_DESC,
        CAT_DESC
    FROM
        ITEM i JOIN CATEGORY c ON i.CAT_ID = c.CAT_ID;
    v_item_row curr_item%ROWTYPE;

CURSOR curr_inventory IS
    SELECT
        ITEM_ID,
        INV_ID,
        COLOR,
        INV_SIZE,
        INV_PRICE,
        INV_QOH
    FROM
        INVENTORY;
    v_inventory_row curr_inventory%ROWTYPE;

BEGIN
    OPEN curr_item;
    FETCH curr_item INTO v_item_row;
    WHILE curr_item%FOUND LOOP
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Item: ' || v_item_row.ITEM_ID || '. ' || v_item_row.ITEM_DESC ||
                            ' (' || v_item_row.CAT_DESC || '):');

        OPEN curr_inventory;
        FETCH curr_inventory INTO v_inventory_row;
        WHILE curr_inventory%FOUND LOOP
            IF v_item_row.ITEM_ID = v_inventory_row.ITEM_ID THEN
                IF v_inventory_row.INV_SIZE IS NULL THEN
                    v_inventory_row.INV_SIZE := 'UNIVERSAL';
                END IF;
                IF v_inventory_row.INV_QOH = 0 THEN
                    DBMS_OUTPUT.PUT_LINE(chr(32) || chr(32) || 'Inventory: ' || v_inventory_row.INV_ID || '. ' ||
                                        v_inventory_row.COLOR || ', ' || v_inventory_row.INV_SIZE || ', $' ||
                                        v_inventory_row.INV_PRICE || ', UNAVAILABLE');
                ELSE
                    DBMS_OUTPUT.PUT_LINE(chr(32) || chr(32) || 'Inventory: ' || v_inventory_row.INV_ID || '. ' ||
                                        v_inventory_row.COLOR || ', ' || v_inventory_row.INV_SIZE || ', $' ||
                                        v_inventory_row.INV_PRICE || ', ' || v_inventory_row.INV_QOH || ' left');
                END IF;
            END IF;
            FETCH curr_inventory INTO v_inventory_row;
        END LOOP;
        CLOSE curr_inventory;

        FETCH curr_item INTO v_item_row;
    END LOOP;
    CLOSE curr_item;
END;
/

EXEC p_display_items


/* Question 4:
Modify question 3 to display beside the item description the value of 
the item (value = inv_price * inv_qoh). */
CREATE OR REPLACE PROCEDURE p_display_items_with_value AS
CURSOR curr_item IS
    WITH x AS (
                SELECT
                    ITEM_ID,
                    SUM(INV_PRICE * INV_QOH) AS VALUE
                FROM
                    INVENTORY
                GROUP BY
                    ITEM_ID
                )
    SELECT
        it.ITEM_ID,
        ITEM_DESC,
        c.CAT_ID,
        CAT_DESC,
        VALUE
    FROM
        x val JOIN ITEM it ON it.ITEM_ID = val.ITEM_ID
        JOIN CATEGORY c ON c.CAT_ID = it.CAT_ID;
    v_item_row curr_item%ROWTYPE;

CURSOR curr_inventory IS
    SELECT
        ITEM_ID,
        INV_ID,
        COLOR,
        INV_SIZE,
        INV_PRICE,
        INV_QOH
    FROM
        INVENTORY;
    v_inventory_row curr_inventory%ROWTYPE;

BEGIN
    OPEN curr_item;
    FETCH curr_item INTO v_item_row;
    WHILE curr_item%FOUND LOOP
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Item: ' || v_item_row.ITEM_ID || '. ' || v_item_row.ITEM_DESC ||
                            ' (' || v_item_row.CAT_DESC || '), Value: $' || v_item_row.VALUE || ':');

        OPEN curr_inventory;
        FETCH curr_inventory INTO v_inventory_row;
        WHILE curr_inventory%FOUND LOOP
            IF v_item_row.ITEM_ID = v_inventory_row.ITEM_ID THEN
                IF v_inventory_row.INV_SIZE IS NULL THEN
                    v_inventory_row.INV_SIZE := 'universal';
                END IF;
                IF v_inventory_row.INV_QOH = 0 THEN
                    DBMS_OUTPUT.PUT_LINE(chr(32) || chr(32) || 'Inventory: ' || v_inventory_row.INV_ID || '. ' ||
                                    v_inventory_row.COLOR || ', ' || v_inventory_row.INV_SIZE || ', $' ||
                                    v_inventory_row.INV_PRICE || ', UNAVAILABLE');
                ELSE
                    DBMS_OUTPUT.PUT_LINE(chr(32) || chr(32) || 'Inventory: ' || v_inventory_row.INV_ID || '. ' ||
                                        v_inventory_row.COLOR || ', ' || v_inventory_row.INV_SIZE || ', $' ||
                                        v_inventory_row.INV_PRICE || ', ' || v_inventory_row.INV_QOH || ' left');
                END IF;                    
            END IF;
            FETCH curr_inventory INTO v_inventory_row;
        END LOOP;
        CLOSE curr_inventory;

        FETCH curr_item INTO v_item_row;
    END LOOP;
    CLOSE curr_item;
END;
/

EXEC p_display_items_with_value


/* Question 5:
Run script 7software in schemas des04
Create a procedure that accepts a consultant id, and a character used to 
update the status (certified or not) of all the SKILLs belonged to the 
consultant inserted. 
Display 4 information about the consultant such as id, name, …Under each 
consultant display all his/her skill (skill description) and the OLD and NEW 
status of the skill (certified or not). */
CONNECT des04/des04

SET SERVEROUTPUT ON FORMAT WRAPPED

CREATE OR REPLACE PROCEDURE p_update_cons_skills(p_c_id IN CONSULTANT.C_ID%TYPE, p_skill_stat IN CONSULTANT_SKILL.CERTIFICATION%TYPE) AS
existing_cons_id NUMBER;

CURSOR curr_cons IS
    SELECT
        C_ID,
        C_LAST,
        C_FIRST
    FROM
        CONSULTANT;
    v_cons_row curr_cons%ROWTYPE;

CURSOR curr_skill IS
    SELECT
        C_ID,
        s.SKILL_ID,
        SKILL_DESCRIPTION,
        CERTIFICATION
    FROM
        SKILL s JOIN CONSULTANT_SKILL cs ON s.SKILL_ID = cs.SKILL_ID
    FOR UPDATE OF CERTIFICATION;
    v_consult_id CONSULTANT.C_ID%TYPE;
    v_skill_id SKILL.SKILL_ID%TYPE;
    v_skill_desc SKILL.SKILL_DESCRIPTION%TYPE;
    v_cert CONSULTANT_SKILL.CERTIFICATION%TYPE;
    v_updated_cert CONSULTANT_SKILL.CERTIFICATION%TYPE;

BEGIN
    OPEN curr_cons;
    FETCH curr_cons INTO v_cons_row;
    WHILE curr_cons%FOUND LOOP
        IF p_c_id = v_cons_row.C_ID THEN        
            DBMS_OUTPUT.PUT_LINE('Consultant: ' || v_cons_row.C_ID || '. ' || v_cons_row.C_LAST ||
                                ' ' || v_cons_row.C_FIRST || ':');
            DBMS_OUTPUT.PUT_LINE('---------------------------------------------------');    
            
            OPEN curr_skill;
            FETCH curr_skill INTO
                        v_consult_id,
                        v_skill_id,
                        v_skill_desc,
                        v_cert;
            IF p_skill_stat IN ('Y', 'N') THEN                                
                WHILE curr_skill%FOUND LOOP
                    IF v_consult_id = v_cons_row.C_ID THEN
                        v_updated_cert := p_skill_stat;
                        UPDATE CONSULTANT_SKILL
                        SET CERTIFICATION = v_updated_cert
                        WHERE
                            CURRENT OF curr_skill;
                        DBMS_OUTPUT.PUT_LINE('Skill: ' || v_skill_id || '. ' || v_skill_desc);
                        IF v_cert = 'Y' THEN
                            DBMS_OUTPUT.PUT_LINE(chr(32) || chr(32) || chr(32) || chr(32) || chr(32) ||
                                                chr(32) || chr(32) || 'OLD status: --- CERTIFIED ---' );
                        ELSE
                            DBMS_OUTPUT.PUT_LINE(chr(32) || chr(32) || chr(32) || chr(32) || chr(32) ||
                                                chr(32) || chr(32) || 'OLD status: --- NOT CERTIFIED ---' );
                        END IF;
                        IF v_updated_cert = 'Y' THEN
                            DBMS_OUTPUT.PUT_LINE(chr(32) || chr(32) || chr(32) || chr(32) || chr(32) ||
                                                chr(32) || chr(32) || 'NEW status: --- CERTIFIED ---' );
                        ELSE
                            DBMS_OUTPUT.PUT_LINE(chr(32) || chr(32) || chr(32) || chr(32) || chr(32) ||
                                                chr(32) || chr(32) || 'NEW status: --- NOT CERTIFIED ---' );
                        END IF;
                        DBMS_OUTPUT.PUT_LINE('---------------------------------------------------');            
                    END IF;
                    FETCH curr_skill INTO
                            v_consult_id,
                            v_skill_id,
                            v_skill_desc,
                            v_cert;
                END LOOP;
            ELSE
                DBMS_OUTPUT.PUT_LINE('INCORRECT Skill Status!');
            END IF;
            CLOSE curr_skill;

        END IF;
        FETCH curr_cons INTO v_cons_row;
    END LOOP;
    CLOSE curr_cons;
    COMMIT;

    -- Checking if inserted ID (p_c_id) exist in table CONSULTANT_SKILL
    BEGIN
        SELECT
            COUNT(*) INTO existing_cons_id
        FROM
            CONSULTANT_SKILL
        WHERE
            C_ID = p_c_id;
    END;

    IF existing_cons_id <= 0 THEN
        DBMS_OUTPUT.PUT_LINE('INCORRECT Consultant ID!');
    END IF;

END;
/

EXEC p_update_cons_skills(104, 'N')

EXEC p_update_cons_skills(102, 'Z')

EXEC p_update_cons_skills(110, 'Y')


SPOOL OFF;