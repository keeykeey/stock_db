-- create
-- equities master --
CREATE TABLE IF NOT EXISTS section_17 (
    code          varchar(2) PRIMARY KEY,
    label         varchar(16) NOT NULL,
    created_at    timestamptz DEFAULT now(),
    updated_at    timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS section_33 (
    code          varchar(4) PRIMARY KEY,
    label         varchar(16) NOT NULL,
    created_at    timestamptz DEFAULT now(),
    updated_at    timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS scale_cat (
    code          integer PRIMARY KEY,
    label         varchar(32), -- "TOPIX CORE30", "TOPIX Large70", "TOPIX Mid400", "TOPIX SMALL", "-" --
    created_at    timestamptz DEFAULT now(),
    updated_at    timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS market (
    code          varchar(4) PRIMARY KEY,
    label         varchar(16) NOT NULL,
    created_at    timestamptz DEFAULT now(),
    updated_at    timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS mrgn (
    code          varchar(4) PRIMARY KEY,
    label         varchar(16) NOT NULL, -- 1: 信用, 2: 賃借, 3: その他 --
    created_at    timestamptz DEFAULT now(),
    updated_at    timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS prod_cat (
    code          varchar(4) PRIMARY KEY,
    label         varchar(16) NOT NULL,
    created_at    timestamptz DEFAULT now(),
    updated_at    timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS brand (
    code          varchar(5) PRIMARY KEY,
    co_name       varchar(100) NOT NULL,
    co_name_en    varchar(100),
    sec_17_code   varchar(2) NOT NULL REFERENCES section_17(code),
    sec_33_code   varchar(4) NOT NULL REFERENCES section_33(code),
    scale_cat     integer NOT NULL REFERENCES scale_cat(code),
    market_code   varchar(4) NOT NULL REFERENCES market(code),
    mrgn_code     varchar(4) NOT NULL REFERENCES mrgn(code),
    prod_cat_code varchar(4) NOT NULL REFERENCES prod_cat(code),
    created_at    timestamptz DEFAULT now(),
    updated_at    timestamptz DEFAULT now()
);

-- equities bars daily --
CREATE TABLE IF NOT EXISTS equity_history (
    target_date   date NOT NULL,
    code          varchar(5) NOT NULL REFERENCES brand(code),
    ul            integer NOT NULL, -- 0: ストップ高以外, 1: ストップ高 --
    ll            integer NOT NULL, -- 0: ストップ安以外, 1: ストップ安 --
    va            bigint  NOT NULL, -- 取引代金 --
    adj_o         numeric NOT NULL,
    adj_h         numeric NOT NULL,
    adj_l         numeric NOT NULL,
    adj_c         numeric NOT NULL,
    adj_vo        bigint NOT NULL,
    PRIMARY KEY (code, target_date)
);

-- fin summary --
CREATE TABLE IF NOT EXISTS doc_type (
    code          integer PRIMARY KEY,
    label         varchar(40),
    label_en      varchar(64),
    created_at    timestamptz DEFAULT now(),
    updated_at    timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS fin_summary (
    disc_no            bigint PRIMARY KEY,
    disc_date          date NOT NULL,
    code               varchar(5) NOT NULL REFERENCES brand(code),
    doc_type_code      integer NOT NULL REFERENCES doc_type(code),
    cur_per_type       varchar(2) NOT NULL CHECK (cur_per_type IN ('1Q', '2Q', '3Q', '4Q', 'FY')),
    cur_per_st         date,
    cur_per_en         date,
    cur_fy_st          date,
    cur_fy_en          date,
    sales              bigint,
    op                 bigint,
    odp                bigint,
    np                 bigint,
    eps                numeric,
    dep                numeric,
    ta                 bigint,
    eq                 bigint,
    eq_ar              numeric,
    bps                numeric,
    cfo                bigint,
    cfi                bigint,
    cff                bigint,
    cash_eq            bigint,
    div_ann            integer,
    div_unit           integer,
    div_total_ann      bigint,
    payout_ratio_ann   numeric,
    f_div_ann          integer,
    f_div_unit         integer,
    f_div_total_ann    bigint,
    f_payout_ratio_ann numeric,
    sh_out_fy          bigint,
    tr_sh_fy           bigint,
    roe                numeric
);

-- insert
INSERT INTO section_17 (code, label) VALUES
('1',  '食品'),
('2',  'エネルギー資源'),
('3',  '建設・資材'),
('4',  '素材・化学'),
('5',  '医薬品'),
('6',  '自動車・輸送機'),
('7',  '鉄鋼・非鉄'),
('8',  '機械'),
('9',  '電機・精密'),
('10', '情報通信・サービスその他'),
('11', '電気・ガス'),
('12', '運輸・物流'),
('13', '商社・卸売'),
('14', '小売'),
('15', '銀行'),
('16', '金融（除く銀行）'),
('17', '不動産'),
('99', 'その他')
ON CONFLICT (code) DO NOTHING;

INSERT INTO section_33 (code, label) VALUES
('0050', '水産・農林業'),
('1050', '鉱業'),
('2050', '建設業'),
('3050', '食料品'),
('3100', '繊維製品'),
('3150', 'パルプ・紙'),
('3200', '化学'),
('3250', '医薬品'),
('3300', '石油･石炭製品'),
('3350', 'ゴム製品'),
('3400', 'ガラス･土石製品'),
('3450', '鉄鋼'),
('3500', '非鉄金属'),
('3550', '金属製品'),
('3600', '機械'),
('3650', '電気機器'),
('3700', '輸送用機器'),
('3750', '精密機器'),
('3800', 'その他製品'),
('4050', '電気･ガス業'),
('5050', '陸運業'),
('5100', '海運業'),
('5150', '空運業'),
('5200', '倉庫･運輸関連業'),
('5250', '情報･通信業'),
('6050', '卸売業'),
('6100', '小売業'),
('7050', '銀行業'),
('7100', '証券･商品先物取引業'),
('7150', '保険業'),
('7200', 'その他金融業'),
('8050', '不動産業'),
('9050', 'サービス業'),
('9999', 'その他')
ON CONFLICT (code) DO NOTHING;

INSERT INTO scale_cat (code, label) VALUES
(1, 'TOPIX CORE30'),
(2, 'TOPIX Large70'),
(3, 'TOPIX Mid400'),
(4, 'TOPIX SMALL'),
(5, '-')
ON CONFLICT (code) DO NOTHING;

INSERT INTO market (code, label) VALUES
('0101', '東証一部'),
('0102', '東証二部'),
('0104', 'マザーズ'),
('0105', 'TOKYO PRO MARKET'),
('0106', 'JASDAQ スタンダード'),
('0107', 'JASDAQ グロース'),
('0109', 'その他'),
('0111', 'プライム'),
('0112', 'スタンダード'),
('0113', 'グロース')
ON CONFLICT (code) DO NOTHING;

INSERT INTO mrgn (code, label) VALUES
('1', '信用'),
('2', '賃借'),
('3', 'その他')
ON CONFLICT (code) DO NOTHING;

INSERT INTO prod_cat (code, label) VALUES
('011', '内国株券'),
('012', '優先出資証券'),
('013', 'REIT'),
('014', 'ETF'),
('021', '外国株券'),
('022', '外国REIT'),
('023', '外国ETF'),
('024', '外国株預託証券')
ON CONFLICT (code) DO NOTHING;

INSERT INTO doc_type (code, label, label_en) VALUES
(1,  '決算短信（連結・日本基準）', 'FYFinancialStatements_Consolidated_JP'),
(2,  '決算短信（連結・米国基準）', 'FYFinancialStatements_Consolidated_US'),
(3,  '決算短信（非連結・日本基準）', 'FYFinancialStatements_NonConsolidated_JP'),
(4,  '第1四半期決算短信（連結・日本基準）', '1QFinancialStatements_Consolidated_JP'),
(5,  '第1四半期決算短信（連結・米国基準）', '1QFinancialStatements_Consolidated_US'),
(6,  '第1四半期決算短信（非連結・日本基準）', '1QFinancialStatements_NonConsolidated_JP'),
(7,  '第2四半期決算短信（連結・日本基準）', '2QFinancialStatements_Consolidated_JP'),
(8,  '第2四半期決算短信（連結・米国基準）', '2QFinancialStatements_Consolidated_US'),
(9,  '第2四半期決算短信（非連結・日本基準）', '2QFinancialStatements_NonConsolidated_JP'),
(10, '第3四半期決算短信（連結・日本基準）', '3QFinancialStatements_Consolidated_JP'),
(11, '第3四半期決算短信（連結・米国基準）', '3QFinancialStatements_Consolidated_US'),
(12, '第3四半期決算短信（非連結・日本基準）', '3QFinancialStatements_NonConsolidated_JP'),
(13, 'その他四半期決算短信（連結・日本基準）', 'OtherPeriodFinancialStatements_Consolidated_JP'),
(14, 'その他四半期決算短信（連結・米国基準）', 'OtherPeriodFinancialStatements_Consolidated_US'),
(15, 'その他四半期決算短信（非連結・日本基準）', 'OtherPeriodFinancialStatements_NonConsolidated_JP'),
(16, '決算短信（連結・ＪＭＩＳ）', 'FYFinancialStatements_Consolidated_JMIS'),
(17, '第1四半期決算短信（連結・ＪＭＩＳ）', '1QFinancialStatements_Consolidated_JMIS'),
(18, '第2四半期決算短信（連結・ＪＭＩＳ）', '2QFinancialStatements_Consolidated_JMIS'),
(19, '第3四半期決算短信（連結・ＪＭＩＳ）', '3QFinancialStatements_Consolidated_JMIS'),
(20, 'その他四半期決算短信（連結・ＪＭＩＳ）', 'OtherPeriodFinancialStatements_Consolidated_JMIS'),
(21, '決算短信（非連結・ＩＦＲＳ）', 'FYFinancialStatements_NonConsolidated_IFRS'),
(22, '第1四半期決算短信（非連結・ＩＦＲＳ）', '1QFinancialStatements_NonConsolidated_IFRS'),
(23, '第2四半期決算短信（非連結・ＩＦＲＳ）', '2QFinancialStatements_NonConsolidated_IFRS'),
(24, '第3四半期決算短信（非連結・ＩＦＲＳ）', '3QFinancialStatements_NonConsolidated_IFRS'),
(25, 'その他四半期決算短信（非連結・ＩＦＲＳ）', 'OtherPeriodFinancialStatements_NonConsolidated_IFRS'),
(26, '決算短信（連結・ＩＦＲＳ）', 'FYFinancialStatements_Consolidated_IFRS'),
(27, '第1四半期決算短信（連結・ＩＦＲＳ）', '1QFinancialStatements_Consolidated_IFRS'),
(28, '第2四半期決算短信（連結・ＩＦＲＳ）', '2QFinancialStatements_Consolidated_IFRS'),
(29, '第3四半期決算短信（連結・ＩＦＲＳ）', '3QFinancialStatements_Consolidated_IFRS'),
(30, 'その他四半期決算短信（連結・ＩＦＲＳ）', 'OtherPeriodFinancialStatements_Consolidated_IFRS'),
(31, '決算短信（非連結・外国株）', 'FYFinancialStatements_NonConsolidated_Foreign'),
(32, '第1四半期決算短信（非連結・外国株）', '1QFinancialStatements_NonConsolidated_Foreign'),
(33, '第2四半期決算短信（非連結・外国株）', '2QFinancialStatements_NonConsolidated_Foreign'),
(34, '第3四半期決算短信（非連結・外国株）', '3QFinancialStatements_NonConsolidated_Foreign'),
(35, 'その他四半期決算短信（非連結・外国株）', 'OtherPeriodFinancialStatements_NonConsolidated_Foreign'),
(36, '決算短信（連結・外国株）', 'FYFinancialStatements_Consolidated_Foreign'),
(37, '第1四半期決算短信（連結・外国株）', '1QFinancialStatements_Consolidated_Foreign'),
(38, '第2四半期決算短信（連結・外国株）', '2QFinancialStatements_Consolidated_Foreign'),
(39, '第3四半期決算短信（連結・外国株）', '3QFinancialStatements_Consolidated_Foreign'),
(40, 'その他四半期決算短信（連結・外国株）', 'OtherPeriodFinancialStatements_Consolidated_Foreign'),
(41, '決算短信（REIT）', 'FYFinancialStatements_Consolidated_REIT'),
(42, '配当予想の修正', 'DividendForecastRevision'),
(43, '業績予想の修正', 'EarnForecastRevision'),
(44, '分配予想の修正', 'REITDividendForecastRevision'),
(45, '利益予想の修正', 'REITEarnForecastRevision')
ON CONFLICT (code) DO NOTHING;
