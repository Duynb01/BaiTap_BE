-- Delete if exists

drop table if exists subject cascade ;
drop table if exists student cascade ;
drop table if exists exam cascade ;
drop table if exists question cascade ;
drop table if exists exam_result cascade ;

-- Create Table

create table if not exists subject(
    id bigserial not null,
    name text,
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
    name text,
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
    name text,
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
    question text,
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
    is_correct boolean default true,
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

-- Query

-- Lấy danh sách các bài thi where theo subject_id
select exam.id,  exam.name, subject.name as subject
from exam join subject on exam.subject_id = subject.id
where exam.subject_id in (1, 2, 3, 4, 5, 6, 7) and exam.active and subject.active
order by exam.id;

-- Lấy ra danh sách các bài thi (trong bài thi có danh sách các câu hỏi)
select exam.id,  exam.name, json_agg(json_build_object('id', question.id, 'question', question.question)) as question
from exam
join question on question.exam_id = exam.id
join subject on subject.id = exam.subject_id
where exam.subject_id in (1, 2, 3, 4, 5, 6, 7) and exam.active and subject.active and question.active
group by exam.id, exam.name, subject.name
order by exam.id;

-- Lấy ra kết quả làm bài của 1 môn học
select student.id, student.name, exam.name as exam, json_agg(json_build_object('id', question.id, 'question', question.question)) as question, exam_result.is_correct
from exam_result
join student on exam_result.student_id = student.id
join question on exam_result.question_id = question.id
join exam on question.exam_id = exam.id
join subject on exam.subject_id = subject.id
where exam.subject_id = 1 and exam.active and subject.active and question.active and student.active and exam_result.active
group by student.id, student.name, exam.name, exam_result.is_correct;

--
select * from subject order by subject.id;
select * from student order by student.id;
select * from exam order by exam.id;
select * from question order by question.id;
select * from exam_result order by exam_result.id;