-- Exported from QuickDBD: https://www.quickdatabasediagrams.com/
-- Link to schema: https://app.quickdatabasediagrams.com/#/d/N6aArv
-- NOTE! If you have used non-SQL datatypes in your design, you will have to change these here.


CREATE TABLE "card_holder" (
    "id_card_holder" int   NOT NULL,
    "name" varchar(255)   NOT NULL,
    CONSTRAINT "pk_card_holder" PRIMARY KEY (
        "id_card_holder"
     )
);

CREATE TABLE "credit_card" (
    "card" varchar(20)   NOT NULL,
    "id_card_holder" int   NOT NULL
);

CREATE TABLE "merchant" (
    "id_merchant" int   NOT NULL,
    "name" varchar(255)   NOT NULL,
    "id_merchant_category" int   NOT NULL
);

CREATE TABLE "merchant_category" (
    "id_merchant_category" int   NOT NULL,
    "name" varchar(255)   NOT NULL
);

CREATE TABLE "transaction" (
    "transaction" int   NOT NULL,
    "date" date   NOT NULL,
    "amount" float   NOT NULL,
    "card" varchar(20)   NOT NULL,
    "id_merchant" int   NOT NULL
);

ALTER TABLE "card_holder" ADD CONSTRAINT "fk_card_holder_id_card_holder" FOREIGN KEY("id_card_holder")
REFERENCES "credit_card" ("id_card_holder");

ALTER TABLE "credit_card" ADD CONSTRAINT "fk_credit_card_card" FOREIGN KEY("card")
REFERENCES "transaction" ("card");

ALTER TABLE "merchant" ADD CONSTRAINT "fk_merchant_id_merchant_category" FOREIGN KEY("id_merchant_category")
REFERENCES "merchant_category" ("id_merchant_category");

ALTER TABLE "transaction" ADD CONSTRAINT "fk_transaction_id_merchant" FOREIGN KEY("id_merchant")
REFERENCES "merchant" ("id_merchant");

