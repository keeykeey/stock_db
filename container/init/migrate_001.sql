CREATE TABLE IF NOT EXISTS company (
    code       varchar(5) PRIMARY KEY,
    co_name    varchar(100) NOT NULL,
    co_name_en varchar(100)
);

CREATE TABLE IF NOT EXISTS section_17 (
    code  varchar(2) PRIMARY KEY,
    label varchar(16) NOT NULL
);

CREATE TABLE IF NOT EXISTS section_33 (
    code  varchar(4) PRIMARY KEY,
    label varchar(16) NOT NULL
);

CREATE TABLE IF NOT EXISTS market (
    code  varchar(4) PRIMARY KEY,
    label varchar(16) NOT NULL
);

CREATE TABLE IF NOT EXISTS company_section_relations (
    company_code varchar(5) PRIMARY KEY REFERENCES company(code),
    sec_17_code varchar(2) NOT NULL REFERENCES section_17(code),
    sec_33_code varchar(4) NOT NULL REFERENCES section_33(code),
    market_code varchar(4) NOT NULL REFERENCES market(code)
);

CREATE TABLE IF NOT EXISTS equity_history (
    target_date   date NOT NULL,
    company_code  varchar(5) NOT NULL REFERENCES company(code),
    adj_o         integer NOT NULL,
    adj_h         integer NOT NULL,
    adj_l         integer NOT NULL,
    adj_c         integer NOT NULL,
    adj_vo        bigint NOT NULL,
    PRIMARY KEY (company_code, target_date)
);

CREATE TABLE IF NOT EXISTS fin_summary (
    disc_date       date NOT NULL,
    company_code    varchar(5) NOT NULL REFERENCES company(code),
    doc_type        varchar(80),
    cur_per_type    varchar(2) NOT NULL CHECK (cur_per_type IN ('1Q', '2Q', '3Q', '4Q', 'FY')),
    cur_per_st      date,
    cur_per_en      date,
    cur_fy_st       date,
    cur_fy_en       date,
    sales           bigint,
    op              bigint,
    odp             bigint,
    np              bigint,
    eps             numeric,
    ta              bigint,
    eq              bigint,
    eq_ar           numeric,
    bps             numeric,
    cfo             bigint,
    cfi             bigint,
    cash_eq         bigint,
    div_total_ann   bigint,
    sh_out_fy       bigint,
    tr_sh_fy        bigint,
    UNIQUE (disc_date, company_code, doc_type)
);
