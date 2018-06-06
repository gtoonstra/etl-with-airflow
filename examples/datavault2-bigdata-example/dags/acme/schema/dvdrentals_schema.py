from collections import OrderedDict


def create_address_schema():
    d = OrderedDict()
    d["dv__bk"] = "STRING"
    d["dv__rec_source"] = "STRING"
    d["dv__load_dtm"] = "TIMESTAMP"
    d["dv__status"] = "STRING"
    d["address"] = "STRING"
    d["address2"] = "STRING"
    d["district"] = "STRING"
    d["city_id"] = "INT"
    d["postal_code"] = "STRING"
    d["phone"] = "STRING"
    d["last_update"] = "TIMESTAMP"
    return d


def create_actor_schema():
    d = OrderedDict()
    d["dv__bk"] = "STRING"
    d["dv__rec_source"] = "STRING"
    d["dv__load_dtm"] = "TIMESTAMP"
    d["dv__status"] = "STRING"
    d["first_name"] = "STRING"
    d["last_name"] = "STRING"
    d["last_update"] = "TIMESTAMP"
    return d


def create_category_schema():
    d = OrderedDict()
    d["dv__bk"] = "STRING"
    d["dv__rec_source"] = "STRING"
    d["dv__load_dtm"] = "TIMESTAMP"
    d["dv__status"] = "STRING"
    d["name"] = "STRING"
    d["last_update"] = "TIMESTAMP"
    return d


def create_city_schema():
    d = OrderedDict()
    d["dv__bk"] = "STRING"
    d["dv__rec_source"] = "STRING"
    d["dv__load_dtm"] = "TIMESTAMP"
    d["dv__status"] = "STRING"
    d["city_id"] = "INT"
    d["city"] = "STRING"
    d["country_id"] = "INT"
    d["last_update"] = "TIMESTAMP"
    return d


def create_country_schema():
    d = OrderedDict()
    d["dv__bk"] = "STRING"
    d["dv__rec_source"] = "STRING"
    d["dv__load_dtm"] = "TIMESTAMP"
    d["dv__status"] = "STRING"
    d["country_id"] = "INT"
    d["country"] = "STRING"
    d["last_update"] = "TIMESTAMP"
    return d


def create_customer_schema():
    d = OrderedDict()
    d["dv__bk"] = "STRING"
    d["dv__rec_source"] = "STRING"
    d["dv__load_dtm"] = "TIMESTAMP"
    d["dv__status"] = "STRING"
    d["first_name"] = "STRING"
    d["last_name"] = "STRING"
    d["email"] = "STRING"
    d["activebool"] = "STRING"
    d["create_date"] = "TIMESTAMP"
    d["last_update"] = "TIMESTAMP"
    d["active"] = "INT"
    d["address_bk"] = "STRING"
    return d


def create_film_schema():
    d = OrderedDict()
    d["dv__bk"] = "STRING"
    d["dv__rec_source"] = "STRING"
    d["dv__load_dtm"] = "TIMESTAMP"
    d["dv__status"] = "STRING"
    d["title"] = "STRING"
    d["description"] = "STRING"
    d["release_year"] = "INT"
    d["rental_duration"] = "INT"
    d["rental_rate"] = "FLOAT"
    d["length"] = "INT"
    d["replacement_cost"] = "FLOAT"
    d["rating"] = "STRING"
    d["last_update"] = "TIMESTAMP"
    d["special_features"] = "STRING"
    d["fulltext"] = "STRING"
    d["language_bk"] = "STRING"
    return d


def create_film_actor_schema():
    d = OrderedDict()
    d["dv__bk"] = "STRING"
    d["dv__rec_source"] = "STRING"
    d["dv__load_dtm"] = "TIMESTAMP"
    d["dv__status"] = "STRING"
    d["film_bk"] = "STRING"
    d["actor_bk"] = "STRING"
    return d


def create_film_category_schema():
    d = OrderedDict()
    d["dv__bk"] = "STRING"
    d["dv__rec_source"] = "STRING"
    d["dv__load_dtm"] = "TIMESTAMP"
    d["dv__status"] = "STRING"
    d["film_bk"] = "STRING"
    d["category_bk"] = "STRING"
    return d


def create_inventory_schema():
    d = OrderedDict()
    d["dv__bk"] = "STRING"
    d["dv__rec_source"] = "STRING"
    d["dv__load_dtm"] = "TIMESTAMP"
    d["dv__status"] = "STRING"
    d["film_bk"] = "STRING"
    d["store_bk"] = "STRING"
    d["last_update"] = "TIMESTAMP"
    return d


def create_language_schema():
    d = OrderedDict()
    d["dv__bk"] = "STRING"
    d["dv__rec_source"] = "STRING"
    d["dv__load_dtm"] = "TIMESTAMP"
    d["dv__status"] = "STRING"
    d["name"] = "STRING"
    d["last_update"] = "TIMESTAMP"
    return d


def create_payment_schema():
    d = OrderedDict()
    d["dv__bk"] = "STRING"
    d["dv__rec_source"] = "STRING"
    d["dv__load_dtm"] = "TIMESTAMP"
    d["dv__status"] = "STRING"
    d["payment_date"] = "TIMESTAMP"
    d["amount"] = "FLOAT"
    d["customer_bk"] = "STRING"
    d["staff_bk"] = "STRING"
    d["rental_bk"] = "STRING"
    return d


def create_rental_schema():
    d = OrderedDict()
    d["dv__bk"] = "STRING"
    d["dv__rec_source"] = "STRING"
    d["dv__load_dtm"] = "TIMESTAMP"
    d["dv__status"] = "STRING"
    d["rental_date"] = "TIMESTAMP"
    d["return_date"] = "TIMESTAMP"
    d["last_update"] = "TIMESTAMP"
    d["inventory_bk"] = "STRING"
    d["customer_bk"] = "STRING"
    return d


def create_staff_schema():
    d = OrderedDict()
    d["dv__bk"] = "STRING"
    d["dv__rec_source"] = "STRING"
    d["dv__load_dtm"] = "TIMESTAMP"
    d["dv__status"] = "STRING"
    d["staff_id"] = "INT"
    d["first_name"] = "STRING"
    d["last_name"] = "STRING"
    d["address_bk"] = "STRING"
    d["email"] = "STRING"
    d["store_bk"] = "STRING"
    d["active"] = "STRING"
    d["last_update"] = "TIMESTAMP"
    return d


def create_store_schema():
    d = OrderedDict()
    d["dv__bk"] = "STRING"
    d["dv__rec_source"] = "STRING"
    d["dv__load_dtm"] = "TIMESTAMP"
    d["dv__status"] = "STRING"
    d["last_update"] = "TIMESTAMP"
    d["manager_staff_id"] = "INT"
    d["address_bk"] = "STRING"
    return d


schemas = {
    "public.address": create_address_schema(),
    "public.actor": create_actor_schema(),
    "public.category": create_category_schema(),
    "public.city": create_city_schema(),
    "public.country": create_country_schema(),
    "public.customer": create_customer_schema(),
    "public.film": create_film_schema(),
    "public.film_actor": create_film_actor_schema(),
    "public.film_category": create_film_category_schema(),
    "public.inventory": create_inventory_schema(),
    "public.language": create_language_schema(),
    "public.payment": create_payment_schema(),
    "public.rental": create_rental_schema(),
    "public.staff": create_staff_schema(),
    "public.store": create_store_schema()
}

