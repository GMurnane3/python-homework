DROP TABLE IF EXISTS card_holder CASCADE;
DROP TABLE IF EXISTS credit_card CASCADE;
DROP TABLE IF EXISTS merchant CASCADE;
DROP TABLE IF EXISTS merchant_category CASCADE;
DROP TABLE IF EXISTS transaction CASCADE;


CREATE TABLE "card_holder" (
    "id_card_holder" int NOT NULL,
    "ch_name" varchar(255) NOT NULL,
    CONSTRAINT "pk_card_holder" PRIMARY KEY (
        "id_card_holder"
     )
);

CREATE TABLE "credit_card" (
    "card" varchar(20),
    "id_card_holder" int NOT NULL,
    CONSTRAINT "pk_credit_card" PRIMARY KEY (
        "card"
     )
);

CREATE TABLE "merchant" (
    "id_merchant" int NOT NULL,
    "m_name" varchar(255) NOT NULL,
    "id_merchant_category" int,
    CONSTRAINT "pk_merchant" PRIMARY KEY (
        "id_merchant"
     )
);

CREATE TABLE "merchant_category" (
    "id_merchant_category" int,
    "mc_name" varchar(255) NOT NULL,
    CONSTRAINT "pk_merchant_category" PRIMARY KEY (
        "id_merchant_category"
     )
);

CREATE TABLE "transaction" (
    "transaction" int NOT NULL,
    "date" TIMESTAMP NOT NULL,
    "amount" float NOT NULL,
    "card" varchar(20),
    "id_merchant" int NOT NULL,
    CONSTRAINT "pk_transaction" PRIMARY KEY (
        "transaction"
     )
);

ALTER TABLE "credit_card" ADD CONSTRAINT "fk_credit_card_id_card_holder" FOREIGN KEY("id_card_holder")
REFERENCES "card_holder" ("id_card_holder");

ALTER TABLE "merchant" ADD CONSTRAINT "fk_merchant_id_merchant_category" FOREIGN KEY("id_merchant_category")
REFERENCES "merchant_category" ("id_merchant_category");

ALTER TABLE "transaction" ADD CONSTRAINT "fk_transaction_card" FOREIGN KEY("card")
REFERENCES "credit_card" ("card");

ALTER TABLE "transaction" ADD CONSTRAINT "fk_transaction_id_merchant" FOREIGN KEY("id_merchant")
REFERENCES "merchant" ("id_merchant");


-- Group transactions by cardholder
select ch.ch_name, cc.card, t.transaction, t.date, t.amount
from card_holder as ch
left join credit_card as cc
	on ch.id_card_holder = cc.id_card_holder
left join transaction as t
	on cc.card = t.card
group by ch.ch_name, cc.card, t.transaction
order by ch.ch_name


-- 1. Group transactions by cardholder, include merchant data
DROP TABLE IF EXISTS transactions CASCADE;

select ch.ch_name, cc.card, t.transaction, t.date, t.amount, m.m_name, mc.mc_name
	INTO transactions
from card_holder as ch
left join credit_card as cc
	on ch.id_card_holder = cc.id_card_holder
left join transaction as t
	on cc.card = t.card
left join merchant as m
	on t.id_merchant = m.id_merchant
left join merchant_category as mc
	on m.id_merchant_category = mc.id_merchant_category
group by ch.ch_name, cc.card, t.transaction, m.m_name, mc.mc_name
order by ch.ch_name

-- Consider the 7:00 am to 9:00 am time period
select * from transactions
where date_part('hour', date) > 7 and date_part('hour', date) < 9 -- '07:00:00'


-- 2. List transactions in descending order, include merchant data, top 100 highest transactions between 7:00 am and 9:00 am
DROP TABLE IF EXISTS transactions_t CASCADE;

select ch.ch_name, cc.card, t.transaction, date_part('hour', t.date) > 7 and date_part('hour', t.date) < 9 as "time", t.amount, m.m_name, mc.mc_name
	INTO transactions_t
from card_holder as ch
left join credit_card as cc
	on ch.id_card_holder = cc.id_card_holder
left join transaction as t
	on cc.card = t.card
left join merchant as m
	on t.id_merchant = m.id_merchant
left join merchant_category as mc
	on m.id_merchant_category = mc.id_merchant_category
group by ch.ch_name, cc.card, t.transaction, m.m_name, mc.mc_name
order by amount desc;

select * from transactions_t where time = TRUE
LIMIT 100;


-- 3. Total $ amount and number of transactions, per card holder, of $2.00 or less
select ch_name, sum(amount) as "Total Amount", count(amount) as "Total Number"
from transactions 
where amount <= 2
group by ch_name
order by "Total Amount" desc


-- 4. Top Merchants, by Total $ amount of $2.00 or less
select m_name, sum(amount) as "Total Amount", count(amount) as "Total Number", avg(amount) as "Average Transaction"
from transactions 
where amount <= 2
group by m_name
order by "Total Amount" desc
LIMIT 5


-- 5. Creating views
-- 5a. Top 100 transactions between 7:00 am and 9:00 am

DROP TABLE IF EXISTS transactions_t CASCADE;

select ch.ch_name, cc.card, t.transaction, date_part('hour', t.date) > 7 and date_part('hour', t.date) < 9 as "time", t.amount, m.m_name, mc.mc_name
	INTO transactions_t
from card_holder as ch
left join credit_card as cc
	on ch.id_card_holder = cc.id_card_holder
left join transaction as t
	on cc.card = t.card
left join merchant as m
	on t.id_merchant = m.id_merchant
left join merchant_category as mc
	on m.id_merchant_category = mc.id_merchant_category
group by ch.ch_name, cc.card, t.transaction, m.m_name, mc.mc_name
order by amount desc;

Create view "Top 100 Morning Transactions" AS
select * from transactions_t where time = TRUE
LIMIT 100;

select * from "Top 100 Morning Transactions"

-- 5b. Transactions of less than $2.00

CREATE VIEW "Transactions <= $2.00" AS
select ch_name, sum(amount) as "Total Amount", count(amount) as "Total Number"
from transactions 
where amount <= 2
group by ch_name
order by "Total Amount" desc;

select * from "Transactions <= $2.00"

-- 5c. Top 5 Merchants pron eo being hacked

Create view "Merchants Prone to being Hacked" AS
select m_name, sum(amount) as "Total Amount", count(amount) as "Total Number"
from transactions 
where amount <= 2
group by m_name
order by "Total Amount" desc

select * from "Merchants Prone to being Hacked"


-- 6. Create Table of Transactions for Just Cardholders 18 and 2
DROP TABLE IF EXISTS large_clients CASCADE;

select cc.id_card_holder, cc.card, t.transaction, t.date, t.amount, m.m_name, mc.mc_name
	INTO large_clients
from credit_card as cc -- where id_card_holder = 2 and id_card_holder = 18
left join transaction as t
	on cc.card = t.card
left join merchant as m
	on t.id_merchant = m.id_merchant
left join merchant_category as mc
	on m.id_merchant_category = mc.id_merchant_category
group by cc.id_card_holder, cc.card, t.transaction, m.m_name, mc.mc_name
order by cc.id_card_holder

select * from large_clients where id_card_holder = 2 or id_card_holder = 18
group by card, id_card_holder, transaction, date, amount, m_name, mc_name
order by id_card_holder asc, amount desc


-- 7. Identify Transactions for Cardholder 25 during the First Half of of 2018
select * from large_clients where id_card_holder = 25 AND date >= '2017-12-31' AND 
      date < '2018-04-01'
group by card, id_card_holder, transaction, date, amount, m_name, mc_name
order by id_card_holder asc, amount desc

