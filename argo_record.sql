CREATE TABLE ARGO_RECORD
(
  RECORD_ID    INTEGER,
  TEXT         VARCHAR2(128 BYTE),
  INSERT_TIME  DATE,
  EXPIRE_TIME  DATE,
  ARCHIVE      INTEGER                          DEFAULT 0
);
