/*
 * This file is released under the terms of the Artistic License.  Please see
 * the file LICENSE, included in this package, for details.
 *
 * Copyright (C) 2003 Mark Wong & Open Source Development Lab, Inc.
 *
 * Based on TPC-C Standard Specification Revision 5.0 Clause 2.8.2.
 */
CREATE TYPE new_order_info
AS (ol_i_id INTEGER, ol_supply_w_id INTEGER, ol_quantity INTEGER);

CREATE OR REPLACE FUNCTION new_order (INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, new_order_info, new_order_info, new_order_info, new_order_info, new_order_info, new_order_info, new_order_info, new_order_info, new_order_info, new_order_info, new_order_info, new_order_info, new_order_info, new_order_info, new_order_info) RETURNS INTEGER AS '
DECLARE
	tmp_w_id ALIAS FOR $1;
	tmp_d_id ALIAS FOR $2;
	tmp_c_id ALIAS FOR $3;
	tmp_o_all_local ALIAS FOR $4;
	tmp_o_ol_cnt ALIAS FOR $5;

	in_row1 ALIAS FOR $6;
	in_row2 ALIAS FOR $7;
	in_row3 ALIAS FOR $8;
	in_row4 ALIAS FOR $9;
	in_row5 ALIAS FOR $10;
	in_row6 ALIAS FOR $11;
	in_row7 ALIAS FOR $12;
	in_row8 ALIAS FOR $13;
	in_row9 ALIAS FOR $14;
	in_row10 ALIAS FOR $15;
	in_row11 ALIAS FOR $16;
	in_row12 ALIAS FOR $17;
	in_row13 ALIAS FOR $18;
	in_row14 ALIAS FOR $19;
	in_row15 ALIAS FOR $20;

	out_w_tax NUMERIC;

	out_d_tax NUMERIC;
	out_d_next_o_id INTEGER;

	out_c_discount NUMERIC;
	out_c_last VARCHAR;
	out_c_credit VARCHAR;

	tmp_i_id INTEGER;
	tmp_i_price NUMERIC;
	tmp_i_name VARCHAR;
	tmp_i_data VARCHAR;

	tmp_ol_amount NUMERIC;
	tmp_ol_supply_w_id INTEGER;
	tmp_ol_quantity INTEGER;

	tmp_s_quantity INTEGER;

	tmp_total_amount NUMERIC;
BEGIN
	SELECT w_tax
	INTO out_w_tax
	FROM warehouse
	WHERE w_id = tmp_w_id;

	SELECT d_tax, d_next_o_id
	INTO out_d_tax, out_d_next_o_id
	FROM district   
	WHERE d_w_id = tmp_w_id
	  AND d_id = tmp_d_id;

	UPDATE district
	SET d_next_o_id = d_next_o_id + 1
	WHERE d_w_id = tmp_w_id
	  AND d_id = tmp_d_id;

	SELECT c_discount, c_last, c_credit
	INTO out_c_discount, out_c_last, out_c_credit
	FROM customer
	WHERE c_w_id = tmp_w_id
	  AND c_d_id = tmp_d_id
	  AND c_id = tmp_c_id;

	INSERT INTO new_order (no_o_id, no_d_id, no_w_id)
	VALUES (out_d_next_o_id, tmp_d_id, tmp_w_id);

	INSERT INTO orders (o_id, o_d_id, o_w_id, o_c_id, o_entry_d,
	                    o_carrier_id, o_ol_cnt, o_all_local)
	VALUES (out_d_next_o_id, tmp_d_id, tmp_w_id, tmp_c_id,
	        current_timestamp, NULL, tmp_o_ol_cnt, tmp_o_all_local);

	tmp_total_amount = 0;

	/* More goofy logic. :( */
	IF tmp_o_ol_cnt > 0 THEN
		SELECT in_row1.ol_i_id
		INTO tmp_i_id;
		SELECT in_row1.ol_supply_w_id
		INTO tmp_ol_supply_w_id;
		SELECT in_row1.ol_quantity
		INTO tmp_ol_quantity;

		SELECT i_price, i_name, i_data
		INTO tmp_i_price, tmp_i_name, tmp_i_data
		FROM item
		WHERE i_id = tmp_i_id;

		IF tmp_i_price > 0 THEN
			tmp_ol_amount = tmp_i_price * tmp_ol_quantity;
			SELECT new_order_2(tmp_w_id, tmp_d_id, tmp_i_id,
		                   	tmp_ol_quantity, tmp_i_price,
					tmp_i_name, tmp_i_data,
					out_d_next_o_id, tmp_ol_amount,
                                   	tmp_ol_supply_w_id, 1)
			INTO tmp_s_quantity;
			tmp_total_amount = tmp_total_amount + tmp_ol_amount;
		ELSE
			RETURN 1;
		END IF;
	ELSIF tmp_o_ol_cnt > 1 THEN
		SELECT in_row2.ol_i_id
		INTO tmp_i_id;
		SELECT in_row2.ol_supply_w_id
		INTO tmp_ol_supply_w_id;
		SELECT in_row2.ol_quantity
		INTO tmp_ol_quantity;

		SELECT i_price, i_name, i_data
		INTO tmp_i_price, tmp_i_name, tmp_i_data
		FROM item
		WHERE i_id = tmp_i_id;

		IF tmp_i_price > 0 THEN
			tmp_ol_amount = tmp_i_price * tmp_ol_quantity;
			SELECT new_order_2(tmp_w_id, tmp_d_id, tmp_i_id,
		                   	tmp_ol_quantity, tmp_i_price,
					tmp_i_name, tmp_i_data,
					out_d_next_o_id, tmp_ol_amount,
                                   	tmp_ol_supply_w_id, 2)
			INTO tmp_s_quantity;
			tmp_total_amount = tmp_total_amount + tmp_ol_amount;
		ELSE
			RETURN 1;
		END IF;
	ELSIF tmp_o_ol_cnt > 2 THEN
		SELECT in_row3.ol_i_id
		INTO tmp_i_id;
		SELECT in_row3.ol_supply_w_id
		INTO tmp_ol_supply_w_id;
		SELECT in_row3.ol_quantity
		INTO tmp_ol_quantity;

		SELECT i_price, i_name, i_data
		INTO tmp_i_price, tmp_i_name, tmp_i_data
		FROM item
		WHERE i_id = tmp_i_id;

		IF tmp_i_price > 0 THEN
			tmp_ol_amount = tmp_i_price * tmp_ol_quantity;
			SELECT new_order_2(tmp_w_id, tmp_d_id, tmp_i_id,
		                   	tmp_ol_quantity, tmp_i_price,
					tmp_i_name, tmp_i_data,
					out_d_next_o_id, tmp_ol_amount,
                                   	tmp_ol_supply_w_id, 3)
			INTO tmp_s_quantity;
			tmp_total_amount = tmp_total_amount + tmp_ol_amount;
		ELSE
			RETURN 1;
		END IF;
	ELSIF tmp_o_ol_cnt > 3 THEN
		SELECT in_row4.ol_i_id
		INTO tmp_i_id;
		SELECT in_row4.ol_supply_w_id
		INTO tmp_ol_supply_w_id;
		SELECT in_row4.ol_quantity
		INTO tmp_ol_quantity;

		SELECT i_price, i_name, i_data
		INTO tmp_i_price, tmp_i_name, tmp_i_data
		FROM item
		WHERE i_id = tmp_i_id;

		IF tmp_i_price > 0 THEN
			tmp_ol_amount = tmp_i_price * tmp_ol_quantity;
			SELECT new_order_2(tmp_w_id, tmp_d_id, tmp_i_id,
		                   	tmp_ol_quantity, tmp_i_price,
					tmp_i_name, tmp_i_data,
					out_d_next_o_id, tmp_ol_amount,
                                   	tmp_ol_supply_w_id, 4)
			INTO tmp_s_quantity;
			tmp_total_amount = tmp_total_amount + tmp_ol_amount;
		ELSE
			RETURN 1;
		END IF;
	ELSIF tmp_o_ol_cnt > 4 THEN
		SELECT in_row5.ol_i_id
		INTO tmp_i_id;
		SELECT in_row5.ol_supply_w_id
		INTO tmp_ol_supply_w_id;
		SELECT in_row5.ol_quantity
		INTO tmp_ol_quantity;

		SELECT i_price, i_name, i_data
		INTO tmp_i_price, tmp_i_name, tmp_i_data
		FROM item
		WHERE i_id = tmp_i_id;

		IF tmp_i_price > 0 THEN
			tmp_ol_amount = tmp_i_price * tmp_ol_quantity;
			SELECT new_order_2(tmp_w_id, tmp_d_id, tmp_i_id,
		                   	tmp_ol_quantity, tmp_i_price,
					tmp_i_name, tmp_i_data,
					out_d_next_o_id, tmp_ol_amount,
                                   	tmp_ol_supply_w_id, 5)
			INTO tmp_s_quantity;
			tmp_total_amount = tmp_total_amount + tmp_ol_amount;
		ELSE
			RETURN 1;
		END IF;
	ELSIF tmp_o_ol_cnt > 5 THEN
		SELECT in_row6.ol_i_id
		INTO tmp_i_id;
		SELECT in_row6.ol_supply_w_id
		INTO tmp_ol_supply_w_id;
		SELECT in_row6.ol_quantity
		INTO tmp_ol_quantity;

		SELECT i_price, i_name, i_data
		INTO tmp_i_price, tmp_i_name, tmp_i_data
		FROM item
		WHERE i_id = tmp_i_id;

		IF tmp_i_price > 0 THEN
			tmp_ol_amount = tmp_i_price * tmp_ol_quantity;
			SELECT new_order_2(tmp_w_id, tmp_d_id, tmp_i_id,
		                   	tmp_ol_quantity, tmp_i_price,
					tmp_i_name, tmp_i_data,
					out_d_next_o_id, tmp_ol_amount,
                                   	tmp_ol_supply_w_id, 6)
			INTO tmp_s_quantity;
			tmp_total_amount = tmp_total_amount + tmp_ol_amount;
		ELSE
			RETURN 1;
		END IF;
	ELSIF tmp_o_ol_cnt > 6 THEN
		SELECT in_row7.ol_i_id
		INTO tmp_i_id;
		SELECT in_row7.ol_supply_w_id
		INTO tmp_ol_supply_w_id;
		SELECT in_row7.ol_quantity
		INTO tmp_ol_quantity;

		SELECT i_price, i_name, i_data
		INTO tmp_i_price, tmp_i_name, tmp_i_data
		FROM item
		WHERE i_id = tmp_i_id;

		IF tmp_i_price > 0 THEN
			tmp_ol_amount = tmp_i_price * tmp_ol_quantity;
			SELECT new_order_2(tmp_w_id, tmp_d_id, tmp_i_id,
		                   	tmp_ol_quantity, tmp_i_price,
					tmp_i_name, tmp_i_data,
					out_d_next_o_id, tmp_ol_amount,
                                   	tmp_ol_supply_w_id, 7)
			INTO tmp_s_quantity;
			tmp_total_amount = tmp_total_amount + tmp_ol_amount;
		ELSE
			RETURN 1;
		END IF;
	ELSIF tmp_o_ol_cnt > 7 THEN
		SELECT in_row8.ol_i_id
		INTO tmp_i_id;
		SELECT in_row8.ol_supply_w_id
		INTO tmp_ol_supply_w_id;
		SELECT in_row8.ol_quantity
		INTO tmp_ol_quantity;

		SELECT i_price, i_name, i_data
		INTO tmp_i_price, tmp_i_name, tmp_i_data
		FROM item
		WHERE i_id = tmp_i_id;

		IF tmp_i_price > 0 THEN
			tmp_ol_amount = tmp_i_price * tmp_ol_quantity;
			SELECT new_order_2(tmp_w_id, tmp_d_id, tmp_i_id,
		                   	tmp_ol_quantity, tmp_i_price,
					tmp_i_name, tmp_i_data,
					out_d_next_o_id, tmp_ol_amount,
                                   	tmp_ol_supply_w_id, 8)
			INTO tmp_s_quantity;
			tmp_total_amount = tmp_total_amount + tmp_ol_amount;
		ELSE
			RETURN 1;
		END IF;
	ELSIF tmp_o_ol_cnt > 8 THEN
		SELECT in_row9.ol_i_id
		INTO tmp_i_id;
		SELECT in_row9.ol_supply_w_id
		INTO tmp_ol_supply_w_id;
		SELECT in_row9.ol_quantity
		INTO tmp_ol_quantity;

		SELECT i_price, i_name, i_data
		INTO tmp_i_price, tmp_i_name, tmp_i_data
		FROM item
		WHERE i_id = tmp_i_id;

		IF tmp_i_price > 0 THEN
			tmp_ol_amount = tmp_i_price * tmp_ol_quantity;
			SELECT new_order_2(tmp_w_id, tmp_d_id, tmp_i_id,
		                   	tmp_ol_quantity, tmp_i_price,
					tmp_i_name, tmp_i_data,
					out_d_next_o_id, tmp_ol_amount,
                                   	tmp_ol_supply_w_id, 9)
			INTO tmp_s_quantity;
			tmp_total_amount = tmp_total_amount + tmp_ol_amount;
		ELSE
			RETURN 1;
		END IF;
	ELSIF tmp_o_ol_cnt > 9 THEN
		SELECT in_row10.ol_i_id
		INTO tmp_i_id;
		SELECT in_row10.ol_supply_w_id
		INTO tmp_ol_supply_w_id;
		SELECT in_row10.ol_quantity
		INTO tmp_ol_quantity;

		SELECT i_price, i_name, i_data
		INTO tmp_i_price, tmp_i_name, tmp_i_data
		FROM item
		WHERE i_id = tmp_i_id;

		IF tmp_i_price > 0 THEN
			tmp_ol_amount = tmp_i_price * tmp_ol_quantity;
			SELECT new_order_2(tmp_w_id, tmp_d_id, tmp_i_id,
		                   	tmp_ol_quantity, tmp_i_price,
					tmp_i_name, tmp_i_data,
					out_d_next_o_id, tmp_ol_amount,
                                   	tmp_ol_supply_w_id, 10)
			INTO tmp_s_quantity;
			tmp_total_amount = tmp_total_amount + tmp_ol_amount;
		ELSE
			RETURN 1;
		END IF;
	ELSIF tmp_o_ol_cnt > 10 THEN
		SELECT in_row11.ol_i_id
		INTO tmp_i_id;
		SELECT in_row11.ol_supply_w_id
		INTO tmp_ol_supply_w_id;
		SELECT in_row11.ol_quantity
		INTO tmp_ol_quantity;

		SELECT i_price, i_name, i_data
		INTO tmp_i_price, tmp_i_name, tmp_i_data
		FROM item
		WHERE i_id = tmp_i_id;

		IF tmp_i_price > 0 THEN
			tmp_ol_amount = tmp_i_price * tmp_ol_quantity;
			SELECT new_order_2(tmp_w_id, tmp_d_id, tmp_i_id,
		                   	tmp_ol_quantity, tmp_i_price,
					tmp_i_name, tmp_i_data,
					out_d_next_o_id, tmp_ol_amount,
                                   	tmp_ol_supply_w_id, 11)
			INTO tmp_s_quantity;
			tmp_total_amount = tmp_total_amount + tmp_ol_amount;
		ELSE
			RETURN 1;
		END IF;
	ELSIF tmp_o_ol_cnt > 11 THEN
		SELECT in_row12.ol_i_id
		INTO tmp_i_id;
		SELECT in_row12.ol_supply_w_id
		INTO tmp_ol_supply_w_id;
		SELECT in_row12.ol_quantity
		INTO tmp_ol_quantity;

		SELECT i_price, i_name, i_data
		INTO tmp_i_price, tmp_i_name, tmp_i_data
		FROM item
		WHERE i_id = tmp_i_id;

		IF tmp_i_price > 0 THEN
			tmp_ol_amount = tmp_i_price * tmp_ol_quantity;
			SELECT new_order_2(tmp_w_id, tmp_d_id, tmp_i_id,
		                   	tmp_ol_quantity, tmp_i_price,
					tmp_i_name, tmp_i_data,
					out_d_next_o_id, tmp_ol_amount,
                                   	tmp_ol_supply_w_id, 12)
			INTO tmp_s_quantity;
			tmp_total_amount = tmp_total_amount + tmp_ol_amount;
		ELSE
			RETURN 1;
		END IF;
	ELSIF tmp_o_ol_cnt > 12 THEN
		SELECT in_row13.ol_i_id
		INTO tmp_i_id;
		SELECT in_row13.ol_supply_w_id
		INTO tmp_ol_supply_w_id;
		SELECT in_row13.ol_quantity
		INTO tmp_ol_quantity;

		SELECT i_price, i_name, i_data
		INTO tmp_i_price, tmp_i_name, tmp_i_data
		FROM item
		WHERE i_id = tmp_i_id;

		IF tmp_i_price > 0 THEN
			tmp_ol_amount = tmp_i_price * tmp_ol_quantity;
			SELECT new_order_2(tmp_w_id, tmp_d_id, tmp_i_id,
		                   	tmp_ol_quantity, tmp_i_price,
					tmp_i_name, tmp_i_data,
					out_d_next_o_id, tmp_ol_amount,
                                   	tmp_ol_supply_w_id, 13)
			INTO tmp_s_quantity;
			tmp_total_amount = tmp_total_amount + tmp_ol_amount;
		ELSE
			RETURN 1;
		END IF;
	ELSIF tmp_o_ol_cnt > 13 THEN
		SELECT in_row14.ol_i_id
		INTO tmp_i_id;
		SELECT in_row14.ol_supply_w_id
		INTO tmp_ol_supply_w_id;
		SELECT in_row14.ol_quantity
		INTO tmp_ol_quantity;

		SELECT i_price, i_name, i_data
		INTO tmp_i_price, tmp_i_name, tmp_i_data
		FROM item
		WHERE i_id = tmp_i_id;

		IF tmp_i_price > 0 THEN
			tmp_ol_amount = tmp_i_price * tmp_ol_quantity;
			SELECT new_order_2(tmp_w_id, tmp_d_id, tmp_i_id,
		                   	tmp_ol_quantity, tmp_i_price,
					tmp_i_name, tmp_i_data,
					out_d_next_o_id, tmp_ol_amount,
                                   	tmp_ol_supply_w_id, 14)
			INTO tmp_s_quantity;
			tmp_total_amount = tmp_total_amount + tmp_ol_amount;
		ELSE
			RETURN 1;
		END IF;
	ELSIF tmp_o_ol_cnt > 14 THEN
		SELECT in_row15.ol_i_id
		INTO tmp_i_id;
		SELECT in_row15.ol_supply_w_id
		INTO tmp_ol_supply_w_id;
		SELECT in_row15.ol_quantity
		INTO tmp_ol_quantity;

		SELECT i_price, i_name, i_data
		INTO tmp_i_price, tmp_i_name, tmp_i_data
		FROM item
		WHERE i_id = tmp_i_id;

		IF tmp_i_price > 0 THEN
			tmp_ol_amount = tmp_i_price * tmp_ol_quantity;
			SELECT new_order_2(tmp_w_id, tmp_d_id, tmp_i_id,
		                   	tmp_ol_quantity, tmp_i_price,
					tmp_i_name, tmp_i_data,
					out_d_next_o_id, tmp_ol_amount,
                                   	tmp_ol_supply_w_id, 15)
			INTO tmp_s_quantity;
			tmp_total_amount = tmp_total_amount + tmp_ol_amount;
		ELSE
			RETURN 1;
		END IF;
	END IF;

	RETURN 0;
END;
' LANGUAGE 'plpgsql';
