-- Создание архитектуры баз данных

-- Справочник  ТЦ, stores as st
CREATE TABLE IF NOT EXISTS stores (
    store_id BIGINT PRIMARY KEY,
    city_desc VARCHAR(60) NOT NULL,
    district VARCHAR NOT NULL
);

-- Справочник артикулов product as p:
CREATE TABLE IF NOT EXISTS product (
    id BIGSERIAL PRIMARY KEY,
    cma VARCHAR(100) NOT NULL,
    art_no INTEGER NOT NULL,
    art_name VARCHAR(100) NOT NULL
);
ALTER TABLE product ADD CONSTRAINT product_art_no_unique UNIQUE (art_no);

-- Таблица продаж sales as s:
CREATE TABLE IF NOT EXISTS sales (
    id BIGSERIAL PRIMARY KEY,
    store_id BIGINT NOT NULL REFERENCES stores(store_id),
    date_of_day DATE,
    art_no INTEGER NOT NULL REFERENCES product(art_no),
    sell_qty_colli DECIMAL(10, 3),
    sell_val_gsp DECIMAL(12, 2)
);

-- Таблица скидок prod_disc as pd
CREATE TABLE IF NOT EXISTS prod_disc (
    id BIGSERIAL PRIMARY KEY,
    date_from DATE,
    date_to DATE,
    art_no INTEGER NOT NULL REFERENCES product(art_no),
    store_id BIGINT NOT NULL REFERENCES stores(store_id),
    old_colli_gsp DECIMAL(12, 2),
    discount_colli_gsp DECIMAL(12, 2)
);
