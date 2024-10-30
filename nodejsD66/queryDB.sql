-- Create Table

create table if not exists subject(
    id bigserial not null,
    name text not null ,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    created_by bigint,
    modified_at timestamp with time zone,
    modified_by bigint,
    deleted_at timestamp with time zone,
    deleted_by bigint,
    active boolean default TRUE,
    constraint pk_subject primary key (id)
);
create table if not exists student(
    id bigserial not null,
    name text not null ,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    created_by bigint,
    modified_at timestamp with time zone,
    modified_by bigint,
    deleted_at timestamp with time zone,
    deleted_by bigint,
    active boolean default TRUE,
    constraint pk_student primary key (id)
);
create table if not exists exam(
    id bigserial not null,
    name text not null ,
    subject_id bigint,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    created_by bigint,
    modified_at timestamp with time zone,
    modified_by bigint,
    deleted_at timestamp with time zone,
    deleted_by bigint,
    active boolean default TRUE,
    constraint pk_exam primary key (id),
    constraint fk_exam_subject foreign key (subject_id) references subject(id)
);
create table if not exists question(
    id bigserial not null,
    question text not null ,
    correct_answer text,
    exam_id bigint,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    created_by bigint,
    modified_at timestamp with time zone,
    modified_by bigint,
    deleted_at timestamp with time zone,
    deleted_by bigint,
    active boolean default TRUE,
    constraint pk_question primary key (id),
    constraint fk_question_exam foreign key (exam_id) references exam(id)
);
create table if not exists exam_result(
    id bigserial not null,
    student_id bigint,
    question_id bigint,
    is_correct boolean,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    created_by bigint,
    modified_at timestamp with time zone,
    modified_by bigint,
    deleted_at timestamp with time zone,
    deleted_by bigint,
    active boolean default TRUE,
    constraint pk_examResult primary key (id),
    constraint fk_examResult_student foreign key (student_id) references student(id),
    constraint fk_examResult_question foreign key (question_id) references question(id)
);
create table if not exists subject_student(
    student_id bigint,
    subject_id bigint,
    constraint fk_subjectStudent_student foreign key (student_id) references student(id),
    constraint fk_subjectStudent_subject foreign key (subject_id) references subject(id)
);

-- Add tạm dữ liệu

insert into subject (name) values ('Math'),
                                  ('Data Structures and Algorithms'),
                                  ('Object-Oriented Programming'),
                                  ('Programming Language'),
                                  ('Database'),
                                  ('English'),
                                  ('Music');
insert into student (name) values ('Cristiano Ronaldo'),
                                  ('Gareth Bale'),
                                  ('Karim Benzema'),
                                  ('Marcelo Vieira'),
                                  ('Sergio Ramos');
insert into exam (name, subject_id) values ('TOEFL', 1),
                                           ('IELTS', 3),
                                           ('SAT', 7),
                                           ('HSK', 2),
                                           ('GRE', 4),
                                           ('GMAT', 4),
                                           ('CISSP', 5);
insert into question (question, correct_answer, exam_id) values  ('1+1=', '2', 1),
                                                                 ('2+2=', '4', 7),
                                                                 ('4+1=', '5', 5),
                                                                 ('1+9=', '10', 2),
                                                                 ('3x4=', '12', 1),
                                                                 ('5x6=', '30', 3),
                                                                 ('27:3=', '9', 5),
                                                                 ('6x6=', '36', 7),
                                                                 ('7x6=', '42', 6),
                                                                 ('9x9=', '81', 4);
insert into exam_result (student_id, question_id, is_correct) values (1, 1, true),
                                                                     (1, 5, false),
                                                                     (1, 6, true),
                                                                     (2, 1, true),
                                                                     (2, 3, false),
                                                                     (2, 5, true),
                                                                     (3, 9, true),
                                                                     (4, 2, true),
                                                                     (4, 7, true),
                                                                     (5, 4, false),
                                                                     (5, 8, true);
-- 5 stud vs 7 subj
insert into subject_student (student_id, subject_id) values (1, 1),
                                                            (1, 3),
                                                            (1, 6),
                                                            (2, 1),
                                                            (2, 2),
                                                            (2, 4),
                                                            (2, 7),
                                                            (3, 1),
                                                            (3, 6),
                                                            (4, 2),
                                                            (4, 5),
                                                            (4, 7),
                                                            (5, 1),
                                                            (5, 2),
                                                            (5, 4),
                                                            (5, 6),
                                                            (5, 7);

-- Query

with
    details as(
        select question.exam_id as ques_id, json_agg(json_build_object('id', question.id, 'name', question.question, 'is_correct', exam_result.is_correct)) as detail
        from question
        join exam_result on question.id = exam_result.question_id
        join exam on question.exam_id = exam.id
        join student on exam_result.student_id = student.id
        group by question.exam_id
    ),
    quantity as (
        select student.name , exam.name as exam_name, count(case when exam_result.is_correct then 1 end ) as quantity
        from  student
        join exam_result on student.id = exam_result.student_id
        join question on exam_result.question_id = question.id
        join exam on exam.id = question.exam_id
        where exam_result.is_correct
        group by student.name, exam.name),
    exams as (
        select exam.id,
               exam.name,
               exam.subject_id,
               json_agg(json_build_object( 'total_correct', quantity.quantity,
                                           'total_question', (select count(question.question) from question where question.exam_id = exam.id),
                                           'details', details.detail)) as exam_detail
        from exam
        join quantity on quantity.exam_name = exam.name
        join details on details.ques_id = exam.id
        group by exam.id, exam.name)
select subject.id, subject.name, json_agg(json_build_object('id', student.id, 'name', student.name, 'exams', exams.exam_detail)) as students
from subject
left join subject_student  on subject.id = subject_student.subject_id
left join student on subject_student.student_id = student.id
left join exams on exams.subject_id = subject.id
where subject.id = subject_student.subject_id and subject_student.student_id = student.id
group by subject.id, subject.name
order by id;