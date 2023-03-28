! Version: 0.1
! DRI: Dave Carlton
! Description: CNC Jobs
! Copyright (C) 2022 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors cnc.jobs cnc.machine cnc.material db.tuples db.types kernel io
sequences uuid uuid.private ;

IN: cnc.job


TUPLE: job job_id job_name job_date job_finish job_cost job_note job_status client_id machine_id material_id customer_id ;

job "JOB" {
    { "job_id" "JOB_ID" +db-assigned-id+ }
    { "job_name" "JOB_NAME" TEXT }
    { "job_date" "JOB_DATE" DATE }
    { "job_finish" "JOB_FINISH" DATE }
    { "job_cost" "JOB_COST" DOUBLE }
    { "job_note" "JOB_NOTE" TEXT }
    { "job_status" "JOB_STATUS" TEXT }
    { "client_id" "CLIENT_ID" INTEGER }
    { "machine_id" "MACHINE_ID" INTEGER }
    { "material_id" "MATERIAL_ID" INTEGER }
    { "customer_id" "CUSTOMER_ID" INTEGER }
} define-persistent

: <job> ( name machine material -- job )
    job new 
    over find-material >>material_id
    nip  over find-machine >>machine_id
    nip swap >>job_name
    uuid1 >>job_id
    (timestamp) >>job_date
    ;

: fix-job ( job -- job )
    ;

: define-jobs ( -- )
    [ job ensure-table ] with-jobs-db ;

:: insert-job ( name machine material -- job )
    [ job ensure-table
      name machine material <job> dup insert-tuple
    ] with-jobs-db ;

: job1 ( -- job )
    "Test" "SM2 CNC" "Red Oak" insert-job ;

